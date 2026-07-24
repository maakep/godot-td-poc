# TODO:
# 1. aoe visual indicator?
# 

extends Node2D

const TowerRangeIndicator = preload("res://buildings/tower_range_indicator.gd")

var lives = 100

var _g: int
var gold: int:
	get:
		return _g
	set(value):
		_g = value
		Events.on_gold_change.emit(_g)
		

@onready var tilemap = $"../Layers/TileMapLayer"
@onready var mousemap = $"../Layers/MouseLayer"

var tower = preload("res://buildings/tower.tscn")

var selected_tower_id_for_placing = null
var range_indicator

func _ready():
	Events.on_wave_done.connect(get_wave_bounty)
	Events.tower_clicked.connect(on_tower_clicked)
	Events.on_enemy_killed.connect(func(): gold += 1) # should be bounty per enemy?
	Events.on_enemy_destination_reached.connect(func(): lives -= 1)
	Events.on_tower_ui_clicked.connect(select_tower_for_placing)
	range_indicator = TowerRangeIndicator.new()
	range_indicator.visible = false
	add_child(range_indicator)
	gold = 20


func select_tower_for_placing(tower_id):
	selected_tower_id_for_placing = tower_id
	var tower_data = Towers.get_tower(tower_id)
	range_indicator.set_tower_range(tower_data.range)
	range_indicator.visible = true


func get_wave_bounty(wave):
	gold += wave.bounty

func _unhandled_input(e):
	if selected_tower_id_for_placing and placable and e is InputEventMouseButton and e.button_index == 1 and e.pressed:
		place_obstacle(selected_tower_id_for_placing)
		return
	
	if e is InputEventMouseButton and e.button_index == 2 and e.pressed:
		selected_tower_id_for_placing = null
		range_indicator.visible = false
		mousemap.set_cell(last_hovered_cell)
		return

var last_hovered_cell = Vector2i(0,0)
var placable = false

func _physics_process(_delta):
	if !selected_tower_id_for_placing:
		return
		
	var hovered_cell = tilemap.local_to_map(tilemap.get_local_mouse_position())
	var data = tilemap.get_cell_tile_data(hovered_cell)
	
	if !data:
		placable = false
		range_indicator.visible = false
		return

	range_indicator.visible = true
	range_indicator.position = tilemap.map_to_local(hovered_cell)
	
	var cell_changed = last_hovered_cell != hovered_cell
	if cell_changed:
		mousemap.set_cell(last_hovered_cell)
	
	if ["Obstacle", "Waypoint"].any(func(x): return data.get_custom_data(x)):
		placable = false
		if cell_changed:
			mousemap.set_cell(hovered_cell, 1, Vector2i(0, 0))
	else:
		placable = true
		if cell_changed:
			mousemap.set_cell(hovered_cell, 0, Vector2i(0, 0))

	range_indicator.set_placement_valid(placable and gold >= Towers.get_tower(selected_tower_id_for_placing).cost)
		
	last_hovered_cell = hovered_cell

func place_obstacle(tower_type):
	var buying_tower = Towers.get_tower(tower_type)
	
	if gold < buying_tower.cost:
		return
		
	placable = false # This updates when changing tile
	
	var clicked_cell = tilemap.local_to_map(tilemap.get_local_mouse_position())
	
	if !validate_path(clicked_cell):
		return
		
	# tilemap.set_cell(clicked_cell, 1, Vector2i(0, 0)) # sets the tile background
	var t = tower.instantiate()
	t.position = tilemap.map_to_local(clicked_cell)
	t.cell = clicked_cell
	t.tilemap = tilemap
	t.tower_id = tower_type
	add_child(t)
	gold = gold - buying_tower.cost
	Events.tower_built.emit(t, clicked_cell)

func validate_path(cell):
	return Pathfinder.instance.validate_full_path(cell)
	
func on_tower_clicked(t_obj):
	var tower_data = t_obj.tower
	var upgrade = tower_data.upgrades[0] if !tower_data.upgrades.is_empty() else null
	if upgrade:
		var upg_data = Towers.get_tower(upgrade)
		if gold >= upg_data.cost:
			gold = gold - upg_data.cost
			t_obj.load_tower(upgrade) # BUG: Sometimes towers shoot every other colour?

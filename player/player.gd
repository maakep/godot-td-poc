# TODO:
# 1. aoe visual indicator?
# 

extends Node2D

const TowerRangeIndicator = preload("res://buildings/tower_range_indicator.gd")

var _lives = 100
var lives: int:
	get: 
		return _lives
	set(value):
		_lives = value
		Events.on_live_change.emit(_lives)

var _g: int
var gold: int:
	get:
		return _g
	set(value):
		_g = value
		Events.on_gold_change.emit(_g)



@onready var tilemap = $"../Layers/TileMapLayer"
@onready var mousemap = $"../Layers/MouseLayer"
@onready var tower_inspector = $"../CanvasLayer/TowerInspector"

var tower = preload("res://buildings/tower.tscn")

var selected_tower_id_for_placing = null
var range_indicator
var towers_by_cell: Dictionary = {}
var tower_just_placed: Node2D

func _ready():
	Events.on_wave_done.connect(get_wave_bounty)
	Events.tower_clicked.connect(on_tower_clicked)
	Events.on_enemy_killed.connect(func(): gold += 1) # should be bounty per enemy?
	Events.on_enemy_destination_reached.connect(func(): lives -= 1)
	Events.on_tower_ui_clicked.connect(select_tower_for_placing)
	Events.on_gold_change.connect(_on_gold_changed)
	tower_inspector.upgrade_requested.connect(upgrade_tower)
	tower_inspector.sell_requested.connect(sell_tower)
	tower_inspector.closed.connect(_on_tower_inspector_closed)
	range_indicator = TowerRangeIndicator.new()
	range_indicator.visible = false
	add_child(range_indicator)
	gold = 20


func select_tower_for_placing(tower_id):
	if tower_inspector.visible:
		tower_inspector.hide_inspector()
	selected_tower_id_for_placing = tower_id
	var tower_data = Towers.get_tower(tower_id)
	range_indicator.set_tower_range(tower_data.range)
	range_indicator.visible = true


func get_wave_bounty(wave):
	gold += wave.bounty

func _unhandled_input(e):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
		selected_tower_id_for_placing = null
		range_indicator.visible = false
		mousemap.set_cell(last_hovered_cell)
		if tower_inspector.visible:
			tower_inspector.hide_inspector()
		return

	if selected_tower_id_for_placing and placable and e is InputEventMouseButton and e.button_index == 1 and e.pressed:
		var keep_placing: bool = e.shift_pressed or Input.is_key_pressed(KEY_SHIFT)
		place_obstacle(selected_tower_id_for_placing, keep_placing)
		return

	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed and tower_inspector.visible and !_is_clicking_tower():
		tower_inspector.hide_inspector()
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
	
	if ["Obstacle", "Waypoint"].any(func(x): return data.get_custom_data(x)) or towers_by_cell.has(hovered_cell):
		placable = false
		if cell_changed:
			mousemap.set_cell(hovered_cell, 1, Vector2i(0, 0))
	else:
		placable = true
		if cell_changed:
			mousemap.set_cell(hovered_cell, 0, Vector2i(0, 0))

	range_indicator.set_placement_valid(placable and gold >= Towers.get_tower(selected_tower_id_for_placing).cost)
		
	last_hovered_cell = hovered_cell

func place_obstacle(tower_type, keep_placing := false):
	var buying_tower = Towers.get_tower(tower_type)
	
	if gold < buying_tower.cost:
		return
		
	placable = false # This updates when changing tile
	
	var clicked_cell = tilemap.local_to_map(tilemap.get_local_mouse_position())
	if towers_by_cell.has(clicked_cell):
		return
	
	if !validate_path(clicked_cell):
		return
		
	# tilemap.set_cell(clicked_cell, 1, Vector2i(0, 0)) # sets the tile background
	var t = tower.instantiate()
	t.position = tilemap.map_to_local(clicked_cell)
	t.cell = clicked_cell
	t.tilemap = tilemap
	t.tower_id = tower_type
	tower_just_placed = t
	add_child(t)
	towers_by_cell[clicked_cell] = t
	t.tree_exited.connect(func():
		if towers_by_cell.get(clicked_cell) == t:
			towers_by_cell.erase(clicked_cell)
	)
	gold = gold - buying_tower.cost
	Events.tower_built.emit(t, clicked_cell)
	call_deferred("_clear_just_placed_tower", t)

	if !keep_placing:
		selected_tower_id_for_placing = null
		range_indicator.visible = false
		mousemap.set_cell(clicked_cell)

func validate_path(cell):
	return Pathfinder.instance.validate_full_path(cell)

func _is_clicking_tower() -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collision_mask = 1
	query.collide_with_areas = true
	for result in get_world_2d().direct_space_state.intersect_point(query):
		var collider = result.collider
		if collider.get_parent().is_in_group("obstacle"):
			return true
	return false
	
func on_tower_clicked(t_obj):
	if t_obj == tower_just_placed:
		return
	if tower_inspector.visible and tower_inspector.selected_tower == t_obj:
		return
	selected_tower_id_for_placing = null
	mousemap.set_cell(last_hovered_cell)
	range_indicator.position = t_obj.position
	range_indicator.set_tower_range(t_obj.tower.range)
	range_indicator.set_placement_valid(true)
	range_indicator.visible = true
	tower_inspector.show_tower(t_obj, gold)

func _clear_just_placed_tower(t_obj) -> void:
	if tower_just_placed == t_obj:
		tower_just_placed = null

func upgrade_tower(t_obj, upgrade_id: String) -> void:
	if !is_instance_valid(t_obj):
		return
	if !(upgrade_id in t_obj.tower.upgrades):
		return
	var upgrade_data = Towers.get_tower(upgrade_id)
	if gold < upgrade_data.cost:
		return
	gold -= upgrade_data.cost
	t_obj.load_tower(upgrade_id)
	range_indicator.set_tower_range(t_obj.tower.range)
	tower_inspector.refresh(gold)

func sell_tower(t_obj) -> void:
	if !is_instance_valid(t_obj):
		return
	var sell_price := ceili(t_obj.tower.cost / 2.0)
	Events.on_obstacle_removed.emit(t_obj, t_obj.cell)
	towers_by_cell.erase(t_obj.cell)
	gold += sell_price
	tower_inspector.hide_inspector()
	t_obj.queue_free()

func _on_gold_changed(new_gold: int) -> void:
	if tower_inspector.visible:
		tower_inspector.refresh(new_gold)

func _on_tower_inspector_closed() -> void:
	if !selected_tower_id_for_placing:
		range_indicator.visible = false

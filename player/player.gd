extends Node2D

var lives = 100
var gold := 20

@onready var tilemap = $"../Layers/TileMapLayer"
@onready var mousemap = $"../Layers/MouseLayer"

var tower = preload("res://buildings/tower.tscn")

func _ready():
	Events.on_wave_done.connect(get_wave_bounty)


func get_wave_bounty(wave):
	gold += wave.bounty

func _input(e):	
	if placable and e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		place_obstacle()

var last = Vector2i(0,0)
var placable = false
func _physics_process(delta):
	var hovered_cell = tilemap.local_to_map(tilemap.get_local_mouse_position())
	var data = tilemap.get_cell_tile_data(hovered_cell)
	
	if !data:
		return
	
	if last != hovered_cell:
		mousemap.set_cell(last)
	else:
		return
	
	if ["Obstacle", "Waypoint"].any(func(x): return data.get_custom_data(x)):
		mousemap.set_cell(hovered_cell, 1, Vector2i(0, 0))
		placable = false
	else:
		placable = true
		mousemap.set_cell(hovered_cell, 0, Vector2i(0, 0))
		
	last = hovered_cell

func place_obstacle():
	if gold < 1:
		return
	
	var clicked_cell = tilemap.local_to_map(tilemap.get_local_mouse_position())
	
	if !validate_path(clicked_cell):
		return
		
	tilemap.set_cell(clicked_cell, 1, Vector2i(0, 0))
	var t = tower.instantiate()
	t.position = tilemap.map_to_local(clicked_cell)
	t.cell = clicked_cell
	t.tilemap = tilemap
	add_child(t)
	gold = gold - 1
	Events.on_obstacles_built.emit(t, clicked_cell)

func validate_path(cell):
	return Pathfinder.instance.validate_full_path(cell)

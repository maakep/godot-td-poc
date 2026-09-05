extends Node
class_name Pathfinder

const TERRAIN := preload("res://misc/obstacle_painter.gd")

## Set a nonnegative seed to reproduce a map while tuning its appearance.
@export var generation_seed: int = -1
@export_range(0.0, 1.0) var forest_chance := 0.5

static var instance: Pathfinder

var grid = AStarGrid2D.new()
@onready var tilemap: TileMapLayer = %TileMapLayer

func _ready():
	instance = self

	grid.region = tilemap.get_used_rect()
	grid.cell_size = Vector2(64, 64)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	grid.update()
	
	var seed_value := randi() if generation_seed < 0 else generation_seed
	var map = Levels.generate_obstacles(65, 57, 0.4, 5, seed_value)

	map.append_array([
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(1, 0),
	])
	
	TERRAIN.paint(tilemap, map, seed_value, forest_chance)
	
	for cell in tilemap.get_used_cells():
		var tile = tilemap.get_cell_tile_data(cell)

		if tile and tile.get_custom_data("Obstacle"):
			grid.set_point_solid(cell)

	Events.tower_built.connect(on_obstacle_added)
	Events.on_obstacle_removed.connect(on_obstacle_removed)
	
func on_obstacle_added(_obj, cell):
	var tile = tilemap.get_cell_tile_data(cell)
	grid.set_point_solid(cell)
	
func on_obstacle_removed(_obj, cell):
	var tile = tilemap.get_cell_tile_data(cell)
	grid.set_point_solid(cell, false)
	

func validate_full_path(cell):
	on_obstacle_added(null, cell)
	
	var res = calc_path()
	for coord in Levels.waypoints:
		if coord not in res:
			on_obstacle_removed(null, cell)
			return false
	
	return true
	
var recalc_queue = []
func request_recalc(obj):
	if obj in recalc_queue:
		return
	
	recalc_queue.push_back(obj)

func v(x, y): return Vector2i(x, y)
		
		
func calc_path(from_global_position = null, waypoints = null, flying = false):
	if waypoints == null:
		waypoints = Levels.waypoints
	
	if flying:
		return waypoints.duplicate()

	var path = [from_global_position if from_global_position != null else waypoints[0]]
	
	for waypoint in waypoints:
		var path_between_waypoints = grid.get_id_path(
				tilemap.local_to_map(path.back()),
				tilemap.local_to_map(waypoint)
			).map(func(x): return tilemap.map_to_local(x))
		path.append_array(path_between_waypoints)
	
	return path


func _physics_process(_delta):
	var budget = 15
	
	while budget > 0 and recalc_queue.size() > 0:
		var enemy = recalc_queue.pop_front()
		
		if !is_instance_valid(enemy):
			continue
			
		var new_path = calc_path(enemy.next_target, enemy.my_waypoints, enemy.flying)
		if new_path:
			enemy.path = new_path
			enemy.next_target = new_path.pop_front()
			
		budget -= 1

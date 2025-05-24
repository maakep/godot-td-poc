extends Node
class_name Pathfinder

static var instance: Pathfinder

var grid = AStarGrid2D.new()
@onready var tilemap = %TileMapLayer

func _ready():	
	instance = self
	grid.region = tilemap.get_used_rect()
	grid.cell_size = Vector2(64, 64)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	grid.update()
	
	for cell in tilemap.get_used_cells():
		var tile = tilemap.get_cell_tile_data(cell)
		if tile and tile.get_custom_data("Obstacle"):
			grid.set_point_solid(cell)
	
	Events.on_obstacles_built.connect(on_tower_built)
	Events.on_obstacle_removed.connect(on_tower_removed)
	
func on_tower_built(obj, cell):
	var tile = tilemap.get_cell_tile_data(cell)
	grid.set_point_solid(cell)
	grid.update()
	
func on_tower_removed(obj, cell):
	var tile = tilemap.get_cell_tile_data(cell)
	grid.set_point_solid(cell, false)
	grid.update()
	

func validate_full_path(cell):
	on_tower_built(null, cell)
	
	var res = calc_path()
	for coord in Levels.waypoints:
		if coord not in res:
			on_tower_removed(null, cell)
			return false
	
	return true
	

func calc_path(from_global_position = null, waypoints = null):
	if waypoints == null:
		waypoints = Levels.waypoints

	var path = [from_global_position if from_global_position != null else waypoints[0]]
	
	for waypoint in waypoints:
		var path_between_waypoints = grid.get_id_path(
				tilemap.local_to_map(path.back()),
				tilemap.local_to_map(waypoint)
			).map(func(x): return tilemap.map_to_local(x))
		path.append_array(path_between_waypoints)
	
	return path

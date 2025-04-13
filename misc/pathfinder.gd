extends Node
class_name Pathfinder

static func calc_path(tilemap, from_global_position = null, waypoints = null):
	if waypoints == null:
		waypoints = Levels.waypoints

	var grid = AStarGrid2D.new()
	grid.region = tilemap.get_used_rect()
	grid.cell_size = Vector2(64, 64)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	grid.update()
	
	for cell in tilemap.get_used_cells():
		var tile = tilemap.get_cell_tile_data(cell)
		if tile and tile.get_custom_data("Obstacle"):
			grid.set_point_solid(cell)
			
	var path = [from_global_position if from_global_position != null else waypoints[0]]
	
	for waypoint in waypoints:
		var path_between_waypoints = grid.get_id_path(
				tilemap.local_to_map(path.back()),
				tilemap.local_to_map(waypoint)
			).map(func(x): return tilemap.map_to_local(x))
		path.append_array(path_between_waypoints)
	
	return path

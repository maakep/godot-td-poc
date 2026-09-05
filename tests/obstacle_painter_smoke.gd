extends Node

const TERRAIN := preload("res://misc/obstacle_painter.gd")
const GAME := preload("res://game.tscn")

var failed := false


func _ready() -> void:
	_test_rectangles()
	_test_awkward_shapes()
	_test_generated_maps()
	_test_game_integration()

	if not failed:
		print("Obstacle painter smoke tests passed")

	get_tree().quit(1 if failed else 0)


func _test_rectangles() -> void:
	var cells := _rectangle(Rect2i(-4, -7, 3, 3))

	for forest_chance: float in [0.0, 1.0]:
		var layout := TERRAIN.build_layout(cells, 17, forest_chance)
		var first_row := 4 if forest_chance == 1.0 else 1

		for y in range(3):
			for x in range(3):
				_check(layout[Vector2i(x - 4, y - 7)] == Vector2i(x, y + first_row),
					"3x3 patches use the correct corners, edges and center")

		_check_layout(cells, layout)

	for size: Vector2i in [Vector2i(2, 2), Vector2i(2, 8), Vector2i(9, 2), Vector2i(7, 6)]:
		cells = _rectangle(Rect2i(Vector2i.ZERO, size))

		var layout := TERRAIN.build_layout(cells, 3, 0.0)

		_check_layout(cells, layout)

		for atlas: Vector2i in layout.values():
			_check(atlas.x < 3, "Solid rectangles should not need fallback props")


func _test_awkward_shapes() -> void:
	_check(TERRAIN.build_layout([], 1).is_empty(), "Empty masks stay empty")

	var thin := _rectangle(Rect2i(-3, 0, 7, 1))

	thin.append_array(_rectangle(Rect2i(0, -3, 1, 7)))

	var layout := TERRAIN.build_layout(thin, 42)

	_check_layout(thin, layout)

	for atlas: Vector2i in layout.values():
		_check(atlas.x >= 3, "One-cell strips and crosses use standalone props")

	var awkward := _rectangle(Rect2i(-5, -5, 7, 7))

	awkward.erase(Vector2i(-2, -2)) # An interior hole cannot be a water center.
	awkward.append_array(_rectangle(Rect2i(2, 0, 5, 1))) # Thin protrusion.
	awkward.append_array(_rectangle(Rect2i(1, 1, 4, 4))) # Concave join.

	layout = TERRAIN.build_layout(awkward, 92)
	_check_layout(awkward, layout)

	awkward.reverse()

	_check(layout == TERRAIN.build_layout(awkward, 92), "Input order and duplicates do not change seeded visuals")
	_check(layout != TERRAIN.build_layout(awkward, 93), "Different seeds vary the scenery")


func _test_generated_maps() -> void:
	var started := Time.get_ticks_msec()
	var terrain_counts := [0, 0, 0]

	for map_seed in range(6):
		var cells := Levels.generate_obstacles(65, 57, 0.4, 5, map_seed)
		var layout := TERRAIN.build_layout(cells, map_seed)

		_check_layout(cells, layout)

		for atlas: Vector2i in layout.values():
			terrain_counts[2 if atlas.x >= 3 else (0 if atlas.y < 4 else 1)] += 1

	for count: int in terrain_counts:
		_check(count > 0, "Generated maps contain lakes, forests and fallback props")

	print("Six generated maps checked in %d ms; water/forest/props: %s" % [
		Time.get_ticks_msec() - started, terrain_counts])


func _test_game_integration() -> void:
	Levels.reset_run()
	seed(42)

	var world := GAME.instantiate()

	world.get_node("Layers").generation_seed = 42
	add_child(world)

	var tilemap: TileMapLayer = world.get_node("Layers/TileMapLayer")
	var pathfinder = world.get_node("Layers")
	var spawner = world.get_node("Spawner")
	var source: TileSetAtlasSource = tilemap.tile_set.get_source(2)

	for row in range(1, 7):
		for column in range(3):
			_check(source.get_tile_data(Vector2i(column, row), 0).get_custom_data("Obstacle"),
				"Lake and forest tiles keep their Obstacle flag")

	for atlas: Vector2i in [Vector2i(3, 1), Vector2i(4, 1), Vector2i(3, 2)]:
		_check(source.get_tile_data(atlas, 0).get_custom_data("Obstacle"), "Props keep their Obstacle flag")

	for cell in tilemap.get_used_cells():
		var tile := tilemap.get_cell_tile_data(cell)

		if tile != null and tile.get_custom_data("Obstacle"):
			_check(pathfinder.grid.region.has_point(cell), "Every obstacle is inside the navigation grid")

			if pathfinder.grid.region.has_point(cell):
				_check(pathfinder.grid.is_point_solid(cell), "Visual obstacles remain blocked")

	var path: Array = pathfinder.calc_path()

	for waypoint: Vector2 in Levels.waypoints:
		_check(path.has(waypoint), "The generated waypoints remain reachable")

		var cell := tilemap.local_to_map(waypoint)

		_check(tilemap.get_cell_source_id(cell) == 2 and tilemap.get_cell_atlas_coords(cell).y == 7,
			"The starting waypoint and destination both use the new markers")

	for point: Vector2 in path:
		_check(not pathfinder.grid.is_point_solid(tilemap.local_to_map(point)), "The path avoids scenery")

	var waypoint_cell := tilemap.local_to_map(Levels.waypoints.back())
	var variants := {}

	for iteration in range(60):
		spawner.spawn_waypoint_flag(waypoint_cell)

		var atlas := tilemap.get_cell_atlas_coords(waypoint_cell)

		variants[atlas] = true
		_check(tilemap.get_cell_source_id(waypoint_cell) == 2, "Waypoints use the new atlas source")
		_check(atlas.y == 7 and atlas.x >= 0 and atlas.x <= 2, "Waypoints use only the three requested tiles")

		var tile := tilemap.get_cell_tile_data(waypoint_cell)

		_check(tile.get_custom_data("Waypoint") and not tile.get_custom_data("Obstacle"),
			"Waypoints stay unbuildable and walkable")

	_check(variants.size() == 3, "All three waypoint variants can be selected")

	var waypoint_atlas := tilemap.get_cell_atlas_coords(waypoint_cell)

	TERRAIN.paint(tilemap, [waypoint_cell], 10)
	_check(tilemap.get_cell_atlas_coords(waypoint_cell) == waypoint_atlas, "Painting preserves existing waypoints")
	world.free()
	Pathfinder.instance = null
	Levels.reset_run()


func _check_layout(cells: Array, layout: Dictionary) -> void:
	var mask := {}

	for cell: Vector2i in cells:
		mask[cell] = true

	_check(layout.size() == mask.size(), "Painting preserves the number of blocked cells")

	for cell: Vector2i in layout:
		_check(mask.has(cell), "Painting does not spread into walkable ground")

		var atlas: Vector2i = layout[cell]

		if atlas.x >= 3:
			_check(atlas in [Vector2i(3, 1), Vector2i(4, 1), Vector2i(3, 2)], "Only configured fallback props are used")
			continue

		_check(atlas.x >= 0 and atlas.y >= 1 and atlas.y <= 6, "Only configured body tiles are used")
		# Verify visible connections, independently of how rectangles were fitted.
		var origin_row := 1 if atlas.y < 4 else 4
		var local := atlas - Vector2i(0, origin_row)

		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var open_side := (
				(direction.x == -1 and local.x != 0)
				or (direction.x == 1 and local.x != 2)
				or (direction.y == -1 and local.y != 0)
				or (direction.y == 1 and local.y != 2)
			)

			if not open_side:
				continue

			var neighbor: Vector2i = layout.get(cell + direction, Vector2i(-1, -1))

			_check(neighbor.x >= 0 and neighbor.x < 3 and neighbor.y >= origin_row and neighbor.y < origin_row + 3,
				"Open water/canopy edges always meet the same terrain")

			var opposite_open := (
				(direction.x == -1 and neighbor.x != 2)
				or (direction.x == 1 and neighbor.x != 0)
				or (direction.y == -1 and neighbor.y != origin_row + 2)
				or (direction.y == 1 and neighbor.y != origin_row)
			)

			_check(opposite_open, "Adjacent body tiles join without an internal shore or canopy edge")


func _rectangle(rect: Rect2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			cells.append(Vector2i(x, y))

	return cells


func _check(condition: bool, label: String) -> void:
	if not condition:
		failed = true
		push_error(label)

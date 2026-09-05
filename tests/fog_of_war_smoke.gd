extends Node

const GAME := preload("res://game.tscn")

var failed := false


func _ready() -> void:
	Levels.reset_run()
	seed(42)

	var world := GAME.instantiate()

	world.get_node("Layers").generation_seed = 42
	add_child(world)

	var fog = world.get_node("FogOfWar")
	var player = world.get_node("Player")
	var tilemap: TileMapLayer = world.get_node("Layers/TileMapLayer")
	var starting_waypoint_count := Levels.waypoints.size()

	fog.set_process(false)

	_check(fog._sources.size() == starting_waypoint_count, "Every starting waypoint reveals the map")
	_check(fog._overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Fog does not consume mouse input")
	_check(world.get_node("CanvasLayer").layer > fog.layer, "The interface is drawn above the darkness")

	for waypoint: Vector2 in Levels.waypoints:
		var source = fog._sources[waypoint]

		_check(source.position == tilemap.to_global(waypoint), "Waypoints reveal their world position")
		_check(source.strength == 1.0, "Initial visibility is ready without a dark startup fade")

	var building := Node2D.new()
	var cell := Vector2i(10, 4)

	player.add_child(building)
	building.global_position = Vector2(672, 288)
	player.towers_by_cell[cell] = building
	fog._process(fog.fade_duration * 0.5)

	var building_id := building.get_instance_id()
	var building_light = fog._sources[building_id]

	_check(is_equal_approx(building_light.strength, 0.5), "New buildings reveal the map gradually")
	_check(building_light.radius == fog.building_radius, "Building visibility uses its own radius")

	fog._process(fog.fade_duration)
	_check(building_light.strength == 1.0, "Building visibility reaches full strength")

	# Selling erases this registry entry before the building leaves the tree.
	player.towers_by_cell.erase(cell)
	fog._process(fog.fade_duration * 0.5)
	_check(is_equal_approx(building_light.strength, 0.5), "Removed buildings fade back into darkness")

	building.free()
	fog._process(fog.fade_duration)
	_check(not fog._sources.has(building_id), "A removed building leaves no permanent reveal")

	var new_waypoint := Vector2(736, -160)

	Levels.waypoints.append(new_waypoint)
	fog._process(fog.fade_duration)
	_check(fog._sources.has(new_waypoint), "Later wave waypoints automatically reveal the map")

	_test_enemy_visibility(fog, world.get_node("Creeps"))

	# Use more sources than a small shader uniform array could hold.
	for index in range(300):
		var extra_building := Node2D.new()

		player.add_child(extra_building)
		extra_building.position = Vector2(index * 64, 0)
		player.towers_by_cell[Vector2i(index, 20)] = extra_building

	fog._process(fog.fade_duration)
	_check(fog._sources.size() == 300 + Levels.waypoints.size(), "Visibility has no small building-count cap")

	# Camera pan and zoom must transform the mask together with the world.
	var viewport := get_viewport()
	var original_transform := viewport.canvas_transform
	var test_transform := Transform2D(0.0, Vector2(0.35, 0.35), 0.0, Vector2(230, -90))
	var world_point := Vector2(640, 320)

	viewport.canvas_transform = test_transform
	fog._update_camera()

	var mask_ratio: Vector2 = Vector2(fog._mask_viewport.size) / viewport.get_visible_rect().size
	var expected_point := (test_transform * world_point) * mask_ratio
	var actual_point: Vector2 = fog._mask.transform * world_point

	_check(actual_point.is_equal_approx(expected_point), "The visibility mask follows camera pan and zoom")

	viewport.canvas_transform = original_transform
	world.free()
	Pathfinder.instance = null
	Levels.reset_run()

	if not failed:
		print("Fog of war smoke tests passed")

	get_tree().quit(1 if failed else 0)


func _test_enemy_visibility(fog: CanvasLayer, creeps: Node2D) -> void:
	var enemy := Node2D.new()
	var decoration := Node2D.new()
	var initial_source_count: int = fog._sources.size()
	var configured_radius: float = fog.enemy_radius

	enemy.add_to_group("enemy")
	enemy.position = Vector2(736, 416)
	creeps.add_child(enemy)
	creeps.add_child(decoration)
	fog._process(fog.fade_duration * 0.5)

	var enemy_id := enemy.get_instance_id()
	var reveal = fog._sources[enemy_id]

	_check(fog._sources.size() == initial_source_count + 1, "Only enemy units add moving reveals")
	_check(reveal.radius == configured_radius, "Enemies use the smaller configurable radius")
	_check(is_equal_approx(reveal.strength, 0.5), "An enemy reveal fades in when it spawns")

	enemy.position += Vector2(64, -32)
	fog._process(fog.fade_duration)

	_check(reveal.position == enemy.global_position, "The reveal follows the moving enemy")
	_check(fog._sources.size() == initial_source_count + 1, "Movement leaves no permanent reveals behind")

	fog.enemy_radius = 0.0
	fog._process(fog.fade_duration)
	_check(not fog._sources.has(enemy_id), "A zero radius disables enemy reveals")

	fog.enemy_radius = configured_radius
	fog._process(fog.fade_duration)
	enemy.queue_free()
	fog._process(fog.fade_duration * 0.5)

	_check(is_equal_approx(fog._sources[enemy_id].strength, 0.5), "Death or reaching the goal fades out the reveal")

	fog._process(fog.fade_duration)
	_check(not fog._sources.has(enemy_id), "Despawned enemies leave no lingering reveal sources")
	decoration.free()


func _check(condition: bool, label: String) -> void:
	if not condition:
		failed = true
		push_error(label)

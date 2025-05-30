extends Node2D

@onready var tilemap: TileMapLayer = $"../Layers/TileMapLayer"
@onready var mousemap: TileMapLayer = $"../Layers/MouseLayer"

@onready var creep_container = $"../Creeps"
var unit = preload("res://creeps/enemy.tscn")

var target: Vector2

var lvl := -1
var lvl_active = false

var creeps_to_kill = 999


func _ready():
	set_waypoint_random_position()
	Events.on_enemy_destination_reached.connect(enemy_gone)
	Events.on_enemy_killed.connect(enemy_gone)

func enemy_gone():
	creeps_to_kill -= 1
	
	# Wave done!
	if creeps_to_kill <= 0 && creep_container.get_child_count() <= 1:
		set_waypoint_random_position()
		lvl_active = false
		Events.on_wave_done.emit(Levels.all[lvl])

func _input(e):
	if e is InputEventKey and e.pressed and e.keycode == KEY_R:
		if lvl < Levels.all.size() - 1:
			if not lvl_active:
				spawn()
	
func spawn_waypoint_flag(pos):
	tilemap.set_cell(pos, 0, Vector2i(0, 0))

func spawn():
	lvl_active = true
	lvl = lvl + 1
	
	var path = Pathfinder.instance.calc_path()
	
	if !path:
		return # some kind of error here, unpathable
		
	await visualise_path(path)
	
	var toSpawn = Levels.all[lvl]
	var data = Enemies.all[toSpawn.unit]
	creeps_to_kill = toSpawn.amount
	
	for i in range(toSpawn.amount):
		var u = unit.instantiate()
		u.tilemap = tilemap
		u.global_position = Levels.waypoints[0]
		u.hp = data.hp
		u.ms = data.ms
		u.get_node("Sprite2D").texture = data.sprite
		creep_container.call_deferred("add_child", u)
		await get_tree().create_timer(toSpawn.get("spawnInterval", 0.7)).timeout

func visualise_path(path):
	for coord in path.slice(2):
		mousemap.set_cell(mousemap.local_to_map(coord), 0, Vector2i(0, 0))
		get_tree().create_timer(0.35).timeout.connect(func(): mousemap.erase_cell(mousemap.local_to_map(coord)))
		await get_tree().create_timer(0.05).timeout
		
func set_waypoint_random_position():
	var lastWaypoint = tilemap.local_to_map(Levels.waypoints.back())
	
	while true:
		var random_pos = Vector2i(
			lastWaypoint.x + randi_range(-10, 10),
			lastWaypoint.y + randi_range(-10, 10),
		)
		
		var cell = tilemap.get_cell_tile_data(random_pos)
		if cell == null:
			print("out of bounds", random_pos)
			continue
			
		var is_obstacle = cell.get_custom_data("Obstacle")
		if is_obstacle:
			print("nah not there", random_pos)
			continue
		
		var too_close_to_another = Levels.waypoints.any(func(x: Vector2i): return random_pos.distance_to(tilemap.local_to_map(x)) < 5)
		if too_close_to_another:
			print("too close to another", random_pos)
			continue

		spawn_waypoint_flag(random_pos)
		
		var new_waypoint = tilemap.map_to_local(random_pos)
		Levels.waypoints.append(new_waypoint)
		return

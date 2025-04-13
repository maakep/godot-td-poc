extends Area2D


var path
var next_target
var tilemap
var my_waypoints = Levels.waypoints.duplicate()

@export var ms: int
@export var hp: int

func _ready():
	path = Pathfinder.calc_path(tilemap)
	next_target = path.pop_front()
	Events.on_obstacles_modified.connect(on_tower_built)

var waypoints_reached = 0
func _physics_process(delta):
	global_position = global_position.move_toward(next_target, 1 * ms)
	
	if global_position.distance_to(next_target) < 0.01:
		var matched_waypoint = null
		for i in range(my_waypoints.size()):
			if global_position.distance_to(my_waypoints[i]) < 0.5:
				my_waypoints.remove_at(i)
				break
		
		if !path.is_empty():
			next_target = path.pop_front()
		else: 
			Events.on_enemy_destination_reached.emit()
			queue_free()


func on_tower_built(obj):
	var new_path = Pathfinder.calc_path(tilemap, next_target, my_waypoints)
	if !new_path:
		return
		
	path = new_path
	next_target = path.pop_front()
	
	
		

func take_damage(dmg: int):
	if is_queued_for_deletion():
		return
		
	hp -= dmg
	
	if hp <= 0:
		Events.on_enemy_killed.emit()
		queue_free()

func _on_area_entered(area):
	area.get_parent().take_damage(100)

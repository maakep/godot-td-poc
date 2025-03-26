extends Area2D


var path
var next_target
var tilemap

@export var ms: int
@export var hp: int

func _ready():
	path = Pathfinder.calc_path(tilemap)
	next_target = path.pop_front()
	Events.on_obstacles_modified.connect(on_tower_built)

func _physics_process(delta):
	global_position = global_position.move_toward(next_target, 1 * ms)
	
	if global_position.distance_to(next_target) < 0.1:
		if !path.is_empty():
			next_target = path.pop_front()
		else: 
			Events.on_enemy_destination_reached.emit()
			queue_free()


func on_tower_built(obj):
	var new_path = Pathfinder.calc_path(tilemap, next_target)
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

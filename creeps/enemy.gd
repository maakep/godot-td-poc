extends Area2D

var path
var next_target
var my_waypoints = Levels.waypoints.duplicate()
var active_effects = {}

var tilemap # set by creator

var data # emeies.gd data object set by creator

@export var ms: float
@export var hp: int

func _ready():
	path = Pathfinder.instance.calc_path()
	next_target = path.pop_front()
	Events.tower_built.connect(on_tower_built)

var waypoints_reached = 0
func _physics_process(_delta):
	global_position = global_position.move_toward(next_target, 1 * ms)
	
	## -- ## -- ##
	
	var now = Time.get_ticks_msec()
	var expired_effects = []
	for effect_name in active_effects.keys():
		var effect = active_effects[effect_name]
		
		if (now >= effect.end_time):
			expired_effects.append(effect_name)
			effect.handle_end.call()
			
	for effect in expired_effects:
		active_effects.erase(effect)
		
	## -- ## -- ##
	
	if global_position.distance_to(next_target) < 0.01:
		for i in range(my_waypoints.size()):
			if global_position.distance_to(my_waypoints[i]) < 0.5:
				my_waypoints.remove_at(i)
				break
		
		if !path.is_empty():
			next_target = path.pop_front()
		else:
			Events.on_enemy_destination_reached.emit()
			queue_free()


func on_tower_built(_obj, _cell):
	var new_path = Pathfinder.instance.calc_path(next_target, my_waypoints)
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
		
		
var effect_dict = {
	"slow": _handle_slow
}

func apply_effect(effect):
	effect_dict[effect.name].call(effect)

func _handle_slow(effect):
	ms = data.ms * (1 - effect.val)
	active_effects["slow"] = {
		"end_time": Time.get_ticks_msec() + int(effect.dur * 1000),
		"handle_end": func(): ms = data.ms
	}
	
	

func _on_area_entered(area):
	area.get_parent().take_damage(100)

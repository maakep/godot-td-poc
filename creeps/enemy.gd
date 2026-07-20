extends Area2D
class_name Enemy

var path
var next_target
var my_waypoints = Levels.waypoints.duplicate()
var active_effects = {}

var tilemap # set by creator

var data # emeies.gd data object set by creator

@export var ms: float
@export var hp: float
var ms_modifiers = {}
var ms_modifier: float = 1

@onready var hp_bar = $HP_bar
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	path = Pathfinder.instance.calc_path()
	next_target = path.pop_front()
	Events.tower_built.connect(on_tower_built)

var waypoints_reached = 0
func _physics_process(_delta):
	global_position = global_position.move_toward(next_target, ms * ms_modifier)
	
	## -- ## -- ##
	
	var now = Time.get_ticks_msec()
	var expired_effects = []
	for effect_name in active_effects.keys():
		var effect = active_effects[effect_name]
		
		if effect.tick_rate && now >= effect.next_tick:
			effect.tick.call()
			effect.next_tick += effect.tick_rate * 1000
		
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
	var new_path = Pathfinder.instance.request_recalc(self)
	#
	#if !new_path:
		#return
		#
	#path = new_path
	#next_target = path.pop_front()
	#
	
func take_damage(dmg: int):
	if is_queued_for_deletion():
		return
		
	hp -= dmg
	hp_bar.value = (hp / data.hp) * 100
	
	anim.stop()
	anim.play("hit")
	
	if hp <= 0:
		Events.on_enemy_killed.emit()
		
		for effect in active_effects:
			var e = active_effects[effect]
			if e.has("on_death") && e.on_death != null:
				e.on_death.call()
		
		queue_free()

func _on_area_entered(area):
	take_damage(100)

		
var effect_dict = {
	"slow": _handle_slow,
	"poison": _handle_poison,
	"burn": _handle_burn,
}

func apply_effect(effect):
	effect_dict[effect.handler].call(effect)
	
func ts(dur):
	if dur == null:
		return null
	return Time.get_ticks_msec() + int(dur * 1000)

func add_active_effect(effect, tick, handle_end):
	var name = effect.name
	
	if effect.stacking:
		name = name + str(randi() % 1000)
	
	active_effects[name] = {
		"end_time": ts(effect.dur),
		"tick": tick,
		"tick_rate": effect.get("tick_rate", null),
		"next_tick": ts(effect.get("tick_rate", null)),
		"on_death": effect.get("on_death", null),
		"handle_end": func(): handle_end.call(name),
	}
	
	return name
	
func recalculate_ms_modifier():
	var modifier = 1
	for mod in ms_modifiers:
		modifier = modifier * (1 - ms_modifiers[mod])
	
	ms_modifier = modifier

func _handle_slow(effect):
	var eff_id = add_active_effect(
		effect,
		func():
			pass, 
		func(id):
			ms_modifiers.erase(id)
			recalculate_ms_modifier()
			sprite.self_modulate = Color(1, 1, 1)
	)
	
	ms_modifiers[eff_id] = effect.val
	recalculate_ms_modifier()
	sprite.self_modulate = Color(0, 0, 1, 1)
	

func _handle_poison(effect):
	var eff_id = add_active_effect(
		effect,
		func():
			take_damage(effect.dmg),
		func(id):
			ms_modifiers.erase(id)
			recalculate_ms_modifier()
			sprite.self_modulate = Color(1, 1, 1)			
	)
	
	ms_modifiers[eff_id] = effect.val
	recalculate_ms_modifier()
	sprite.self_modulate = Color(0.5, 0, 0.5)
	
func _handle_burn(effect):
	var _eff_id = add_active_effect(
			effect,
			func():
				take_damage(effect.dmg),
			func(_id):
				pass,
		)
	
	sprite.self_modulate = Color(0.825, 0.357, 0.212, 1.0)	
	

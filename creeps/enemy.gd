extends Area2D
class_name Enemy

var path
var next_target
var my_waypoints = Levels.waypoints.duplicate()
var resistance_tags: Dictionary[StringName, bool] = {}

var tilemap # set by creator

var data # emeies.gd data object set by creator

@export var ms: float
@export var hp: float
var ms_modifier: float = 1

var flying = false

@onready var hp_bar = $HP_bar
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var status_effects: StatusEffectComponent = $StatusEffects
@onready var status_effect_view: StatusEffectView = $StatusEffectView

func _ready():
	for tag in data.get("resist", []):
		resistance_tags[StringName(tag)] = true

	status_effects.setup(self)
	status_effects.speed_multiplier_changed.connect(_on_speed_multiplier_changed)
	status_effects.effects_changed.connect(status_effect_view.set_effects)

	path = Pathfinder.instance.calc_path(null, null, flying)
	next_target = path.pop_front()
	Events.tower_built.connect(on_tower_built)
	Events.on_obstacle_removed.connect(on_tower_removed)

var waypoints_reached = 0
func _physics_process(delta):
	global_position = global_position.move_toward(next_target, ms * ms_modifier * delta)
	
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
	if !flying:
		Pathfinder.instance.request_recalc(self)

func on_tower_removed(_obj, _cell):
	if !flying:
		Pathfinder.instance.request_recalc(self)

func take_damage(dmg: float, source_tower: Node2D = null):
	if is_queued_for_deletion():
		return
		
	var actual_damage = minf(dmg, hp)
	hp -= actual_damage
	var killed = hp <= 0
	if is_instance_valid(source_tower):
		source_tower.record_damage(actual_damage, killed)
	hp_bar.value = (hp / data.hp) * 100
	
	anim.stop()
	anim.play("hit")
	
	if killed:
		Events.on_enemy_killed.emit()
		status_effects.notify_target_death()
		queue_free()

func _on_area_entered(area):
	pass
	#take_damage(100)


func apply_effect(application: StatusEffectApplication, source: Node = null) -> bool:
	if is_queued_for_deletion() or application == null or application.definition == null:
		return false

	var resistance_tag := application.definition.resistance_tag
	if resistance_tag != &"" and resistance_tags.has(resistance_tag):
		return false

	return status_effects.apply(application, source)


func _on_speed_multiplier_changed(multiplier: float) -> void:
	ms_modifier = multiplier

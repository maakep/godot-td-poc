class_name StatusEffectRuntime
extends RefCounted

var instance_id: int
var application: StatusEffectApplication
var source: Node
var remaining: float
var time_until_tick: float
var stack_count: int = 1

var definition: StatusEffectDefinition:
	get:
		return application.definition


func initialize(
		effect_application: StatusEffectApplication,
		effect_source: Node,
		new_instance_id: int
	) -> void:
	application = effect_application
	source = effect_source
	instance_id = new_instance_id
	remaining = application.duration
	time_until_tick = application.tick_interval
	stack_count = 1


func refresh(
		effect_application: StatusEffectApplication,
		effect_source: Node,
		keep_stronger_values: bool = false
	) -> void:
	var previous_tick_time := time_until_tick
	var replace_values := not keep_stronger_values or effect_application.magnitude >= application.magnitude

	if replace_values:
		application = effect_application
		source = effect_source
		remaining = effect_application.duration
	else:
		# A weaker refresh must not shorten the stronger effect that is active.
		remaining = maxf(remaining, effect_application.duration)

	# Preserve tick progress when duration is refreshed. Otherwise an effect
	# applied faster than its tick interval could postpone its damage forever.
	if application.tick_interval > 0.0:
		time_until_tick = minf(previous_tick_time, application.tick_interval)
	else:
		time_until_tick = 0.0


func effective_magnitude() -> float:
	if definition.stack_policy == StatusEffectDefinition.StackPolicy.ADD_STACKS:
		return application.magnitude * stack_count
	return application.magnitude


func effective_tick_damage() -> float:
	if definition.stack_policy == StatusEffectDefinition.StackPolicy.ADD_STACKS:
		return application.damage_per_tick * stack_count
	return application.damage_per_tick

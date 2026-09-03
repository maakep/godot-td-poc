class_name StatusEffectComponent
extends Node

signal effects_changed(active_effects: Array)
signal speed_multiplier_changed(multiplier: float)

## Effects do not need frame-perfect expiry, and batching updates greatly reduces
## script work when hundreds of enemies are alive.
const UPDATE_INTERVAL := 0.05
const TICK_EPSILON := 0.00001

var _target: Node
var _effects: Array[StatusEffectRuntime] = []
var _update_accumulator: float = 0.0
var _next_instance_id: int = 1


func _ready() -> void:
	set_physics_process(false)


func setup(target: Node) -> void:
	_target = target


func apply(application: StatusEffectApplication, source: Node = null) -> bool:
	if _target == null or application == null or not application.is_valid():
		push_warning("Rejected an invalid status effect application")
		return false

	var definition := application.definition
	var existing := _find_first(definition.id)
	match definition.stack_policy:
		StatusEffectDefinition.StackPolicy.REFRESH:
			if existing != null:
				existing.refresh(application, source)
				_notify_reapplied(existing)
				_publish_changes()
				return true

		StatusEffectDefinition.StackPolicy.STRONGEST_REFRESH:
			if existing != null:
				existing.refresh(application, source, true)
				_notify_reapplied(existing)
				_publish_changes()
				return true

		StatusEffectDefinition.StackPolicy.ADD_STACKS:
			if existing != null:
				existing.stack_count = mini(existing.stack_count + 1, definition.max_stacks)
				existing.refresh(application, source)
				_notify_reapplied(existing)
				_publish_changes()
				return true

		StatusEffectDefinition.StackPolicy.INDEPENDENT:
			var same_effect_count := _count_effect(definition.id)
			if same_effect_count >= definition.max_stacks:
				var replacement := _find_shortest_remaining(definition.id)
				replacement.refresh(application, source)
				_notify_reapplied(replacement)
				_publish_changes()
				return true

	var runtime := StatusEffectRuntime.new()
	runtime.initialize(application, source, _next_instance_id)
	_next_instance_id += 1
	_effects.append(runtime)
	set_physics_process(true)

	if definition.behavior != null:
		definition.behavior.on_apply(_target, runtime)

	_publish_changes()
	return true


func get_active_effects() -> Array[StatusEffectRuntime]:
	return _effects


func notify_target_death() -> void:
	for runtime in _effects:
		if runtime.definition.behavior != null:
			runtime.definition.behavior.on_death(_target, runtime)


func clear() -> void:
	for index in range(_effects.size() - 1, -1, -1):
		_remove_at(index)
	_update_accumulator = 0.0
	set_physics_process(false)
	_publish_changes()


func _physics_process(delta: float) -> void:
	_update_accumulator += delta
	if _update_accumulator < UPDATE_INTERVAL:
		return

	var elapsed := _update_accumulator
	_update_accumulator = 0.0
	_advance(elapsed)


func _advance(elapsed: float) -> void:
	var state_changed := false

	for index in range(_effects.size() - 1, -1, -1):
		var runtime := _effects[index]
		var active_elapsed := minf(elapsed, maxf(runtime.remaining, 0.0))

		if runtime.application.tick_interval > 0.0 and active_elapsed > 0.0:
			runtime.time_until_tick -= active_elapsed
			var tick_count := 0
			while runtime.time_until_tick <= TICK_EPSILON:
				tick_count += 1
				runtime.time_until_tick += runtime.application.tick_interval

			if tick_count > 0:
				_process_ticks(runtime, tick_count)
				if not is_instance_valid(_target) or _target.is_queued_for_deletion():
					return

		runtime.remaining -= elapsed
		if runtime.remaining <= TICK_EPSILON:
			_remove_at(index)
			state_changed = true

	if state_changed:
		if _effects.is_empty():
			set_physics_process(false)
			_update_accumulator = 0.0
		_publish_changes()


func _process_ticks(runtime: StatusEffectRuntime, tick_count: int) -> void:
	if runtime.definition.deals_periodic_damage:
		var damage := runtime.effective_tick_damage() * tick_count
		if damage > 0.0:
			var valid_source: Node2D
			if is_instance_valid(runtime.source):
				valid_source = runtime.source as Node2D
			_target.take_damage(damage, valid_source)

	if runtime.definition.behavior != null:
		runtime.definition.behavior.on_tick(_target, runtime, tick_count)


func _remove_at(index: int) -> void:
	var runtime := _effects[index]
	if runtime.definition.behavior != null:
		runtime.definition.behavior.on_remove(_target, runtime)
	_effects.remove_at(index)


func _notify_reapplied(runtime: StatusEffectRuntime) -> void:
	if runtime.definition.behavior != null:
		runtime.definition.behavior.on_reapply(_target, runtime)


func _find_first(effect_id: StringName) -> StatusEffectRuntime:
	for runtime in _effects:
		if runtime.definition.id == effect_id:
			return runtime
	return null


func _count_effect(effect_id: StringName) -> int:
	var count := 0
	for runtime in _effects:
		if runtime.definition.id == effect_id:
			count += 1
	return count


func _find_shortest_remaining(effect_id: StringName) -> StatusEffectRuntime:
	var result: StatusEffectRuntime
	for runtime in _effects:
		if runtime.definition.id != effect_id:
			continue
		if result == null or runtime.remaining < result.remaining:
			result = runtime
	return result


func _publish_changes() -> void:
	var speed_multiplier := 1.0
	for runtime in _effects:
		if runtime.definition.affects_move_speed:
			var reduction := clampf(runtime.effective_magnitude(), 0.0, 1.0)
			speed_multiplier *= 1.0 - reduction

	speed_multiplier_changed.emit(maxf(speed_multiplier, 0.0))
	effects_changed.emit(_effects)

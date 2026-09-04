class_name StatusEffectView
extends Sprite2D

const NO_EFFECTS := Vector4.ZERO


func _ready() -> void:
	set_instance_shader_parameter(&"effect_phase", randf() * 20.0)
	visible = false


func set_effects(active_effects: Array) -> void:
	var intensities := NO_EFFECTS

	for runtime: StatusEffectRuntime in active_effects:
		var definition := runtime.definition
		if definition.visual_channel == StatusEffectDefinition.VisualChannel.NONE:
			continue

		var full_strength := maxf(definition.visual_full_strength, 0.001)
		var normalized := clampf(runtime.effective_magnitude() / full_strength, 0.0, 1.0)
		if normalized > 0.0:
			normalized = maxf(normalized, definition.visual_min_intensity)

		var old_value := _get_channel(intensities, definition.visual_channel)
		# Saturating composition makes stacks visibly stronger without allowing a
		# large stack count to produce an overbright solid block.
		var combined := 1.0 - (1.0 - old_value) * (1.0 - normalized)
		intensities = _set_channel(intensities, definition.visual_channel, combined)

	set_instance_shader_parameter(&"effect_intensity", intensities)
	visible = intensities != NO_EFFECTS


func _get_channel(values: Vector4, channel: int) -> float:
	match channel:
		StatusEffectDefinition.VisualChannel.FROST:
			return values.x
		StatusEffectDefinition.VisualChannel.POISON:
			return values.y
		StatusEffectDefinition.VisualChannel.FIRE:
			return values.z
		StatusEffectDefinition.VisualChannel.OIL:
			return values.w
	return 0.0


func _set_channel(values: Vector4, channel: int, value: float) -> Vector4:
	match channel:
		StatusEffectDefinition.VisualChannel.FROST:
			values.x = value
		StatusEffectDefinition.VisualChannel.POISON:
			values.y = value
		StatusEffectDefinition.VisualChannel.FIRE:
			values.z = value
		StatusEffectDefinition.VisualChannel.OIL:
			values.w = value
	return values

class_name StatusEffectApplication
extends Resource

@export var definition: StatusEffectDefinition
@export_range(0.001, 3600.0, 0.001, "or_greater") var duration: float = 1.0
@export_range(0.0, 1.0, 0.01, "or_greater") var magnitude: float = 1.0
@export_range(0.0, 3600.0, 0.001, "or_greater") var tick_interval: float = 0.0
@export_range(0.0, 1000000.0, 0.1, "or_greater") var damage_per_tick: float = 0.0


func is_valid() -> bool:
	if definition == null or definition.id == &"" or duration <= 0.0:
		return false
	if definition.deals_periodic_damage:
		return tick_interval > 0.0
	return true

class_name StatusEffectDefinition
extends Resource

enum StackPolicy {
	REFRESH,
	STRONGEST_REFRESH,
	ADD_STACKS,
	INDEPENDENT,
}

enum VisualChannel {
	NONE = -1,
	FROST,
	POISON,
	FIRE,
	OIL,
}

@export_group("Identity")
@export var id: StringName
@export var resistance_tag: StringName
@export var tags: Array[StringName] = []
@export var transient: bool = false

@export_group("Rules")
@export var stack_policy: StackPolicy = StackPolicy.REFRESH
@export_range(1, 16, 1) var max_stacks: int = 1
@export var affects_move_speed: bool = false
@export var deals_periodic_damage: bool = false
@export var behavior: StatusEffectBehavior

@export_group("Presentation")
@export var visual_channel: VisualChannel = VisualChannel.NONE
@export_range(0.001, 10000.0, 0.001, "or_greater") var visual_full_strength: float = 1.0
@export_range(0.0, 1.0, 0.01) var visual_min_intensity: float = 0.25

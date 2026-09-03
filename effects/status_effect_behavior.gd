class_name StatusEffectBehavior
extends Resource

## Extend this resource for effects that cannot be expressed as movement modifiers
## or periodic damage. Behavior resources are shared, so runtime state belongs in
## StatusEffectRuntime rather than on the behavior itself.

func on_apply(_target: Node, _runtime: StatusEffectRuntime) -> void:
	pass


func on_reapply(_target: Node, _runtime: StatusEffectRuntime) -> void:
	pass


func on_tick(_target: Node, _runtime: StatusEffectRuntime, _tick_count: int) -> void:
	pass


func on_remove(_target: Node, _runtime: StatusEffectRuntime) -> void:
	pass


func on_death(_target: Node, _runtime: StatusEffectRuntime) -> void:
	pass

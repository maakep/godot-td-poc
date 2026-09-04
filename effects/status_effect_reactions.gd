class_name StatusEffectReactions
extends RefCounted

const BURNING_OIL := preload("res://effects/applications/burning_oil.tres")
const INFERNO := preload("res://effects/applications/inferno.tres")
const SPREAD_BURN := preload("res://effects/applications/spread_burn.tres")
const SHATTER_STUN := preload("res://effects/applications/shatter_stun.tres")
const TOXIC_COMBUSTION := preload("res://effects/applications/toxic_combustion.tres")
const TOXIC_CLOUD := preload("res://effects/applications/toxic_cloud.tres")

const SPREAD_RADIUS := 80.0
const MAX_SPREAD_TARGETS := 16


static func try_react(component: Node, incoming: StatusEffectApplication, source: Node) -> bool:
	var tags := incoming.definition.tags
	var reacted := false
	var oil_reacted := false

	if &"fire" in tags:
		if component.has_tag(&"oil"):
			_ignite_oil(component, source)
			reacted = true
			oil_reacted = true
		if _is_alive(component) and component.has_tag(&"poison"):
			_combust_poison(component, incoming, source, not oil_reacted)
			reacted = true

	if not reacted and &"impact" in tags and component.has_tag(&"frost"):
		_shatter(component, source)
		reacted = true

	return reacted


static func _ignite_oil(component: Node, source: Node) -> void:
	var stacks: int = component.consume_tag(&"oil")
	_damage(component, 8.0 * stacks, source)
	if not _is_alive(component):
		return
	component.apply_direct(BURNING_OIL, source)
	var scaled_inferno: StatusEffectApplication = INFERNO.duplicate()
	scaled_inferno.magnitude = 1.0 + 0.5 * (stacks - 1)
	scaled_inferno.damage_per_tick *= scaled_inferno.magnitude
	component.apply_direct(scaled_inferno, source)
	_spread(component, SPREAD_BURN, source)


static func _combust_poison(
		component: Node,
		incoming: StatusEffectApplication,
		source: Node,
		preserve_fire: bool
	) -> void:
	component.consume_tag(&"poison")
	_damage(component, 12.0, source)
	if not _is_alive(component):
		return
	if preserve_fire:
		component.apply_direct(incoming, source)
	component.apply_direct(TOXIC_COMBUSTION, source)
	_spread(component, TOXIC_CLOUD, source)


static func _shatter(component: Node, source: Node) -> void:
	var stacks: int = component.consume_tag(&"frost")
	_damage(component, 10.0 + 5.0 * stacks, source)
	if _is_alive(component):
		component.apply_direct(SHATTER_STUN, source)


static func _damage(component: Node, amount: float, source: Node) -> void:
	var target: Node = component.get_target()
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return
	target.take_damage(amount, source as Node2D)


static func _is_alive(component: Node) -> bool:
	var target: Node = component.get_target()
	return is_instance_valid(target) and not target.is_queued_for_deletion()


static func _spread(component: Node, application: StatusEffectApplication, source: Node) -> void:
	var target := component.get_target() as Node2D
	if target == null or not target.is_inside_tree():
		return

	var shape := CircleShape2D.new()
	shape.radius = SPREAD_RADIUS
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, target.global_position)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for result in target.get_world_2d().direct_space_state.intersect_shape(query, MAX_SPREAD_TARGETS):
		var enemy = result.collider
		if enemy != target and enemy != null and enemy.has_method("apply_effect"):
			enemy.apply_effect(application, source)

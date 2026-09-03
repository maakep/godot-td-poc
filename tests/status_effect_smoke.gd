extends Node

const CHILL := preload("res://effects/applications/ice_chill.tres")
const POISON := preload("res://effects/applications/poison.tres")
const BURN := preload("res://effects/applications/burn.tres")
const TOWER_INSPECTOR := preload("res://ui/tower_inspector.gd")
const TEST_SPAWNER := preload("res://tests/test_spawner.gd")


class DummyTarget extends Node:
	var damage_taken: float = 0.0

	func take_damage(amount: float, _source: Node2D = null) -> void:
		damage_taken += amount


func _ready() -> void:
	var target := DummyTarget.new()
	add_child(target)

	var component := StatusEffectComponent.new()
	target.add_child(component)
	component.setup(target)

	var last_speed_multiplier := [1.0]
	component.speed_multiplier_changed.connect(
		func(value: float) -> void: last_speed_multiplier[0] = value
	)

	component.apply(CHILL)
	component.apply(CHILL)
	_assert_equal(component.get_active_effects().size(), 2, "Independent chill stacks")
	_assert_near(last_speed_multiplier[0], 0.49, "Multiplicative movement reduction")

	component.apply(POISON)
	component.apply(BURN)
	component._advance(1.0)
	_assert_near(target.damage_taken, 50.0, "Poison and burn tick together")
	_assert_equal(component.get_active_effects().size(), 1, "Only burn remains after one second")
	_assert_near(last_speed_multiplier[0], 1.0, "Expired movement effects are removed")

	component.clear()
	target.damage_taken = 0.0
	component.apply(POISON)
	component._advance(0.5)
	component.apply(POISON)
	component._advance(0.5)
	_assert_near(target.damage_taken, 40.0, "Refresh preserves periodic tick progress")

	component.clear()
	for index in 6:
		component.apply(CHILL)
	_assert_equal(component.get_active_effects().size(), 5, "Independent stacks respect their cap")

	var inspector := TOWER_INSPECTOR.new()
	var effect_text: String = inspector._effects_text([CHILL, POISON, BURN])
	_assert_equal(
		effect_text,
		"Chill: 30% slow for 1s, Poison: 50% slow, 40 damage/s for 1s, Burn: 10 damage/s for 10s",
		"Tower inspector reads typed effect resources",
	)
	inspector.free()

	var spawner = TEST_SPAWNER.new()
	spawner.lvl = Levels.all.size() - 1
	spawner.lvl_active = true
	spawner.creeps_to_kill = 2
	var victories := [0]
	Events.run_win.connect(func() -> void: victories[0] += 1, CONNECT_ONE_SHOT)
	spawner.enemy_gone()
	_assert_equal(victories[0], 0, "Wave remains active while a creep is accounted for")
	spawner.enemy_gone()
	_assert_equal(victories[0], 1, "Last accounted creep reports victory")
	_assert_equal(spawner.lvl_active, false, "Completed wave becomes inactive")
	spawner.enemy_gone()
	_assert_equal(victories[0], 1, "Duplicate notifications cannot report victory twice")
	spawner.free()

	print("Status effect smoke tests passed")
	get_tree().quit()


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		push_error("%s: expected %s, got %s" % [label, expected, actual])
		get_tree().quit(1)


func _assert_near(actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		push_error("%s: expected %s, got %s" % [label, expected, actual])
		get_tree().quit(1)

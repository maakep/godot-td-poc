extends Node

const CHILL := preload("res://effects/applications/ice_chill.tres")
const POISON := preload("res://effects/applications/poison.tres")
const BURN := preload("res://effects/applications/burn.tres")
const OIL := preload("res://effects/applications/goblin_oil.tres")
const IMPACT := preload("res://effects/applications/impact.tres")
const TOWER_INSPECTOR := preload("res://ui/tower_inspector.gd")
const TEST_SPAWNER := preload("res://tests/test_spawner.gd")
const FACTION_SELECT := preload("res://main_menu/faction_select.tscn")
const TOWER_BUTTON := preload("res://ui/TowerUIButton.tscn")
const TOWER_SCENE := preload("res://buildings/tower.tscn")

var failed := false


class DummyTarget extends Node:
	var damage_taken: float = 0.0

	func take_damage(amount: float, _source: Node2D = null) -> void:
		damage_taken += amount


class DummyEnemy extends Area2D:
	var damage_taken := 0.0
	var effects: StatusEffectComponent

	func _init() -> void:
		collision_layer = 2
		collision_mask = 0
		add_to_group("enemy")
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 8.0
		collision.shape = shape
		add_child(collision)
		effects = StatusEffectComponent.new()
		add_child(effects)

	func _ready() -> void:
		effects.setup(self)

	func apply_effect(application: StatusEffectApplication, source: Node = null) -> bool:
		return effects.apply(application, source)

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
	_assert_near(target.damage_taken, 34.0, "Fire combusts poison without losing its own damage")
	_assert_equal(component.get_active_effects().size(), 2, "Combustion keeps fire and adds a toxic aftermath")
	_assert_near(last_speed_multiplier[0], 0.75, "Toxic combustion retains its slow")

	component.clear()
	target.damage_taken = 0.0
	component.apply(POISON)
	component._advance(0.5)
	component.apply(POISON)
	component._advance(0.5)
	_assert_near(target.damage_taken, 20.0, "Refresh preserves periodic tick progress")

	component.clear()
	for index in 6:
		component.apply(CHILL)
	_assert_equal(component.get_active_effects().size(), 5, "Independent stacks respect their cap")

	component.clear()
	target.damage_taken = 0.0
	component.apply(OIL)
	component.apply(OIL)
	_assert_near(last_speed_multiplier[0], 0.7, "Oil stacks intensify its slow")
	component.apply(BURN)
	_assert_equal(component.has_tag(&"oil"), false, "Fire consumes oil")
	_assert_equal(component.get_active_effects().size(), 2, "Ignited oil leaves tar and inferno effects together")
	_assert_near(target.damage_taken, 16.0, "Oil stacks intensify ignition burst")
	component._advance(1.0)
	_assert_near(target.damage_taken, 40.0, "Oil stacks intensify inferno damage")

	component.clear()
	target.damage_taken = 0.0
	component.apply(CHILL)
	component.apply(CHILL)
	component.apply(IMPACT)
	_assert_equal(component.has_tag(&"frost"), false, "Impact consumes frost")
	_assert_equal(component.get_active_effects().size(), 1, "Shatter leaves a brief stun")
	_assert_near(last_speed_multiplier[0], 0.0, "Shatter briefly stops its target")
	_assert_near(target.damage_taken, 20.0, "Frost stacks strengthen shatter damage")

	var ignited := DummyEnemy.new()
	var neighbor := DummyEnemy.new()
	var distant := DummyEnemy.new()
	add_child(ignited)
	add_child(neighbor)
	add_child(distant)
	neighbor.position = Vector2(40, 0)
	distant.position = Vector2(160, 0)
	await get_tree().physics_frame
	ignited.apply_effect(OIL)
	ignited.apply_effect(BURN)
	_assert_equal(_has_effect(neighbor.effects, &"spread_burn"), true, "Ignited oil spreads fire to nearby enemies")
	_assert_equal(_has_effect(distant.effects, &"spread_burn"), false, "Ignition spread respects its radius")
	ignited.free()
	neighbor.free()
	distant.free()

	var inspector := TOWER_INSPECTOR.new()
	var effect_text: String = inspector._effects_text([CHILL, POISON, BURN])
	_assert_equal(
		effect_text,
		"Chill: 30% slow for 1s, Poison: 50% slow, 20 damage/s for 1s, Burn: 10 damage/s for 10s",
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

	var faction_select := FACTION_SELECT.instantiate()
	add_child(faction_select)
	faction_select._show_faction_details("human")
	_assert_equal(
		faction_select.detail_name.text,
		Factions.get_faction("human").name,
		"Faction hover details show the faction name",
	)
	var faction_buttons: Array[Node] = faction_select.faction_container.get_children()
	for button in faction_buttons:
		_assert_equal(button.get_node_or_null("Label"), null, "Faction tiles remain icon-only")
	faction_select._select_faction("human")
	faction_select._select_faction("goblin")
	_assert_equal(faction_select.selected_ids.size(), 2, "Two factions can be selected")
	_assert_equal(faction_select.play_button.disabled, false, "Two selections enable play")
	faction_select.free()

	var selected: Array[String] = ["human", "goblin"]
	_assert_equal(FactionProgress.select_factions(selected), true, "Two unlocked factions form a loadout")
	var buyable := Towers.get_buyable_towers()
	_assert_equal(buyable.has("palisade"), true, "Human towers appear in the merged loadout")
	_assert_equal(buyable.has("goblin_tar"), true, "Goblin towers appear in the merged loadout")
	_assert_equal(Towers.get_sell_price(buyable.palisade), 0, "Palisade sells for zero")
	_assert_equal(Towers.get_sell_price(buyable.goblin_scraps), 0, "Scrap heap cannot be freely repositioned")
	var blocker = TOWER_SCENE.instantiate()
	blocker.tower_id = "palisade"
	add_child(blocker)
	_assert_equal(blocker.behavior, "blocker", "Palisade uses the shared blocker behavior")
	_assert_equal(blocker.area.monitoring, false, "Blockers skip attack-area monitoring")
	blocker.free()

	FactionProgress.unlocked_factions["elemental"] = true
	var elemental_selection: Array[String] = ["elemental", "goblin"]
	_assert_equal(FactionProgress.select_factions(elemental_selection), true, "Any two unlocked factions can be combined")
	var elemental_buyable := Towers.get_buyable_towers()
	_assert_equal(elemental_buyable.has("frost_monolith"), true, "Elemental aura tower appears in the merged loadout")
	_assert_equal(Towers.get_sell_price(elemental_buyable.frost_monolith), 2, "Default sell price rounds half down")
	var aura = TOWER_SCENE.instantiate()
	aura.tower_id = "frost_monolith"
	add_child(aura)
	_assert_equal(aura.behavior, "aura", "Frost Monolith uses the shared aura behavior")
	aura.free()
	FactionProgress.select_factions(selected)

	var unavailable_button = TOWER_BUTTON.instantiate()
	unavailable_button.setup(buyable.goblin_scrap_cannon, "goblin_scrap_cannon", 4, false)
	add_child(unavailable_button)
	_assert_equal(unavailable_button.get_node("TextureButton").disabled, true, "Unaffordable towers are disabled")
	_assert_equal(unavailable_button.get_node("TextureButton").tooltip_text, "", "Unaffordable towers hide details")
	unavailable_button.set_choice_enabled(true)
	_assert_equal(unavailable_button.get_node("TextureButton").tooltip_text.is_empty(), false, "Affordable towers reveal details")
	unavailable_button.free()

	if failed:
		get_tree().quit(1)
	else:
		print("Status effect smoke tests passed")
		get_tree().quit()


func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		push_error("%s: expected %s, got %s" % [label, expected, actual])
		failed = true


func _assert_near(actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		push_error("%s: expected %s, got %s" % [label, expected, actual])
		failed = true


func _has_effect(component: StatusEffectComponent, effect_id: StringName) -> bool:
	for runtime in component.get_active_effects():
		if runtime.definition.id == effect_id:
			return true
	return false

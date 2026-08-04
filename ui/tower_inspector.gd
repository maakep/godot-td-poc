extends PanelContainer

signal upgrade_requested(tower: Node2D, upgrade_id: String)
signal sell_requested(tower: Node2D)
signal closed

var selected_tower: Node2D
var available_gold := 0

var title_label: Label
var description_label: Label
var performance_label: Label
var stats_label: Label
var upgrades_box: HFlowContainer
var sell_button: Button

const TOWER_ICON_BUTTON = preload("res://ui/TowerUIButton.tscn")


func _ready() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.075, 0.09, 0.13, 0.96)
	panel_style.border_color = Color(0.55, 0.68, 0.8, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)

	var header := HBoxContainer.new()
	content.add_child(header)
	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 20)
	header.add_child(title_label)
	var close_button := Button.new()
	close_button.text = "×"
	close_button.tooltip_text = "Close tower inspector"
	close_button.pressed.connect(hide_inspector)
	header.add_child(close_button)

	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(description_label)

	performance_label = Label.new()
	performance_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.92))
	content.add_child(performance_label)

	stats_label = Label.new()
	stats_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.92))
	content.add_child(stats_label)

	var upgrades_heading := Label.new()
	upgrades_heading.text = "UPGRADES"
	upgrades_heading.add_theme_font_size_override("font_size", 13)
	content.add_child(upgrades_heading)

	upgrades_box = HFlowContainer.new()
	upgrades_box.add_theme_constant_override("separation", 5)
	content.add_child(upgrades_box)

	sell_button = Button.new()
	sell_button.tooltip_text = "Remove this tower and receive half of its current cost."
	sell_button.pressed.connect(func(): sell_requested.emit(selected_tower))
	content.add_child(sell_button)
	visible = false


func show_tower(tower: Node2D, gold: int) -> void:
	selected_tower = tower
	available_gold = gold
	visible = true
	refresh()


func refresh(gold: int = available_gold) -> void:
	available_gold = gold
	if title_label == null:
		return
	if !is_instance_valid(selected_tower):
		hide_inspector()
		return

	var data = selected_tower.tower
	title_label.text = data.name
	description_label.text = data.description
	performance_label.text = "Damage dealt: %d    Kills: %d" % [roundi(selected_tower.damage_dealt), selected_tower.kills]
	stats_label.text = _stats_text(data)

	for child in upgrades_box.get_children():
		child.queue_free()

	for upgrade_id in data.upgrades:
		var upgrade_data = Towers.get_tower(upgrade_id)
		var upgrade_button = TOWER_ICON_BUTTON.instantiate()
		upgrade_button.setup(upgrade_data, upgrade_id, upgrade_data.cost, available_gold >= upgrade_data.cost)
		upgrade_button.get_node("TextureButton").tooltip_text = _upgrade_tooltip(upgrade_data)
		upgrade_button.activated.connect(func(id): upgrade_requested.emit(selected_tower, id))
		upgrades_box.add_child(upgrade_button)

	if data.upgrades.is_empty():
		var final_label := Label.new()
		final_label.text = "This tower is fully upgraded."
		final_label.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
		upgrades_box.add_child(final_label)

	var sell_price := ceili(data.cost / 2.0)
	sell_button.text = "Sell - %d gold" % sell_price


func hide_inspector() -> void:
	selected_tower = null
	visible = false
	closed.emit()


func _process(_delta: float) -> void:
	if visible and is_instance_valid(selected_tower):
		performance_label.text = "Damage dealt: %d    Kills: %d" % [roundi(selected_tower.damage_dealt), selected_tower.kills]


func _stats_text(data: Dictionary) -> String:
	var projectile = data.proj
	var lines = [
		"Damage: %s    Targets: %s" % [projectile.damage, data.targets],
		"Range: %s    Attack cooldown: %ss" % [data.range, data.atkspd],
	]
	if projectile.aoe > 0:
		lines.append("Area radius: %s" % projectile.aoe)
	if projectile.effects.size() > 0:
		lines.append("Effects: " + _effects_text(projectile.effects))
	return "\n".join(lines)


func _upgrade_tooltip(data: Dictionary) -> String:
	return "%s\n\n%s\n\n%s" % [data.name, data.description, _stats_text(data)]


func _effects_text(effects: Array) -> String:
	var names: Array[String] = []
	for effect in effects:
		match effect.handler:
			"slow": names.append("Slow %d%% for %ss" % [roundi(effect.val * 100), effect.dur])
			"poison": names.append("Poison: %s damage/s for %ss" % [effect.dmg, effect.dur])
			"burn": names.append("Burn: %s damage/s for %ss" % [effect.dmg, effect.dur])
			_: names.append(effect.handler.capitalize())
	return ", ".join(names)

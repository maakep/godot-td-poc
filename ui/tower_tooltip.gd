extends PanelContainer

enum StatImportance {
	PRIMARY,
	SECONDARY,
	TERTIARY,
}

var tower_id := ""
var tower_data: Dictionary = {}

@onready var name_label = $VBoxContainer/Name
@onready var description_label = $VBoxContainer/Description
@onready var core_stats_grid = $VBoxContainer/CoreStats
@onready var combat_stats_grid = $VBoxContainer/CombatStats
@onready var projectile_stats_grid = $VBoxContainer/ProjectileStats


func setup(new_tower_id: String, new_tower_data: Dictionary) -> void:
	tower_id = new_tower_id
	tower_data = new_tower_data

	if is_node_ready():
		_populate()


func _ready() -> void:
	_populate()


func _populate() -> void:
	if tower_data.is_empty():
		return

	name_label.text = tower_data.get("display_name", tower_id.capitalize())

	var description: String = tower_data.get("description", "")
	description_label.text = description
	description_label.visible = !description.is_empty()

	_clear_grid(core_stats_grid)
	_clear_grid(combat_stats_grid)
	_clear_grid(projectile_stats_grid)

	var projectile: Dictionary = tower_data.get("proj", {})
	var damage: float = projectile.get("damage", 0)
	var attack_interval: float = tower_data.get("atkspd", 0)
	var attacks_per_second := 1.0 / attack_interval if attack_interval > 0.0 else 0.0
	var base_dps := damage * attacks_per_second

	_add_stat(core_stats_grid, "Damage", _format_number(damage), StatImportance.PRIMARY)
	_add_stat(core_stats_grid, "Direct DPS", _format_number(base_dps), StatImportance.PRIMARY)
	_add_stat(core_stats_grid, "Attack rate", "%s / sec" % _format_number(attacks_per_second), StatImportance.PRIMARY)
	_add_stat(core_stats_grid, "Range", str(tower_data.get("range", 0)), StatImportance.PRIMARY)

	_add_stat(combat_stats_grid, "Cost", "%s gold" % tower_data.get("cost", 0), StatImportance.SECONDARY)
	_add_stat(combat_stats_grid, "Targets", str(tower_data.get("targets", 1)), StatImportance.SECONDARY)

	var effects: Array = projectile.get("effects", [])
	if !effects.is_empty():
		_add_stat(combat_stats_grid, "Effects", _format_effects(effects), StatImportance.SECONDARY)

	var area_radius = projectile.get("aoe", 0)
	if area_radius > 0:
		_add_stat(combat_stats_grid, "Area radius", str(area_radius), StatImportance.SECONDARY)

	var piercing = projectile.get("piercing", 0)
	if piercing > 0:
		_add_stat(combat_stats_grid, "Piercing", str(piercing), StatImportance.SECONDARY)

	var upgrades: Array = tower_data.get("upgrades", [])
	if !upgrades.is_empty():
		var upgrade_names = PackedStringArray()
		for upgrade_id in upgrades:
			upgrade_names.append(str(upgrade_id).capitalize())
		_add_stat(combat_stats_grid, "Upgrades to", ", ".join(upgrade_names), StatImportance.SECONDARY)

	_add_stat(projectile_stats_grid, "Speed", str(projectile.get("speed", 0)), StatImportance.TERTIARY)
	_add_stat(projectile_stats_grid, "Lifetime", "%s s" % projectile.get("range", 0), StatImportance.TERTIARY)


func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()


func _add_stat(grid: GridContainer, label_text: String, value_text: String, importance: int) -> void:
	var stat_label = Label.new()
	stat_label.text = label_text
	stat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_child(stat_label)

	var stat_value = Label.new()
	stat_value.text = value_text
	stat_value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stat_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_child(stat_value)

	match importance:
		StatImportance.PRIMARY:
			stat_label.modulate = Color(0.88, 0.9, 0.95)
			stat_label.add_theme_font_size_override("font_size", 14)
			stat_value.add_theme_color_override("font_color", Color(1, 0.84, 0.3))
			stat_value.add_theme_font_size_override("font_size", 17)
		StatImportance.SECONDARY:
			stat_label.modulate = Color(0.72, 0.76, 0.82)
		StatImportance.TERTIARY:
			stat_label.modulate = Color(0.55, 0.59, 0.66)
			stat_value.modulate = Color(0.65, 0.69, 0.75)
			stat_label.add_theme_font_size_override("font_size", 12)
			stat_value.add_theme_font_size_override("font_size", 12)


func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))

	return str(snappedf(value, 0.01))


func _format_effects(effects: Array) -> String:
	var effect_descriptions = PackedStringArray()

	for effect in effects:
		var effect_data: Dictionary = effect
		var description := _format_effect(effect_data)
		if description not in effect_descriptions:
			effect_descriptions.append(description)

	return "; ".join(effect_descriptions)


func _format_effect(effect: Dictionary) -> String:
	var handler: String = effect.get("handler", effect.get("name", "Unknown"))
	var duration := _format_number(float(effect.get("dur", 0)))

	match handler:
		"slow":
			var slow_percent: float = effect.get("val", 0) * 100.0
			if slow_percent >= 99.5:
				return "Stun · %ss" % duration
			return "%s%% slow · %ss" % [_format_number(slow_percent), duration]
		"poison":
			var poison_dps := _effect_dps(effect)
			var poison_slow: float = effect.get("val", 0) * 100.0
			return "Poison · %s DPS + %s%% slow · %ss" % [
				_format_number(poison_dps),
				_format_number(poison_slow),
				duration,
			]
		"burn":
			return "Burn · %s DPS · %ss" % [_format_number(_effect_dps(effect)), duration]
		_:
			return handler.capitalize()


func _effect_dps(effect: Dictionary) -> float:
	var tick_rate: float = effect.get("tick_rate", 1.0)
	if tick_rate <= 0.0:
		return 0.0

	return float(effect.get("dmg", 0)) / tick_rate

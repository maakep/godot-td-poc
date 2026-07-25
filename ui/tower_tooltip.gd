extends PanelContainer

const SLOW_COLOR := Color(0.35, 0.78, 1.0)
const STUN_COLOR := Color(1.0, 0.92, 0.45)
const POISON_COLOR := Color(0.72, 0.45, 1.0)
const BURN_COLOR := Color(1.0, 0.45, 0.2)

var tower_id := ""
var tower_data: Dictionary = {}

@onready var name_label = $VBoxContainer/Name
@onready var description_label = $VBoxContainer/Description
@onready var core_stats_grid = $VBoxContainer/CoreStats
@onready var traits_stats_grid = $VBoxContainer/TraitsStats
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
	_clear_grid(traits_stats_grid)
	_clear_grid(projectile_stats_grid)

	var projectile: Dictionary = tower_data.get("proj", {})
	var damage: float = projectile.get("damage", 0)
	var attack_interval: float = tower_data.get("atkspd", 0)
	var attacks_per_second := 1.0 / attack_interval if attack_interval > 0.0 else 0.0
	var base_dps := damage * attacks_per_second

	_add_stat(core_stats_grid, "Damage", _format_number(damage))
	_add_stat(core_stats_grid, "Direct DPS", _format_number(base_dps))
	_add_stat(core_stats_grid, "Attack rate", "%s / sec" % _format_number(attacks_per_second))
	_add_stat(core_stats_grid, "Range", str(tower_data.get("range", 0)))

	_add_stat(traits_stats_grid, "Targets", str(tower_data.get("targets", 1)))

	var effects: Array = projectile.get("effects", [])
	for index in range(effects.size()):
		var effect: Dictionary = effects[index]
		var effect_label := "Effect" if index == 0 else ""
		_add_stat(
			traits_stats_grid,
			effect_label,
			_format_effect(effect),
			_effect_color(effect)
		)

	var upgrades: Array = tower_data.get("upgrades", [])
	if !upgrades.is_empty():
		var upgrade_names = PackedStringArray()
		for upgrade_id in upgrades:
			upgrade_names.append(str(upgrade_id).capitalize())
		_add_stat(traits_stats_grid, "Upgrades to", ", ".join(upgrade_names))

	var area_radius = projectile.get("aoe", 0)
	if area_radius > 0:
		_add_stat(projectile_stats_grid, "Area radius", str(area_radius))

	var piercing = projectile.get("piercing", 0)
	if piercing > 0:
		_add_stat(projectile_stats_grid, "Piercing", str(piercing))

	_add_stat(projectile_stats_grid, "Speed", str(projectile.get("speed", 0)))
	_add_stat(projectile_stats_grid, "Lifetime", "%s s" % projectile.get("range", 0))


func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()


func _add_stat(
	grid: GridContainer,
	label_text: String,
	value_text: String,
	value_color: Color = Color.TRANSPARENT
) -> void:
	var stat_label = Label.new()
	stat_label.text = label_text
	stat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stat_label.theme_type_variation = &"TooltipMeta"
	grid.add_child(stat_label)

	var stat_value = Label.new()
	stat_value.text = value_text
	stat_value.theme_type_variation = &"TooltipBody"
	stat_value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stat_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if value_color.a > 0.0:
		stat_value.add_theme_color_override("font_color", value_color)
	grid.add_child(stat_value)


func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))

	return str(snappedf(value, 0.01))


func _format_effect(effect: Dictionary) -> String:
	var handler: String = effect.get("handler", effect.get("name", "Unknown"))
	var duration := _format_number(float(effect.get("dur", 0)))

	match handler:
		"slow":
			var slow_percent: float = effect.get("val", 0) * 100.0
			if slow_percent >= 99.5:
				return "Stun · %ss" % duration
			return "Slow %s%% · %ss" % [_format_number(slow_percent), duration]
		"poison":
			var poison_dps := _effect_dps(effect)
			var poison_slow: float = effect.get("val", 0) * 100.0
			return "Poison %s DPS · %s%% slow · %ss" % [
				_format_number(poison_dps),
				_format_number(poison_slow),
				duration,
			]
		"burn":
			return "Burn %s DPS · %ss" % [_format_number(_effect_dps(effect)), duration]
		_:
			return handler.capitalize()


func _effect_color(effect: Dictionary) -> Color:
	var handler: String = effect.get("handler", effect.get("name", ""))
	if handler == "slow" and float(effect.get("val", 0)) >= 0.995:
		return STUN_COLOR

	match handler:
		"slow":
			return SLOW_COLOR
		"poison":
			return POISON_COLOR
		"burn":
			return BURN_COLOR
		_:
			return Color.WHITE


func _effect_dps(effect: Dictionary) -> float:
	var tick_rate: float = effect.get("tick_rate", 1.0)
	if tick_rate <= 0.0:
		return 0.0

	return float(effect.get("dmg", 0)) / tick_rate

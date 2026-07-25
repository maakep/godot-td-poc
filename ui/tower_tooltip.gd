extends MarginContainer

var tower_id := ""
var tower_data: Dictionary = {}

@onready var name_label = $VBoxContainer/Name
@onready var description_label = $VBoxContainer/Description
@onready var stats_grid = $VBoxContainer/Stats


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

	for child in stats_grid.get_children():
		stats_grid.remove_child(child)
		child.queue_free()

	var projectile: Dictionary = tower_data.get("proj", {})
	_add_stat("Cost", "%s gold" % tower_data.get("cost", 0))
	_add_stat("Damage", str(projectile.get("damage", 0)))
	_add_stat("Attack interval", "%s s" % tower_data.get("atkspd", 0))
	_add_stat("Range", str(tower_data.get("range", 0)))
	_add_stat("Targets", str(tower_data.get("targets", 1)))
	_add_stat("Projectile speed", str(projectile.get("speed", 0)))
	_add_stat("Projectile lifetime", "%s s" % projectile.get("range", 0))

	var area_radius = projectile.get("aoe", 0)
	if area_radius > 0:
		_add_stat("Area radius", str(area_radius))

	var piercing = projectile.get("piercing", 0)
	if piercing > 0:
		_add_stat("Piercing", str(piercing))

	_add_stat("Effects", _format_effects(projectile.get("effects", [])))

	var upgrades: Array = tower_data.get("upgrades", [])
	if !upgrades.is_empty():
		var upgrade_names = PackedStringArray()
		for upgrade_id in upgrades:
			upgrade_names.append(str(upgrade_id).capitalize())
		_add_stat("Upgrades to", ", ".join(upgrade_names))


func _add_stat(label_text: String, value_text: String) -> void:
	var stat_label = Label.new()
	stat_label.text = label_text
	stat_label.modulate = Color(0.72, 0.76, 0.82)
	stat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_grid.add_child(stat_label)

	var stat_value = Label.new()
	stat_value.text = value_text
	stat_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stat_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stats_grid.add_child(stat_value)


func _format_effects(effects: Array) -> String:
	var effect_names = PackedStringArray()

	for effect in effects:
		var effect_name = str(effect.get("handler", effect.get("name", "Unknown"))).capitalize()
		if effect_name not in effect_names:
			effect_names.append(effect_name)

	return ", ".join(effect_names) if !effect_names.is_empty() else "None"

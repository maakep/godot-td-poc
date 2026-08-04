extends Control

const TILE_SIZE := Vector2(128, 128)
const COLUMNS := 6

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_menu()
	get_tree().paused = true

func _build_menu() -> void:
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.02, 0.028, 0.05, 0.95)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(900, 610)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title := Label.new()
	title.text = "CHOOSE A FACTION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Each faction has its own tower roster. Discover more factions as you play."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color(0.68, 0.73, 0.82))
	content.add_child(subtitle)

	var divider := HSeparator.new()
	divider.custom_minimum_size.y = 12
	content.add_child(divider)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	scroll.add_child(grid)
	for faction_id in Factions.all:
		grid.add_child(_make_faction_tile(faction_id))

func _make_faction_tile(faction_id: String) -> Button:
	var faction := Factions.get_faction(faction_id)
	var unlocked := FactionProgress.is_unlocked(faction_id)
	var tile := Button.new()
	tile.custom_minimum_size = TILE_SIZE
	tile.tooltip_text = faction.name + "\n\n" + faction.description if unlocked else "Unknown faction"
	tile.add_theme_stylebox_override("normal", _tile_style(Color(0.10, 0.13, 0.20)))
	tile.add_theme_stylebox_override("hover", _tile_style(Color(0.17, 0.25, 0.36), Color(0.50, 0.75, 0.95)))
	tile.add_theme_stylebox_override("pressed", _tile_style(Color(0.12, 0.19, 0.29), Color(0.75, 0.9, 1.0)))
	if unlocked:
		tile.pressed.connect(_select_faction.bind(faction_id))
		var icon := TextureRect.new()
		icon.texture = faction.get("icon")
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2(22, 12)
		icon.size = Vector2(84, 76)
		tile.add_child(icon)
		_add_tile_label(tile, faction.name, Color(0.92, 0.95, 1.0))
	else:
		tile.disabled = true
		tile.add_theme_stylebox_override("disabled", _tile_style(Color(0.055, 0.065, 0.09), Color(0.15, 0.17, 0.21)))
		_add_tile_label(tile, "???", Color(0.48, 0.52, 0.60), 30)
	return tile

func _add_tile_label(tile: Button, text: String, color: Color, font_size := 13) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(8, 92)
	label.size = Vector2(112, 28)
	tile.add_child(label)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.07, 0.11, 0.985)
	style.border_color = Color(0.32, 0.45, 0.62)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style

func _tile_style(background: Color, border := Color(0.24, 0.30, 0.40)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style

func _select_faction(faction_id: String) -> void:
	if FactionProgress.select_faction(faction_id):
		get_tree().paused = false
		queue_free()

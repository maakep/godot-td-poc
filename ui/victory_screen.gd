extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	Events.run_win.connect(show_victory)

func show_victory() -> void:
	if visible:
		return
	visible = true
	_build()
	get_tree().paused = true

func _build() -> void:
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.015, 0.025, 0.045, 0.96)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dimmer)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 480)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	var title := Label.new()
	title.text = "VICTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	content.add_child(title)
	var summary := Label.new()
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.add_theme_color_override("font_color", Color(0.75, 0.82, 0.92))
	var player := get_tree().current_scene.get_node_or_null("Player")
	if player != null:
		summary.text = "All %d waves cleared in %s" % [Levels.all.size(), _format_duration(player.get_run_duration_seconds())]
	content.add_child(summary)
	var divider := HSeparator.new()
	divider.custom_minimum_size.y = 8
	content.add_child(divider)
	var heading := Label.new()
	heading.text = "TOWER PERFORMANCE"
	heading.add_theme_font_size_override("font_size", 17)
	content.add_child(heading)
	var rankings: Array = player.get_tower_damage_ranking() if player != null else []
	if rankings.is_empty():
		var empty := Label.new()
		empty.text = "No tower damage was recorded."
		empty.add_theme_color_override("font_color", Color(0.6, 0.65, 0.73))
		content.add_child(empty)
	else:
		for index in range(rankings.size()):
			content.add_child(_ranking_row(index + 1, rankings[index]))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)
	var hint := Label.new()
	hint.text = "Press Escape to return to the menu"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color(0.58, 0.65, 0.75))
	content.add_child(hint)

func _ranking_row(rank: int, entry: Dictionary) -> Label:
	var row := Label.new()
	row.text = "%d.  %-24s  %6d damage   %3d kills" % [rank, entry.name, roundi(entry.damage), entry.kills]
	row.add_theme_font_size_override("font_size", 16)
	return row

func _format_duration(seconds: int) -> String:
	return "%d:%02d" % [seconds / 60, seconds % 60]

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.07, 0.11, 0.99)
	style.border_color = Color(0.72, 0.58, 0.25)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

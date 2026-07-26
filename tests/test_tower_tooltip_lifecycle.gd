extends SceneTree

const TOOLTIP_SCENE := preload("res://ui/TowerTooltip.tscn")
const TOWERS_DATA := preload("res://data/towers.gd")

var failures := PackedStringArray()


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var elemental_towers: Dictionary = TOWERS_DATA.get_towers("elemental")
	var ice_data: Dictionary = elemental_towers["ice"]
	var fire_data: Dictionary = elemental_towers["fire"]

	var tooltip = TOOLTIP_SCENE.instantiate()
	tooltip.setup("ice", ice_data)
	root.add_child(tooltip)
	await process_frame
	_assert_tooltip(tooltip, "Ice Tower", 8, 4, 6, "initial hover")

	var retained_row: Node = tooltip.get_node("VBoxContainer/CoreStats").get_child(0)
	tooltip.hide()
	await process_frame
	tooltip.setup("ice", ice_data)
	tooltip.show()
	_assert_tooltip(tooltip, "Ice Tower", 8, 4, 6, "same tower re-hover")
	if tooltip.get_node("VBoxContainer/CoreStats").get_child(0) != retained_row:
		failures.append("same tower re-hover rebuilt unchanged rows")

	var replaced_rows: Array[Node] = []
	for grid_path in ["CoreStats", "TraitsStats", "ProjectileStats"]:
		replaced_rows.append_array(
			tooltip.get_node("VBoxContainer/%s" % grid_path).get_children()
		)

	tooltip.hide()
	tooltip.setup("fire", fire_data)
	tooltip.show()
	_assert_tooltip(tooltip, "Fire Tower", 8, 4, 4, "different tower hover")
	for old_row in replaced_rows:
		if is_instance_valid(old_row):
			failures.append("different tower hover left an old row pending deletion")

	var button_scene = load("res://ui/TowerUIButton.tscn")
	var button = button_scene.instantiate()
	button.tower_id = "ice"
	button.tower_data = ice_data
	button.tower_hovered.connect(
		func(tower_id: String, tower_data: Dictionary) -> void:
			tooltip.setup(tower_id, tower_data)
			tooltip.show()
	)
	root.add_child(button)
	await process_frame

	for cycle in range(3):
		tooltip.hide()
		await process_frame
		button._on_texture_button_mouse_entered()
		_assert_tooltip(
			tooltip,
			"Ice Tower",
			8,
			4,
			6,
			"button re-hover %d" % cycle
		)
		await process_frame

	if failures.is_empty():
		print("TOWER_TOOLTIP_LIFECYCLE_TEST: PASS")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("TOWER_TOOLTIP_LIFECYCLE_TEST: FAIL (%d issues)" % failures.size())
	quit(1)


func _assert_tooltip(
	tooltip: Control,
	expected_name: String,
	expected_core_children: int,
	expected_traits_children: int,
	expected_projectile_children: int,
	context: String
) -> void:
	var name_label: Label = tooltip.get_node("VBoxContainer/Name")
	if !tooltip.visible:
		failures.append("%s: tooltip is hidden" % context)
	if name_label.text != expected_name:
		failures.append("%s: expected '%s', got '%s'" % [
			context,
			expected_name,
			name_label.text,
		])

	_assert_grid(
		tooltip.get_node("VBoxContainer/CoreStats"),
		expected_core_children,
		context
	)
	_assert_grid(
		tooltip.get_node("VBoxContainer/TraitsStats"),
		expected_traits_children,
		context
	)
	_assert_grid(
		tooltip.get_node("VBoxContainer/ProjectileStats"),
		expected_projectile_children,
		context
	)


func _assert_grid(grid: GridContainer, expected_children: int, context: String) -> void:
	if grid.get_child_count() != expected_children:
		failures.append("%s: %s has %d children, expected %d" % [
			context,
			grid.name,
			grid.get_child_count(),
			expected_children,
		])

	for index in range(grid.get_child_count()):
		var row_node := grid.get_child(index)
		if row_node.is_queued_for_deletion():
			failures.append("%s: %s contains a row queued for deletion" % [
				context,
				grid.name,
			])
		if index % 2 == 1 and row_node.text.is_empty():
			failures.append("%s: %s contains an empty stat value" % [
				context,
				grid.name,
			])

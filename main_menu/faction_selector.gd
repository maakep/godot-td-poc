extends Control

const SELECTION := preload("res://main_menu/faction_selection.tscn")
const LOCKED_COLOR := Color(0.95, 0.67, 0.34)
const REQUIRED_FACTIONS := 2

@onready var faction_container: FlowContainer = $MarginContainer/ScrollContainer/FlowContainer
@onready var detail_name: Label = $FactionDetails/MarginContainer/VBoxContainer/Name
@onready var detail_description: Label = $FactionDetails/MarginContainer/VBoxContainer/Description
@onready var detail_status: Label = $FactionDetails/MarginContainer/VBoxContainer/Status
@onready var selection_count: Label = $StartBar/SelectionCount
@onready var play_button: Button = $StartBar/Play

var selected_ids: Array[String] = []
var buttons: Dictionary = {}


func _ready() -> void:
	var first_button: TextureButton
	for faction_id in Factions.all:
		var btn: TextureButton = SELECTION.instantiate()
		var faction: Dictionary = Factions.get_faction(faction_id)
		var unlocked := FactionProgress.is_unlocked(faction_id)

		btn.texture_normal = faction.icon
		btn.tooltip_text = ""
		btn.focus_mode = Control.FOCUS_ALL
		if not unlocked:
			btn.self_modulate = Color(0.42, 0.42, 0.48)

		btn.mouse_entered.connect(_show_faction_details.bind(faction_id))
		btn.focus_entered.connect(_show_faction_details.bind(faction_id))
		btn.pressed.connect(_select_faction.bind(faction_id))
		faction_container.add_child(btn)
		buttons[faction_id] = btn

		if first_button == null:
			first_button = btn

	if first_button != null:
		first_button.grab_focus()
	_update_selection_ui()


func _show_faction_details(faction_id: String) -> void:
	var faction: Dictionary = Factions.get_faction(faction_id)
	var unlocked := FactionProgress.is_unlocked(faction_id)
	detail_name.text = faction.name
	detail_description.text = faction.description

	if unlocked:
		detail_status.text = ""
	else:
		var unlock: Dictionary = faction.get("unlock", {})
		detail_status.text = "Locked - %s" % unlock.get("description", "continue playing to unlock")
		detail_status.add_theme_color_override("font_color", LOCKED_COLOR)


func _select_faction(faction_id: String) -> void:
	if not FactionProgress.is_unlocked(faction_id):
		return
	if faction_id in selected_ids:
		selected_ids.erase(faction_id)
	elif selected_ids.size() < REQUIRED_FACTIONS:
		selected_ids.append(faction_id)
	else:
		selected_ids.pop_front()
		selected_ids.append(faction_id)
	_update_selection_ui()

func _update_selection_ui() -> void:
	selection_count.text = "%d / %d" % [selected_ids.size(), REQUIRED_FACTIONS]
	play_button.disabled = selected_ids.size() != REQUIRED_FACTIONS
	for faction_id in buttons:
		buttons[faction_id].get_node("Selection").visible = faction_id in selected_ids

func _on_play_pressed() -> void:
	if FactionProgress.select_factions(selected_ids):
		Levels.reset_run()
		FactionProgress.reset_run()
		get_tree().change_scene_to_file("res://game.tscn")

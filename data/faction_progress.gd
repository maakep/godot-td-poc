extends Node

signal faction_unlocked(faction_id: String)
signal faction_selected(faction_id: String)

const SAVE_PATH := "user://faction_progress.cfg"
var unlocked_factions: Dictionary = {"human": true}
var selected_faction_id := "human"
var towers_built_this_run := 0

func _ready() -> void:
	_load_progress()
	Events.tower_built.connect(_on_tower_built)

func is_unlocked(faction_id: String) -> bool:
	return unlocked_factions.get(faction_id, false)

func select_faction(faction_id: String) -> bool:
	if !is_unlocked(faction_id) or Factions.get_faction(faction_id).is_empty():
		return false
	selected_faction_id = faction_id
	faction_selected.emit(faction_id)
	return true

func reset_run() -> void:
	towers_built_this_run = 0

func _on_tower_built(_tower: Node2D, _cell: Vector2i) -> void:
	towers_built_this_run += 1
	for faction_id in Factions.all:
		if is_unlocked(faction_id):
			continue
		var requirement: Dictionary = Factions.get_faction(faction_id).get("unlock", {})
		if requirement.get("type") == "towers_built_in_run" and towers_built_this_run >= requirement.get("amount", 0):
			unlocked_factions[faction_id] = true
			_save_progress()
			faction_unlocked.emit(faction_id)

func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for faction_id in config.get_value("factions", "unlocked", []):
			unlocked_factions[faction_id] = true

func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("factions", "unlocked", unlocked_factions.keys())
	config.save(SAVE_PATH)

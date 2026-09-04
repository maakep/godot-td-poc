extends Node

signal faction_unlocked(faction_id: String)
signal faction_selected(faction_id: String)
signal factions_selected(faction_ids: Array[String])

const SAVE_PATH := "user://faction_progress.cfg"
var unlocked_factions: Dictionary = {"human": true, "goblin": true}
var selected_faction_ids: Array[String] = ["human", "goblin"]
var selected_faction_id: String:
	get:
		return selected_faction_ids[0] if not selected_faction_ids.is_empty() else "human"
var towers_built_this_run := 0

func _ready() -> void:
	_load_progress()
	_unlock_starter_factions()
	Events.tower_built.connect(_on_tower_built)

func is_unlocked(faction_id: String) -> bool:
	return unlocked_factions.get(faction_id, false)

func select_faction(faction_id: String) -> bool:
	if !is_unlocked(faction_id) or Factions.get_faction(faction_id).is_empty():
		return false
	selected_faction_ids = [faction_id]
	faction_selected.emit(faction_id)
	factions_selected.emit(selected_faction_ids.duplicate())
	return true

func select_factions(faction_ids: Array[String]) -> bool:
	if faction_ids.size() != 2 or faction_ids[0] == faction_ids[1]:
		return false
	for faction_id in faction_ids:
		if !is_unlocked(faction_id) or Factions.get_faction(faction_id).is_empty():
			return false
	selected_faction_ids = faction_ids.duplicate()
	faction_selected.emit(selected_faction_ids[0])
	factions_selected.emit(selected_faction_ids.duplicate())
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

func _unlock_starter_factions() -> void:
	for faction_id in Factions.all:
		if Factions.get_faction(faction_id).get("unlock", {}).get("type") == "starter":
			unlocked_factions[faction_id] = true

func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("factions", "unlocked", unlocked_factions.keys())
	config.save(SAVE_PATH)

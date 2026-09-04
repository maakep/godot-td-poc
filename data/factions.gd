class_name Factions

const HUMAN_FACTION := preload("res://data/factions/human.gd")
const ELEMENTAL_FACTION := preload("res://data/factions/elemental.gd")
const GOBLIN_FACTION := preload("res://data/factions/goblin.gd")

static var all := {
	"human": HUMAN_FACTION.data,
	"elemental": ELEMENTAL_FACTION.data,
	"goblin": GOBLIN_FACTION.data,
}

static func get_faction(id: String) -> Dictionary:
	return all.get(id, {})

static func get_active_faction() -> Dictionary:
	var active := get_active_factions()
	return active[0] if not active.is_empty() else get_faction("human")

static func get_active_factions() -> Array[Dictionary]:
	var active: Array[Dictionary] = []
	for faction_id in FactionProgress.selected_faction_ids:
		var faction := get_faction(faction_id)
		if not faction.is_empty():
			active.append(faction)
	return active

static func get_tower(id: String) -> Dictionary:
	for faction in get_active_factions():
		var tower: Dictionary = faction.get("towers", {}).get(id, {})
		if not tower.is_empty():
			return tower
	return {}

static func get_buyable_towers() -> Dictionary:
	var buyable := {}
	for faction in get_active_factions():
		for tower_id in faction.get("towers", {}):
			var tower: Dictionary = faction.towers[tower_id]
			if tower.get("buyable", false):
				buyable[tower_id] = tower
	return buyable

static func get_active_faction_names() -> Array[String]:
	var names: Array[String] = []
	for faction in get_active_factions():
		names.append(faction.name)
	return names

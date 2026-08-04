class_name Factions


static var all := {
	"human": HumanFaction.data,
	"elemental": ElementalFaction.data,
}

static func get_faction(id: String) -> Dictionary:
	return all.get(id, {})

static func get_active_faction() -> Dictionary:
	return get_faction(FactionProgress.selected_faction_id)

static func get_tower(id: String) -> Dictionary:
	return get_active_faction().get("towers", {}).get(id, {})

static func get_buyable_towers() -> Dictionary:
	var buyable := {}
	for tower_id in get_active_faction().get("towers", {}):
		var tower: Dictionary = get_tower(tower_id)
		if tower.get("buyable", false):
			buyable[tower_id] = tower
	return buyable

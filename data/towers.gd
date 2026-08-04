class_name Towers

## Compatibility facade for gameplay code. Tower data now belongs to Factions.
static func get_tower(id: String) -> Dictionary:
	return Factions.get_tower(id)

static func get_buyable_towers() -> Dictionary:
	return Factions.get_buyable_towers()

class_name Towers

## Compatibility facade for gameplay code. Tower data now belongs to Factions.
static func get_tower(id: String) -> Dictionary:
	return Factions.get_tower(id)

static func get_buyable_towers() -> Dictionary:
	return Factions.get_buyable_towers()

static func get_sell_price(tower: Dictionary) -> int:
	if tower.has("sell_value"):
		return maxi(int(tower.sell_value), 0)
	return floori(float(tower.get("cost", 0)) / 2.0)

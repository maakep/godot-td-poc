class_name Towers

static func get_faction(id: String) -> Dictionary:
	return factions.get(id, {})


static func get_towers(faction_id: String) -> Dictionary:
	var faction = get_faction(faction_id)
	return faction.get("towers", {})


static var factions = {
	"elemental": {
		"display_name": "Elemental",
		"description": "Elemental towers use fire, frost, and poison.",
		"towers": {
			"ice": {
				"display_name": "Ice Tower",
				"description": "Slows enemies caught in its frosty blast.",
				"atkspd": 1,
				"range": 50,
				"sprite": preload("res://buildings/tower_sprites/tower_ice.png"),
				"targets": 1,
				"cost": 2,
				"buyable": true,
				"proj": {
					"damage": 1,
					"range": 50,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/ice.png"),
					"aoe": 30,
					"piercing": 0,
					"effects": [slow(0.3, 1, true)]
				},
				"upgrades": []
			},
			"poison": {
				"display_name": "Poison Tower",
				"description": "Poisons enemies in a small area over time.",
				"atkspd": 1,
				"range": 50,
				"sprite": preload("res://buildings/tower_sprites/tower_poison.png"),
				"targets": 1,
				"cost": 2,
				"buyable": true,
				"proj": {
					"damage": 1,
					"range": 50,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/purple.png"),
					"aoe": 30,
					"piercing": 0,
					"effects": [poison(0.5, 40, 1)]
				},
				"upgrades": []
			},
			"fire": {
				"display_name": "Fire Tower",
				"description": "Ignites several enemies with each attack.",
				"atkspd": 2,
				"range": 200,
				"sprite": preload("res://buildings/projectile_sprites/orange.png"),
				"targets": 3,
				"cost": 2,
				"buyable": true,
				"proj": {
					"damage": 10,
					"range": 50,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/orange.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": [burn(10, 10)]
				},
				"upgrades": []
			}
		}
	},
	"goblin": {
		"display_name": "Goblin",
		"description": "Goblin towers favor arrows, brawlers, and explosives.",
		"towers": {
			"arrow": {
				"display_name": "Arrow Tower",
				"description": "A reliable long-range single-target tower.",
				"atkspd": 1,
				"range": 200,
				"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"),
				"targets": 1,
				"cost": 1,
				"buyable": true,
				"proj": {
					"damage": 5,
					"range": 2,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/pink.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": []
				},
				"upgrades": ["arrow 2"]
			},
			"arrow 2": {
				"display_name": "Arrow Tower II",
				"description": "An upgraded tower that attacks two targets.",
				"atkspd": 1,
				"range": 200,
				"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"),
				"targets": 2,
				"cost": 1,
				"buyable": false,
				"proj": {
					"damage": 10,
					"range": 5,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/proj.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": []
				},
				"upgrades": ["arrow 3"]
			},
			"arrow 3": {
				"display_name": "Arrow Tower III",
				"description": "An upgraded tower that attacks four targets.",
				"atkspd": 1,
				"range": 200,
				"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"),
				"targets": 4,
				"cost": 1,
				"buyable": false,
				"proj": {
					"damage": 15,
					"range": 5,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/proj.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": []
				},
				"upgrades": []
			},
			"melee": {
				"display_name": "Brawler",
				"description": "Rapidly attacks enemies that come close.",
				"atkspd": 0.2,
				"range": 45,
				"sprite": preload("res://buildings/projectile_sprites/bryellow.png"),
				"targets": 10,
				"cost": 1,
				"buyable": true,
				"proj": {
					"damage": 5,
					"range": 5,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/bryellow.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": []
				},
				"upgrades": []
			},
			"melee stun": {
				"display_name": "Stunner",
				"description": "Periodically locks down nearby enemies.",
				"atkspd": 4,
				"range": 45,
				"sprite": preload("res://buildings/projectile_sprites/bryellow.png"),
				"targets": 10,
				"cost": 1,
				"buyable": true,
				"proj": {
					"damage": 5,
					"range": 5,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/bryellow.png"),
					"aoe": 0,
					"piercing": 0,
					"effects": [slow(1, 1)]
				},
				"upgrades": []
			},
			"cannon": {
				"display_name": "Cannon",
				"description": "Fires slow explosive shots that deal area damage.",
				"atkspd": 2,
				"range": 200,
				"sprite": preload("res://buildings/projectile_sprites/brown.png"),
				"targets": 1,
				"cost": 3,
				"buyable": true,
				"proj": {
					"damage": 10,
					"range": 50,
					"speed": 500,
					"sprite": preload("res://buildings/projectile_sprites/brown.png"),
					"aoe": 100,
					"piercing": 0,
					"effects": []
				},
				"upgrades": []
			}
		}
	}
}


static func burn(dmg, dur, stacking = false, id = ""):
	return {"handler": "burn", "name": "burn" + id, "stacking": stacking, "dmg": dmg, "dur": dur, "tick_rate": 1}


static func slow(val, dur, stacking = false, id = ""):
	return {"handler": "slow", "name": "slow" + id, "stacking": stacking, "val": val, "dur": dur}


static func poison(val, dmg, dur, stacking = false, id = ""):
	return {"handler": "poison", "name": "poison" + id, "stacking": stacking, "val": val, "dmg": dmg, "dur": dur, "tick_rate": 1}

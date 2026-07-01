class_name Towers

static func get_tower(id): 
	return all.get(id)

static var all = {
	"arrow": {
		"atkspd": 1,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 1,
		"cost": 1,
		"proj": {
			"damage": 5,
			"range": 5,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/proj.png"),
			"aoe": 0,
			"piercing": 0,
			"effects": []
		},
		"upgrades": ["arrow 2"]
	},
	"arrow 2": {
		"atkspd": 1,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 2,
		"cost": 1,
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
		"atkspd": 1,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 4,
		"cost": 1,
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
		"atkspd": 0.2,
		"range": 45,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 10,
		"cost": 1,
		"proj": {
			"damage": 5,
			"range": 5,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/proj.png"),
			"aoe": 0,
			"piercing": 0,
			"effects": []
		},
		"upgrades": []
	},
	"ice": {
		"atkspd": 1,
		"range": 50,
		"sprite": preload("res://buildings/projectile_sprites/ice.png"),
		"targets": 1,
		"cost": 2,
		"proj": {
			"damage": 1,
			"range": 50,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/ice.png"),
			"aoe": 30,
			"piercing": 0,
			"effects": [ slow(0.3, 1) ]
		},
		"upgrades": []
	},
	"poison": {
		"atkspd": 1,
		"range": 50,
		"sprite": preload("res://buildings/projectile_sprites/ice.png"),
		"targets": 1,
		"cost": 2,
		"proj": {
			"damage": 1,
			"range": 50,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/ice.png"),
			"aoe": 30,
			"piercing": 0,
			"effects": [ poison(0.5, 40, 1) ]
		},
		"upgrades": []
	},
	"fire": {
		"atkspd": 2,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 3,
		"cost": 2,
		"proj": {
			"damage": 10,
			"range": 50,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/proj.png"),
			"aoe": 0,
			"piercing": 0,
			"effects": [ burn(10, 10) ]
		},
		"upgrades": []
	}, 
	"cannon": {
		"atkspd": 2,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/greenp.png"),
		"targets": 1,
		"cost": 3,
		"proj": {
			"damage": 10,
			"range": 50,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/greenp.png"),
			"aoe": 100,
			"piercing": 0,
			"effects": []
		},
		"upgrades": []
	}
}


static func burn(dmg, dur, id = ""):
	return { "name": "burn" + id, "dmg": dmg, "dur": dur, "tick_rate": 1 }
static func slow(val, dur, id = ""):
	return { "name": "slow" + id, "val": val, "dur": dur}
static func poison(val, dmg, dur, id = ""):
	return { "name": "poison" + id, "val": val, "dmg": dmg, "dur": dur, "tick_rate": 1}
	

class_name Towers

static func get_tower(id): 
	return all.get(id)

static var all = {
	"arrow": {
		"atkspd": 0.5,
		"range": 200,
		"sprite": preload("res://buildings/projectile_sprites/proj.png"),
		"targets": 1,
		"cost": 1,
		"proj": {
			"damage": 10,
			"range": 100,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/proj.png"),
			"aoe": 0,
			"effects": []
		},
		"upgrades": ["ice"]
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
			"aoe": 100,
			"effects": [ { "name": "slow", "val": 0.3, "dur": 2 } ]
		},
		"upgrades": ["cannon"]
	},
	"cannon": {
		"atkspd": 3,
		"range": 400,
		"sprite": preload("res://buildings/projectile_sprites/greenp.png"),
		"targets": 1,
		"cost": 5,
		"proj": {
			"damage": 250,
			"range": 50,
			"speed": 500,
			"sprite": preload("res://buildings/projectile_sprites/greenp.png"),
			"aoe": 100,
			"effects": []
		},
		"upgrades": []
	}
}

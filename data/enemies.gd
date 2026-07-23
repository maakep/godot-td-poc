class_name Enemies

static var all = {
	"Goblin": {
		"ms": 120,
		"hp": 150,
		"sprite": preload("res://icon.svg"),
		"resist": ["burn"],
		"flying": false,
		"attributes": [],
	},
	"Bee": {
		"ms": 100,
		"hp": 30,
		"sprite": preload("res://buildings/projectile_sprites/orange.png"),
		"resist": ["burn"],
		"attributes": ["flying"],
	},
	"Goblin Tank": {
		"ms": 90,
		"hp": 2000,
		"sprite": preload("res://icon.svg"),
		"resist": ["burn"],
		"attributes": [],
	},
	"Kobold": {
		"ms": 400,
		"hp": 70,
		"sprite": preload("res://green.png"),
		"resist": [],
		"attributes": [],
	},
	"Goblin King": {
		"ms": 120,
		"hp": 350,
		"sprite": preload("res://icon.svg"),
		"resist": ["slow"],
		"attributes": [],
	},
	"Goblin Queen": {
		"ms": 160,
		"hp": 1500,
		"sprite": preload("res://red.png"),
		"resist": ["poison", "slow"],
		"attributes": [],
	}
}

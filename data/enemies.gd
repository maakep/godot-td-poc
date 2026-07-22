class_name Enemies

static var all = {
	"Goblin": {
		"ms": 120,
		"hp": 150,
		"sprite": preload("res://icon.svg"),
		"resist": ["burn"],
	},
	"Goblin Tank": {
		"ms": 90,
		"hp": 2000,
		"sprite": preload("res://icon.svg"),
		"resist": ["burn"],
	},
	"Kobold": {
		"ms": 400,
		"hp": 70,
		"sprite": preload("res://green.png"),
		"resist": [],
	},
	"Goblin King": {
		"ms": 120,
		"hp": 350,
		"sprite": preload("res://icon.svg"),
		"resist": ["slow"],
	},
	"Goblin Queen": {
		"ms": 160,
		"hp": 1500,
		"sprite": preload("res://red.png"),
		"resist": ["poison", "slow"]
	}
}

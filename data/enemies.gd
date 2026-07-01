class_name Enemies

static var all = {
	"Goblin": {
		"ms": 2,
		"hp": 250,
		"sprite": preload("res://icon.svg"),
		"resist": [],
	},
	"Kobold": {
		"ms": 5,
		"hp": 70,
		"sprite": preload("res://green.png"),
		"resist": [],
	},
	"Goblin King": {
		"ms": 2,
		"hp": 350,
		"sprite": preload("res://icon.svg"),
		"resist": ["slow"],
	},
	"Goblin Queen": {
		"ms": 1.2,
		"hp": 1500,
		"sprite": preload("res://red.png"),
		"resist": ["poison", "slow"]
	}
}

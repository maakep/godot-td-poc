class_name Enemies

static var all = {
	"Goblin": {
		"ms": 4,
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
	}
}

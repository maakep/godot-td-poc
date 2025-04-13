extends Node
class_name Levels

var ref = Enemies

static var all = [
	{
		"unit": "Goblin",
		"amount": 5,
		"bounty": 10,
	},
	{
		"unit": "Kobold",
		"amount": 2,
		"bounty": 11,
	},
	{
		"unit": "Goblin King",
		"amount": 1,
		"bounty": 40,
	},
	{
		"unit": "Goblin",
		"amount": 100,
		"bounty": 13,
	},
	{
		"unit": "Goblin",
		"amount": 999,
		"bounty": 14,
	}
]

static var waypoints = [Vector2i(96, 96)]

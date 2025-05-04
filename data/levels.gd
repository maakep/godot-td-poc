extends Node
class_name Levels

var ref = Enemies

static var all = [
	{
		"unit": "Goblin",
		"amount": 2,
		"bounty": 10,
		"spawnInterval": 0.3,
	},
	{
		"unit": "Kobold",
		"amount": 2,
		"bounty": 11,
		"spawnInterval": 0.3,
		
	},
	{
		"unit": "Goblin King",
		"amount": 100,
		"bounty": 5,
		"spawnInterval": 0.3,
		
	},
	{
		"unit": "Goblin",
		"amount": 100,
		"bounty": 13,
		"spawnInterval": 0.3,
		
	},
	{
		"unit": "Goblin",
		"amount": 999,
		"bounty": 14,
		"spawnInterval": 0.3,
		
	}
]

static var waypoints = [Vector2i(96, 96)]

extends Node
class_name Levels

var ref = Enemies
	

static var all = [
	wave("Goblin", 20, 10),
	wave("Goblin King", 1, 1),
	{
		"unit": "Goblin",
		"amount": 2,
		"bounty": 10,
		"spawnInterval": 0.3,
	},
	{
		"unit": "Goblin",
		"amount": 5,
		"bounty": 11,
		"spawnInterval": 0.3,
		
	},
	{
		"unit": "Kobold",
		"amount": 10,
		"bounty": 5,
		"spawnInterval": 0.3,
		
	},
	{
		"unit": "Goblin King",
		"amount": 3,
		"bounty": 13,
		"spawnInterval": 2,
		
	},
	{
		"unit": "Goblin",
		"amount": 999,
		"bounty": 14,
		"spawnInterval": 0.3,
	}
]

static var waypoints = [Vector2i(96, 96)]

static func wave(enemyName, amount, bounty, interval = 0.3):
	return {
		"unit": enemyName,
		"amount": amount,
		"bounty": bounty,
		"spawnInterval": interval,
	}

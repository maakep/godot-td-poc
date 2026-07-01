extends Node
class_name Levels

var ref = Enemies
	

static var all = [
	wave("Goblin", 20, 10, 0.5),
	wave("Kobold", 20, 10),
	wave("Goblin King", 1, 1),
	wave("Goblin Queen", 1, 100),
	wave("Goblin", 999, 10, 0.1)
]

static var waypoints = [Vector2i(96, 96)]

static func wave(enemyName, amount, bounty, interval = 0.3):
	return {
		"unit": enemyName,
		"amount": amount,
		"bounty": bounty,
		"spawnInterval": interval,
	}

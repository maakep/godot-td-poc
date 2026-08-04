class_name HumanFaction

static var data := {
	"id": "human",
	"name": "Kingdom of Ardent",
	"description": "Disciplined defenders using reliable martial towers and artillery.",
	"icon": preload("res://green.png"),
	"unlock": {"type": "starter"},
	"towers": {
		"arrow": {
			"name": "Arrow Tower", "description": "A dependable long-range tower that fires at one enemy at a time.", "atkspd": 1, "range": 200,
			"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"), "targets": 1, "cost": 1, "buyable": true,
			"proj": {"damage": 5, "range": 2, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/pink.png"), "aoe": 0, "piercing": 0, "effects": []}, "upgrades": ["arrow 2"]
		},
		"arrow 2": {
			"name": "Arrow Tower II", "description": "A long-range split-shot tower that fires at two enemies at once.", "atkspd": 1, "range": 200,
			"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"), "targets": 2, "cost": 1, "buyable": false,
			"proj": {"damage": 10, "range": 5, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/proj.png"), "aoe": 0, "piercing": 0, "effects": []}, "upgrades": ["arrow 3"]
		},
		"arrow 3": {
			"name": "Arrow Tower III", "description": "A long-range volley tower that fires at four enemies at once.", "atkspd": 1, "range": 200,
			"sprite": preload("res://buildings/tower_sprites/tower_arrow.png"), "targets": 4, "cost": 1, "buyable": false,
			"proj": {"damage": 15, "range": 5, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/proj.png"), "aoe": 0, "piercing": 0, "effects": []}, "upgrades": []
		},
		"melee": {
			"name": "Guard Tower", "description": "A close-range guard that attacks up to ten nearby enemies.", "atkspd": 0.2, "range": 45,
			"sprite": preload("res://buildings/projectile_sprites/bryellow.png"), "targets": 10, "cost": 1, "buyable": true,
			"proj": {"damage": 5, "range": 5, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/bryellow.png"), "aoe": 0, "piercing": 0, "effects": []}, "upgrades": []
		},
		"cannon": {
			"name": "Cannon Tower", "description": "Fires powerful long-range shells that damage enemies in a large area.", "atkspd": 2, "range": 200,
			"sprite": preload("res://buildings/projectile_sprites/brown.png"), "targets": 1, "cost": 3, "buyable": true,
			"proj": {"damage": 10, "range": 50, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/brown.png"), "aoe": 100, "piercing": 0, "effects": []}, "upgrades": []
		}
	}
}

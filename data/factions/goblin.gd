class_name GoblinFaction

const OIL := preload("res://effects/applications/goblin_oil.tres")
const FIRE := preload("res://effects/applications/goblin_burn.tres")

static var data := {
	"id": "goblin",
	"name": "Mucktooth Mob",
	"description": "Crude area weapons coat crowds in oil, then turn the whole mess into fire.",
	"icon": preload("res://data/factions/goblin_icon.svg"),
	"unlock": {"type": "starter"},
	"towers": {
		"goblin_tar": {
			"name": "Tar Lobber", "description": "Splashes stacking oil over a crowd. Oil slows and amplifies the next fire hit.", "atkspd": 1.5, "range": 150,
			"sprite": preload("res://buildings/tower_sprites/goblin_tar.svg"), "targets": 1, "cost": 2, "buyable": true,
			"proj": {"damage": 2, "range": 3, "speed": 340, "sprite": preload("res://buildings/projectile_sprites/brown.png"), "aoe": 50, "piercing": 0, "effects": [OIL]}, "upgrades": []
		},
		"goblin_firepot": {
			"name": "Firepot", "description": "Hurls burning pots. Fire ignites oil into a stronger blaze that spreads nearby.", "atkspd": 1.8, "range": 145,
			"sprite": preload("res://buildings/tower_sprites/goblin_firepot.svg"), "targets": 1, "cost": 3, "buyable": true,
			"proj": {"damage": 5, "range": 3, "speed": 380, "sprite": preload("res://buildings/projectile_sprites/orange.png"), "aoe": 45, "piercing": 0, "effects": [FIRE]}, "upgrades": []
		},
		"goblin_scrap_cannon": {
			"name": "Scrap Mortar", "description": "Slow, ugly, and effective against tightly packed enemies.", "atkspd": 2.6, "range": 175,
			"sprite": preload("res://buildings/tower_sprites/goblin_scrap_cannon.svg"), "targets": 1, "cost": 4, "buyable": true,
			"proj": {"damage": 24, "range": 4, "speed": 300, "sprite": preload("res://buildings/projectile_sprites/bryellow.png"), "aoe": 75, "piercing": 0, "effects": []}, "upgrades": []
		},
		"goblin_powder_keg": {
			"name": "Powder Keg", "description": "A huge, infrequent fire blast built to trigger several reactions at once.", "atkspd": 4.0, "range": 125,
			"sprite": preload("res://buildings/tower_sprites/goblin_powder_keg.svg"), "targets": 1, "cost": 6, "buyable": true,
			"proj": {"damage": 42, "range": 3, "speed": 260, "sprite": preload("res://buildings/projectile_sprites/orange.png"), "aoe": 100, "piercing": 0, "effects": [FIRE]}, "upgrades": []
		},
		"goblin_scraps": {
			"name": "Scrap Heap", "description": "Bent metal and bad ideas, piled high enough to redirect enemies.", "behavior": "blocker", "range": 0,
			"sprite": preload("res://buildings/tower_sprites/scraps.svg"), "cost": 1, "sell_value": 0, "buyable": true, "upgrades": []
		}
	}
}

class_name ElementalFaction

const FROST_GUARD_FREEZE := preload("res://effects/applications/frost_guard_freeze.tres")
const ICE_CHILL := preload("res://effects/applications/ice_chill.tres")
const POISON := preload("res://effects/applications/poison.tres")
const BURN := preload("res://effects/applications/burn.tres")

static var data := {
	"id": "elemental",
	"name": "Elemental Conclave",
	"description": "Spell towers that control the battlefield with frost, venom, and flame.",
	"icon": preload("res://red.png"),
	"unlock": {"type": "towers_built_in_run", "amount": 5, "description": "Build 5 towers in one run"},
	"towers": {
		"frost_guard": {
			"name": "Frost Guard", "description": "A close-range guardian whose attacks heavily slow nearby enemies.", "atkspd": 4, "range": 45,
			"sprite": preload("res://buildings/projectile_sprites/bryellow.png"), "targets": 10, "cost": 1, "buyable": true,
			"proj": {"damage": 5, "range": 5, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/bryellow.png"), "aoe": 0, "piercing": 0, "effects": [FROST_GUARD_FREEZE]}, "upgrades": []
		},
		"ice": {
			"name": "Ice Tower", "description": "Launches small area blasts that slow enemies caught in the frost.", "atkspd": 1, "range": 50,
			"sprite": preload("res://buildings/tower_sprites/tower_ice.png"), "targets": 1, "cost": 2, "buyable": true,
			"proj": {"damage": 1, "range": 50, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/ice.png"), "aoe": 30, "piercing": 0, "effects": [ICE_CHILL]}, "upgrades": []
		},
		"poison": {
			"name": "Poison Tower", "description": "Launches area blasts that poison enemies, slowing them and dealing damage over time.", "atkspd": 1, "range": 50,
			"sprite": preload("res://buildings/tower_sprites/tower_poison.png"), "targets": 1, "cost": 2, "buyable": true,
			"proj": {"damage": 1, "range": 50, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/purple.png"), "aoe": 30, "piercing": 0, "effects": [POISON]}, "upgrades": []
		},
		"fire": {
			"name": "Fire Tower", "description": "A long-range tower that ignites up to three enemies, dealing burn damage over time.", "atkspd": 2, "range": 200,
			"sprite": preload("res://buildings/projectile_sprites/orange.png"), "targets": 3, "cost": 2, "buyable": true,
			"proj": {"damage": 10, "range": 50, "speed": 500, "sprite": preload("res://buildings/projectile_sprites/orange.png"), "aoe": 0, "piercing": 0, "effects": [BURN]}, "upgrades": []
		}
	}
}

extends Control

@onready var margin_container = $MarginContainer/ScrollContainer/FlowContainer
var selection = preload("res://main_menu/faction_selection.tscn")

var factions = Factions.all

func _ready():
	for fac in factions:
		var btn: TextureButton = selection.instantiate()
		var lbl: Label = btn.get_node("Label")
		
		var faction = factions[fac]
		btn.texture_normal = faction.icon
		lbl.text = faction.name
		
		btn.pressed.connect(
			func(): 
				FactionProgress.select_faction(fac)
				get_tree().change_scene_to_file("res://game.tscn")
		)

		margin_container.add_child(btn)

extends HFlowContainer

var button = preload("res://ui/TowerUIButton.tscn")

func _ready():
	for faction_id in Towers.factions.keys():
		var faction = Towers.get_faction(faction_id)
		add_faction_label(faction)

		for tower_id in faction.towers.keys():
			var tower = faction.towers[tower_id]
			if !tower.buyable:
				continue

			var b: Control = button.instantiate()
			b.faction = faction
			b.faction_id = faction_id
			b.tower = tower
			b.tower_id = tower_id
			add_child(b)


func add_faction_label(faction):
	var label = Label.new()
	label.text = faction.display_name
	label.tooltip_text = faction.description
	label.custom_minimum_size = Vector2(80, 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)

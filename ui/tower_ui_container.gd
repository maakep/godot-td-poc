extends HFlowContainer

const TowerButtonScene = preload("res://ui/TowerUIButton.tscn")

func load_towers(towers: Dictionary) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for tower_id in towers.keys():
		var tower = towers[tower_id]
		if !tower.buyable:
			continue

		var button = TowerButtonScene.instantiate()
		button.tower_data = tower
		button.tower_id = tower_id
		add_child(button)

extends HFlowContainer

const TowerButtonScene = preload("res://ui/TowerUIButton.tscn")

@onready var tower_tooltip = %TowerTooltip

var hovered_tower_id: String = ""


func load_towers(towers: Dictionary) -> void:
	_hide_tower_tooltip()

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
		button.tower_hovered.connect(_show_tower_tooltip)
		button.tower_unhovered.connect(_on_tower_unhovered)
		add_child(button)


func _show_tower_tooltip(tower_id: String, tower_data: Dictionary) -> void:
	hovered_tower_id = tower_id
	tower_tooltip.setup(tower_id, tower_data)
	tower_tooltip.show()


func _on_tower_unhovered(tower_id: String) -> void:
	if hovered_tower_id != tower_id:
		return

	_hide_tower_tooltip()


func _hide_tower_tooltip() -> void:
	hovered_tower_id = ""

	if is_instance_valid(tower_tooltip):
		tower_tooltip.hide()

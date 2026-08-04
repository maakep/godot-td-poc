extends HFlowContainer

var button = preload("res://ui/TowerUIButton.tscn")

func _ready():
	FactionProgress.faction_selected.connect(_rebuild)

func _rebuild(_faction_id := "") -> void:
	for child in get_children():
		child.queue_free()
	var towers = Towers.get_buyable_towers()
	for tower_id in towers:
		var t = towers[tower_id]
		var b = button.instantiate()
		b.setup(t, tower_id, t.cost)
		b.activated.connect(func(id): Events.on_tower_ui_clicked.emit(id))
		add_child(b)

extends HFlowContainer

var button = preload("res://ui/TowerUIButton.tscn")

func _ready():
	var towers = Towers.all
	
	for tower_id in towers.keys():
		var t = towers[tower_id]
		if !t.buyable:
			continue
			
		var b = button.instantiate()
		b.setup(t, tower_id, t.cost)
		b.activated.connect(func(id): Events.on_tower_ui_clicked.emit(id))
		add_child(b)

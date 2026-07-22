extends HFlowContainer

var button = preload("res://ui/TowerUIButton.tscn")

func _ready():
	var towers = Towers.all
	
	for tower_id in towers.keys():
		var t = towers[tower_id]
		if !t.buyable:
			continue
			
		var b: Control = button.instantiate()
		b.tower = t
		b.tower_id = tower_id
		add_child(b)

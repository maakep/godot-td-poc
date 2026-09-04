extends HFlowContainer

var button = preload("res://ui/TowerUIButton.tscn")
var available_gold := 0
var buttons_by_id: Dictionary = {}

func _ready():
	FactionProgress.factions_selected.connect(rebuild)
	Events.on_gold_change.connect(_on_gold_changed)
	var player := get_tree().current_scene.get_node_or_null("Player")
	if player != null:
		available_gold = player.gold
	rebuild()

func rebuild(_faction_ids: Array[String] = []) -> void:
	for child in get_children():
		child.queue_free()
	buttons_by_id.clear()
	var towers = Towers.get_buyable_towers()
	for tower_id in towers:
		var t = towers[tower_id]
		var b = button.instantiate()
		b.setup(t, tower_id, t.cost, available_gold >= t.cost)
		b.activated.connect(func(id): Events.on_tower_ui_clicked.emit(id))
		add_child(b)
		buttons_by_id[tower_id] = b

func _on_gold_changed(gold: int) -> void:
	available_gold = gold
	for tower_id in buttons_by_id:
		var tower := Towers.get_tower(tower_id)
		buttons_by_id[tower_id].set_choice_enabled(gold >= tower.get("cost", 0))

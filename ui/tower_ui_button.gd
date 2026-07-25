extends Control

var tower_data: Dictionary = {}
var tower_id: String = ""

func _ready() -> void:
	$TextureButton.configure(tower_id, tower_data)
	$CostLabel.text = "%s G" % tower_data.cost

func _on_pressed() -> void:
	Events.on_tower_ui_clicked.emit(tower_id)

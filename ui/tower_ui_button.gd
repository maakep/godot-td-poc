extends Control

signal tower_hovered(tower_id: String, tower_data: Dictionary)

var tower_data: Dictionary = {}
var tower_id: String = ""

func _ready() -> void:
	$TextureButton.texture_normal = tower_data.sprite
	$CostBadge/Cost.text = str(tower_data.cost)

func _on_pressed() -> void:
	Events.on_tower_ui_clicked.emit(tower_id)


func _on_texture_button_mouse_entered() -> void:
	tower_hovered.emit(tower_id, tower_data)

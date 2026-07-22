extends Control

var tower
var tower_id

func _ready():
	$TextureButton.texture_normal = tower.sprite

func _on_pressed():
	Events.on_tower_ui_clicked.emit(tower_id)

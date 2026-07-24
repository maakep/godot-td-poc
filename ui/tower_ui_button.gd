extends Control

var faction
var faction_id
var tower
var tower_id

func _ready():
	$TextureButton.texture_normal = tower.sprite
	$TextureButton.tooltip_text = "%s: %s" % [faction.display_name, tower_id.capitalize()]

func _on_pressed():
	Events.on_tower_ui_clicked.emit(faction_id, tower_id)

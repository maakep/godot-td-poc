extends TextureButton

const TowerTooltipScene = preload("res://ui/TowerTooltip.tscn")

var tower_id := ""
var tower_data: Dictionary = {}


func configure(new_tower_id: String, new_tower_data: Dictionary) -> void:
	tower_id = new_tower_id
	tower_data = new_tower_data
	texture_normal = tower_data.sprite
	tooltip_text = tower_data.get("display_name", tower_id.capitalize())


func _make_custom_tooltip(_for_text: String) -> Object:
	if tower_data.is_empty():
		return null

	var tooltip = TowerTooltipScene.instantiate()
	tooltip.setup(tower_id, tower_data)
	return tooltip

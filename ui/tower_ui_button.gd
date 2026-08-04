extends Control

signal activated(tower_id: String)

var tower
var tower_id: String
var display_cost := 0
var choice_enabled := true

func _ready():
	refresh()

func setup(data: Dictionary, id: String, cost: int = -1, enabled := true) -> void:
	tower = data
	tower_id = id
	display_cost = data.cost if cost < 0 else cost
	choice_enabled = enabled
	if is_node_ready():
		refresh()

func refresh() -> void:
	if tower == null:
		return
	$TextureButton.texture_normal = tower.sprite
	$TextureButton.tooltip_text = "%s\n\n%s\n\nCost: %d gold" % [tower.name, tower.description, display_cost]
	$TextureButton.disabled = !choice_enabled
	$CostBadge.text = str(display_cost)
	modulate = Color(1, 1, 1, 1) if choice_enabled else Color(0.55, 0.55, 0.55, 1)

func _on_pressed():
	activated.emit(tower_id)

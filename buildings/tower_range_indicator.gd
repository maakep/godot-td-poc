extends Node2D

const VALID_FILL := Color(0.2, 0.85, 0.45, 0.16)
const VALID_OUTLINE := Color(0.35, 1.0, 0.55, 0.9)
const INVALID_FILL := Color(1.0, 0.2, 0.2, 0.14)
const INVALID_OUTLINE := Color(1.0, 0.35, 0.35, 0.9)

var tower_range := 0.0
var placement_valid := true


func set_tower_range(value: float) -> void:
	tower_range = value
	queue_redraw()


func set_placement_valid(value: bool) -> void:
	if placement_valid == value:
		return

	placement_valid = value
	queue_redraw()


func _draw() -> void:
	if tower_range <= 0.0:
		return

	var fill_color := VALID_FILL if placement_valid else INVALID_FILL
	var outline_color := VALID_OUTLINE if placement_valid else INVALID_OUTLINE
	draw_circle(Vector2.ZERO, tower_range, fill_color)
	draw_arc(Vector2.ZERO, tower_range, 0.0, TAU, 96, outline_color, 3.0, true)

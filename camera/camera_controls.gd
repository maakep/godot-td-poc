extends Camera2D

var dragging := false
var last_mouse_position := Vector2.ZERO

# Zoom settings
var zoom_speed := 0.01
var min_zoom := 0.2
var max_zoom := 1.5

func _input(event):
	if event is InputEventMouseButton:
		# Handle camera dragging movement
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed  # Start or stop dragging
			last_mouse_position = event.position
			
		# Handle zooming with scroll wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = (zoom - Vector2(zoom_speed, zoom_speed)).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = (zoom + Vector2(zoom_speed, zoom_speed)).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_position
		position -= delta / zoom  # Adjust movement based on zoom level
		last_mouse_position = event.position

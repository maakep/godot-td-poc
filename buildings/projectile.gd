extends Area2D

var damage: float = 1
var piercing: int = 0

var speed = 500
var range = 4

var direction


var travelled = 0

func _physics_process(delta):
	travelled += delta
	if travelled > range:
		queue_free()
		
	global_position += direction * speed * delta

func _on_area_entered(area):		
	if !area.is_in_group("enemy"):
		return
	
	area.take_damage(damage)
	
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1
	
	

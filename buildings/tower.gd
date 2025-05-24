extends Node2D

@export var attack_radius: float = 100.0
@export var attack_speed: float = 1

var enemies_in_range: Array = []
@onready var area = $AttackArea2D
@onready var col = $AttackArea2D/CollisionShape2D
@onready var attack_timer = $AttackTimer

var cell
var tilemap

var proj = preload("res://buildings/projectile.tscn")

func _ready():
	col.shape.radius = attack_radius
	attack_timer.wait_time = attack_speed
	
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self,"_on_area_exited"))

func attack():
	if !attack_timer.is_stopped():
		return
		
	var enemy = get_closest_enemy()
	if !enemy:
		return
	
	
	var p = proj.instantiate()
	p.direction = global_position.direction_to(enemy.global_position)
	p.damage = 5
	call_deferred("add_child", p)
	
	attack_timer.start()
	await attack_timer.timeout
	attack()
	

var attacking = false

func _on_area_entered(obj):
	if obj.is_in_group("enemy"):
		enemies_in_range.append(obj)
		attack()

func _on_area_exited(obj):
	if obj in enemies_in_range:
		enemies_in_range.erase(obj)

func get_closest_enemy():
	if enemies_in_range.is_empty():
		return null
	return enemies_in_range[0]  
	
func take_damage(dmg):
	#tilemap.set_cell(cell, 1, Vector2i(1, 0))
	#Events.on_obstacles_removed.emit(self)
	#queue_free()
	pass

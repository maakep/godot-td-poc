extends Node2D

var attack_targets: int = 1

var enemies_in_range: Array = []
@onready var area = $AttackArea2D
@onready var col = $AttackArea2D/CollisionShape2D
@onready var attack_timer = $AttackTimer

var cell
var tilemap

var starting_tower = "fire"
var tower = Towers.get_tower(starting_tower)

var proj = preload("res://buildings/projectile.tscn")

func _ready():
	load_tower(starting_tower)
	
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self,"_on_area_exited"))

func load_tower(id):
	var tower = Towers.get_tower(id)
	col.shape.radius = tower.range
	attack_timer.wait_time = tower.atkspd
	attack_targets = tower.targets
	$Sprite2D.texture = tower.sprite
	self.tower = tower


var attacking = false

func attack():
	if !attack_timer.is_stopped():
		return
	
	
	var enemies = get_closest_enemies(attack_targets)
	if enemies.size() == 0:
		return
	
	for i in range(enemies.size()):
		var p = proj.instantiate()
		p.direction = global_position.direction_to(enemies[i].global_position)
		p.load_projectile(tower.proj)
		call_deferred("add_child", p)
	
	attack_timer.start()
	await attack_timer.timeout
	attack()
	

func _on_area_entered(obj):
	if obj.is_in_group("enemy"):
		enemies_in_range.append(obj)
		attack()

func _on_area_exited(obj):
	if obj in enemies_in_range:
		enemies_in_range.erase(obj)

func get_closest_enemies(n = 1):
	if enemies_in_range.is_empty():
		return []
		
	return enemies_in_range.slice(0, n)
	
func take_damage(dmg):
	#tilemap.set_cell(cell, 1, Vector2i(1, 0))
	#Events.on_obstacles_removed.emit(self)
	#queue_free()
	pass

func _on_tower_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click:
			Events.tower_clicked.emit(self)

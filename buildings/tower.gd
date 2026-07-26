extends Node2D

const ProjectileScene = preload("res://buildings/projectile.tscn")

var attack_targets: int = 1

var enemies_in_range: Array = []
@onready var area = $AttackArea2D
@onready var col = $AttackArea2D/CollisionShape2D
@onready var attack_timer = $AttackTimer

var cell
var tilemap

var tower_id: String = "" # set by load_tower
var tower_data: Dictionary = {} # set by load_tower

func _ready() -> void:
	_apply_tower_data()
	
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self,"_on_area_exited"))

func load_tower(new_tower_id: String, new_tower_data: Dictionary) -> void:
	if new_tower_data.is_empty():
		push_error("Cannot load tower without tower data: %s" % new_tower_id)
		return

	tower_id = new_tower_id
	tower_data = new_tower_data

	if is_node_ready():
		_apply_tower_data()


func _apply_tower_data() -> void:
	if tower_data.is_empty():
		push_error("Tower was added to the scene without tower data")
		return

	col.shape.radius = tower_data.range
	attack_timer.wait_time = tower_data.atkspd
	attack_targets = tower_data.targets
	$Sprite2D.texture = tower_data.sprite


var attacking = false

func attack():
	if !attack_timer.is_stopped():
		return
	
	
	var enemies = get_closest_enemies(attack_targets)
	if enemies.size() == 0:
		return
	
	for i in range(enemies.size()):
		var p = ProjectileScene.instantiate()
		p.direction = global_position.direction_to(enemies[i].global_position)
		p.load_projectile(tower_data.proj)
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

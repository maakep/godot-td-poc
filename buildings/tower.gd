extends Node2D

var attack_targets: int = 1

var enemies_in_range: Array = []
@onready var area = $AttackArea2D
@onready var col = $AttackArea2D/CollisionShape2D
@onready var attack_timer = $AttackTimer

var cell
var tilemap

var tower_id # set by creator
var tower # set by load_tower
var behavior := "projectile"
var damage_dealt: float = 0.0
var kills: int = 0

var proj = preload("res://buildings/projectile.tscn")

func _ready():
	area.connect("area_entered", Callable(self, "_on_area_entered"))
	area.connect("area_exited", Callable(self,"_on_area_exited"))
	attack_timer.timeout.connect(attack)
	load_tower(tower_id)

func load_tower(id):
	var twr = Towers.get_tower(id)
	if twr.is_empty():
		push_error("Unknown tower: %s" % id)
		return
	tower_id = id
	behavior = twr.get("behavior", "projectile")
	col.shape.radius = maxf(float(twr.get("range", 0)), 1.0)
	attack_timer.wait_time = float(twr.get("aura_interval", twr.get("atkspd", 1.0)))
	attack_targets = int(twr.get("targets", 1))
	area.monitoring = behavior != "blocker"
	$Sprite2D.texture = twr.sprite
	tower = twr
	if behavior == "aura" and not enemies_in_range.is_empty():
		attack()


var attacking = false

func attack():
	if behavior == "blocker" or !attack_timer.is_stopped():
		return
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy) and not enemy.is_queued_for_deletion())
	var enemies = get_closest_enemies(attack_targets)
	if enemies.size() == 0:
		return

	if behavior == "aura":
		for enemy in enemies:
			enemy.apply_effect(tower.aura_effect, self)
	else:
		for enemy in enemies:
			var p = proj.instantiate()
			p.direction = global_position.direction_to(enemy.global_position)
			p.load_projectile(tower.proj, self)
			call_deferred("add_child", p)

	attack_timer.start()
	

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

func record_damage(amount: float, killed: bool) -> void:
	damage_dealt += amount
	if killed:
		kills += 1

func _on_tower_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !event.shift_pressed and !Input.is_key_pressed(KEY_SHIFT):
			viewport.set_input_as_handled()
			Events.tower_clicked.emit(self)

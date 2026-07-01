extends Area2D

var damage: float = 1
var piercing: int = 0
var aoe: int = -1
var speed = 500
var projectile_range = 4
var effects = []

var direction # set by creator
@onready var shapecast: ShapeCast2D = $AOE

func load_projectile(proj):
	speed = proj.speed
	projectile_range = proj.range
	damage = proj.damage
	aoe = proj.aoe
	piercing = proj.piercing
	
	if proj.aoe > 0:
		$AOE.shape.radius = proj.aoe
		shapecast = $AOE
		
	effects = proj.effects
	$Sprite2D.texture = proj.sprite
	
var travelled = 0
func _physics_process(delta):
	travelled += delta
	if travelled > projectile_range:
		queue_free()
		
	global_position += direction * speed * delta

func _on_area_entered(enemy):		
	if !enemy.is_in_group("enemy"):
		return
	
	apply_effects(enemy)
	
	if aoe > 0 and shapecast.is_colliding():
		var targets_hit = shapecast.get_collision_count()
		
		for i in range(targets_hit):
			var aoe_enemy = shapecast.get_collider(i)
			
			if aoe_enemy != null:
				aoe_enemy.take_damage(damage)
				apply_effects(aoe_enemy)
	
	enemy.take_damage(damage)
		
	
	if piercing == 0:
		queue_free()
	else:
		piercing -= 1

func apply_effects(enemy):
	var resists = enemy.data.resist
	
	for effect in effects:
		var res = resists.any(func(x): return x == effect.name)
		if res:
			continue # resisted the effect
		
		enemy.apply_effect(effect)
		
		
		
	

extends CanvasLayer

const FOG_SHADER := preload("res://effects/fog_of_war.gdshader")
const NOISE_WORLD_SIZE := 768.0

## Visibility distances are in world pixels, independent of camera zoom.
@export_range(64.0, 1024.0, 16.0) var building_radius := 356.0
@export_range(64.0, 1024.0, 16.0) var waypoint_radius := 420.0

## Small moving reveals. Set to zero to disable enemy visibility.
@export_range(0.0, 512.0, 16.0) var enemy_radius := 128.0

@export_range(0.1, 0.9) var edge_softness := 0.8
@export_range(0.05, 3.0) var fade_duration := 0.2

@export_range(0.0, 1.0) var darkness := 0.98
@export_color_no_alpha var fog_color := Color(0.025, 0.04, 0.065)
@export_range(0.0, 1.0) var edge_movement := 0.45

@onready var _tilemap: TileMapLayer = $"../Layers/TileMapLayer"
@onready var _player = $"../Player"
@onready var _creeps: Node2D = $"../Creeps"

var _sources: Dictionary = {}
var _mask_viewport: SubViewport
var _mask_background: ColorRect
var _mask: RevealMask
var _overlay: ColorRect
var _fog_material: ShaderMaterial
var _noise_offset := Vector2.ZERO


class RevealSource extends RefCounted:
	var position := Vector2.ZERO
	var radius := 0.0
	var strength := 0.0
	var active := false


class RevealMask extends Node2D:
	var sources: Array[RevealSource] = []
	var brush: GradientTexture2D


	func _draw() -> void:
		for source in sources:
			var extent := Vector2.ONE * source.radius
			var bounds := Rect2(source.position - extent, extent * 2.0)
			var tint := Color(1.0, 1.0, 1.0, source.strength)

			# Black circles cut holes into the white fog mask. Overlaps merge.
			draw_texture_rect(brush, bounds, false, tint)


func _ready() -> void:
	_create_mask()
	_create_overlay()
	_update_sources(0.0, true)
	_update_camera()
	_update_shader(0.0)


func _create_mask() -> void:
	var gradient := Gradient.new()
	var brush := GradientTexture2D.new()

	gradient.offsets = PackedFloat32Array([0.0, 1.0 - edge_softness, 1.0])
	gradient.colors = PackedColorArray([Color.BLACK, Color.BLACK, Color(0, 0, 0, 0)])
	brush.gradient = gradient
	brush.width = 256
	brush.height = 256
	brush.fill = GradientTexture2D.FILL_RADIAL
	brush.fill_from = Vector2(0.5, 0.5)
	brush.fill_to = Vector2(1.0, 0.5)

	# A separate canvas prevents the game world from appearing in the mask.
	_mask_viewport = SubViewport.new()
	_mask_viewport.name = "VisibilityMask"
	_mask_viewport.world_2d = World2D.new()
	_mask_viewport.disable_3d = true
	_mask_viewport.gui_disable_input = true
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_mask_viewport)

	_mask_background = ColorRect.new()
	_mask_background.color = Color.WHITE
	_mask_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask_viewport.add_child(_mask_background)

	_mask = RevealMask.new()
	_mask.brush = brush
	_mask.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_mask_viewport.add_child(_mask)


func _create_overlay() -> void:
	var noise := FastNoiseLite.new()
	var noise_texture := NoiseTexture2D.new()

	noise.seed = 83
	noise.frequency = 0.025
	noise.fractal_octaves = 3
	noise_texture.width = 256
	noise_texture.height = 256
	noise_texture.noise = noise
	noise_texture.seamless = true
	noise_texture.generate_mipmaps = false

	_fog_material = ShaderMaterial.new()
	_fog_material.shader = FOG_SHADER
	_fog_material.set_shader_parameter("visibility_mask", _mask_viewport.get_texture())
	_fog_material.set_shader_parameter("fog_noise", noise_texture)
	_fog_material.set_shader_parameter("noise_world_size", NOISE_WORLD_SIZE)

	_overlay = ColorRect.new()
	_overlay.name = "Darkness"
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.material = _fog_material
	add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	_mask_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible else SubViewport.UPDATE_DISABLED

	if not visible:
		return

	_update_sources(delta)
	_update_camera()
	_update_shader(delta)


func _update_sources(delta: float, immediate := false) -> void:
	for source: RevealSource in _sources.values():
		source.active = false

	for waypoint: Vector2 in Levels.waypoints:
		_track_source(waypoint, _tilemap.to_global(waypoint), waypoint_radius)

	for building in _player.towers_by_cell.values():
		if is_instance_valid(building) and not building.is_queued_for_deletion():
			_track_source(building.get_instance_id(), building.global_position, building_radius)

	if enemy_radius > 0.0:
		for enemy in _creeps.get_children():
			if enemy is Node2D and enemy.is_in_group("enemy") and not enemy.is_queued_for_deletion():
				_track_source(enemy.get_instance_id(), enemy.global_position, enemy_radius)

	_mask.sources.clear()

	for key in _sources.keys():
		var source: RevealSource = _sources[key]
		var target_strength := 1.0 if source.active else 0.0

		source.strength = target_strength if immediate else move_toward(
			source.strength, target_strength, delta / maxf(fade_duration, 0.001)
		)

		if not source.active and source.strength <= 0.0:
			_sources.erase(key)
		else:
			_mask.sources.append(source)

	_mask.queue_redraw()


func _track_source(key: Variant, world_position: Vector2, radius: float) -> void:
	if not _sources.has(key):
		_sources[key] = RevealSource.new()

	var source: RevealSource = _sources[key]

	source.position = world_position
	source.radius = radius
	source.active = true


func _update_camera() -> void:
	var viewport_size := get_viewport().get_visible_rect().size.maxf(2.0)
	var mask_size := Vector2i((viewport_size * 0.5).ceil()).max(Vector2i(2, 2))
	var camera_transform := get_viewport().get_canvas_transform()
	var screen_to_world := camera_transform.affine_inverse()

	# Half-resolution soft masks keep the cost down without a tower-count cap.
	if _mask_viewport.size != mask_size:
		_mask_viewport.size = mask_size
		_mask_background.size = Vector2(mask_size)

	_mask.transform = camera_transform.scaled(Vector2(mask_size) / viewport_size)
	_fog_material.set_shader_parameter("world_origin", screen_to_world.origin)
	_fog_material.set_shader_parameter("world_axis_x", screen_to_world.x * viewport_size.x)
	_fog_material.set_shader_parameter("world_axis_y", screen_to_world.y * viewport_size.y)


func _update_shader(delta: float) -> void:
	var inner_edge := 1.0 - edge_softness

	if not is_equal_approx(_mask.brush.gradient.get_offset(1), inner_edge):
		_mask.brush.gradient.set_offset(1, inner_edge)

	_noise_offset = (_noise_offset + Vector2(2.0, -1.0) * delta / NOISE_WORLD_SIZE).posmod(1.0)
	_fog_material.set_shader_parameter("noise_offset", _noise_offset)
	_fog_material.set_shader_parameter("fog_color", fog_color)
	_fog_material.set_shader_parameter("darkness", darkness)
	_fog_material.set_shader_parameter("edge_movement", edge_movement)

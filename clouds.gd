extends Sprite2D

const CLOUD_SHADER := preload("res://effects/clouds.gdshader")
const SECONDARY_SCALE := 1.37

## Movement in world pixels per second. Keep these small for subtle shadows.
@export var drift_velocity := Vector2(20.0, 1.0)
@export var secondary_drift_velocity := Vector2(1.0, -0.7)

## Blends a second sample of the same texture to gently change the cloud shapes.
@export_range(0.0, 0.5) var shape_variation := 0.25

var _cloud_material: ShaderMaterial
var _drift_offset := Vector2.ZERO
var _secondary_offset := Vector2(0.37, 0.61)


func _ready() -> void:
	if texture == null:
		set_process(false)
		return

	var noise_texture := texture as NoiseTexture2D

	if noise_texture != null:
		noise_texture.seamless = true

	# The sprite and shader share this texture, so both must allow wrapping.
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	_cloud_material = ShaderMaterial.new()
	_cloud_material.shader = CLOUD_SHADER
	_cloud_material.set_shader_parameter("cloud_texture", texture)
	_cloud_material.set_shader_parameter("secondary_scale", SECONDARY_SCALE)
	material = _cloud_material

	_update_shader_offsets()


func _process(delta: float) -> void:
	var displayed_size := (get_rect().size * global_scale.abs()).maxf(1.0)
	var primary_step := drift_velocity * delta / displayed_size
	var secondary_step := secondary_drift_velocity * delta / displayed_size * SECONDARY_SCALE

	# Scroll the texture inside the stationary sprite. Wrapping whole texture
	# lengths is invisible with seamless noise and keeps long runs precise.
	_drift_offset = (_drift_offset - primary_step).posmod(1.0)
	_secondary_offset = (_secondary_offset - secondary_step).posmod(1.0)

	_update_shader_offsets()


func _update_shader_offsets() -> void:
	_cloud_material.set_shader_parameter("drift_offset", _drift_offset)
	_cloud_material.set_shader_parameter("secondary_offset", _secondary_offset)
	_cloud_material.set_shader_parameter("shape_variation", shape_variation)

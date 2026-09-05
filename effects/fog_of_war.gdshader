shader_type canvas_item;
render_mode unshaded;

uniform sampler2D visibility_mask : filter_linear, repeat_disable;
uniform sampler2D fog_noise : filter_linear, repeat_enable;
uniform vec4 fog_color : source_color = vec4(0.025, 0.04, 0.065, 1.0);
uniform float darkness : hint_range(0.0, 1.0) = 0.98;
uniform float edge_movement : hint_range(0.0, 1.0) = 0.45;

uniform vec2 world_origin;
uniform vec2 world_axis_x;
uniform vec2 world_axis_y;
uniform vec2 noise_offset;
uniform float noise_world_size = 768.0;


void fragment() {
	vec2 world_position = world_origin + UV.x * world_axis_x + UV.y * world_axis_y;
	vec2 noise_uv = world_position / noise_world_size;
	float broad_noise = texture(fog_noise, noise_uv + noise_offset).r;
	float fine_noise = texture(fog_noise, noise_uv * 2.13 - noise_offset * 0.71).r;
	float mist = mix(broad_noise, fine_noise, 0.3);
	float fog_amount = texture(visibility_mask, UV).r;

	// Only the soft boundary wavers. Fully revealed centers stay clear.
	float edge = fog_amount * (1.0 - fog_amount);
	fog_amount = clamp(fog_amount + (mist - 0.5) * edge * edge_movement, 0.0, 1.0);

	vec3 mist_color = fog_color.rgb * mix(0.85, 1.15, mist);
	COLOR = vec4(mist_color, fog_amount * darkness);
}

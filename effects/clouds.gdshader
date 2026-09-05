shader_type canvas_item;
render_mode unshaded;

uniform sampler2D cloud_texture : source_color, repeat_enable, filter_linear;
uniform vec2 drift_offset = vec2(0.0);
uniform vec2 secondary_offset = vec2(0.37, 0.61);
uniform float secondary_scale = 1.37;
uniform float shape_variation : hint_range(0.0, 0.5) = 0.25;

varying vec4 sprite_tint;


void vertex() {
	sprite_tint = COLOR;
}


void fragment() {
	vec2 primary_uv = UV + drift_offset;
	vec2 secondary_uv = UV * secondary_scale + secondary_offset;
	vec4 primary_clouds = texture(cloud_texture, primary_uv);
	vec4 secondary_clouds = texture(cloud_texture, secondary_uv);

	// Reuse the existing texture and its color ramp for both drifting samples.
	COLOR = mix(primary_clouds, secondary_clouds, shape_variation) * sprite_tint;
}

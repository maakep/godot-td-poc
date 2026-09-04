shader_type canvas_item;
render_mode unshaded, blend_mix;

// x: frost, y: poison, z: fire, w: oil.
instance uniform vec4 effect_intensity = vec4(0.0);
instance uniform float effect_phase = 0.0;

uniform vec4 frost_color : source_color = vec4(0.25, 0.78, 1.0, 1.0);
uniform vec4 poison_color : source_color = vec4(0.58, 0.14, 0.78, 1.0);
uniform vec4 fire_color : source_color = vec4(1.0, 0.30, 0.055, 1.0);
uniform vec4 oil_color : source_color = vec4(0.035, 0.03, 0.025, 1.0);


float disc(vec2 point, vec2 center, float radius) {
	float edge = max(radius * 0.35, 0.004);
	return 1.0 - smoothstep(radius - edge, radius, length(point - center));
}


float ring(vec2 point, vec2 center, float radius, float width) {
	float distance_from_ring = abs(length(point - center) - radius);
	return 1.0 - smoothstep(width * 0.45, width, distance_from_ring);
}


void fragment() {
	vec2 point = (UV - vec2(0.5)) * 2.0;
	float time = TIME + effect_phase;

	// Frost occupies the outside edge and rotates crystalline sparks. This
	// remains legible alongside effects that rise through the middle.
	float frost = ring(point, vec2(0.0), 0.72 + sin(time * 2.0) * 0.018, 0.038) * 0.32;
	for (int index = 0; index < 6; index++) {
		float seed = float(index) / 6.0;
		float angle = seed * 6.2831853 + time * (0.35 + seed * 0.1);
		vec2 center = vec2(cos(angle), sin(angle)) * (0.72 + 0.05 * sin(time * 1.7 + seed * 13.0));
		frost += disc(point, center, 0.035 + 0.022 * effect_intensity.x);
	}
	frost *= effect_intensity.x;

	// Poison uses hollow bubbles drifting upward from the lower half.
	float poison = 0.0;
	for (int index = 0; index < 5; index++) {
		float seed = float(index) / 5.0;
		float phase = fract(time * (0.18 + seed * 0.04) + seed * 1.71);
		float x = -0.52 + seed * 1.04 + sin(time * 1.1 + seed * 19.0) * 0.10;
		float y = 0.72 - phase * 1.15;
		float radius = mix(0.075, 0.025, phase);
		poison += ring(point, vec2(x, y), radius, 0.018);
	}
	poison *= effect_intensity.y;

	// Fire rises faster and uses solid embers plus a soft base flicker.
	float fire = disc(point, vec2(sin(time * 4.0) * 0.10, 0.58), 0.20) * 0.22;
	for (int index = 0; index < 7; index++) {
		float seed = float(index) / 7.0;
		float phase = fract(time * (0.45 + seed * 0.12) + seed * 2.31);
		float x = -0.42 + seed * 0.84 + sin(time * 2.4 + seed * 23.0) * (0.08 + phase * 0.08);
		float y = 0.70 - phase * 1.38;
		fire += disc(point, vec2(x, y), mix(0.065, 0.014, phase));
	}
	fire *= effect_intensity.z;

	// Oil clings low as irregular black globules and a pooled base.
	float oil = disc(point, vec2(sin(time * 0.8) * 0.08, 0.66), 0.25) * 0.38;
	for (int index = 0; index < 5; index++) {
		float seed = float(index) / 5.0;
		float x = -0.48 + seed * 0.96 + sin(time * 1.2 + seed * 17.0) * 0.06;
		float y = 0.50 + sin(time * 1.5 + seed * 11.0) * 0.12;
		oil += disc(point, vec2(x, y), 0.055 + seed * 0.02);
	}
	oil *= effect_intensity.w;

	float total = frost + poison + fire + oil;
	vec3 weighted_color =
		frost_color.rgb * frost
		+ poison_color.rgb * poison
		+ fire_color.rgb * fire
		+ oil_color.rgb * oil;
	vec3 final_color = weighted_color / max(total, 0.0001);
	COLOR = vec4(final_color, clamp(total, 0.0, 0.92));
}

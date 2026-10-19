shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.42;
uniform vec4 phosphor_color : source_color = vec4(0.31, 0.55, 0.30, 1.0);

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float lines = 0.5 + 0.5 * sin(uv.y * 1250.0);
	float noise = hash21(floor(uv * vec2(560.0, 350.0)) + floor(TIME * 8.0));
	vec2 screen_centered = (uv - vec2(0.5)) * vec2(1.0, 0.65);
	float vignette = smoothstep(0.25, 0.64, length(screen_centered));
	float alpha = strength * (0.012 + lines * 0.031 + noise * 0.011 + vignette * 0.065);
	COLOR = vec4(phosphor_color.rgb, alpha);
}

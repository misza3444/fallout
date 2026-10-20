shader_type spatial;

// Lightweight world-space surface treatment for the WebGL 2 Compatibility renderer.
// Makes large surfaces weathered without shipping heavyweight textures.
uniform vec4 base_color : source_color = vec4(0.45, 0.43, 0.37, 1.0);
uniform float fleck_scale : hint_range(1.0, 40.0) = 13.0;
uniform float weathering : hint_range(0.0, 1.0) = 0.75;
uniform float metalness : hint_range(0.0, 1.0) = 0.08;

varying vec3 world_coordinates;

float hash_3d(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

void vertex() {
    world_coordinates = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 cell = floor(world_coordinates * fleck_scale);
    float grain = hash_3d(cell);
    float stains = hash_3d(floor(world_coordinates * 0.53));
    float wear = mix(0.94, 0.88 + grain * 0.12, weathering);
    wear *= mix(0.92, 1.0, stains);
    ALBEDO = clamp(base_color.rgb * wear, vec3(0.0), vec3(1.0));
    ROUGHNESS = 0.95;
    METALLIC = metalness;
}

shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 1.0) = 0.75;
uniform float softness : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    vec2 uv = UV - 0.5;
    float len = length(uv);
    float vignette = smoothstep(radius, radius - softness, len);
    COLOR = mix(vignette_color, vec4(0.0), vignette);
    // Alternatively, multiply color to blend or adjust alpha values
}

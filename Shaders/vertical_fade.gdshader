shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    float gradient = UV.y;
    
    // Transition douce grâce à smoothstep
    float edge = cutoff * (1.0 - smoothness);
    float alpha = smoothstep(edge, cutoff, gradient);
    
    COLOR = vec4(color.rgb, color.a * alpha);
}
shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 glow = glow_color * glow_intensity;
    COLOR = mix(tex_color, glow, glow.a);
}
shader_type canvas_item;

uniform float glow_intensity = 1.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // Gold

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec3 glow = glow_color.rgb * glow_intensity;
    COLOR = vec4(tex.rgb + glow, tex.a);
}
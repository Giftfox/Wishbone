RSRC                     Shader            ��������                                                  resource_local_to_scene    resource_name    code    script           local://Shader_mebew �          Shader          �  shader_type canvas_item;

uniform vec4 color: source_color;
uniform float intensity;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	vec4 diffs = vec4(color.r - base_color.r, color.g - base_color.g, color.b - base_color.b, color.a - base_color.a);
	COLOR = vec4(base_color.r + diffs.r * intensity, base_color.g + diffs.g * intensity, base_color.b + diffs.b * intensity, color.a * base_color.a);
}       RSRC
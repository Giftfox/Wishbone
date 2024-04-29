RSRC                     Shader            ��������                                                  resource_local_to_scene    resource_name    code    script           local://Shader_co36l �          Shader            shader_type canvas_item;

uniform sampler2D mask : source_color;
uniform float offset : hint_range(-1.0, 1.0);

void fragment()
{
	float value = texture(mask, UV - vec2(0.0, offset)).a;
	if (value == 0.0) {
		COLOR = vec4(COLOR.rgb, 0.0);
	}
	else {
		COLOR = texture(TEXTURE, UV)
	}
}       RSRC
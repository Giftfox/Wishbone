RSRC                     Shader            ��������                                                  resource_local_to_scene    resource_name    code    script           local://Shader_w6ynu �          Shader          2  shader_type canvas_item;

void fragment() {
    vec4 _tex_read = texture(TEXTURE , UV.xy);
    vec3 rgb = _tex_read.rgb;
    float oriaplha = _tex_read.a;

    float uvy = UV.y;

    float showhowmuch = 0.70000;
    float alphamultiplier;

    if(abs(uvy - showhowmuch) < 0.02)
    {
        alphamultiplier = 0.5;
    }
    else if(uvy < showhowmuch)
    {
        alphamultiplier = 1.0;
    }
    else
    {
        alphamultiplier = 0.2;
    }

    float moddedalpha = oriaplha * alphamultiplier;

// Output
    COLOR.rgb = rgb;
    COLOR.a = moddedalpha;

}       RSRC
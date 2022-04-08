shader_type canvas_item;


uniform vec4 color : hint_color = vec4(0, 0, 0, 1);
uniform float thickness : hint_range(0, 8) = 1.0;


void fragment()
{
    vec2 kernel_size = TEXTURE_PIXEL_SIZE * thickness;
    
    float outline = texture(TEXTURE, UV + vec2(-kernel_size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, kernel_size.y)).a;
    outline += texture(TEXTURE, UV + vec2(kernel_size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -kernel_size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-kernel_size.x, kernel_size.y)).a;
    outline += texture(TEXTURE, UV + vec2(kernel_size.x, kernel_size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-kernel_size.x, -kernel_size.y)).a;
    outline += texture(TEXTURE, UV + vec2(kernel_size.x, -kernel_size.y)).a;
    outline = min(outline, 1.0);
    
    vec4 sprite_color = texture(TEXTURE, UV);
    COLOR = mix(sprite_color, color, outline - sprite_color.a);
}

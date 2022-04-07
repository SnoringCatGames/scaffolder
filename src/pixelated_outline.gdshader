shader_type canvas_item;


uniform vec4 color : hint_color = vec4(0, 0, 0, 1);
uniform float thickness : hint_range(0, 8) = 1.0;
uniform bool fades_out = false;
uniform bool adds_margins = true;


//void vertex() {
//    if (adds_margins) {
//        VERTEX += (UV * 2.0 - 1.0) * thickness;
//    }
//}
//
//
//void fragment() {
//    vec4 tex_color = texture(TEXTURE, UV);
//
//    // Different color channels contribute different weights to brightness, so
//    // we scale their saturation with different weights.
//    COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114))), tex_color.rgb, saturation);
//    COLOR.a = tex_color.a;
//}


void fragment()
{
    vec4 sprite_color = texture(TEXTURE, UV);
    if (sprite_color.a == 0.0)
    {
        sprite_color = color;
        sprite_color.a = 0.0;
        for (float x = -ceil(thickness); x <= ceil(thickness); x++)
        {
            for (float y = -ceil(thickness); y <= ceil(thickness); y++)
            {
                if ((x == 0.0 && y == 0.0) ||
                    texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE)
                        .a == 0.0)
                {
                    continue;
                }
                if (fades_out)
                {
                    sprite_color.a +=
                            color.a /
                            (pow(x, 2) + pow(y, 2)) *
                            (1.0 - pow(2.0, -thickness));
                    if (sprite_color.a > 1.0)
                    {
                        sprite_color.a = 1.0;
                    }
                }
                else
                {
                    sprite_color.a = color.a;
                    break;
                }
            }
            if (sprite_color.a >= color.a)
            {
                break;
            }
        }
    }
    COLOR = sprite_color;
}

shader_type canvas_item;
// This shader was originally based on the example from Juulpower at
// https://godotshaders.com/shader/2d-outline-inline/.


uniform vec4 color : hint_color = vec4(1.0);
uniform float thickness : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // Diamond, Circle, Square.
uniform bool is_inside = false;
uniform bool adds_margins = true; // Ignored when is_inside is false.

uniform float saturation : hint_range(0, 1) = 1.0;


void vertex()
{
    if (adds_margins)
    {
        VERTEX += (UV * 2.0 - 1.0) * thickness;
    }
}


bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture)
{
    for (float i = -ceil(thickness); i <= ceil(thickness); i++)
    {
        float x = abs(i) > thickness ? thickness * sign(i) : i;
        float offset;
        
        if (pattern == 0)
        {
            offset = thickness - abs(x);
        }
        else if (pattern == 1)
        {
            offset = floor(sqrt(pow(thickness + 0.5, 2) - x * x));
        }
        else if (pattern == 2)
        {
            offset = thickness;
        }
        
        for (float j = -ceil(offset); j <= ceil(offset); j++)
        {
            float y = abs(j) > offset ? offset * sign(j) : j;
            vec2 xy = uv + texture_pixel_size * vec2(x, y);
            
            if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) ||
                    texture(texture, xy).a == 0.0) == is_inside)
            {
                return true;
            }
        }
    }
    
    return false;
}


void fragment()
{
    vec2 uv = UV;
    
    if (adds_margins)
    {
        vec2 texture_pixel_size =
                vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE +
                vec2(thickness * 2.0));
        
        uv = (uv - texture_pixel_size * thickness) *
                TEXTURE_PIXEL_SIZE / texture_pixel_size;
        
        if (uv != clamp(uv, vec2(0.0), vec2(1.0)))
        {
            COLOR.a = 0.0;
        }
        else
        {
            COLOR = texture(TEXTURE, uv);
        }
    }
    else
    {
        COLOR = texture(TEXTURE, uv);
    }
    
    if ((COLOR.a > 0.0) == is_inside &&
            hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE))
    {
        COLOR.rgb = is_inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
        COLOR.a += (1.0 - COLOR.a) * color.a;
    }
    
    // Desaturate.
    COLOR.rgb = mix(vec3(dot(COLOR.rgb, vec3(0.299, 0.587, 0.114))), COLOR.rgb, saturation);
}

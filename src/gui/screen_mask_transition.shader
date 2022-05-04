shader_type canvas_item;
render_mode unshaded;


uniform float cutoff : hint_range(0.0, 1.0);
uniform float smooth_size : hint_range(0.0, 1.0);
uniform sampler2D mask : hint_albedo;
uniform vec2 mask_size;
uniform vec2 mask_scale;
uniform vec2 mask_offset;
uniform bool pixel_snap;


void fragment() {
    vec2 mask_uv = UV;
    // Uniformly expand the mask to fill the screen, rather than stretching the
    // mask.
    mask_uv *= mask_scale;
    mask_uv += mask_offset;
    if (pixel_snap) {
        // Snap the mask to the nearest pixel.
        mask_uv = round(mask_uv * mask_size) / mask_size;
    }
    
	float mask_value = texture(mask, mask_uv).r;
	float alpha = smoothstep(
        cutoff, 
        cutoff + smooth_size, 
        mask_value * (1.0 - smooth_size) + smooth_size);
    
    vec4 color = texture(TEXTURE, UV);
	COLOR = vec4(color.rgb, alpha);
}

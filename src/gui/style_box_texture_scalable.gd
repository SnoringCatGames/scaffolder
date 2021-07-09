class_name StyleBoxTextureScalable
extends StyleBoxTexture


var initial_texture_scale := 1.0

var initial_texture: Texture
var initial_content_margin: float
var initial_expand_margin: float
var initial_margin: float

var latest_gui_scale := INF


func ready() -> void:
    # TODO: Support tiling. There is a bug with tiling, where 1-pixel gaps are
    #       shown between some tiles when resizing the image.
    axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    
    initial_texture = texture
    initial_content_margin = content_margin_top
    initial_expand_margin = expand_margin_top
    initial_margin = margin_top
    
    Gs.gui.add_gui_to_scale(self)


func destroy() -> void:
    Gs.gui.remove_gui_to_scale(self)


func _on_gui_scale_changed() -> bool:
    if latest_gui_scale == Gs.gui.scale:
        return true
    
    latest_gui_scale = Gs.gui.scale
    
    var image_scale := initial_texture_scale * latest_gui_scale
    
    var image: Image = initial_texture.duplicate().get_data()
    var size: Vector2 = Gs.utils.floor_vector(image.get_size() * image_scale)
    image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
    var resized_texture := ImageTexture.new()
    resized_texture.create_from_image(image)
    
    texture = resized_texture
    
    region_rect = Rect2(Vector2.ZERO, size)
    
    var current_margin := \
            ceil(initial_margin * image_scale)
    margin_left = current_margin
    margin_top = current_margin
    margin_right = current_margin
    margin_bottom = current_margin
    
    var current_content_margin := \
            ceil(initial_content_margin * latest_gui_scale)
    content_margin_left = current_content_margin
    content_margin_top = current_content_margin
    content_margin_right = current_content_margin
    content_margin_bottom = current_content_margin
    
    var current_expand_margin := \
            ceil(initial_expand_margin * latest_gui_scale)
    expand_margin_left = current_expand_margin
    expand_margin_top = current_expand_margin
    expand_margin_right = current_expand_margin
    expand_margin_bottom = current_expand_margin
    
    return true

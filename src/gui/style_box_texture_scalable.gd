tool
class_name StyleBoxTextureScalable
extends StyleBoxTexture


var initial_texture_scale := 1.0

var initial_texture: Texture

var initial_content_margin_left: float
var initial_content_margin_top: float
var initial_content_margin_right: float
var initial_content_margin_bottom: float

var initial_expand_margin_left: float
var initial_expand_margin_top: float
var initial_expand_margin_right: float
var initial_expand_margin_bottom: float

var initial_margin_left: float
var initial_margin_top: float
var initial_margin_right: float
var initial_margin_bottom: float

var latest_gui_scale := INF


func ready() -> void:
    # TODO: Support tiling. There is a bug with tiling, where 1-pixel gaps are
    #       shown between some tiles when resizing the image.
    axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
    
    initial_texture = texture
    
    initial_content_margin_left = content_margin_left
    initial_content_margin_top = content_margin_top
    initial_content_margin_right = content_margin_right
    initial_content_margin_bottom = content_margin_bottom
    
    initial_expand_margin_left = expand_margin_left
    initial_expand_margin_top = expand_margin_top
    initial_expand_margin_right = expand_margin_right
    initial_expand_margin_bottom = expand_margin_bottom
    
    initial_margin_left = margin_left
    initial_margin_top = margin_top
    initial_margin_right = margin_right
    initial_margin_bottom = margin_bottom
    
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
    
    margin_left = initial_margin_left * image_scale
    margin_top = initial_margin_top * image_scale
    margin_right = initial_margin_right * image_scale
    margin_bottom = initial_margin_bottom * image_scale
    
    content_margin_left = initial_content_margin_left * latest_gui_scale
    content_margin_top = initial_content_margin_top * latest_gui_scale
    content_margin_right = initial_content_margin_right * latest_gui_scale
    content_margin_bottom = initial_content_margin_bottom * latest_gui_scale
    
    expand_margin_left = initial_expand_margin_left * latest_gui_scale
    expand_margin_top = initial_expand_margin_top * latest_gui_scale
    expand_margin_right = initial_expand_margin_right * latest_gui_scale
    expand_margin_bottom = initial_expand_margin_bottom * latest_gui_scale
    
    return true


func duplicate(subresources := false) -> Resource:
    return Gs.styles._create_stylebox_texture_scalable_from_stylebox(self)

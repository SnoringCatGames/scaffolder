tool
class_name StyleBoxFlatScalable
extends StyleBoxFlat


var initial_border_width: int

var initial_content_margin_left: float
var initial_content_margin_top: float
var initial_content_margin_right: float
var initial_content_margin_bottom: float

var initial_expand_margin_left: float
var initial_expand_margin_top: float
var initial_expand_margin_right: float
var initial_expand_margin_bottom: float

var initial_corner_detail: int
var initial_corner_radius: int

var initial_shadow_offset: Vector2
var initial_shadow_size: int

var has_local_lifecycle := true


func ready() -> void:
    initial_border_width = border_width_top
    
    initial_content_margin_left = content_margin_left
    initial_content_margin_top = content_margin_top
    initial_content_margin_right = content_margin_right
    initial_content_margin_bottom = content_margin_bottom
    
    initial_expand_margin_left = expand_margin_left
    initial_expand_margin_top = expand_margin_top
    initial_expand_margin_right = expand_margin_right
    initial_expand_margin_bottom = expand_margin_bottom
    
    initial_corner_detail = corner_detail
    initial_corner_radius = corner_radius_top_left
    initial_shadow_offset = shadow_offset
    initial_shadow_size = shadow_size
    
    if !Engine.editor_hint:
        Sc.gui.add_gui_to_scale(self)


func _destroy() -> void:
    if has_local_lifecycle:
        Sc.gui.remove_gui_to_scale(self)


func _on_gui_scale_changed() -> bool:
    var current_border_width := round(initial_border_width * Sc.gui.scale)
    border_width_left = current_border_width
    border_width_top = current_border_width
    border_width_right = current_border_width
    border_width_bottom = current_border_width
    
    content_margin_left = initial_content_margin_left * Sc.gui.scale
    content_margin_top = initial_content_margin_top * Sc.gui.scale
    content_margin_right = initial_content_margin_right * Sc.gui.scale
    content_margin_bottom = initial_content_margin_bottom * Sc.gui.scale
    
    expand_margin_left = initial_expand_margin_left * Sc.gui.scale
    expand_margin_top = initial_expand_margin_top * Sc.gui.scale
    expand_margin_right = initial_expand_margin_right * Sc.gui.scale
    expand_margin_bottom = initial_expand_margin_bottom * Sc.gui.scale
    
    corner_detail = round(initial_corner_detail * Sc.gui.scale)
    
    var current_corner_radius := round(initial_corner_radius * Sc.gui.scale)
    corner_radius_top_left = current_corner_radius
    corner_radius_top_right = current_corner_radius
    corner_radius_bottom_left = current_corner_radius
    corner_radius_bottom_right = current_corner_radius
    
    shadow_offset = initial_shadow_offset * Sc.gui.scale
    
    shadow_size = round(initial_shadow_size * Sc.gui.scale)
    
    return true


func duplicate(subresources := false) -> Resource:
    return Sc.styles._create_stylebox_flat_scalable_from_stylebox(self, has_local_lifecycle)

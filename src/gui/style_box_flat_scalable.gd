class_name StyleBoxFlatScalable
extends StyleBoxFlat


var initial_border_width: int
var initial_content_margin: float
var initial_corner_detail: int
var initial_corner_radius: int
var initial_expand_margin: float
var initial_shadow_offset: Vector2
var initial_shadow_size: int


func ready() -> void:
    initial_border_width = border_width_top
    initial_content_margin = content_margin_top
    initial_corner_detail = corner_detail
    initial_corner_radius = corner_radius_top_left
    initial_expand_margin = expand_margin_top
    initial_shadow_offset = shadow_offset
    initial_shadow_size = shadow_size
    Gs.gui.add_gui_to_scale(self)


func destroy() -> void:
    Gs.gui.remove_gui_to_scale(self)


func _on_gui_scale_changed() -> bool:
    var current_border_width := round(initial_border_width * Gs.gui.scale)
    border_width_left = current_border_width
    border_width_top = current_border_width
    border_width_right = current_border_width
    border_width_bottom = current_border_width
    
    var current_content_margin: float = initial_content_margin * Gs.gui.scale
    content_margin_left = current_content_margin
    content_margin_top = current_content_margin
    content_margin_right = current_content_margin
    content_margin_bottom = current_content_margin
    
    corner_detail = round(initial_corner_detail * Gs.gui.scale)
    
    var current_corner_radius := round(initial_corner_radius * Gs.gui.scale)
    corner_radius_top_left = current_corner_radius
    corner_radius_top_right = current_corner_radius
    corner_radius_bottom_left = current_corner_radius
    corner_radius_bottom_right = current_corner_radius
    
    var current_expand_margin: float = initial_expand_margin * Gs.gui.scale
    expand_margin_left = current_expand_margin
    expand_margin_top = current_expand_margin
    expand_margin_right = current_expand_margin
    expand_margin_bottom = current_expand_margin
    
    shadow_offset = initial_shadow_offset * Gs.gui.scale
    
    shadow_size = round(initial_shadow_size * Gs.gui.scale)
    
    return true

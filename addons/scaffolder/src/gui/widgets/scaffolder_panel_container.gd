tool
class_name ScaffolderPanelContainer, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_panel_container.png"
extends PanelContainer


enum PanelStyle {
    TRANSPARENT,
    OVERLAY,
    NOTIFICATION,
    HEADER,
    HUD,
}

export(PanelStyle) var style := PanelStyle.TRANSPARENT setget _set_style
export var is_unique := false setget _set_is_unique
export var content_margin_left_override := -1 setget \
        _set_content_margin_left_override
export var content_margin_top_override := -1 setget \
        _set_content_margin_top_override
export var content_margin_right_override := -1 setget \
        _set_content_margin_right_override
export var content_margin_bottom_override := -1 setget \
        _set_content_margin_bottom_override

var _stylebox: StyleBox


func _enter_tree() -> void:
    if !is_instance_valid(_stylebox):
        _set_style(style)


func _exit_tree() -> void:
    _clear_style()


func _clear_style() -> void:
    if is_instance_valid(_stylebox):
        _stylebox._destroy()


func _set_style(value: int) -> void:
    var old_style := style
    style = value
    
    if style == old_style and \
            is_instance_valid(_stylebox):
        return
    
    _clear_style()
    
    match style:
        PanelStyle.TRANSPARENT:
            _stylebox = Sc.styles.transparent_panel_stylebox
        PanelStyle.OVERLAY:
            _stylebox = Sc.styles.overlay_panel_stylebox
        PanelStyle.NOTIFICATION:
            _stylebox = Sc.styles.notification_panel_stylebox
        PanelStyle.HEADER:
            _stylebox = Sc.styles.header_panel_stylebox
        PanelStyle.HUD:
            _stylebox = Sc.styles.hud_panel_stylebox
        _:
            Sc.logger.error()
            _stylebox = null
    
    if is_instance_valid(_stylebox):
        if is_unique:
            _stylebox = Sc.styles.create_stylebox_scalable(_stylebox, true)
    
    add_stylebox_override("panel", _stylebox)


func _set_is_unique(value: bool) -> void:
    var was_unique := is_unique
    is_unique = value
    if is_unique == was_unique:
        return
    _set_style(style)


func _set_content_margin_left_override(value: int) -> void:
    content_margin_left_override = value
    _update_content_margin()


func _set_content_margin_top_override(value: int) -> void:
    content_margin_top_override = value
    _update_content_margin()


func _set_content_margin_right_override(value: int) -> void:
    content_margin_right_override = value
    _update_content_margin()


func _set_content_margin_bottom_override(value: int) -> void:
    content_margin_bottom_override = value
    _update_content_margin()


func _update_content_margin() -> void:
    if content_margin_left_override != -1 or \
            content_margin_top_override != -1 or \
            content_margin_right_override != -1 or \
            content_margin_bottom_override != -1:
        _set_is_unique(true)
    
    if !is_instance_valid(_stylebox):
        return
    
    _stylebox.content_margin_left = \
            content_margin_left_override * Sc.gui.scale
    _stylebox.content_margin_top = \
            content_margin_top_override * Sc.gui.scale
    _stylebox.content_margin_right = \
            content_margin_right_override * Sc.gui.scale
    _stylebox.content_margin_bottom = \
            content_margin_bottom_override * Sc.gui.scale

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
    SIMPLE_TRANSPARENT_BLACK,
}
const _PANEL_STYLE_HINT_STRING := (
    "Transparent:0," +
    "Overlay:1," +
    "Notification:2," +
    "Header:3," +
    "Hud:4," +
    "Simple Transparent Black:5"
)

var style: int = PanelStyle.TRANSPARENT setget _set_style
var color_override: ColorConfig = null setget _set_color_override
var is_unique := false setget _set_is_unique
var content_margin_left_override := -1 setget \
        _set_content_margin_left_override
var content_margin_top_override := -1 setget \
        _set_content_margin_top_override
var content_margin_right_override := -1 setget \
        _set_content_margin_right_override
var content_margin_bottom_override := -1 setget \
        _set_content_margin_bottom_override

var _stylebox: StyleBox

const _PROPERTY_LIST_ADDENDUM := [
    {
        name = "style",
        type = TYPE_INT,
        hint = PROPERTY_HINT_ENUM,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint_string = _PANEL_STYLE_HINT_STRING,
    },
    {
        name = "color_override",
        type = TYPE_OBJECT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG,
    },
    {
        name = "is_unique",
        type = TYPE_BOOL,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
    {
        name = "content_margin_left_override",
        type = TYPE_INT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
    {
        name = "content_margin_top_override",
        type = TYPE_INT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
    {
        name = "content_margin_right_override",
        type = TYPE_INT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
    {
        name = "content_margin_bottom_override",
        type = TYPE_INT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
]


func _get_property_list() -> Array:
    return _PROPERTY_LIST_ADDENDUM


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
    
    _update_style()


func _update_style() -> void:
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
        PanelStyle.SIMPLE_TRANSPARENT_BLACK:
            _stylebox = Sc.styles.simple_transparent_black_panel_stylebox
        _:
            Sc.logger.error("ScaffolderPanelContainer._set_style")
            _stylebox = null
    
    if is_instance_valid(_stylebox):
        if is_unique or color_override != null:
            _stylebox = Sc.styles.create_stylebox_scalable(_stylebox, true)
            if color_override != null and _stylebox is StyleBoxFlat:
                _stylebox.bg_color = color_override.sample()
    
    _update_content_margin()
    
    add_stylebox_override("panel", _stylebox)


func _set_color_override(value: ColorConfig) -> void:
    color_override = value
    if color_override != null:
        _set_is_unique(true)
    _update_style()


func _set_is_unique(value: bool) -> void:
    var was_unique := is_unique
    is_unique = value
    if is_unique == was_unique:
        return
    _update_style()


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

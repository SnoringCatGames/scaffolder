tool
class_name PluginAccordionHeaderCaret, \
"res://addons/scaffolder/addons/plugger/assets/images/caret_right_dark_theme_1.png"
extends Control


const _TEXTURE_PATH_PREFIX := \
        "res://addons/scaffolder/addons/plugger/assets/images/caret_right"

const _OPEN_ROTATION := 90.0
const _CLOSED_ROTATION := 0

export var is_open: bool setget _set_is_open,_get_is_open

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    var texture: Texture = Pl.get_icon(_TEXTURE_PATH_PREFIX)
    var texture_size := texture.get_size()
    $TextureRect.texture = texture
    $TextureRect.rect_pivot_offset = texture_size / 2.0
    self.rect_min_size = texture_size


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    $TextureRect.rect_rotation = _OPEN_ROTATION if value else _CLOSED_ROTATION


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return $TextureRect.rect_rotation == _OPEN_ROTATION

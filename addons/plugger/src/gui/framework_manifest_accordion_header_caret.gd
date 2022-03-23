tool
class_name FrameworkManifestAccordionHeaderCaret, \
"res://addons/scaffolder/addons/plugger/assets/images/caret_right_dark_theme_1.png"
extends TextureRect


const _TEXTURE_PATH_PREFIX := \
        "res://addons/scaffolder/addons/plugger/assets/images/caret_right"

const _OPEN_ROTATION := 90.0
const _CLOSED_ROTATION := 0

export var is_open: bool setget _set_is_open,_get_is_open

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    self.texture = Pl.get_icon(_TEXTURE_PATH_PREFIX)
    self.rect_pivot_offset = self.texture.get_size() / 2.0


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    self.rect_rotation = _OPEN_ROTATION if value else _CLOSED_ROTATION


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return self.rect_rotation == _OPEN_ROTATION

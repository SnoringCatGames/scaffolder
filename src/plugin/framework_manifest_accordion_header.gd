tool
class_name FrameworkManifestAccordionHeader, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_header.png"
extends HBoxContainer


const _LEFT_CARET_TEXTURE := preload(
        "res://addons/scaffolder/assets/images/gui/icons/left_caret_normal.png")
const _OPEN_ROTATION := 90.0
const _CLOSED_ROTATION := -90.0

export var is_open: bool setget _set_is_open,_get_is_open

var contents: Control
var caret: TextureRect
var _is_ready := false


func _ready() -> void:
    _is_ready = true
    var children := self.get_children()
    assert(children.size() <= 2 and children.size() > 0)
    if children.size() == 1:
        assert(children[0] is Control)
        contents = children[0]
    
        caret = TextureRect.new()
        caret.texture = _LEFT_CARET_TEXTURE
        caret.rect_rotation = _OPEN_ROTATION
        self.add_child(caret)
        self.move_child(caret, 0)
    else:
        var is_first_child_caret: bool = \
                children[0] is TextureRect and \
                children[0].texture == _LEFT_CARET_TEXTURE
        var is_second_child_caret: bool = \
                children[1] is TextureRect and \
                children[1].texture == _LEFT_CARET_TEXTURE
        assert(is_first_child_caret or is_second_child_caret)
        if is_first_child_caret:
            caret = children[0]
            contents = children[1]
        else:
            caret = children[1]
            contents = children[0]


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    caret.scale.y = _OPEN_ROTATION if value else _CLOSED_ROTATION


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return caret.scale.y < 0.0

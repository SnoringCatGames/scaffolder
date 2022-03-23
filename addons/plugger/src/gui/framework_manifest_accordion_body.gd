tool
class_name FrameworkManifestAccordionBody, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_body.png"
extends VBoxContainer


export var is_open: bool setget _set_is_open,_get_is_open

var contents: Control
var _is_ready := false


func _ready() -> void:
    _is_ready = true
    var children := self.get_children()
    assert(children.size() == 1)
    assert(children[0] is Control)
    contents = children[0]


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    contents.visible = value


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return contents.visible

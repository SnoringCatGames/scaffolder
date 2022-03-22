tool
class_name FrameworkManifestAccordionPanel, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends VBoxContainer


export var is_open: bool setget _set_is_open,_get_is_open

var header: FrameworkManifestAccordionHeader
var body: FrameworkManifestAccordionBody
var _is_ready := false


func _ready() -> void:
    _is_ready = true
    header = Sc.utils.get_child_by_type(self, FrameworkManifestAccordionHeader)
    body = Sc.utils.get_child_by_type(self, FrameworkManifestAccordionBody)


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    body.is_open = value
    header.is_open = value


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return body.is_open

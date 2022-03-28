tool
class_name PluginAccordionBody, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_body.png"
extends VBoxContainer


export var is_open: bool setget _set_is_open,_get_is_open

var contents: Control
var _is_ready := false
var _configuration_warning := ""


func _ready() -> void:
    _is_ready = true
    var children := self.get_children()
    if children.size() != 1:
        _configuration_warning = "Must have one child."
        update_configuration_warning()
        return
    if !children[0] is Control:
        _configuration_warning = "Child must be a Control."
        update_configuration_warning()
        return
    contents = children[0]


func _set_is_open(value: bool) -> void:
    if !_is_ready or \
            !is_instance_valid(contents):
        return
    contents.visible = value


func _get_is_open() -> bool:
    if !_is_ready or \
            !is_instance_valid(contents):
        return false
    return contents.visible


func _get_configuration_warning() -> String:
    return _configuration_warning

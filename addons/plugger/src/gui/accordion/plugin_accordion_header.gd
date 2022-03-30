tool
class_name PluginAccordionHeader, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_header.png"
extends Button


export var is_open: bool setget _set_is_open
export var size_override := Vector2.ZERO setget _set_size_override

var contents: Control
var caret: PluginAccordionHeaderCaret
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
    
    var carets: Array = Sc.utils.get_children_by_type(
            self,
            PluginAccordionHeaderCaret,
            true)
    if carets.size() > 1:
        _configuration_warning = \
                "There must not be more than one " + \
                "PluginAccordionHeaderCaret descendant"
        update_configuration_warning()
        return
    if !carets.empty():
        caret = carets[0]
    
    _update_size()

    connect("resized", self, "_on_resized")


func _update_size() -> void:
    self.rect_min_size = size_override
    if is_instance_valid(contents):
        contents.rect_min_size = size_override


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    if is_instance_valid(caret):
        caret.is_open = value


func _set_size_override(value: Vector2) -> void:
    size_override = value
    _update_size()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _on_resized() -> void:
    if is_instance_valid(contents):
        contents.rect_size = rect_size

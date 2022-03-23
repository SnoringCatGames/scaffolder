tool
class_name FrameworkManifestAccordionPanel, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends VBoxContainer


export var is_open: bool setget _set_is_open,_get_is_open

var header: FrameworkManifestAccordionHeader
var body: FrameworkManifestAccordionBody
var _is_ready := false
var _configuration_warning := ""


func _ready() -> void:
    _is_ready = true
    
    var headers := Sc.utils.get_children_by_type(
            self, FrameworkManifestAccordionHeader)
    var bodies := Sc.utils.get_children_by_type(
            self, FrameworkManifestAccordionBody)
    if headers.size() != 1:
        _configuration_warning = \
                "Must have one FrameworkManifestAccordionHeader child."
        update_configuration_warning()
        return
    if headers.size() != 1:
        _configuration_warning = \
                "Must have one FrameworkManifestAccordionBody child."
        update_configuration_warning()
        return
    header = headers[0]
    body = bodies[0]
    
    header.connect("pressed", self, "_on_header_pressed")


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    body.is_open = value
    header.is_open = value


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return body.is_open


func _on_header_pressed() -> void:
    _set_is_open(!_get_is_open())


func _get_configuration_warning() -> String:
    return _configuration_warning

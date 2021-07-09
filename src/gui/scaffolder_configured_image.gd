tool
class_name ScaffolderConfiguredImage, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends Control


export var original_scale := 1.0 setget _set_original_scale

var _is_ready := false

var _configuration_warning := ""


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    _is_ready = true
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    _configuration_warning = ""
    
    if !_is_ready:
        return
    
    var children := get_children()
    if children.size() != 1:
        _configuration_warning = "Exactly one child must be defined."
        return
    var child: Node = children[0]
    
    Gs.utils.scale_gui_recursively(child)
    
    var scale: Vector2 = Vector2.ONE * original_scale
    child.rect_scale = scale
    rect_min_size = child.rect_size * scale
    rect_size = child.rect_size * scale


func _set_original_scale(value: float) -> void:
    original_scale = value
    _update()


func _get_configuration_warning() -> String:
    return _configuration_warning

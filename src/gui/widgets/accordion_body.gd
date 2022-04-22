tool
class_name AccordionBody, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_body.png"
extends Control


const HEIGHT_TWEEN_DURATION := 0.2

var _configuration_warning := ""

var _is_open := false

var _is_ready := false

var _panel
var _projected_control: Control

var _debounced_update_children: FuncRef = Sc.time.debounce(
        self, "_update_children_debounced", 0.02, true)


func _ready() -> void:
    _is_ready = true
    rect_clip_content = true
    _update_children()


func _on_gui_scale_changed() -> bool:
    rect_min_size.x = _panel.rect_min_size.x
    rect_size = rect_min_size
    
    Sc.gui.scale_gui_recursively(_projected_control)
    _projected_control.rect_size.x = rect_size.x
    
    return true


func add_child(child: Node, legible_unique_name := false) -> void:
    .add_child(child, legible_unique_name)
    _update_children()


func remove_child(child: Node) -> void:
    .remove_child(child)
    _update_children()


func _update_children() -> void:
    _debounced_update_children.call_func()


func _update_children_debounced() -> void:
    if !_is_ready:
        return
    
    var children := get_children()
    if children.size() != 1:
        _configuration_warning = \
                "Must define a child node." if \
                children.size() < 1 else \
                "Must define only one child node."
        update_configuration_warning()
        return
    
    var projected_node: Node = children[0]
    if !(projected_node is Control):
        _configuration_warning = "Child node must be of type 'Control'."
        update_configuration_warning()
        return
    
    _configuration_warning = ""
    update_configuration_warning()
    
    _projected_control = projected_node
    _projected_control.size_flags_vertical = Control.SIZE_FILL


func _tween_height(
        tween: ScaffolderTween,
        is_open: bool) -> void:
    if !is_instance_valid(_projected_control):
        return
    
    _projected_control.visible = true
    rect_clip_content = true
    
    var height_ratio_start: float
    var height_ratio_end: float
    if is_open:
        height_ratio_start = 0.0
        height_ratio_end = 1.0
    else:
        height_ratio_start = 1.0
        height_ratio_end = 0.0
    
    tween.interpolate_method(
            self,
            "_interpolate_height",
            height_ratio_start,
            height_ratio_end,
            HEIGHT_TWEEN_DURATION,
            "ease_in_out")


func _interpolate_height(open_ratio: float) -> void:
    if !is_instance_valid(_projected_control):
        return
    
    # NOTE: This hack is a work-around for an underlying bug in Godot's size
    #       calculations. For some reason, this forces an update to the actual
    #       rect_size value. Without this, rect_size will be inaccurate.
    _projected_control.rect_size.y = 0
    
    var projected_height := _projected_control.rect_size.y
    rect_min_size.y = projected_height * open_ratio
    rect_size = rect_min_size
    _projected_control.rect_position.y = -projected_height * (1.0 - open_ratio)
    
    _panel.update_height()


func _on_is_open_tween_completed(is_open: bool) -> void:
    if !is_instance_valid(_projected_control):
        return
    
    update_height()
    
    _projected_control.visible = is_open
    rect_clip_content = !is_open


func update_height() -> void:
    if !is_instance_valid(_projected_control):
        return
    
    var open_ratio := 1.0 if _is_open else 0.0
    _interpolate_height(open_ratio)


func _set_is_open(
        value: bool,
        is_tweening := false) -> void:
    if value == _is_open:
        return
    
    _is_open = value
    if _is_ready:
        _panel._trigger_open_change(is_tweening)


func _get_configuration_warning() -> String:
    return _configuration_warning

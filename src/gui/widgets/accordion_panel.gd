tool
class_name AccordionPanel, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends VBoxContainer


signal toggled
signal caret_rotated(rotation)

const SCROLL_TWEEN_DURATION := 0.3

export var is_open := false setget _set_is_open,_get_is_open

var _configuration_warning := ""

var _is_ready := false
var _scroll_container: ScrollContainer

var _header: AccordionHeader
var _body: AccordionBody
var _tween: ScaffolderTween

var _start_scroll_vertical: int

var _debounced_update_children: FuncRef = Sc.time.debounce(
        self, "_update_children_debounced", 0.02, true)


func _ready() -> void:
    _is_ready = true
    _update_children()


func _on_gui_scale_changed() -> bool:
    _update_children()
    Sc.time.set_timeout(self, "_trigger_open_change", 0.2, [false])
    return true


func _on_gui_scale_changed_debounced() -> void:
    if !_get_is_projection_valid():
        return
    
    var size := Vector2(
            (_header.size_override.x if \
            _header.size_override.x != 0.0 else \
            Sc.gui.screen_body_width) * Sc.gui.scale,
            rect_min_size.y)
    
    rect_min_size = size
    rect_size = size
    
    _header._on_gui_scale_changed()
    _body._on_gui_scale_changed()
    
    Sc.time.set_timeout(self, "_set_size", 0.01, [size])
    
    call_deferred("_on_is_open_tween_completed")


func update_height() -> void:
    rect_size.y = _header.rect_size.y + _body.rect_size.y


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
    
    if !is_instance_valid(_tween):
        _tween = ScaffolderTween.new(self)
        _tween.connect(
                "tween_all_completed",
                self,
                "_on_is_open_tween_completed")
        move_child(_tween, 0)
    
    var children := get_children()
    if children.size() < 3:
        _configuration_warning = (
            "Must define both a child AccordionHeader " +
            "and a child AccordionBody."
        )
        update_configuration_warning()
        return
    if children.size() > 3:
        _configuration_warning = (
            "Must define only a child AccordionHeader " +
            "and a child AccordionBody."
        )
        update_configuration_warning()
        return
    elif !(children[1] is AccordionHeader) and \
            !(children[2] is AccordionHeader):
        _configuration_warning = "Must define a child AccordionHeader."
        update_configuration_warning()
        return
    elif !(children[1] is AccordionBody) and \
            !(children[2] is AccordionBody):
        _configuration_warning = "Must define a child AccordionBody."
        update_configuration_warning()
        return
    elif children[1] is AccordionBody:
        _configuration_warning = "AccordionHeader must be before AccordionBody."
        update_configuration_warning()
        return
    else:
        _configuration_warning = ""
        update_configuration_warning()
    
    _header = children[1]
    _body = children[2]
    
    _header._panel = self
    _body._panel = self
    
    if _header.is_connected("caret_rotated", self, "_on_caret_rotated"):
        _header.disconnect("caret_rotated", self, "_on_caret_rotated")
    _header.connect("caret_rotated", self, "_on_caret_rotated")
    
    _on_gui_scale_changed_debounced()


func _trigger_open_change(is_tweening: bool) -> void:
    if !_get_is_projection_valid():
        return
    
    _tween.stop_all()
    
    if is_tweening:
        _body._tween_height(_tween, _body._is_open)
        _header._tween_caret_rotation(_tween, _body._is_open)
        _tween_scroll(_tween, _body._is_open)
        _tween.start()
    else:
        _on_is_open_tween_completed()


func _tween_scroll(
        tween: ScaffolderTween,
        is_open: bool) -> void:
    if !is_open:
        return
    
    var scroll_container: ScrollContainer = \
            Sc.nav.current_screen_container.scroll_container
    _start_scroll_vertical = scroll_container.scroll_vertical
    
    tween.interpolate_method(
            self,
            "_interpolate_scroll",
            0.0,
            1.0,
            SCROLL_TWEEN_DURATION,
            "ease_in_out")


func _on_is_open_tween_completed() -> void:
    if !_get_is_projection_valid():
        return
    
    _header._on_is_open_tween_completed(_body._is_open)
    _body._on_is_open_tween_completed(_body._is_open)


# Auto-scroll if opened past bottom of screen, but don't auto-scroll the header
# off the top of the screen!
func _interpolate_scroll(open_ratio: float) -> void:
    if !_get_is_projection_valid():
        return
    
    var scroll_container: ScrollContainer = \
            Sc.nav.current_screen_container.scroll_container
    if scroll_container == null:
        return
    
    var accordion_position_y_in_scroll_container: int = \
            Sc.utils.get_node_vscroll_position(scroll_container, self)
    var accordion_height := _body.rect_size.y + _header.rect_size.y
    
    var min_scroll_vertical_to_show_accordion_bottom := \
            accordion_position_y_in_scroll_container + \
            accordion_height - \
            scroll_container.rect_size.y
    var max_scroll_vertical_to_show_accordion_top: float = \
            accordion_position_y_in_scroll_container
    
    var is_scrolling_upward := \
            scroll_container.scroll_vertical > \
            max_scroll_vertical_to_show_accordion_top
    
    var end_scroll_vertical: float
    end_scroll_vertical = max_scroll_vertical_to_show_accordion_top
    # TODO: Remove?
#    if is_scrolling_upward:
#        end_scroll_vertical = max_scroll_vertical_to_show_accordion_top
#    else:
#        end_scroll_vertical = min(
#                min_scroll_vertical_to_show_accordion_bottom,
#                max_scroll_vertical_to_show_accordion_top)
    
    scroll_container.scroll_vertical = lerp(
            _start_scroll_vertical,
            end_scroll_vertical,
            open_ratio)


func _on_screen_visible() -> void:
    if !_get_is_projection_valid():
        return
    # If the containing screen has `visible = false`, then Godot will tell us
    # the that height of the projected content is 0.0. So we must wait until
    # the accordion is visible before calculating height.
    _body.update_height()


func _on_caret_rotated(rotation: float) -> void:
    emit_signal("caret_rotated", rotation)


func _get_configuration_warning() -> String:
    return _configuration_warning


func toggle() -> void:
    if !is_instance_valid(_body):
        return
    _body._set_is_open(!_body._is_open, true)
    emit_signal("toggled")


func _set_is_open(value: bool) -> void:
    if !is_instance_valid(_body):
        return
    _body._set_is_open(value, false)


func _get_is_open() -> bool:
    if !is_instance_valid(_body):
        return false
    else:
        return _body._is_open


func _get_is_projection_valid() -> bool:
    return is_instance_valid(_body) and \
            is_instance_valid(_header)


func update() -> void:
    _update_children()

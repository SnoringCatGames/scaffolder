tool
class_name DebugPanel, \
"res://addons/scaffolder/assets/images/editor_icons/debug_panel.png"
extends Node2D


const FONT_COLOR := Color("c5ff5e")
const CORNER_OFFSET := Vector2(0.0, 0.0)
const MESSAGE_COUNT_LIMIT := 500

var _is_ready := false
var text := ""
var _message_count := 0


func _init() -> void:
    name = "DebugPanel"


func _ready() -> void:
    _is_ready = true
    
    _log_print_queue()
    
    $PanelContainer.theme = Sc.gui.theme
    
    position.y = max(CORNER_OFFSET.y, Sc.device.get_safe_area_margin_top())
    position.x = max(CORNER_OFFSET.x, Sc.device.get_safe_area_margin_left())
    
    $PanelContainer/ScrollContainer/Label.add_color_override(
            "font_color", FONT_COLOR)
    $PanelContainer/ScaffolderTime.add_color_override("font_color", FONT_COLOR)
    
    Sc.time.set_timeout(self, "_delayed_init", 0.8)
    
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    
    $PanelContainer/ScaffolderTime.text = Sc.utils.get_time_string_from_seconds(
            Sc.time.get_app_time(),
            false,
            false,
            true) + " "


func _on_resized() -> void:
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    $PanelContainer/ScrollContainer.rect_min_size = viewport_size
    $PanelContainer/ScrollContainer/Label.rect_min_size.x = viewport_size.x


func _delayed_init() -> void:
    $PanelContainer/ScrollContainer/Label.text = text
    Sc.time.set_timeout(self, "_scroll_to_bottom", 0.2)


func add_message(message: String) -> void:
    text += "> " + message + "\n"
    _message_count += 1
    _remove_surplus_message()
    if _is_ready:
        $PanelContainer/ScrollContainer/Label.text = text
        Sc.time.set_timeout(self, "_scroll_to_bottom", 0.2)


func _remove_surplus_message() -> void:
    # Remove the oldest message.
    if _message_count > MESSAGE_COUNT_LIMIT:
        var index := text.find("\n> ")
        text = text.substr(index + 1)


func _scroll_to_bottom() -> void:
    $PanelContainer/ScrollContainer.scroll_vertical = \
            $PanelContainer/ScrollContainer.get_v_scrollbar().max_value


func _log_print_queue() -> void:
    for entry in Sc.logger._print_queue:
        add_message(entry)
    Sc.logger._print_queue.clear()


func _on_PanelContainer_gui_input(event: InputEvent) -> void:
    var is_mouse_down: bool = \
            event is InputEventMouseButton and \
            event.pressed and \
            event.button_index == BUTTON_LEFT
    var is_touch_down: bool = \
            (event is InputEventScreenTouch and \
                    event.pressed) or \
            event is InputEventScreenDrag
    var is_scroll: bool = \
            event is InputEventMouseButton and \
            (event.button_index == BUTTON_WHEEL_UP or \
            event.button_index == BUTTON_WHEEL_DOWN)\
    
#    if (is_mouse_down or is_touch_down or is_scroll) and \
#            $PanelContainer.get_rect().has_point(event.position):
#        $PanelContainer.accept_event()

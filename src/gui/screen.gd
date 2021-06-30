tool
class_name Screen, "res://addons/scaffolder/assets/images/editor_icons/screen.png"
extends VBoxContainer


export var screen_name := ""
export var nav_bar_text := ""
export var is_back_button_shown := true
export var is_about_button_shown := false
export var is_settings_button_shown := false
export var is_nav_bar_logo_shown := false
export(String, "menu", "game") var layer := "menu"
export var is_always_alive := false
export var width_override := 0.0
var background_color_override := Color.black

var params: Dictionary

var container
var focused_button: ScaffolderButton

var _configuration_warning := ""


func _ready() -> void:
    if Engine.editor_hint:
        rect_size = Vector2(1024, 768)
        return
    
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _destroy() -> void:
    if !is_queued_for_deletion():
        queue_free()


func update_gui_scale() -> bool:
    return false


func _on_activated(previous_screen: Screen) -> void:
    _give_button_focus(_get_focused_button())
    Gs.utils.set_mouse_filter_recursively(
            self,
            Control.MOUSE_FILTER_PASS)


func _on_deactivated(next_screen: Screen) -> void:
    pass


func _on_resized() -> void:
    if Engine.editor_hint:
        _configuration_warning = ""
        if screen_name == "":
            _configuration_warning = "screen_name must be defined."
    update_gui_scale()


func _unhandled_key_input(event: InputEventKey) -> void:
    if (event.scancode == KEY_SPACE or \
            event.scancode == KEY_ENTER) and \
            event.pressed and \
            focused_button != null and \
            Gs.nav.current_screen == self:
        # Press the currently designated main button.
        focused_button.press()
    elif (event.scancode == KEY_ESCAPE) and \
            event.pressed and \
            container.nav_bar != null and \
            container.nav_bar.shows_back and \
            Gs.nav.current_screen == self:
        # Go back when pressing escape.
        Gs.nav.close_current_screen()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and \
            event.pressed and \
            event.button_index == BUTTON_XBUTTON1 and \
            container.nav_bar != null and \
            container.nav_bar.shows_back and \
            Gs.nav.current_screen == self:
        # Go back when pressing the mouse-back button.
        Gs.nav.close_current_screen()


func _get_focused_button() -> ScaffolderButton:
    return null


func _scroll_to_top() -> void:
    yield(get_tree(), "idle_frame")
    var scroll_bar: VScrollBar = container.scrollcontainer.get_v_scrollbar()
    container.scrollcontainer.scroll_vertical = scroll_bar.min_value


func _give_button_focus(button: ScaffolderButton) -> void:
    if focused_button != null:
        focused_button.is_shiny = false
        focused_button.includes_color_pulse = false
    focused_button = button
    if focused_button != null:
        focused_button.is_shiny = true
        focused_button.includes_color_pulse = true


func set_params(params) -> void:
    if params == null:
        return
    self.params = params


func get_is_nav_bar_shown() -> bool:
    return is_back_button_shown or \
            is_about_button_shown or \
            is_settings_button_shown or \
            is_nav_bar_logo_shown or \
            nav_bar_text != ""


func _get_configuration_warning() -> String:
    return _configuration_warning

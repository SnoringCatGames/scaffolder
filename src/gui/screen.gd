tool
class_name Screen, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_panel_container.png"
extends VBoxContainer


export var screen_name := ""
export var nav_bar_text := ""
export(String, "Xs", "S", "M", "L", "Xl") var nav_bar_font_size := "Xl"
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
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _destroy() -> void:
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    return false


func _on_transition_in_started(previous_screen: Screen) -> void:
    _give_button_focus(_get_focused_button())
    if get_is_mouse_handled_by_gui():
        Sc.utils.set_mouse_filter_recursively(
                self,
                Control.MOUSE_FILTER_PASS)


func _on_transition_out_started(next_screen: Screen) -> void:
    pass


func _on_transition_in_ended(previous_screen: Screen) -> void:
    pass


func _on_transition_out_ended(next_screen: Screen) -> void:
    pass


func _on_resized() -> void:
    if Engine.editor_hint:
        if screen_name == "":
            _configuration_warning = "screen_name must be defined."
        else:
            _configuration_warning = ""
        update_configuration_warning()
        rect_min_size = Sc.gui.default_pc_game_area_size
    _on_gui_scale_changed()


func _process(_delta: float) -> void:
    if (Input.is_action_just_pressed("ui_accept") or \
            Input.is_action_just_pressed("ui_select")) and \
            focused_button != null and \
            Sc.nav.current_screen == self:
        # Press the currently designated main button.
        focused_button.press()
        
    # TODO: Use Input.is_action_just_pressed("sc_back") instead of checking
    #       button key directly. Currently, Godot reports an error in the
    #       editor when we try to use this: "ERROR: Request for nonexistent
    #       InputMap action 'sc_back'".
    elif Input.is_action_just_pressed("ui_cancel") and \
            is_instance_valid(container.nav_bar) and \
            container.nav_bar.shows_back and \
            Sc.nav.current_screen == self:
        # Go back when pressing escape or the mouse-back button.
        Sc.nav.close_current_screen()

# TODO: Use Input.is_action_just_pressed("sc_back") in _process instead of
#       checking button key directly. Currently, Godot reports an error in the
#       editor when we try to use this: "ERROR: Request for nonexistent
#       InputMap action 'sc_back'."
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and \
            event.pressed and \
            event.button_index == BUTTON_XBUTTON1 and \
            is_instance_valid(container.nav_bar) and \
            container.nav_bar.shows_back and \
            Sc.nav.current_screen == self:
        Sc.nav.close_current_screen()


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


func get_is_mouse_handled_by_gui() -> bool:
    return layer == "menu"


func _get_configuration_warning() -> String:
    return _configuration_warning

class_name Screen
extends Node2D


var screen_name: String
var layer_name: String
var is_always_alive: bool
var auto_adapts_gui_scale: bool
var includes_standard_hierarchy: bool
var includes_nav_bar: bool
var includes_center_container: bool
var background_color: Color

var outer_panel_container: PanelContainer
var nav_bar: Control
var scroll_container: ScrollContainer
var inner_vbox: VBoxContainer
var stylebox: StyleBoxFlatScalable

var _focused_button: ScaffolderButton

var params: Dictionary


func _init(
        screen_name: String,
        layer_name: String,
        is_always_alive: bool,
        auto_adapts_gui_scale: bool,
        includes_standard_hierarchy: bool,
        includes_nav_bar := true,
        includes_center_container := true,
        background_color := Gs.colors.background) -> void:
    self.screen_name = screen_name
    self.layer_name = layer_name
    self.is_always_alive = is_always_alive
    self.auto_adapts_gui_scale = auto_adapts_gui_scale
    self.includes_standard_hierarchy = includes_standard_hierarchy
    self.includes_nav_bar = includes_nav_bar
    self.includes_center_container = includes_center_container
    self.background_color = background_color


func _ready() -> void:
    _validate_node_hierarchy()
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _destroy() -> void:
    if is_instance_valid(stylebox):
        stylebox.destroy()
    Gs.gui.remove_gui_to_scale(outer_panel_container)
    if !is_queued_for_deletion():
        queue_free()


func _exit_tree() -> void:
    _destroy()


func _on_activated(previous_screen: Screen) -> void:
    _give_button_focus(_get_focused_button())
    if includes_standard_hierarchy:
        Gs.utils.set_mouse_filter_recursively(
                scroll_container,
                Control.MOUSE_FILTER_PASS)


func _on_deactivated(next_screen: Screen) -> void:
    pass


func _on_resized() -> void:
    pass


func _unhandled_key_input(event: InputEventKey) -> void:
    if (event.scancode == KEY_SPACE or \
            event.scancode == KEY_ENTER) and \
            event.pressed and \
            _focused_button != null and \
            Gs.nav.current_screen == self:
        # Press the currently designated main button.
        _focused_button.press()
    elif (event.scancode == KEY_ESCAPE) and \
            event.pressed and \
            nav_bar != null and \
            nav_bar.shows_back and \
            Gs.nav.current_screen == self:
        # Go back when pressing escape.
        Gs.nav.close_current_screen()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and \
            event.pressed and \
            event.button_index == BUTTON_XBUTTON1 and \
            nav_bar != null and \
            nav_bar.shows_back and \
            Gs.nav.current_screen == self:
        # Go back when pressing the mouse-back button.
        Gs.nav.close_current_screen()


func _validate_node_hierarchy() -> void:
    # Give a shadow to the outer-most panel.
    outer_panel_container = get_child(0)
    assert(outer_panel_container is PanelContainer)
    outer_panel_container.theme = Gs.gui.theme
    stylebox = Gs.utils.create_stylebox_flat_scalable({
        bg_color = background_color,
        shadow_size = 8,
        shadow_offset = Vector2(-4.0, 4.0),
    })
    outer_panel_container.add_stylebox_override("panel", stylebox)
    
    if auto_adapts_gui_scale:
        Gs.gui.add_gui_to_scale(outer_panel_container)
    
    if includes_standard_hierarchy:
        var outer_vbox: VBoxContainer = $FullScreenPanel/VBoxContainer
        outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
        
        if includes_nav_bar:
            nav_bar = $FullScreenPanel/VBoxContainer/NavBar
        
        scroll_container = \
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer
        assert(scroll_container != null)
        scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        
        if includes_center_container:
            inner_vbox = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/CenterContainer/VBoxContainer
            assert(inner_vbox != null)
            
            var center_container: CenterContainer = \
                    $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/CenterContainer
            center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        else:
            inner_vbox = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/VBoxContainer
            assert(inner_vbox != null)
        
        var original_rect_min_size := Vector2(
                Gs.gui.screen_body_width,
                inner_vbox.rect_min_size.y)
        inner_vbox.set_meta("gs_rect_min_size", original_rect_min_size)
        inner_vbox.rect_min_size.x = original_rect_min_size.x * Gs.gui.scale
        
        Gs.utils.set_mouse_filter_recursively(
                scroll_container,
                Control.MOUSE_FILTER_PASS)
        
        Gs.utils.set_link_color_recursively(scroll_container)


func _get_focused_button() -> ScaffolderButton:
    return null


func _scroll_to_top() -> void:
    if includes_standard_hierarchy:
        yield(get_tree(), "idle_frame")
        var scroll_bar := scroll_container.get_v_scrollbar()
        scroll_container.scroll_vertical = scroll_bar.min_value


func _give_button_focus(button: ScaffolderButton) -> void:
    if _focused_button != null:
        _focused_button.is_shiny = false
        _focused_button.includes_color_pulse = false
    _focused_button = button
    if _focused_button != null:
        _focused_button.is_shiny = true
        _focused_button.includes_color_pulse = true


func set_params(params) -> void:
    if params == null:
        return
    self.params = params

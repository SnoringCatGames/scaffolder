tool
class_name ScreenContainer, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends Node2D


var contents: Screen
var outer_panel: FullScreenPanel
var nav_bar: NavBar
var scroll_container: ScrollContainer
var stylebox: StyleBoxFlatScalable


func _ready() -> void:
    if Engine.editor_hint:
        $FullScreenPanel.rect_size = Vector2(1024, 768)


func set_up(contents: Screen) -> void:
    self.outer_panel = $FullScreenPanel
    var vbox_container := $FullScreenPanel/VBoxContainer
    self.nav_bar = $FullScreenPanel/VBoxContainer/NavBar
    var centered_panel := $FullScreenPanel/VBoxContainer/CenteredPanel
    self.scroll_container = \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer
    var center_container := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer
    
    self.contents = contents
    contents.container = self
    
    var contents_width := \
            contents.width_override if \
            contents.width_override != 0.0 else \
            Gs.gui.screen_body_width
    var original_rect_min_size := Vector2(
            contents_width,
            0.0)
    contents.set_meta("gs_rect_min_size", original_rect_min_size)
    
    center_container.add_child(contents)
    
    outer_panel.theme = Gs.gui.theme
    var has_background_color_override := \
            contents.background_color_override != Color.black
    var background_color := \
            contents.background_color_override if \
            has_background_color_override else \
            Gs.colors.background
    stylebox = Gs.utils.create_stylebox_scalable({
        bg_color = background_color,
        shadow_size = Gs.styles.screen_shadow_size,
        shadow_offset = Gs.styles.screen_shadow_offset,
        border_width = Gs.styles.screen_border_width,
        border_color = Gs.colors.screen_border,
    })
    outer_panel.add_stylebox_override("panel", stylebox)
    Gs.gui.add_gui_to_scale(outer_panel)
    
    if has_background_color_override:
        var centered_panel_stylebox := StyleBoxFlat.new()
        centered_panel_stylebox.bg_color = background_color
        centered_panel.add_stylebox_override("panel", centered_panel_stylebox)
    
    if !contents.get_is_nav_bar_shown():
        nav_bar.queue_free()
    else:
        nav_bar.shows_back = contents.is_back_button_shown
        nav_bar.shows_about = contents.is_about_button_shown
        nav_bar.shows_settings = contents.is_settings_button_shown
        nav_bar.shows_logo = contents.is_nav_bar_logo_shown
        nav_bar.text = contents.nav_bar_text
        nav_bar.font_size = contents.nav_bar_font_size
    
    if !contents.get_is_mouse_handled_by_gui():
        for control in [
                    outer_panel,
                    vbox_container,
                    nav_bar,
                    centered_panel,
                    scroll_container,
                    center_container,
                    contents,
                ]:
            control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    _update()


func _destroy() -> void:
    if is_instance_valid(contents):
        contents._destroy()
    if is_instance_valid(stylebox):
        stylebox.destroy()
    if is_instance_valid(outer_panel):
        Gs.gui.remove_gui_to_scale(outer_panel)
    if !is_queued_for_deletion():
        queue_free()


func _exit_tree() -> void:
    if Engine.editor_hint:
        return
    
    _destroy()


func _update() -> void:
    var contents_size: Vector2 = \
            contents.get_meta("gs_rect_min_size") * Gs.gui.scale
    contents_size.x = min(contents_size.x, get_viewport().size.x)
    contents.rect_min_size = contents_size


func _on_transition_in_started(
        previous_screen_container: ScreenContainer) -> void:
    var previous_screen := \
            previous_screen_container.contents if \
            is_instance_valid(previous_screen_container) else \
            null
    contents._on_transition_in_started(previous_screen)


func _on_transition_out_started(
        next_screen_container: ScreenContainer) -> void:
    var next_screen := \
            next_screen_container.contents if \
            is_instance_valid(next_screen_container) else \
            null
    contents._on_transition_out_started(next_screen)


func _on_transition_in_ended(
        previous_screen_container: ScreenContainer) -> void:
    var previous_screen := \
            previous_screen_container.contents if \
            is_instance_valid(previous_screen_container) else \
            null
    contents._on_transition_in_ended(previous_screen)


func _on_transition_out_ended(
        next_screen_container: ScreenContainer) -> void:
    var next_screen := \
            next_screen_container.contents if \
            is_instance_valid(next_screen_container) else \
            null
    contents._on_transition_out_ended(next_screen)


func set_visible(value: bool) -> void:
    .set_visible(value)
    if value:
        Gs.utils.notify_on_screen_visible_recursively(self)

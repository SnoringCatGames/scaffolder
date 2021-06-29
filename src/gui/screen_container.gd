tool
class_name ScreenContainer, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
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
    self.nav_bar = $FullScreenPanel/VBoxContainer/NavBar
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
            contents.rect_size.y)
    contents.set_meta("gs_rect_min_size", original_rect_min_size)
    
    center_container.add_child(contents)
    
    outer_panel.theme = Gs.gui.theme
    # FIXME: -----------------------
    # - Configure screen shadow / border in Scaffolder.
    var background_color := \
            contents.background_color_override if \
            contents.background_color_override != Color.black else \
            Gs.colors.background
    stylebox = Gs.utils.create_stylebox_flat_scalable({
        bg_color = background_color,
        shadow_size = 8,
        shadow_offset = Vector2(-4.0, 4.0),
    })
    outer_panel.add_stylebox_override("panel", stylebox)
    Gs.gui.add_gui_to_scale(outer_panel)
    
    if !contents.get_is_nav_bar_shown():
        nav_bar.queue_free()
    else:
        nav_bar.shows_back = contents.is_back_button_shown
        nav_bar.shows_about = contents.is_about_button_shown
        nav_bar.shows_settings = contents.is_settings_button_shown
        nav_bar.shows_logo = contents.is_nav_bar_logo_shown
        nav_bar.text = contents.nav_bar_text
    
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


func update_gui_scale() -> void:
    _update()
    contents.update_gui_scale()


func _update() -> void:
    var contents_size: Vector2 = \
            contents.get_meta("gs_rect_min_size") * Gs.gui.scale
    contents_size.x = min(contents_size.x, get_viewport().size.x)
    contents.rect_min_size = contents_size


func _on_activated(previous_screen_container: ScreenContainer) -> void:
    var previous_screen := \
            previous_screen_container.contents if \
            is_instance_valid(previous_screen_container) else \
            null
    contents._on_activated(previous_screen)


func _on_deactivated(next_screen_container: ScreenContainer) -> void:
    var next_screen := \
            next_screen_container.contents if \
            is_instance_valid(next_screen_container) else \
            null
    contents._on_activated(next_screen)
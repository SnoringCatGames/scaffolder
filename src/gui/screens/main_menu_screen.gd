class_name MainMenuScreen
extends Screen


var go_icon_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    if Gs.gui.is_main_menu_image_shown:
        projected_image = Gs.utils.add_scene(
                $VBoxContainer/MainMenuImageContainer,
                Gs.gui.main_menu_image_scene,
                true,
                true)
        projected_image.original_scale = Gs.gui.main_menu_image_scale
    $VBoxContainer/Title.texture = Gs.app_metadata.app_logo
    $VBoxContainer/StartGameButton.texture = Gs.app_metadata.go_icon
    $VBoxContainer/StartGameButton.texture_scale = \
            Vector2(Gs.app_metadata.go_icon_scale,
                    Gs.app_metadata.go_icon_scale) * \
            go_icon_scale_multiplier
    
    _on_resized()


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/StartGameButton as ScaffolderButton


func _on_resized() -> void:
    ._on_resized()
    
    if Engine.editor_hint:
        return
    
    var viewport_size := get_viewport().size
    var is_wide_enough_to_put_title_in_nav_bar: bool = \
            viewport_size.x > Gs.app_metadata.app_logo.get_width() + 256
    container.nav_bar.shows_logo = \
            is_wide_enough_to_put_title_in_nav_bar
    $VBoxContainer/Title.visible = !is_wide_enough_to_put_title_in_nav_bar


func _on_StartGameButton_pressed() -> void:
    Gs.nav.open("level_select")

class_name MainMenuScreen
extends Screen


var go_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    # FIXME: ------------------- REMOVE
    for option in ["option 1", "option 2", "option 3"]:
        $VBoxContainer/OptionButton.add_item(option)
    
    if Gs.gui.is_main_menu_image_shown:
        projected_image = Gs.utils.add_scene(
                $VBoxContainer/MainMenuImageContainer,
                Gs.gui.main_menu_image_scene,
                true,
                true)
        projected_image.original_scale = Gs.gui.main_menu_image_scale
    $VBoxContainer/StartGameButton.texture = Gs.icons.go_normal
    $VBoxContainer/StartGameButton.texture_scale = \
            Vector2(Gs.icons.go_scale, Gs.icons.go_scale) * \
            go_scale_multiplier
    
    _on_resized()


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/StartGameButton as ScaffolderButton


func _on_StartGameButton_pressed() -> void:
    Gs.nav.open("level_select")

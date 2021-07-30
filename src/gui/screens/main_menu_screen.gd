tool
class_name MainMenuScreen
extends Screen


var go_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _ready() -> void:
    if Sc.gui.is_main_menu_image_shown:
        projected_image = Sc.utils.add_scene(
                $VBoxContainer/MainMenuImageContainer,
                Sc.gui.main_menu_image_scene,
                true,
                true)
        projected_image.original_scale = Sc.gui.main_menu_image_scale
    $VBoxContainer/StartGameButton.texture_scale = \
            Vector2(Sc.images.go_scale, Sc.images.go_scale) * \
            go_scale_multiplier
    
    _on_resized()


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/StartGameButton as ScaffolderButton


func _on_StartGameButton_pressed() -> void:
    Sc.nav.open("level_select")

class_name MainMenuScreen
extends Screen


const NAME := "main_menu"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

var go_icon_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _init().(
        NAME,
        LAYER_NAME,
        IS_ALWAYS_ALIVE,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


func _ready() -> void:
    if Gs.gui.is_main_menu_image_shown:
        projected_image = Gs.utils.add_scene(
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                        CenterContainer/VBoxContainer/MainMenuImageContainer,
                Gs.gui.main_menu_image_scene,
                true,
                true)
        projected_image.original_scale = Gs.gui.main_menu_image_scale
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/Title.texture = \
            Gs.app_metadata.app_logo
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/StartGameButton.texture = \
            Gs.app_metadata.go_icon
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/StartGameButton.texture_scale = \
            Vector2(Gs.app_metadata.go_icon_scale,
                    Gs.app_metadata.go_icon_scale) * \
            go_icon_scale_multiplier
    
    _on_resized()


func _get_focused_button() -> ScaffolderButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/StartGameButton as ScaffolderButton


func _on_resized() -> void:
    ._on_resized()
    var viewport_size := get_viewport().size
    var is_wide_enough_to_put_title_in_nav_bar: bool = \
            viewport_size.x > Gs.app_metadata.app_logo.get_width() + 256
    $FullScreenPanel/VBoxContainer/NavBar.shows_logo = \
            is_wide_enough_to_put_title_in_nav_bar
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/Title.visible = \
                    !is_wide_enough_to_put_title_in_nav_bar


func _on_StartGameButton_pressed() -> void:
    Gs.nav.open("level_select")

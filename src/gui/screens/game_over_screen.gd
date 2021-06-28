tool
class_name GameOverScreen
extends Screen


const NAME := "game_over"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := false
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
    if Gs.gui.is_game_over_image_shown:
        projected_image = Gs.utils.add_scene(
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
                        CenterContainer/VBoxContainer/GameOverImageContainer,
                Gs.gui.game_over_image_scene,
                true,
                true)
        projected_image.original_scale = Gs.gui.game_over_image_scale
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/SelectLevelButton \
            .texture = Gs.app_metadata.go_icon
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/SelectLevelButton \
            .texture_scale = Vector2(
                    Gs.app_metadata.go_icon_scale,
                    Gs.app_metadata.go_icon_scale) * \
                    go_icon_scale_multiplier
    _update_stats()


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    Gs.audio.play_music(Gs.audio_manifest.game_over_music)
    _update_stats()
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel.toggle()


func _get_focused_button() -> ScaffolderButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/ \
            SelectLevelButton as ScaffolderButton


func _update_stats() -> void:
    var unlocked_new_level_label := $FullScreenPanel/VBoxContainer/ \
            CenteredPanel/ScrollContainer/CenterContainer/VBoxContainer/ \
            VBoxContainer2/UnlockedNewLevelLabel
    var was_best_playthrough_label := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            WasBestPlaythroughLabel
    var was_fastest_playthrough_label := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            WasFastestPlaythroughLabel
    var control_list := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/AccordionPanel/ \
            LabeledControlList
    
    unlocked_new_level_label.visible = \
            !Gs.level_session.new_unlocked_levels.empty()
    
    was_best_playthrough_label.visible = \
            Gs.level_session.is_new_high_score
    
    was_fastest_playthrough_label.visible = \
            Gs.level_session.is_fastest_time
    
    control_list.items = _get_items()


func _get_items() -> Array:
    var items := []
    for item_class in Gs.gui.game_over_item_manifest:
        items.push_back(item_class.new(Gs.level_session.id))
    return items


func _on_SelectLevelButton_pressed():
    Gs.audio.play_music(Gs.audio_manifest.main_menu_music)
    Gs.nav.open("level_select")


func _on_HomeButton_pressed():
    Gs.audio.play_music(Gs.audio_manifest.main_menu_music)
    Gs.nav.open("main_menu")


func _on_RetryButton_pressed():
    Gs.nav.open("game")
    Gs.nav.screens["game"].start_level(Gs.level_session.id)

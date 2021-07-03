tool
class_name GameOverScreen
extends Screen


const ACHIEVEMENT_COLOR := Color("fff175")

var go_icon_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    if Gs.gui.is_game_over_image_shown:
        projected_image = Gs.utils.add_scene(
                $VBoxContainer/GameOverImageContainer,
                Gs.gui.game_over_image_scene,
                true,
                true)
        projected_image.original_scale = Gs.gui.game_over_image_scale
    $VBoxContainer/VBoxContainer/SelectLevelButton.texture = \
            Gs.app_metadata.go_icon
    $VBoxContainer/VBoxContainer/SelectLevelButton.texture_scale = \
            Vector2(Gs.app_metadata.go_icon_scale,
                    Gs.app_metadata.go_icon_scale) * \
                    go_icon_scale_multiplier
    
    $VBoxContainer/VBoxContainer2/UnlockedNewLevelLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    $VBoxContainer/VBoxContainer2/WasBestPlaythroughLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    $VBoxContainer/VBoxContainer2/WasFastestPlaythroughLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    
    _update_stats()


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    Gs.audio.play_music(Gs.audio_manifest.game_over_music)
    _update_stats()
    $VBoxContainer/AccordionPanel.toggle()


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/VBoxContainer/SelectLevelButton as ScaffolderButton


func _update_stats() -> void:
    var unlocked_new_level_label := \
            $VBoxContainer/VBoxContainer2/UnlockedNewLevelLabel
    var was_best_playthrough_label := \
            $VBoxContainer/VBoxContainer2/WasBestPlaythroughLabel
    var was_fastest_playthrough_label := \
            $VBoxContainer/VBoxContainer2/WasFastestPlaythroughLabel
    var control_list := $VBoxContainer/AccordionPanel/LabeledControlList
    
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


func _on_SelectLevelButton_pressed() -> void:
    Gs.audio.play_music(Gs.audio_manifest.main_menu_music)
    Gs.nav.open("level_select")


func _on_HomeButton_pressed() -> void:
    Gs.audio.play_music(Gs.audio_manifest.main_menu_music)
    Gs.nav.open("main_menu")


func _on_RetryButton_pressed() -> void:
    Gs.nav.open("loading", false, {level_id = Gs.level_session.id})

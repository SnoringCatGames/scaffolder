tool
class_name GameOverScreen
extends Screen


const ACHIEVEMENT_COLOR := Color("fff175")

var go_scale_multiplier := 1.0

var projected_image: ScaffolderConfiguredImage


func _ready() -> void:
    if Sc.gui.is_game_over_image_shown:
        projected_image = Sc.utils.add_scene(
                $VBoxContainer/GameOverImageContainer,
                Sc.gui.game_over_image_scene,
                true,
                true)
        projected_image.original_scale = Sc.gui.game_over_image_scale
    $VBoxContainer/VBoxContainer/SelectLevelButton \
            .texture = Sc.images.go_normal
    $VBoxContainer/VBoxContainer/SelectLevelButton.texture_scale = \
            Vector2(Sc.images.go_scale, Sc.images.go_scale) * \
                    go_scale_multiplier
    $VBoxContainer/VBoxContainer/HBoxContainer/HomeButton \
            .texture = Sc.images.home_normal
    $VBoxContainer/VBoxContainer/HBoxContainer/HomeButton \
            .texture_scale = Vector2(2.0, 2.0)
    $VBoxContainer/VBoxContainer/HBoxContainer/RetryButton \
            .texture = Sc.images.retry_normal
    $VBoxContainer/VBoxContainer/HBoxContainer/RetryButton \
            .texture_scale = Vector2(2.0, 2.0)
    
    $VBoxContainer/VBoxContainer2/UnlockedNewLevelLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    $VBoxContainer/VBoxContainer2/WasBestPlaythroughLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    $VBoxContainer/VBoxContainer2/WasFastestPlaythroughLabel \
            .add_color_override("font_color", ACHIEVEMENT_COLOR)
    
    _update_stats()


func _on_transition_in_started(previous_screen: Screen) -> void:
    ._on_transition_in_started(previous_screen)
    Sc.audio.play_music(Sc.audio_manifest.game_over_music)
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
    var control_list := \
            $VBoxContainer/AccordionPanel/AccordionBody/LabeledControlList
    
    unlocked_new_level_label.visible = \
            !Sc.level_session.new_unlocked_levels.empty()
    
    was_best_playthrough_label.visible = \
            Sc.level_session.is_new_high_score
    
    was_fastest_playthrough_label.visible = \
            Sc.level_session.is_fastest_time
    
    control_list.items = _get_items()


func _get_items() -> Array:
    var items := []
    for item_class in Sc.gui.game_over_item_manifest:
        items.push_back(item_class.new(Sc.level_session.id))
    return items


func _on_SelectLevelButton_pressed() -> void:
    Sc.audio.play_music(Sc.audio_manifest.main_menu_music)
    Sc.nav.open("level_select")


func _on_HomeButton_pressed() -> void:
    Sc.audio.play_music(Sc.audio_manifest.main_menu_music)
    Sc.nav.open("main_menu")


func _on_RetryButton_pressed() -> void:
    Sc.nav.open(
            "loading",
            ScreenTransition.DEFAULT,
            {level_id = Sc.level_session.id})

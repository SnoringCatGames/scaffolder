tool
class_name PauseScreen
extends Screen


const NAME := "pause"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true


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


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/LabeledControlList \
            .items = _get_items()
    _give_button_focus($FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/VBoxContainer/ \
            ResumeButton)


func _get_items() -> Array:
    var items := []
    for item_class in Gs.gui.pause_item_manifest:
        items.push_back(item_class.new(Gs.level_session))
    return items


func _get_focused_button() -> ScaffolderButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/ResumeButton as \
            ScaffolderButton


func _on_ExitLevelButton_pressed() -> void:
    Gs.nav.close_current_screen()
    Gs.level.quit(false, false)


func _on_ResumeButton_pressed() -> void:
    Gs.nav.close_current_screen()


func _on_RestartButton_pressed() -> void:
    Gs.nav.close_current_screen(true)
    Gs.level.restart()


func _on_SendRecentGestureEventsForDebugging_pressed() -> void:
    Gs.gesture_reporter.record_recent_gestures()

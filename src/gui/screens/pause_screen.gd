tool
class_name PauseScreen
extends Screen


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    $VBoxContainer/LabeledControlList.items = _get_items()
    _give_button_focus($VBoxContainer/VBoxContainer/ResumeButton)


func _get_items() -> Array:
    var items := []
    for item_class in Gs.gui.pause_item_manifest:
        items.push_back(item_class.new(Gs.level_session))
    return items


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/VBoxContainer/ResumeButton as ScaffolderButton


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

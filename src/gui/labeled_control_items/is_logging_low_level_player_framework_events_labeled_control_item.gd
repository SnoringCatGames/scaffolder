class_name IsLoggingLowLevelPlayerFrameworkEventsSettingsLabeledControlItem
extends CheckboxLabeledControlItem


const LABEL := "Low-level logs"
const DESCRIPTION := (
        "This toggles whether low-level player framework events are " +
        "printed. " +
        "These events can be helpful for debugging, and normal users " +
        "won't care. " +
        "These logs would be shown in the debug panel.")


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.metadata.is_logging_low_level_player_framework_events = pressed
    Sc.save_state.set_setting(
            SaveState \
                    .IS_LOGGING_LOW_LEVEL_PLAYER_FRAMEWORK_EVENTS_SETTINGS_KEY,
            pressed)


func get_is_pressed() -> bool:
    return Sc.metadata.is_logging_low_level_player_framework_events


func get_is_enabled() -> bool:
    return true

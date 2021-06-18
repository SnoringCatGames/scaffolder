class_name DebugTimeDisplaySettingsLabeledControlItem
extends CheckboxLabeledControlItem


const LABEL := "Debug time display"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Gs.gui.is_debug_time_shown = pressed
    Gs.save_state.set_setting(
            SaveState.IS_DEBUG_TIME_SHOWN_SETTINGS_KEY,
            Gs.gui.is_debug_time_shown)


func get_is_pressed() -> bool:
    return Gs.gui.is_debug_time_shown


func get_is_enabled() -> bool:
    return true

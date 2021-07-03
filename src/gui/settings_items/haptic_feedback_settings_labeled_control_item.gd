class_name HapticFeedbackSettingsLabeledControlItem
extends CheckboxLabeledControlItem


const LABEL := "Haptic feedback"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Gs.gui.is_giving_haptic_feedback = pressed
    Gs.save_state.set_setting(
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY,
            Gs.gui.is_giving_haptic_feedback)


func get_is_pressed() -> bool:
    return Gs.gui.is_giving_haptic_feedback


func get_is_enabled() -> bool:
    return Gs.device.get_is_mobile_app()

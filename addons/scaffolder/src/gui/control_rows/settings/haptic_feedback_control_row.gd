class_name HapticFeedbackControlRow
extends CheckboxControlRow


const LABEL := "Haptic feedback"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.gui.is_giving_haptic_feedback = pressed
    Sc.save_state.set_setting(
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY,
            Sc.gui.is_giving_haptic_feedback)


func get_is_pressed() -> bool:
    return Sc.gui.is_giving_haptic_feedback


func get_is_enabled() -> bool:
    return Sc.device.get_is_mobile_app()

class_name ButtonControlsControlRow
extends CheckboxControlRow


const LABEL := "Keyboard controls"
const DESCRIPTION := (
        "")


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.metadata.are_button_controls_enabled = pressed
    Sc.save_state.set_setting(
            SaveState.ARE_BUTTON_CONTROLS_ENABLED_SETTINGS_KEY,
            pressed)


func get_is_pressed() -> bool:
    return Sc.metadata.are_button_controls_enabled


func get_is_enabled() -> bool:
    return true

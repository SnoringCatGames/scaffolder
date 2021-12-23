class_name MetronomeControlRow
extends CheckboxControlRow


const LABEL := "Metronome"
const DESCRIPTION := (
        "")


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.audio.is_metronome_enabled = pressed
    Sc.save_state.set_setting(
            SaveState.IS_METRONOME_ENABLED_SETTINGS_KEY,
            pressed)


func get_is_pressed() -> bool:
    return Sc.audio.is_metronome_enabled


func get_is_enabled() -> bool:
    return true

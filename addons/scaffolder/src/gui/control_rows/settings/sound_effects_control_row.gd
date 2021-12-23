class_name SoundEffectsControlRow
extends CheckboxControlRow


const LABEL := "Sound effects"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.audio.is_sound_effects_enabled = pressed
    Sc.save_state.set_setting(
            SaveState.IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY,
            Sc.audio.is_sound_effects_enabled)


func get_is_pressed() -> bool:
    return Sc.audio.is_sound_effects_enabled


func get_is_enabled() -> bool:
    return true

class_name MusicControlRow
extends CheckboxControlRow


const LABEL := "Music"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.audio.is_music_enabled = pressed
    Sc.save_state.set_setting(
            SaveState.IS_MUSIC_ENABLED_SETTINGS_KEY,
            Sc.audio.is_music_enabled)


func get_is_pressed() -> bool:
    return Sc.audio.is_music_enabled


func get_is_enabled() -> bool:
    return true

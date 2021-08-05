class_name WelcomePanelControlRow
extends CheckboxControlRow


const LABEL := "Welcome panel"
const DESCRIPTION := (
        "The 'Welcome panel' is an overlay that is shown when starting a " +
        "new level.")


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Sc.gui.is_welcome_panel_shown = pressed
    Sc.save_state.set_setting(
            SaveState.IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY,
            Sc.gui.is_welcome_panel_shown)


func get_is_pressed() -> bool:
    return Sc.gui.is_welcome_panel_shown


func get_is_enabled() -> bool:
    return true

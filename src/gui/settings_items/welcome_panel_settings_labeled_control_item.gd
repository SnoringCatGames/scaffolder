class_name WelcomePanelSettingsLabeledControlItem
extends CheckboxLabeledControlItem


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
    Gs.gui.is_welcome_panel_shown = pressed
    Gs.save_state.set_setting(
            Gs.gui.IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY,
            Gs.gui.is_welcome_panel_shown)


func get_is_pressed() -> bool:
    return Gs.gui.is_welcome_panel_shown


func get_is_enabled() -> bool:
    return true

class_name RateAppScreen
extends Screen


const NEXT_SCREEN_TYPE := "main_menu"


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    assert(Gs.gui.is_rate_app_shown)


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/VBoxContainer2/RateAppButton as ScaffolderButton


func _on_RateAppButton_pressed() -> void:
    Gs.save_state.set_gave_feedback(true)
    Gs.nav.open(NEXT_SCREEN_TYPE)
    var app_store_url: String = \
            Gs.app_metadata.ios_app_store_url if \
            Gs.device.get_is_ios_app() else \
            Gs.app_metadata.android_app_store_url
    OS.shell_open(app_store_url)


func _on_DontAskAgainButton_pressed() -> void:
    Gs.save_state.set_gave_feedback(true)
    Gs.nav.open(NEXT_SCREEN_TYPE)


func _on_KeepPlayingButton_pressed() -> void:
    Gs.nav.open(NEXT_SCREEN_TYPE)


func _on_SendFeedbackButton_pressed() -> void:
    Gs.nav.open(NEXT_SCREEN_TYPE)
    OS.shell_open(Gs.get_support_url_with_params())

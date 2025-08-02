@icon("res://addons/scaffolder/assets/editor_icons/ScaffolderNode.svg")
class_name ScaffolderShell
extends Container

# FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------


func _init() -> void:
    S.log.on_global_init(self, "ScaffolderShell")


func _ready() -> void:
    if S.log.logs_early_bootstrap_events:
        S.log.print("ScaffolderShell._ready")

    S.shell = self

    await get_tree().process_frame

    S.screens.open(S.scaffolder_settings.initial_screen)

    if S.scaffolder_settings.flag_full_screen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _notification(notification: int) -> void:
    match notification:
        NOTIFICATION_WM_GO_BACK_REQUEST:
            # Handle the Android back button to navigate within the app instead of
            # quitting the app.
            if S.screens.is_top_screen("main_menu"):
                close_app()
            else:
                # TODO: Close the current screen if it's not game_screen.
                pass
        NOTIFICATION_WM_CLOSE_REQUEST:
            close_app()
        NOTIFICATION_WM_WINDOW_FOCUS_OUT:
            if is_instance_valid(S.level) and S.scaffolder_settings.flag_pauses_on_focus_out:
                S.level.pause()
        _:
            pass


func _unhandled_input(event: InputEvent) -> void:
    if S.scaffolder_settings.dev_mode:
        if event is InputEventKey:
            match event.physical_keycode:
                KEY_P:
                    if S.scaffolder_settings.flag_is_screenshot_hotkey_enabled:
                        S.utils.take_screenshot()
                KEY_O:
                    if is_instance_valid(S.hud):
                        S.hud.visible = not S.hud.visible
                        S.log.print(
                            "Toggled HUD visibility: %s" %
                            ("visible" if S.hud.visible else "hidden"))
                KEY_ESCAPE:
                    if is_instance_valid(S.level) and S.scaffolder_settings.pauses_on_focus_out:
                        S.level.pause()
                _:
                    pass


func close_app() -> void:
    if S.utils.were_screenshots_taken:
        S.utils.open_screenshot_folder()
    S.log.print("Shell.close_app")
    get_tree().call_deferred("quit")

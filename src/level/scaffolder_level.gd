tool
class_name ScaffolderLevel, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_level.png"
extends Node2D


const MIN_CONTROLS_DISPLAY_TIME := 0.5

var _configuration_warning := ""


func _enter_tree() -> void:
    _update_editor_configuration()


func _ready() -> void:
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _load() -> void:
    Sc.level = self
    _create_hud()


func _start() -> void:
    Sc.audio.play_music(get_music_name())
    Sc.save_state.set_level_total_plays(
            Sc.level_session.id,
            Sc.save_state.get_level_total_plays(Sc.level_session.id) + 1)
    Sc.analytics.event(
            "level",
            "start",
            Sc.level_config.get_level_version_string(Sc.level_session.id))
    Sc.gui.hud.visible = true
    call_deferred("_on_started")


func _on_started() -> void:
    Sc.level_session._level_start_play_time_unscaled = Sc.time.get_play_time()


func _create_hud() -> void:
    Sc.gui.hud = Sc.gui.hud_manifest.hud_class.new()
    Sc.gui.hud.visible = false
    Sc.canvas_layers.layers.hud.add_child(Sc.gui.hud)


func _destroy() -> void:
    _hide_welcome_panel()
    if is_instance_valid(Sc.gui.hud):
        Sc.gui.hud._destroy()
    Sc.level = null
    Sc.level_session._is_destroyed = true
    if Sc.level_session.is_restarting:
        Sc.nav.open(
                "loading",
                ScreenTransition.DEFAULT,
                {level_id = Sc.level_session.id})
    if !is_queued_for_deletion():
        queue_free()


func quit(
        has_finished: bool,
        immediately: bool) -> void:
    Sc.level_session._level_end_play_time_unscaled = Sc.time.get_play_time()
    Sc.audio.stop_music()
    Sc.level_session._update_for_level_end(has_finished)
    _record_suggested_next_level()
    if immediately:
        if !Sc.level_session.is_restarting:
            Sc.nav.open("game_over", ScreenTransition.FANCY)
        _destroy()
    else:
        var sound_name: String = \
                Sc.audio_manifest.level_end_sound_win if \
                has_finished else \
                Sc.audio_manifest.level_end_sound_lose
        Sc.audio.get_sound_player(sound_name) \
                .connect(
                        "finished",
                        self,
                        "_on_level_quit_sound_finished",
                        [has_finished])
        Sc.audio.play_sound(sound_name)


func _update_editor_configuration() -> void:
    if !Sc.utils.check_whether_sub_classes_are_tools(self):
        _set_configuration_warning(
                "Subclasses of ScaffolderLevel must be marked as tool.")
        return
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()
    property_list_changed_notify()
    if value != "" and \
            !Engine.editor_hint:
        Sc.logger.error(value)


func _get_configuration_warning() -> String:
    return _configuration_warning


func _record_suggested_next_level() -> void:
    var suggested_next_level_id: String = \
            Sc.level_config.calculate_suggested_next_level()
    Sc.save_state.set_setting(
            SaveState.SUGGESTED_NEXT_LEVEL_SETTINGS_KEY,
            suggested_next_level_id)


func restart() -> void:
    Sc.level_session._is_restarting = true
    quit(false, true)


func _input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    if !Sc.level_session.has_initial_input_happened and \
            Sc.gui.is_user_interaction_enabled and \
            Sc.level_session.level_play_time_unscaled > \
                    MIN_CONTROLS_DISPLAY_TIME and \
            (event is InputEventMouseButton or \
                    event is InputEventScreenTouch or \
                    event is InputEventKey) and \
            Sc.level_session.has_started:
        _on_initial_input()


func _on_initial_input() -> void:
    Sc.logger.print("ScaffolderLevel._on_initial_input")
    Sc.level_session._has_initial_input_happened = true
    # Close the welcome panel on any mouse or key click event.
    if is_instance_valid(Sc.gui.welcome_panel):
        _hide_welcome_panel()


func _on_resized() -> void:
    pass


func pause() -> void:
    if Sc.audio_manifest.pauses_level_music_on_pause:
        Sc.level_session._pre_pause_music_name = Sc.audio.get_music_name()
        Sc.level_session._pre_pause_music_position = \
                Sc.audio.get_playback_position()
        if Sc.audio_manifest.pause_menu_music != "":
            Sc.audio.play_music(Sc.audio_manifest.pause_menu_music)
    Sc.nav.open("pause")


func on_unpause() -> void:
    if Sc.audio_manifest.pauses_level_music_on_pause:
        Sc.audio.play_music(Sc.level_session._pre_pause_music_name)
        Sc.audio.seek(Sc.level_session._pre_pause_music_position)


func _show_welcome_panel() -> void:
    if !Sc.gui.is_welcome_panel_shown:
        return
    assert(Sc.gui.welcome_panel == null)
    Sc.gui.welcome_panel = Sc.utils.add_scene(
            Sc.canvas_layers.layers.hud,
            Sc.gui.welcome_panel_scene)


func _hide_welcome_panel() -> void:
    if is_instance_valid(Sc.gui.welcome_panel):
        Sc.gui.welcome_panel._destroy()
        Sc.gui.welcome_panel = null


func _on_level_quit_sound_finished(level_finished: bool) -> void:
    var sound_name: String = \
            Sc.audio_manifest.level_end_sound_win if \
            level_finished else \
            Sc.audio_manifest.level_end_sound_lose
    Sc.audio.get_sound_player(sound_name) \
            .disconnect("finished", self, "_on_level_quit_sound_finished")
    var is_rate_app_screen_next: bool = \
            Sc.gui.is_rate_app_shown and \
            _get_is_rate_app_screen_next()
    var next_screen := \
            "rate_app" if \
            is_rate_app_screen_next else \
            "game_over"
    Sc.nav.open(next_screen, ScreenTransition.FANCY)


func get_music_name() -> String:
    return Sc.audio_manifest.default_level_music


func _get_is_rate_app_screen_next() -> bool:
    Sc.logger.error(
            "Abstract ScaffolderLevel._get_is_rate_app_screen_next " +
            "is not implemented")
    return false

class_name ScaffolderLevel
extends Node2D


const MIN_CONTROLS_DISPLAY_TIME := 0.5


func _ready() -> void:
    Gs.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _load() -> void:
    Gs.level = self
    _create_hud()


func _start() -> void:
    Gs.audio.play_music(get_music_name())
    Gs.save_state.set_level_total_plays(
            Gs.level_session.id,
            Gs.save_state.get_level_total_plays(Gs.level_session.id) + 1)
    Gs.analytics.event(
            "level",
            "start",
            Gs.level_config.get_level_version_string(Gs.level_session.id))
    Gs.gui.hud.visible = true
    call_deferred("_on_started")


func _on_started() -> void:
    Gs.level_session._level_start_play_time_unscaled = Gs.time.get_play_time()


func _create_hud() -> void:
    Gs.gui.hud = Gs.gui.hud_manifest.hud_class.new()
    Gs.gui.hud.visible = false
    Gs.canvas_layers.layers.hud.add_child(Gs.gui.hud)


func _destroy() -> void:
    _hide_welcome_panel()
    if is_instance_valid(Gs.gui.hud):
        Gs.gui.hud._destroy()
    Gs.level = null
    Gs.level_session._is_destroyed = true
    if Gs.level_session.is_restarting:
        Gs.nav.open(
                "loading",
                ScreenTransition.DEFAULT,
                {level_id = Gs.level_session.id})
    if !is_queued_for_deletion():
        queue_free()


func quit(
        has_finished: bool,
        immediately: bool) -> void:
    Gs.level_session._level_end_play_time_unscaled = Gs.time.get_play_time()
    Gs.audio.stop_music()
    Gs.level_session._update_for_level_end(has_finished)
    _record_suggested_next_level()
    if immediately:
        if !Gs.level_session.is_restarting:
            Gs.nav.open("game_over", ScreenTransition.FANCY)
        _destroy()
    else:
        var sound_name: String = \
                Gs.audio_manifest.level_end_sound_win if \
                has_finished else \
                Gs.audio_manifest.level_end_sound_lose
        Gs.audio.get_sound_player(sound_name) \
                .connect(
                        "finished",
                        self,
                        "_on_level_quit_sound_finished",
                        [has_finished])
        Gs.audio.play_sound(sound_name)


func _record_suggested_next_level() -> void:
    var suggested_next_level_id: String = \
            Gs.level_config.calculate_suggested_next_level()
    Gs.save_state.set_setting(
            SaveState.SUGGESTED_NEXT_LEVEL_SETTINGS_KEY,
            suggested_next_level_id)


func restart() -> void:
    Gs.level_session._is_restarting = true
    quit(false, true)


func _input(event: InputEvent) -> void:
    if !Gs.level_session.has_initial_input_happened and \
            Gs.gui.is_user_interaction_enabled and \
            Gs.level_session.level_play_time_unscaled > \
                    MIN_CONTROLS_DISPLAY_TIME and \
            (event is InputEventMouseButton or \
                    event is InputEventScreenTouch or \
                    event is InputEventKey) and \
            Gs.level_session.has_started:
        _on_initial_input()


func _on_initial_input() -> void:
    Gs.logger.print("ScaffolderLevel._on_initial_input")
    Gs.level_session._has_initial_input_happened = true
    # Close the welcome panel on any mouse or key click event.
    if is_instance_valid(Gs.gui.welcome_panel):
        _hide_welcome_panel()


func _on_resized() -> void:
    pass


func pause() -> void:
    if Gs.audio_manifest.pauses_level_music_on_pause:
        Gs.level_session._pre_pause_music_name = Gs.audio.get_music_name()
        Gs.level_session._pre_pause_music_position = \
                Gs.audio.get_playback_position()
        if Gs.audio_manifest.pause_menu_music != "":
            Gs.audio.play_music(Gs.audio_manifest.pause_menu_music)
    Gs.nav.open("pause")


func on_unpause() -> void:
    if Gs.audio_manifest.pauses_level_music_on_pause:
        Gs.audio.play_music(Gs.level_session._pre_pause_music_name)
        Gs.audio.seek(Gs.level_session._pre_pause_music_position)


func _show_welcome_panel() -> void:
    if !Gs.gui.is_welcome_panel_shown:
        return
    assert(Gs.gui.welcome_panel == null)
    Gs.gui.welcome_panel = Gs.utils.add_scene(
            Gs.canvas_layers.layers.hud,
            Gs.gui.welcome_panel_scene)


func _hide_welcome_panel() -> void:
    if is_instance_valid(Gs.gui.welcome_panel):
        Gs.gui.welcome_panel._destroy()
        Gs.gui.welcome_panel = null


func _on_level_quit_sound_finished(level_finished: bool) -> void:
    var sound_name: String = \
            Gs.audio_manifest.level_end_sound_win if \
            level_finished else \
            Gs.audio_manifest.level_end_sound_lose
    Gs.audio.get_sound_player(sound_name) \
            .disconnect("finished", self, "_on_level_quit_sound_finished")
    var is_rate_app_screen_next: bool = \
            Gs.gui.is_rate_app_shown and \
            _get_is_rate_app_screen_next()
    var next_screen := \
            "rate_app" if \
            is_rate_app_screen_next else \
            "game_over"
    Gs.nav.open(next_screen, ScreenTransition.FANCY)


func get_music_name() -> String:
    return Gs.audio_manifest.default_level_music


func _get_is_rate_app_screen_next() -> bool:
    Gs.logger.error(
            "Abstract ScaffolderLevel._get_is_rate_app_screen_next " +
            "is not implemented")
    return false

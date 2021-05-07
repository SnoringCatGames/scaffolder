class_name ScaffolderLevel
extends Node2D

var min_controls_display_time := 0.5

var _id: String
var _is_restarting := false
var _has_initial_input_happened := false
var level_start_play_time_unscaled := INF
var score := 0.0

var id: String setget _set_id,_get_id
var is_started: bool setget ,_get_is_started
var level_play_time_unscaled: float setget ,_get_level_play_time_unscaled

func _ready() -> void:
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()

func _load() -> void:
    Gs.level = self

func _start() -> void:
    Gs.audio.play_music(_get_music_name())
    level_start_play_time_unscaled = Gs.time.get_play_time_sec()
    Gs.save_state.set_level_total_plays(
            _id,
            Gs.save_state.get_level_total_plays(_id) + 1)
    Gs.analytics.event(
            "level",
            "start",
            Gs.level_config.get_level_version_string(_id))

func _exit_tree() -> void:
    if _is_restarting:
        Gs.nav.screens["game"].start_level(_id)

func _destroy() -> void:
    _hide_welcome_panel()
    Gs.level = null
    queue_free()

func quit(immediately := true) -> void:
    Gs.audio.stop_music()
    _record_level_results()
    if immediately:
#        _on_level_quit_sound_finished()
        _destroy()
    else:
        Gs.audio.get_sound_player(Gs.level_end_sound) \
                .connect("finished", self, "_on_level_quit_sound_finished")
        Gs.audio.play_sound(Gs.level_end_sound)

func restart() -> void:
    _is_restarting = true
    quit(true)

func _input(event: InputEvent) -> void:
    if !_has_initial_input_happened and \
            Gs.is_user_interaction_enabled and \
            _get_level_play_time_unscaled() > min_controls_display_time and \
            (event is InputEventMouseButton or \
                    event is InputEventScreenTouch or \
                    event is InputEventKey) and \
            _get_is_started():
        _on_initial_input()

func _on_initial_input() -> void:
    Gs.logger.print("ScaffolderLevel._on_initial_input")
    _has_initial_input_happened = true
    # Close the welcome panel on any mouse or key click event.
    if is_instance_valid(Gs.welcome_panel):
        _hide_welcome_panel()

func _on_resized() -> void:
    pass

func pause() -> void:
    Gs.nav.open("pause")

func on_unpause() -> void:
    pass

func _show_welcome_panel() -> void:
    if !Gs.is_welcome_panel_shown:
        return
    assert(Gs.welcome_panel == null)
    Gs.welcome_panel = Gs.utils.add_scene(
            Gs.canvas_layers.layers.hud,
            Gs.welcome_panel_resource_path)

func _hide_welcome_panel() -> void:
    if is_instance_valid(Gs.welcome_panel):
        Gs.welcome_panel.queue_free()
        Gs.welcome_panel = null

func _record_level_results() -> void:
    var game_over_screen = Gs.nav.screens["game_over"]
    game_over_screen.level_id = _id
    game_over_screen.time = Gs.utils.get_time_string_from_seconds(
            Gs.time.get_play_time_sec() - \
            level_start_play_time_unscaled)
    
    if Gs.uses_level_scores:
        Gs.analytics.event(
                "score",
                "v" + Gs.score_version,
                Gs.level_config.get_level_version_string(_id),
                int(score))
        
        var previous_high_score: int = Gs.save_state.get_level_high_score(_id)
        if score > previous_high_score:
            Gs.save_state.set_level_high_score(
                    _id,
                    int(score))
            game_over_screen.reached_new_high_score = true
        
        var all_scores: Array = Gs.save_state.get_level_all_scores(_id)
        all_scores.push_back(score)
        Gs.save_state.set_level_all_scores(_id, all_scores)
        
        game_over_screen.score = str(int(score))
        game_over_screen.high_score = \
                str(Gs.save_state.get_level_high_score(_id))
    
    var old_unlocked_levels: Array = Gs.level_config.get_old_unlocked_levels()
    var new_unlocked_levels: Array = Gs.level_config.get_new_unlocked_levels()
    Gs.save_state.set_new_unlocked_levels(new_unlocked_levels)
    for other_level_id in new_unlocked_levels:
        Gs.save_state.set_level_is_unlocked(other_level_id, true)
        Gs.analytics.event(
                "level",
                "unlocked",
                Gs.level_config.get_level_version_string(other_level_id),
                Gs.level_config.get_level_config(other_level_id).number)
    game_over_screen.new_unlocked_levels = new_unlocked_levels

func _on_level_quit_sound_finished() -> void:
    Gs.audio.get_sound_player(Gs.level_end_sound) \
            .disconnect("finished", self, "_on_level_quit_sound_finished")
    var is_rate_app_screen_next: bool = \
            Gs.is_rate_app_shown and \
            _get_is_rate_app_screen_next()
    var next_screen := \
            "rate_app" if \
            is_rate_app_screen_next else \
            "game_over"
    Gs.nav.open(next_screen, true)
    _destroy()

func _get_music_name() -> String:
    return "on_a_quest"

func _get_is_rate_app_screen_next() -> bool:
    Gs.logger.error(
            "Abstract ScaffolderLevel._get_is_rate_app_screen_next " +
            "is not implemented")
    return false

func _get_is_started() -> bool:
    return level_start_play_time_unscaled != INF

func _get_level_play_time_unscaled() -> float:
    return Gs.time.get_play_time_sec() - level_start_play_time_unscaled if \
            _get_is_started() else \
            0.0

func _set_id(value: String) -> void:
    _id = value

func _get_id() -> String:
    return _id

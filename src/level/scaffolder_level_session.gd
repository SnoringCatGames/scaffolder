class_name ScaffolderLevelSession
extends Reference
## -   State for single playthrough in a given level.
## -   This state kept alive independent of the level, which makes this useful
##     for things like showing playthrough state in the game-over screen.
## **NOTE**: Don't store references to nodes that should be destroyed with the
##           level, because this session-state will persist after the level is
##           destroyed.[br]


var _id: String
var _is_destroyed := false
var _is_restarting := false
var _has_initial_input_happened := false
var _has_finished := false
var _game_over_explanation := ""

var _level_start_play_time_scaled := -INF
var _level_start_play_time_unscaled := -INF
var _level_end_play_time_unscaled := -INF
var _score := 0.0

var _high_score := 0.0
var _fastest_time := INF
var _longest_time := INF

var _is_new_high_score := false
var _is_new_fastest_time := false
var _is_new_longest_time := false

var _pre_pause_music_name := ""
var _pre_pause_music_position := INF

# Array<String>
var _new_unlocked_levels := []

var id: String setget ,_get_id
var is_destroyed: bool setget ,_get_is_destroyed
var is_restarting: bool setget ,_get_is_restarting
var has_initial_input_happened: bool setget ,_get_has_initial_input_happened
var has_started: bool setget ,_get_has_started
var is_ended: bool setget ,_get_is_ended
var has_finished: bool setget ,_get_has_finished
var game_over_explanation: String setget ,_get_game_over_explanation
var level_start_play_time_scaled: float \
        setget ,_get_level_start_play_time_scaled
var level_start_play_time_unscaled: float \
        setget ,_get_level_start_play_time_unscaled
var level_end_play_time_unscaled: float \
        setget ,_get_level_end_play_time_unscaled
var level_play_time_scaled: float setget ,_get_level_play_time_scaled
var level_play_time_unscaled: float setget ,_get_level_play_time_unscaled
var score: float setget ,_get_score
var high_score: float setget ,_get_high_score
var fastest_time: float setget ,_get_fastest_time
var longest_time: float setget ,_get_longest_time
var is_new_high_score: bool setget ,_get_is_new_high_score
var is_fastest_time: bool setget ,_get_is_new_fastest_time
var is_longest_time: bool setget ,_get_is_new_longest_time
var new_unlocked_levels: Array setget ,_get_new_unlocked_levels

var config: Dictionary


func reset(id: String) -> void:
    self._id = id
    _is_destroyed = false
    _is_restarting = false
    _has_initial_input_happened = false
    _has_finished = false
    _level_start_play_time_scaled = -INF
    _level_start_play_time_unscaled = -INF
    _level_end_play_time_unscaled = -INF
    _score = 0.0
    _high_score = 0.0
    _fastest_time = INF
    _longest_time = INF
    _is_new_high_score = false
    _is_new_fastest_time = false
    _is_new_longest_time = false
    _pre_pause_music_name = ""
    _pre_pause_music_position = INF
    config = Sc.levels.get_level_config(id)
    _update_high_score()
    _update_fastest_time()
    _update_longest_time()


func _get_id() -> String:
    return _id


func _get_is_destroyed() -> bool:
    return _is_destroyed


func _get_is_restarting() -> bool:
    return _is_restarting


func _get_has_initial_input_happened() -> bool:
    return _has_initial_input_happened


func _get_has_started() -> bool:
    return !is_inf(_level_start_play_time_unscaled)


func _get_is_ended() -> bool:
    return !is_inf(_level_end_play_time_unscaled)


func _get_has_finished() -> bool:
    return _has_finished


func _get_game_over_explanation() -> String:
    return _game_over_explanation


func _get_level_start_play_time_scaled() -> float:
    return _level_start_play_time_scaled


func _get_level_start_play_time_unscaled() -> float:
    return _level_start_play_time_unscaled


func _get_level_end_play_time_unscaled() -> float:
    return _level_end_play_time_unscaled


func _get_level_play_time_scaled() -> float:
    if _get_has_started():
        return Sc.time.get_scaled_play_time() - _level_start_play_time_scaled
    else:
        return 0.0


func _get_level_play_time_unscaled() -> float:
    if _get_has_started():
        if _get_is_ended():
            return _level_end_play_time_unscaled - \
                    _level_start_play_time_unscaled
        else:
            return Sc.time.get_play_time() - _level_start_play_time_unscaled
    else:
        return 0.0


func get_level_display_time() -> float:
    return get_level_play_time_by_type(Sc.gui.display_time_type)


func get_level_play_time_by_type(type: int) -> float:
    match type:
        TimeType.PLAY_PHYSICS:
            return _get_level_play_time_unscaled()
        TimeType.PLAY_PHYSICS_SCALED:
            return _get_level_play_time_scaled()
        _:
            Sc.logger.error("ScaffolderLevelSession.get_level_play_time_by_type")
            return INF


func _get_score() -> float:
    return _score


func _get_high_score() -> float:
    return _high_score


func _get_fastest_time() -> float:
    return _fastest_time


func _get_longest_time() -> float:
    return _longest_time


func _get_is_new_high_score() -> bool:
    return _is_new_high_score


func _get_is_new_fastest_time() -> bool:
    return _is_new_fastest_time


func _get_is_new_longest_time() -> bool:
    return _is_new_longest_time


func _get_new_unlocked_levels() -> Array:
    return _new_unlocked_levels


func _update_for_level_end(has_finished: bool) -> void:
    self._has_finished = has_finished

    if !has_finished:
        return
    
    Sc.save_state.set_level_has_finished(
            _id,
            _has_finished)
    
    if Sc.metadata.uses_level_scores:
        _handle_new_score()
    _update_cumulative_time()
    _update_fastest_time()
    _update_longest_time()
    _update_new_unlocked_levels()


func _handle_new_score() -> void:
    Sc.analytics.event(
            "score",
            "v" + Sc.metadata.score_version,
            Sc.levels.get_level_version_string(_id),
            int(_score))
    
    var all_scores: Array = Sc.save_state.get_level_all_scores(_id)
    all_scores.push_back(_score)
    Sc.save_state.set_level_all_scores(_id, all_scores)
    
    _update_high_score()


func _update_high_score() -> void:
    _high_score = Sc.save_state.get_level_high_score(_id)
    _is_new_high_score = \
            _has_finished and \
            _score > _high_score
    if _is_new_high_score:
        _high_score = _score
        Sc.save_state.set_level_high_score(
                _id,
                _score)


func _update_cumulative_time() -> void:
    Sc.save_state.set_level_cumulative_time(
            _id,
            Sc.save_state.get_level_cumulative_time(_id) + \
                get_level_display_time())
    Sc.save_state.set_cumulative_time(
            Sc.save_state.get_cumulative_time() + get_level_display_time())


func _update_fastest_time() -> void:
    var current_time := get_level_display_time()
    var save_state_fastest_time: float = \
            Sc.save_state.get_level_fastest_time(_id)
    _fastest_time = \
            save_state_fastest_time if \
            save_state_fastest_time != Utils.MAX_INT and \
                    !is_inf(save_state_fastest_time) else \
            INF
    _is_new_fastest_time = \
            _has_finished and \
            !is_inf(current_time) and \
            current_time < _fastest_time
    if _is_new_fastest_time:
        _fastest_time = current_time
        Sc.save_state.set_level_fastest_time(
                _id,
                current_time)


func _update_longest_time() -> void:
    var current_time := get_level_display_time()
    var save_state_longest_time: float = \
            Sc.save_state.get_level_longest_time(_id)
    _longest_time = \
            save_state_longest_time if \
            save_state_longest_time != Utils.MAX_INT and \
                    !is_inf(save_state_longest_time) else \
            INF
    _is_new_longest_time = \
            _has_finished and \
            !is_inf(current_time) and \
            current_time > _longest_time
    if _is_new_longest_time:
        _longest_time = current_time
        Sc.save_state.set_level_longest_time(
                _id,
                current_time)


func _update_new_unlocked_levels() -> void:
    _new_unlocked_levels = Sc.levels.get_new_unlocked_levels()
    Sc.save_state.set_new_unlocked_levels(_new_unlocked_levels)
    for other_level_id in _new_unlocked_levels:
        Sc.save_state.set_level_is_unlocked(other_level_id, true)
        Sc.analytics.event(
                "level",
                "unlocked",
                Sc.levels.get_level_version_string(other_level_id),
                Sc.levels.get_level_config(other_level_id).number)

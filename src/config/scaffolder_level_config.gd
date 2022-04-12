tool
class_name ScaffolderLevelConfig
extends Node
# NOTE: Level config Dictionaries must have the following properties:
# -   name: String: Try to keep this short and memorable.
# -   version: String: Of the form "0.0.1".
# -   is_test_level: bool
# -   sort_priority: int: Must be unique. Earlier levels have lower values.
# -   unlock_conditions: String|Object:
#     -   "unlocked": This level is always unlocked.
#     -   "finish_previous_level": This level is unlocked by finishing the
#         previous level.
#     -   Object: This level is unlocked according to some other complex logic.
#         Your app must define this logic, and must override get_unlock_hint
#         and calculate_suggested_next_level.
# -   One of (according to are_levels_scene_based):
#     -   scene_path: String
#     -   script_class: Class
# 
# NOTE: Level config Dictionaries will updated to include the following
#       auto-calculated properties:
# -   id: String
# -   number: int


const DEFAULT_CAMERA_BOUNDS_LEVEL_MARGIN := {
    top = 768.0,
    bottom = 384.0,
    left = 384.0,
    right = 384.0,
}

const DEFAULT_CHARACTER_BOUNDS_LEVEL_MARGIN := \
        DEFAULT_CAMERA_BOUNDS_LEVEL_MARGIN

var are_levels_scene_based: bool
var test_level_count := 0

var default_camera_bounds_level_margin := \
        DEFAULT_CAMERA_BOUNDS_LEVEL_MARGIN
var default_character_bounds_level_margin := \
        DEFAULT_CHARACTER_BOUNDS_LEVEL_MARGIN

var session: ScaffolderLevelSession

var _level_configs_by_id := {}
var _level_configs_by_number := {}
var _level_numbers := []


func _init(
        are_levels_scene_based: bool,
        level_manifest: Dictionary) -> void:
    Sc.logger.on_global_init(self, "ScaffolderLevelConfig")
    self.are_levels_scene_based = are_levels_scene_based
    self._level_configs_by_id = level_manifest


func _ready() -> void:
    _clear_old_version_level_state()
    
    _sanitize_level_configs()
    
    var is_a_level_unlocked_at_the_start := false
    for level_id in get_level_ids():
        if get_level_config(level_id).unlock_conditions == "unlocked":
            is_a_level_unlocked_at_the_start = true
            Sc.save_state.set_level_is_unlocked(level_id, true)
    assert(is_a_level_unlocked_at_the_start)


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("default_camera_bounds_level_margin"):
        self.default_camera_bounds_level_margin = \
                manifest.default_camera_bounds_level_margin
    if manifest.has("default_character_bounds_level_margin"):
        self.default_character_bounds_level_margin = \
                manifest.default_character_bounds_level_margin


func _sanitize_level_configs() -> void:
    var level_configs_by_priority := {}
    var sort_priorities := []
    test_level_count = 0
    for level_id in get_level_ids():
        var config := get_level_config(level_id)
        _sanitize_level_config(config)
        if config.is_test_level:
            if !Sc.metadata.are_test_levels_included:
                continue
            test_level_count += 1
        config.id = level_id
        level_configs_by_priority[config.sort_priority] = config
        sort_priorities.push_back(config.sort_priority)
    
    sort_priorities.sort()
    var number := 1
    for sort_priority in sort_priorities:
        var config: Dictionary = level_configs_by_priority[sort_priority]
        config.number = number
        _level_configs_by_number[number] = config
        _level_numbers.push_back(number)
        number += 1


func _sanitize_level_config(config: Dictionary) -> void:
    assert(config.has("name") and config.name is String)
    assert(config.has("version") and config.version is String)
    assert(config.has("is_test_level") and \
            config.is_test_level is bool and \
            (config.is_test_level == (config.sort_priority <= 0)))
    assert(config.has("sort_priority") and \
            Sc.utils.is_num(config.sort_priority))
    assert(config.has("unlock_conditions") and \
            (config.unlock_conditions == "unlocked" or \
            config.unlock_conditions == "finish_previous_level" or \
            config.unlock_conditions is Object))
    assert(are_levels_scene_based and \
            config.has("scene_path") and \
            config.scene_path is String and \
            !config.has("script_class") or \
            !are_levels_scene_based and \
            config.has("script_class") and \
            !config.has("scene_path"))
    assert(config.has("cell_size") and config.cell_size is Vector2)


func get_level_config(level_id: String) -> Dictionary:
    return _level_configs_by_id[level_id]


func get_level_config_by_number(level_number: int) -> Dictionary:
    return _level_configs_by_number[level_number]


func get_level_ids() -> Array:
    return _level_configs_by_id.keys()


func get_level_numbers() -> Array:
    return _level_numbers


func get_level_version_string(level_id: String) -> String:
    return level_id + "v" + get_level_config(level_id).version


func _clear_old_version_level_state() -> void:
    if Sc.metadata.score_version != Sc.save_state.get_score_version():
        Sc.save_state.set_score_version(Sc.metadata.score_version)
        Sc.save_state.erase_all_scores()
    
    for level_id in get_level_ids():
        var config := get_level_config(level_id)
        if config.version != Sc.save_state.get_level_version(level_id):
            Sc.save_state.erase_level_state(level_id)
            Sc.save_state.set_level_version(level_id, config.version)


func _get_number_from_version(version: String) -> int:
    var parts := version.split(".")
    assert(parts.size() == 3)
    return int(parts[0]) * 1000000 + int(parts[1]) * 1000 + int(parts[2])


func get_previous_level_id(level_id: String) -> String:
    var level_number: int = get_level_config(level_id).number
    
    for i in _level_numbers.size():
        if _level_numbers[i] == level_number:
            if i == 0:
                return ""
            else:
                return _level_configs_by_number[_level_numbers[i - 1]].id
    
    Sc.logger.error("The given level_id is invalid: %s" % level_id)
    
    return ""


func get_next_level_id(level_id: String) -> String:
    var level_number: int = get_level_config(level_id).number
    
    for i in _level_numbers.size():
        if _level_numbers[i] == level_number:
            if i == _level_numbers.size() - 1:
                return ""
            else:
                return _level_configs_by_number[_level_numbers[i + 1]].id
    
    Sc.logger.error("The given level_id is invalid: %s" % level_id)
    
    return ""


func get_old_unlocked_levels() -> Array:
    var old_unlocked_levels := []
    for level_id in get_level_ids():
        if Sc.save_state.get_level_is_unlocked(level_id):
            old_unlocked_levels.push_back(level_id)
    return old_unlocked_levels


func get_new_unlocked_levels() -> Array:
    var new_unlocked_levels := []
    for level_id in get_level_ids():
        if !Sc.save_state.get_level_is_unlocked(level_id) and \
                _check_if_level_meets_unlock_conditions(level_id):
            new_unlocked_levels.push_back(level_id)
    return new_unlocked_levels


func _check_if_level_meets_unlock_conditions(level_id: String) -> bool:
    return get_unlock_hint(level_id) == ""


func get_next_level_to_unlock() -> String:
    var locked_level_numbers := []
    for level_id in get_level_ids():
        if !Sc.save_state.get_level_is_unlocked(level_id):
            var config := get_level_config(level_id)
            locked_level_numbers.push_back(config.number)
    locked_level_numbers.sort()
    
    if locked_level_numbers.empty():
        return ""
    else:
        return _level_configs_by_number[locked_level_numbers.front()].id



func get_unlock_hint(level_id: String) -> String:
    if Sc.save_state.get_level_is_unlocked(level_id):
        return ""
    
    var unlock_conditions = get_level_config(level_id).unlock_conditions
    if unlock_conditions == "finish_previous_level":
        var previous_level_id := get_previous_level_id(level_id)
        if previous_level_id == "":
            Sc.logger.error("No previous level")
            return ""
        
        if Sc.save_state.get_level_has_finished(previous_level_id):
            return ""
        
        return "Finish %s" % get_level_config(previous_level_id).name
    elif unlock_conditions is Object:
        Sc.logger.error(
                "App must override get_unlock_hint if defining custom " +
                "unlock_conditions")
        return ""
    else:
        Sc.logger.error("Invalid value for unlock_conditions: %s" % \
                unlock_conditions)
        return ""


func calculate_suggested_next_level() -> String:
    var last_level_played_id: String = Sc.save_state.get_last_level_played()
    if last_level_played_id == "" or \
            !_level_configs_by_id.has(last_level_played_id):
        # If we haven't ever played any level, then suggest the first level.
        return get_first_always_unlocked_level()
        
    elif self.session.has_finished:
        # If we have already finished a level during this play session, then
        # suggest the next level.
        var next_level_id := get_next_level_id(self.session.id)
        if next_level_id != "" and \
                Sc.save_state.get_level_is_unlocked(next_level_id):
            # The next level is available, so suggest it.
            return next_level_id
        else:
            # The next level isn't available, so suggest the same level.
            return self.session.id
        
    else:
        # If we haven't yet finished a level during this play session, then
        # suggest the last level played.
        return last_level_played_id


func get_recorded_suggested_next_level() -> String:
    var recorded_suggested_next_level: String = Sc.save_state.get_setting(
            SaveState.SUGGESTED_NEXT_LEVEL_SETTINGS_KEY,
            "")
    if recorded_suggested_next_level != "":
        return recorded_suggested_next_level
    else:
        return get_first_always_unlocked_level()


func get_first_always_unlocked_level() -> String:
    for level_number in _level_numbers:
        var level_config: Dictionary = \
                _level_configs_by_number[level_number]
        if level_config.unlock_conditions == "unlocked":
            return level_config.id
    Sc.logger.error("No level is unlocked at the start??")
    return get_level_ids().front()
    

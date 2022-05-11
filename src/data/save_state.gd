tool
class_name SaveState
extends Node


const CONFIG_FILE_PATH := "user://settings.cfg"
const SETTINGS_SECTION_KEY := "settings"
const MISCELLANEOUS_SECTION_KEY := "miscellaneous"
const HAS_FINISHED_SECTION_KEY := "has_finished"
const HIGH_SCORES_SECTION_KEY := "high_scores"
const CUMULATIVE_TIME_SECTION_KEY := "cumulative_time"
const FASTEST_TIMES_SECTION_KEY := "fastest_times"
const LONGEST_TIMES_SECTION_KEY := "longest_times"
const TOTAL_PLAYS_SECTION_KEY := "total_plays"
const ALL_SCORES_SECTION_KEY := "all_scores"
const IS_UNLOCKED_SECTION_KEY := "is_unlocked"
const VERSIONS_SECTION_KEY := "versions"

const LAST_LEVEL_PLAYED_KEY_KEY := "last_level_played"
const NEW_UNLOCKED_LEVELS_KEY := "new_unlocked_levels"
const GAVE_FEEDBACK_KEY := "gave_feedback"
const DATA_AGREEMENT_VERSION_KEY := "data_agreement_v"
const SCORE_VERSION_KEY := "score_v"

const AGREED_TO_TERMS_SETTINGS_KEY := "agreed_to_terms"
const ARE_BUTTON_CONTROLS_ENABLED_SETTINGS_KEY := "are_button_controls_enabled"
const IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY := "is_debug_panel_shown"
const IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY := "is_welcome_panel_shown"
const IS_DEBUG_TIME_SHOWN_SETTINGS_KEY := "is_debug_time_shown"
const IS_MUSIC_ENABLED_SETTINGS_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY := "is_sound_effects_enabled"
const IS_METRONOME_ENABLED_SETTINGS_KEY := "is_metronome_enabled"
const ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY := "additional_debug_time_scale"
const ZOOM_FACTOR_SETTINGS_KEY := "zoom_factor"
const SUGGESTED_NEXT_LEVEL_SETTINGS_KEY := "suggested_next_level"

var config: ConfigFile


func _init() -> void:
    Sc.logger.on_global_init(self, "SaveState")
    _load_config()
    
    if Sc.manifest.metadata.has(
                "is_save_state_cleared_for_debugging") and \
            Sc.manifest.metadata.is_save_state_cleared_for_debugging:
        erase_all_state()


func _load_config() -> void:
    config = ConfigFile.new()
    var status := config.load(CONFIG_FILE_PATH)
    if status != OK and \
            status != ERR_FILE_NOT_FOUND:
        Sc.logger.error("An error occurred loading game state: %s" % status)


func _save_config() -> void:
    var status := config.save(CONFIG_FILE_PATH)
    if status != OK:
        Sc.logger.error("An error occurred saving game state: %s" % status)


func set_setting(
        setting_key: String,
        setting_value) -> void:
    config.set_value(
            SETTINGS_SECTION_KEY,
            setting_key,
            setting_value)
    _save_config()


func get_setting(
        setting_key: String,
        default = null):
    return _get_value(
                    SETTINGS_SECTION_KEY,
                    setting_key) if \
            config.has_section_key(
                    SETTINGS_SECTION_KEY,
                    setting_key) else \
            default


func set_level_setting(
        level_id: String,
        setting_key: String,
        setting_value) -> void:
    var section_key := SETTINGS_SECTION_KEY + ":" + level_id
    config.set_value(
            section_key,
            setting_key,
            setting_value)
    _save_config()


func get_level_setting(
        level_id: String,
        setting_key: String,
        default = null):
    var section_key := SETTINGS_SECTION_KEY + ":" + level_id
    return _get_value(section_key, setting_key) if \
            config.has_section_key(section_key, setting_key) else \
            default


func erase_all_state() -> void:
    for section in config.get_sections():
        if config.has_section(section):
            config.erase_section(section)


func erase_all_scores() -> void:
    var sections := [
        HIGH_SCORES_SECTION_KEY,
        ALL_SCORES_SECTION_KEY,
    ]
    for section_key in sections:
        if config.has_section(section_key):
            config.erase_section(section_key)


func erase_level_state(level_id: String) -> void:
    var sections := [
        HIGH_SCORES_SECTION_KEY,
        TOTAL_PLAYS_SECTION_KEY,
        ALL_SCORES_SECTION_KEY,
        FASTEST_TIMES_SECTION_KEY,
        LONGEST_TIMES_SECTION_KEY,
        HAS_FINISHED_SECTION_KEY,
    ]
    for section_key in sections:
        if config.has_section_key(section_key, level_id):
            config.erase_section_key(
                    section_key,
                    level_id)


func _get_value(section: String, key: String, default = null):
    if !config.has_section_key(section, key):
        config.set_value(section, key, default)
    return config.get_value(section, key, default)


func set_gave_feedback(gave_feedback: bool) -> void:
    config.set_value(
            MISCELLANEOUS_SECTION_KEY,
            GAVE_FEEDBACK_KEY,
            gave_feedback)
    _save_config()


func get_gave_feedback() -> bool:
    return _get_value(
            MISCELLANEOUS_SECTION_KEY,
            GAVE_FEEDBACK_KEY,
            false) as bool


func set_data_agreement_version(version: String) -> void:
    config.set_value(
            VERSIONS_SECTION_KEY,
            DATA_AGREEMENT_VERSION_KEY,
            version)
    _save_config()


func get_data_agreement_version() -> String:
    return _get_value(
            VERSIONS_SECTION_KEY,
            DATA_AGREEMENT_VERSION_KEY,
            "") as String


func set_last_level_played(level_id: String) -> void:
    config.set_value(
            MISCELLANEOUS_SECTION_KEY,
            LAST_LEVEL_PLAYED_KEY_KEY,
            level_id)
    _save_config()


func get_last_level_played() -> String:
    return _get_value(
            MISCELLANEOUS_SECTION_KEY,
            LAST_LEVEL_PLAYED_KEY_KEY,
            "") as String


func set_score_version(version: String) -> void:
    config.set_value(
            VERSIONS_SECTION_KEY,
            SCORE_VERSION_KEY,
            version)
    _save_config()


func get_score_version() -> String:
    return _get_value(
            VERSIONS_SECTION_KEY,
            SCORE_VERSION_KEY,
            "") as String


func set_cumulative_time(
        cumulative_time: float) -> void:
    config.set_value(
            MISCELLANEOUS_SECTION_KEY,
            CUMULATIVE_TIME_SECTION_KEY,
            cumulative_time)
    _save_config()


func get_cumulative_time() -> float:
    return _get_value(
            MISCELLANEOUS_SECTION_KEY,
            CUMULATIVE_TIME_SECTION_KEY,
            Utils.MAX_INT) as float


func set_level_version(
        level_id: String,
        version: String) -> void:
    config.set_value(
            VERSIONS_SECTION_KEY,
            level_id,
            version)
    _save_config()


func get_level_version(level_id: String) -> String:
    return _get_value(
            VERSIONS_SECTION_KEY,
            level_id,
            "") as String


func set_level_has_finished(
        level_id: String,
        has_finished: bool) -> void:
    config.set_value(
            HAS_FINISHED_SECTION_KEY,
            level_id,
            has_finished)
    _save_config()


func get_level_has_finished(level_id: String) -> bool:
    return _get_value(
            HAS_FINISHED_SECTION_KEY,
            level_id,
            false) as bool


func set_level_high_score(
        level_id: String,
        high_score: float) -> void:
    config.set_value(
            HIGH_SCORES_SECTION_KEY,
            level_id,
            high_score)
    _save_config()


func get_level_high_score(level_id: String) -> float:
    return _get_value(
            HIGH_SCORES_SECTION_KEY,
            level_id,
            0) as float


func set_level_cumulative_time(
        level_id: String,
        cumulative_time: float) -> void:
    config.set_value(
            CUMULATIVE_TIME_SECTION_KEY,
            level_id,
            cumulative_time)
    _save_config()


func get_level_cumulative_time(level_id: String) -> float:
    return _get_value(
            CUMULATIVE_TIME_SECTION_KEY,
            level_id,
            Utils.MAX_INT) as float


func set_level_fastest_time(
        level_id: String,
        fastest_time: float) -> void:
    config.set_value(
            FASTEST_TIMES_SECTION_KEY,
            level_id,
            fastest_time)
    _save_config()


func get_level_fastest_time(level_id: String) -> float:
    return _get_value(
            FASTEST_TIMES_SECTION_KEY,
            level_id,
            Utils.MAX_INT) as float


func set_level_longest_time(
        level_id: String,
        longest_time: float) -> void:
    config.set_value(
            LONGEST_TIMES_SECTION_KEY,
            level_id,
            longest_time)
    _save_config()


func get_level_longest_time(level_id: String) -> float:
    return _get_value(
            LONGEST_TIMES_SECTION_KEY,
            level_id,
            Utils.MAX_INT) as float


func set_level_total_plays(
        level_id: String,
        total_plays: int) -> void:
    config.set_value(
            TOTAL_PLAYS_SECTION_KEY,
            level_id,
            total_plays)
    _save_config()


func get_level_total_plays(level_id: String) -> int:
    return _get_value(
            TOTAL_PLAYS_SECTION_KEY,
            level_id,
            0) as int


func set_level_all_scores(
        level_id: String,
        level_all_scores: Array) -> void:
    config.set_value(
            ALL_SCORES_SECTION_KEY,
            level_id,
            level_all_scores)
    _save_config()


func get_level_all_scores(level_id: String) -> Array:
    return _get_value(
            ALL_SCORES_SECTION_KEY,
            level_id,
            []) as Array


func set_level_is_unlocked(
        level_id: String,
        is_unlocked: bool) -> void:
    config.set_value(
            IS_UNLOCKED_SECTION_KEY,
            level_id,
            is_unlocked)
    _save_config()


func get_level_is_unlocked(level_id: String) -> bool:
    return _get_value(
            IS_UNLOCKED_SECTION_KEY,
            level_id,
            false) as bool or \
            Sc.metadata.are_all_levels_unlocked


func set_new_unlocked_levels(new_unlocked_levels: Array) -> void:
    config.set_value(
            MISCELLANEOUS_SECTION_KEY,
            NEW_UNLOCKED_LEVELS_KEY,
            new_unlocked_levels)
    _save_config()


func get_new_unlocked_levels() -> Array:
    return _get_value(
            MISCELLANEOUS_SECTION_KEY,
            NEW_UNLOCKED_LEVELS_KEY,
            []) as Array

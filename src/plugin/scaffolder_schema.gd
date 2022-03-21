tool
class_name ScaffolderSchema
extends FrameworkSchema


const _DISPLAY_NAME := "Scaffolder"
const _FOLDER_NAME := "scaffolder"
const _AUTO_LOAD_NAME := "Sc"
const _AUTO_LOAD_DEPS := []
const _AUTO_LOAD_PATH := "res://addons/scaffolder/src/config/sc.gd"
const _PLUGIN_ICON_DIRECTORY_PATH := "res://addons/scaffolder/assets/images/editor_icons/plugin/"

const _metadata := {
    debug = false,
    playtest = false,
    pauses_on_focus_out = true,
    also_prints_to_stdout = true,
    logs_character_events = true,
    logs_analytics_events = true,
    logs_bootstrap_events = true,
    logs_device_settings = true,
    logs_in_editor_events = true,
    is_profiler_enabled = true,
    are_all_levels_unlocked = true,
    is_splash_skipped = false,
    uses_threads = false,
    thread_count = 1,
    rng_seed = 176,
    is_mobile_supported = true,
    uses_level_scores = false,
    must_restart_level_to_change_settings = true,
    overrides_project_settings = true,
    overrides_input_map = true,
    are_button_controls_enabled_by_default = false,
    base_path = "addons/squirrel_away/",
    
    app_name = "Squirrel Away",
    app_id = "games.snoringcat.squirrel_away",
    app_version = "0.0.3",
    score_version = "0.0.1",
    data_agreement_version = "0.0.1",
    
    # Must start with "UA-".
    google_analytics_id = "UA-186405125-2",
    privacy_policy_url = \
            "https://snoringcat.games/squirrel-away/privacy-policy",
    terms_and_conditions_url = \
            "https://snoringcat.games/squirrel-away/terms-and-conditions",
    android_app_store_url = "",
    ios_app_store_url = "",
    support_url = "https://snoringcat.games/support",
    log_gestures_url = "",
    error_logs_url = \
            "https://storage.googleapis.com/upload/storage/v1/b/squirrel-away-logs/o",
    app_id_query_param = "squirrel-away",
    
    developer_name = "Snoring Cat LLC",
    developer_url = "https://snoringcat.games",
    github_url = "https://github.com/SnoringCatGames/squirrel_away",
    
    godot_splash_screen_duration = 0.8,
    developer_splash_screen_duration = 1.0,
}

const _sounds_manifest := [
    {
        name = "fall",
        volume_db = 18.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "cadence_win",
        volume_db = 10.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "cadence_lose",
        volume_db = 10.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "menu_select",
        volume_db = -2.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "menu_select_fancy",
        volume_db = -6.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "lock_low",
        volume_db = 0.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "lock_high",
        volume_db = 0.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "walk",
        volume_db = 15.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "achievement",
        volume_db = 12.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    {
        name = "single_cat_snore",
        volume_db = 17.0,
        path_prefix = "res://addons/scaffolder/assets/sounds/",
    },
    
    {
        name = "cat_jump",
        volume_db = 0.0,
    },
    {
        name = "cat_land",
        volume_db = 0.0,
    },
    {
        name = "cat_hit_surface",
        volume_db = 0.0,
    },
    {
        name = "contact",
        volume_db = 0.0,
    },
    {
        name = "squirrel_jump",
        volume_db = 0.0,
    },
    {
        name = "squirrel_land",
        volume_db = 0.0,
    },
    {
        name = "squirrel_yell",
        volume_db = 0.0,
    },
]

const _music_manifest := [
    {
        name = "on_a_quest",
        path_prefix = "res://addons/scaffolder/assets/music/",
        volume_db = 0.0,
        bpm = 75,
        meter = 4,
    },
    {
        name = "pause_menu",
        path_prefix = "res://addons/scaffolder/assets/music/",
        volume_db = 0.0,
        bpm = 56.25,
        meter = 4,
    },
]

const _audio_manifest := {
    sounds_manifest = _sounds_manifest,
    default_sounds_path_prefix = "res://addons/squirrel_away/assets/sounds/",
    default_sounds_file_suffix = ".wav",
    default_sounds_bus_index = 1,
    
    music_manifest = _music_manifest,
    default_music_path_prefix = "res://addons/scaffolder/assets/music/",
    default_music_file_suffix = ".ogg",
    default_music_bus_index = 2,
    
    godot_splash_sound = "achievement",
    developer_splash_sound = "single_cat_snore",
    level_end_sound_win = "cadence_win",
    level_end_sound_lose = "cadence_lose",
    
    main_menu_music = "on_a_quest",
    game_over_music = "pause_menu",
    pause_menu_music = "pause_menu",
    default_level_music = "on_a_quest",
    
    pauses_level_music_on_pause = true,
    
    are_beats_tracked_by_default = true,
    
    is_arbitrary_music_speed_change_supported = true,
    is_music_speed_scaled_with_time_scale = true,
    is_music_speed_scaled_with_additional_debug_time_scale = true,
    
    is_music_paused_in_slow_motion = true,
    is_tick_tock_played_in_slow_motion = true,
    is_slow_motion_start_stop_sound_effect_played = true,
}

const _PROPERTIES := {
    metadata = _metadata,
    audio_manifest = _audio_manifest,
}


func _init().(
        _DISPLAY_NAME,
        _FOLDER_NAME,
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_DEPS,
        _AUTO_LOAD_PATH,
        _PLUGIN_ICON_DIRECTORY_PATH,
        _PROPERTIES) -> void:
    pass

tool
class_name ScaffolderSchema
extends FrameworkSchema


const _METADATA_SCRIPT := ScaffolderMetadata

var _metadata := {
    pauses_on_focus_out = true,
    also_prints_to_stdout = true,
    logs_character_events = true,
    logs_analytics_events = true,
    logs_bootstrap_events = true,
    logs_device_settings = true,
    logs_in_editor_events = true,
    is_profiler_enabled = true,
    are_all_levels_unlocked = true,
    are_test_levels_included = true,
    is_save_state_cleared_for_debugging = false,
    opens_directly_to_level_id = "",
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
    base_path = "",
    
    app_name = "Scaffolder",
    app_id = "games.snoringcat.scaffolder",
    app_version = "0.0.1",
    score_version = "0.0.1",
    data_agreement_version = "0.0.1",
    
    # Must start with "UA-".
    google_analytics_id = "",
    privacy_policy_url = "",
    terms_and_conditions_url = "",
    android_app_store_url = "",
    ios_app_store_url = "",
    support_url = "",
    log_gestures_url = "",
    error_logs_url = "",
    app_id_query_param = "",
    
    developer_name = "Snoring Cat LLC",
    developer_url = "https://snoringcat.games",
    github_url = "https://github.com/SnoringCatGames/scaffolder",
    
    godot_splash_screen_duration = 0.8,
    developer_splash_screen_duration = 1.0,
}

var _sounds_manifest := [
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
]

var _music_manifest := [
    {
        name = "on_a_quest",
        path_prefix = "res://addons/scaffolder/assets/music/",
        volume_db = 0.0,
        bpm = 75.0,
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

var _audio_manifest := {
    sounds_manifest = _sounds_manifest,
    default_sounds_path_prefix = "res://addons/scaffolder/assets/sounds/",
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

var _fonts_manifest_anti_aliased := {
    fonts = {
        main_xxs = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xxs.tres"),
        main_xxs_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xxs.tres"),
        main_xxs_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xxs.tres"),
        main_xs = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xs.tres"),
        main_xs_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xs.tres"),
        main_xs_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xs_italic.tres"),
        main_s = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_s.tres"),
        main_s_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_s.tres"),
        main_s_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_s.tres"),
        main_m = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_m.tres"),
        main_m_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_m_bold.tres"),
        main_m_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_m_italic.tres"),
        main_l = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_l.tres"),
        main_l_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_l.tres"),
        main_l_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_l.tres"),
        main_xl = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xl.tres"),
        main_xl_bold = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xl.tres"),
        main_xl_italic = preload( \
                "res://addons/scaffolder/assets/fonts/roboto_font_xl.tres"),
        
        header_s = preload( \
                "res://addons/scaffolder/assets/fonts/nunito_font_s.tres"),
        header_m = preload( \
                "res://addons/scaffolder/assets/fonts/nunito_font_m.tres"),
        header_l = preload( \
                "res://addons/scaffolder/assets/fonts/nunito_font_l.tres"),
        header_xl = preload( \
                "res://addons/scaffolder/assets/fonts/nunito_font_xl.tres"),
    },
    sizes = {
        pc = {
            main_xxs = 10,
            main_xs = 15,
            main_s = 18,
            main_m = 30,
            main_l = 42,
            main_xl = 48,
#            _bold = ,
#            _italic = ,
#            header_s = ,
#            header_m = ,
#            header_l = ,
#            header_xl = ,
        },
        mobile = {
            main_xxs = 12,
            main_xs = 16,
            main_s = 18,
            main_m = 28,
            main_l = 32,
            main_xl = 36,
        },
    },
}

var _fonts_manifest_pixelated := {
    fonts = {
        main_xxs = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xxs.tres"),
        main_xxs_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xxs.tres"),
        main_xxs_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xxs.tres"),
        main_xs = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xs.tres"),
        main_xs_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xs.tres"),
        main_xs_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xs.tres"),
        main_s = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_s.tres"),
        main_s_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_s.tres"),
        main_s_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_s.tres"),
        main_m = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_m.tres"),
        main_m_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_m.tres"),
        main_m_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_m.tres"),
        main_l = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_l.tres"),
        main_l_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_l.tres"),
        main_l_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_l.tres"),
        main_xl = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xl.tres"),
        main_xl_bold = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xl.tres"),
        main_xl_italic = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xl.tres"),
        
        header_s = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_s.tres"),
        header_m = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_m.tres"),
        header_l = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_l.tres"),
        header_xl = preload( \
                "res://addons/scaffolder/assets/fonts/pxlzr_font_xl.tres"),
    },
    sizes = {
        pc = {
            main_xxs = 10,
            main_xs = 15,
            main_s = 18,
            main_m = 30,
            main_l = 42,
            main_xl = 48,
#            _bold = ,
#            _italic = ,
#            header_s = ,
#            header_m = ,
#            header_l = ,
#            header_xl = ,
        },
        mobile = {
            main_xxs = 12,
            main_xs = 16,
            main_s = 18,
            main_m = 28,
            main_l = 32,
            main_xl = 36,
        },
    },
}

var _styles_manifest_anti_aliased := {
    focus_border_corner_radius = 5,
    focus_border_corner_detail = 3,
    focus_border_shadow_size = 0,
    focus_border_border_width = 1,
    focus_border_expand_margin_left = 2.0,
    focus_border_expand_margin_top = 2.0,
    focus_border_expand_margin_right = 2.0,
    focus_border_expand_margin_bottom = 2.0,
    
    button_content_margin_left = 16.0,
    button_content_margin_top = 8.0,
    button_content_margin_right = 16.0,
    button_content_margin_bottom = 8.0,
    
    button_shine_margin_left = 0.0,
    button_shine_margin_top = 0.0,
    button_shine_margin_right = 0.0,
    button_shine_margin_bottom = 0.0,
    
    button_corner_radius = 4,
    button_corner_detail = 3,
    button_shadow_size = 3,
    button_border_width = 0,
    
    dropdown_corner_radius = 4,
    dropdown_corner_detail = 3,
    dropdown_shadow_size = 0,
    dropdown_border_width = 0,
    
    scroll_corner_radius = 6,
    scroll_corner_detail = 3,
    # Width of the scrollbar.
    scroll_content_margin_left = 7,
    scroll_content_margin_top = 7,
    scroll_content_margin_right = 7,
    scroll_content_margin_bottom = 7,
    
    scroll_grabber_corner_radius = 8,
    scroll_grabber_corner_detail = 3,
    
    slider_corner_radius = 6,
    slider_corner_detail = 3,
    slider_content_margin_left = 5,
    slider_content_margin_top = 5,
    slider_content_margin_right = 5,
    slider_content_margin_bottom = 5,
    
    overlay_panel_border_width = 2,
    
    overlay_panel_corner_radius = 4,
    overlay_panel_corner_detail = 3,
    overlay_panel_content_margin_left = 0.0,
    overlay_panel_content_margin_top = 0.0,
    overlay_panel_content_margin_right = 0.0,
    overlay_panel_content_margin_bottom = 0.0,
    overlay_panel_shadow_size = 8,
    overlay_panel_shadow_offset = Vector2(-4.0, 4.0),
    
    notification_panel_border_width = 2,
    
    notification_panel_corner_radius = 4,
    notification_panel_corner_detail = 3,
    notification_panel_content_margin_left = 0.0,
    notification_panel_content_margin_top = 0.0,
    notification_panel_content_margin_right = 0.0,
    notification_panel_content_margin_bottom = 0.0,
    notification_panel_shadow_size = 8,
    notification_panel_shadow_offset = Vector2(-4.0, 4.0),
    
    header_panel_content_margin_left = 0.0,
    header_panel_content_margin_top = 0.0,
    header_panel_content_margin_right = 0.0,
    header_panel_content_margin_bottom = 0.0,
    
    hud_panel_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/overlay_panel.png"),
    hud_panel_nine_patch_margin_left = 3.5,
    hud_panel_nine_patch_margin_top = 3.5,
    hud_panel_nine_patch_margin_right = 3.5,
    hud_panel_nine_patch_margin_bottom = 3.5,
    hud_panel_nine_patch_scale = 3.0,
    hud_panel_content_margin_left = 8.0,
    hud_panel_content_margin_top = 2.0,
    hud_panel_content_margin_right = 8.0,
    hud_panel_content_margin_bottom = 2.0,
    
    screen_shadow_size = 8,
    screen_shadow_offset = Vector2(-4.0, 4.0),
    screen_border_width = 0,
}

var _styles_manifest_pixelated := {
    button_content_margin_left = 16.0,
    button_content_margin_top = 8.0,
    button_content_margin_right = 16.0,
    button_content_margin_bottom = 8.0,
    
    button_shine_margin_left = 6.0,
    button_shine_margin_top = 6.0,
    button_shine_margin_right = 6.0,
    button_shine_margin_bottom = 6.0,
    
    focus_border_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/focus_border.png"),
    focus_border_nine_patch_margin_left = 3.5,
    focus_border_nine_patch_margin_top = 3.5,
    focus_border_nine_patch_margin_right = 3.5,
    focus_border_nine_patch_margin_bottom = 3.5,
    focus_border_nine_patch_scale = 3.0,
    focus_border_expand_margin_left = 3.0,
    focus_border_expand_margin_top = 3.0,
    focus_border_expand_margin_right = 3.0,
    focus_border_expand_margin_bottom = 3.0,
    
    button_pressed_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/button_pressed.png"),
    button_disabled_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/button_hover.png"),
    button_hover_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/button_hover.png"),
    button_normal_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/button_normal.png"),
    button_nine_patch_margin_left = 3.5,
    button_nine_patch_margin_top = 3.5,
    button_nine_patch_margin_right = 3.5,
    button_nine_patch_margin_bottom = 3.5,
    button_nine_patch_scale = 3.0,
    
    dropdown_pressed_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/dropdown_pressed.png"),
    dropdown_disabled_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/dropdown_hover.png"),
    dropdown_hover_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/dropdown_hover.png"),
    dropdown_normal_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/dropdown_normal.png"),
    dropdown_nine_patch_margin_left = 3.5,
    dropdown_nine_patch_margin_top = 3.5,
    dropdown_nine_patch_margin_right = 3.5,
    dropdown_nine_patch_margin_bottom = 3.5,
    dropdown_nine_patch_scale = 3.0,
    
    scroll_track_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/scroll_track.png"),
    scroll_track_nine_patch_margin_left = 3.5,
    scroll_track_nine_patch_margin_top = 3.5,
    scroll_track_nine_patch_margin_right = 3.5,
    scroll_track_nine_patch_margin_bottom = 3.5,
    scroll_track_nine_patch_scale = 3.0,
    
    scroll_grabber_pressed_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/scroll_grabber_pressed.png"),
    scroll_grabber_hover_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/scroll_grabber_hover.png"),
    scroll_grabber_normal_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/scroll_grabber_normal.png"),
    scroll_grabber_nine_patch_margin_left = 3.5,
    scroll_grabber_nine_patch_margin_top = 3.5,
    scroll_grabber_nine_patch_margin_right = 3.5,
    scroll_grabber_nine_patch_margin_bottom = 3.5,
    scroll_grabber_nine_patch_scale = 3.0,
    
    slider_track_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/slider_track.png"),
    slider_track_nine_patch_margin_left = 1.5,
    slider_track_nine_patch_margin_top = 1.5,
    slider_track_nine_patch_margin_right = 1.5,
    slider_track_nine_patch_margin_bottom = 1.5,
    slider_track_nine_patch_scale = 3.0,
    
    overlay_panel_border_width = 2,
    
    overlay_panel_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/overlay_panel.png"),
    overlay_panel_nine_patch_margin_left = 3.5,
    overlay_panel_nine_patch_margin_top = 3.5,
    overlay_panel_nine_patch_margin_right = 3.5,
    overlay_panel_nine_patch_margin_bottom = 3.5,
    overlay_panel_nine_patch_scale = 3.0,
    overlay_panel_content_margin_left = 3.0,
    overlay_panel_content_margin_top = 3.0,
    overlay_panel_content_margin_right = 3.0,
    overlay_panel_content_margin_bottom = 3.0,
    
    notification_panel_border_width = 2,
    
    notification_panel_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/notification_panel.png"),
    notification_panel_nine_patch_margin_left = 3.5,
    notification_panel_nine_patch_margin_top = 3.5,
    notification_panel_nine_patch_margin_right = 3.5,
    notification_panel_nine_patch_margin_bottom = 3.5,
    notification_panel_nine_patch_scale = 3.0,
    notification_panel_content_margin_left = 3.0,
    notification_panel_content_margin_top = 3.0,
    notification_panel_content_margin_right = 3.0,
    notification_panel_content_margin_bottom = 3.0,
    
    header_panel_content_margin_left = 0.0,
    header_panel_content_margin_top = 0.0,
    header_panel_content_margin_right = 0.0,
    header_panel_content_margin_bottom = 0.0,
    
    hud_panel_nine_patch = \
            preload("res://addons/scaffolder/assets/images/gui/nine_patch/overlay_panel.png"),
    hud_panel_nine_patch_margin_left = 3.5,
    hud_panel_nine_patch_margin_top = 3.5,
    hud_panel_nine_patch_margin_right = 3.5,
    hud_panel_nine_patch_margin_bottom = 3.5,
    hud_panel_nine_patch_scale = 3.0,
    hud_panel_content_margin_left = 8.0,
    hud_panel_content_margin_top = 2.0,
    hud_panel_content_margin_right = 8.0,
    hud_panel_content_margin_bottom = 2.0,
    
    screen_shadow_size = 0,
    screen_shadow_offset = Vector2.ZERO,
    screen_border_width = 0,
}

var _images_manifest_anti_aliased := {
    checkbox_path_prefix = \
            ScaffolderImages.DEFAULT_CHECKBOX_NORMAL_PATH_PREFIX,
    default_checkbox_size = \
            ScaffolderImages.DEFAULT_CHECKBOX_NORMAL_SIZE,
    checkbox_sizes = \
            ScaffolderImages.DEFAULT_CHECKBOX_NORMAL_SIZES,
    
    radio_button_path_prefix = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_NORMAL_PATH_PREFIX,
    default_radio_button_size = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_NORMAL_SIZE,
    radio_button_sizes = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_NORMAL_SIZES,
    
    tree_arrow_path_prefix = \
            ScaffolderImages.DEFAULT_TREE_ARROW_NORMAL_PATH_PREFIX,
    default_tree_arrow_size = \
            ScaffolderImages.DEFAULT_TREE_ARROW_NORMAL_SIZE,
    tree_arrow_sizes = \
            ScaffolderImages.DEFAULT_TREE_ARROW_NORMAL_SIZES,
    
    dropdown_arrow_path_prefix = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_NORMAL_PATH_PREFIX,
    default_dropdown_arrow_size = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_NORMAL_SIZE,
    dropdown_arrow_sizes = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_NORMAL_SIZES,
    
    slider_grabber_path_prefix = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_NORMAL_PATH_PREFIX,
    default_slider_grabber_size = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_NORMAL_SIZE,
    slider_grabber_sizes = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_NORMAL_SIZES,
    
    slider_tick_path_prefix = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_NORMAL_PATH_PREFIX,
    default_slider_tick_size = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_NORMAL_SIZE,
    slider_tick_sizes = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_NORMAL_SIZES,
    
    app_logo = preload(
            "res://addons/scaffolder/assets/images/logos/scaffolder_logo.png"),
    app_logo_scale = 1.0,
    
    developer_logo = preload(
            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_about.png"),
    developer_splash = preload(
            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_splash.png"),
    
    go_normal = preload(
            "res://addons/scaffolder/assets/images/gui/icons/go_normal.png"),
    go_scale = 1.5,
    
    about_circle_pressed = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_pressed.png"),
    about_circle_hover = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_hover.png"),
    about_circle_normal = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_normal.png"),
    
    alert_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/alert_normal.png"),
    
    close_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_pressed.png"),
    close_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_hover.png"),
    close_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_normal.png"),
    
    gear_circle_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_pressed.png"),
    gear_circle_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_hover.png"),
    gear_circle_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_normal.png"),
    
    home_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/home_normal.png"),
    
    left_caret_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_pressed.png"),
    left_caret_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_hover.png"),
    left_caret_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_normal.png"),
    
    pause_circle_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_pressed.png"),
    pause_circle_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_hover.png"),
    pause_circle_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_normal.png"),
    
    pause_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_normal.png"),
    play_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/play_normal.png"),
    retry_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/retry_normal.png"),
    stop_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/stop_normal.png"),
}

var _images_manifest_pixelated := {
    checkbox_path_prefix = \
            ScaffolderImages.DEFAULT_CHECKBOX_PIXEL_PATH_PREFIX,
    default_checkbox_size = \
            ScaffolderImages.DEFAULT_CHECKBOX_PIXEL_SIZE,
    checkbox_sizes = \
            ScaffolderImages.DEFAULT_CHECKBOX_PIXEL_SIZES,
    
    radio_button_path_prefix = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_PIXEL_PATH_PREFIX,
    default_radio_button_size = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_PIXEL_SIZE,
    radio_button_sizes = \
            ScaffolderImages.DEFAULT_RADIO_BUTTON_PIXEL_SIZES,
    
    tree_arrow_path_prefix = \
            ScaffolderImages.DEFAULT_TREE_ARROW_PIXEL_PATH_PREFIX,
    default_tree_arrow_size = \
            ScaffolderImages.DEFAULT_TREE_ARROW_PIXEL_SIZE,
    tree_arrow_sizes = \
            ScaffolderImages.DEFAULT_TREE_ARROW_PIXEL_SIZES,
    
    dropdown_arrow_path_prefix = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_PIXEL_PATH_PREFIX,
    default_dropdown_arrow_size = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_PIXEL_SIZE,
    dropdown_arrow_sizes = \
            ScaffolderImages.DEFAULT_DROPDOWN_ARROW_PIXEL_SIZES,
    
    slider_grabber_path_prefix = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_PIXEL_PATH_PREFIX,
    default_slider_grabber_size = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_PIXEL_SIZE,
    slider_grabber_sizes = \
            ScaffolderImages.DEFAULT_SLIDER_GRABBER_PIXEL_SIZES,
    
    slider_tick_path_prefix = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_PIXEL_PATH_PREFIX,
    default_slider_tick_size = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_PIXEL_SIZE,
    slider_tick_sizes = \
            ScaffolderImages.DEFAULT_SLIDER_TICK_PIXEL_SIZES,
    
    app_logo = preload(
            "res://addons/scaffolder/assets/images/logos/scaffolder_logo.png"),
    app_logo_scale = 1.0,
    
    developer_logo = preload(
            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_about.png"),
    developer_splash = preload(
            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_splash.png"),
    
    go_normal = preload(
            "res://addons/scaffolder/assets/images/gui/icons/go_normal.png"),
    go_scale = 1.5,
    
    about_circle_pressed = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_pressed.png"),
    about_circle_hover = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_hover.png"),
    about_circle_normal = preload(
            "res://addons/scaffolder/assets/images/gui/icons/about_circle_normal.png"),
    
    alert_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/alert_normal.png"),
    
    close_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_pressed.png"),
    close_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_hover.png"),
    close_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/close_normal.png"),
    
    gear_circle_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_pressed.png"),
    gear_circle_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_hover.png"),
    gear_circle_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/gear_circle_normal.png"),
    
    home_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/home_normal.png"),
    
    left_caret_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_pressed.png"),
    left_caret_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_hover.png"),
    left_caret_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/left_caret_normal.png"),
    
    pause_circle_pressed = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_pressed.png"),
    pause_circle_hover = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_hover.png"),
    pause_circle_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_circle_normal.png"),
    
    pause_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/pause_normal.png"),
    play_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/play_normal.png"),
    retry_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/retry_normal.png"),
    stop_normal = \
            preload("res://addons/scaffolder/assets/images/gui/icons/stop_normal.png"),
}

var _colors_manifest := \
        Utils.get_direct_color_properties(ScaffolderDefaultColors.new())

var _settings_item_manifest := {
    groups = {
        main = {
            label = "",
            is_collapsible = false,
            item_classes = [
                MusicControlRow,
                SoundEffectsControlRow,
                HapticFeedbackControlRow,
            ],
        },
        annotations = {
            label = "Rendering",
            is_collapsible = true,
            item_classes = [
                RulerAnnotatorControlRow,
                RecentMovementAnnotatorControlRow,
                CharacterAnnotatorControlRow,
                LevelAnnotatorControlRow,
            ],
        },
        hud = {
            label = "HUD",
            is_collapsible = true,
            item_classes = [
                DebugPanelControlRow,
            ],
        },
        miscellaneous = {
            label = "Miscellaneous",
            is_collapsible = true,
            item_classes = [
                ButtonControlsControlRow,
                WelcomePanelControlRow,
                CameraZoomControlRow,
                TimeScaleControlRow,
                MetronomeControlRow,
            ],
        },
    },
}

var _pause_item_manifest := [
    LevelControlRow,
    TimeControlRow,
#     FastestTimeControlRow,
#     ScoreControlRow,
#     HighScoreControlRow,
]

var _game_over_item_manifest := [
    LevelControlRow,
    TimeControlRow,
#     FastestTimeControlRow,
#     ScoreControlRow,
#     HighScoreControlRow,
]

var _level_select_item_manifest := [
    TotalPlaysControlRow,
    FastestTimeControlRow,
#     HighScoreControlRow,
]

var _hud_manifest := {
    hud_class = ScaffolderHud,
    hud_key_value_box_size = Vector2(256.0, 48.0),
    hud_key_value_box_scene = \
            preload("res://addons/scaffolder/src/gui/hud/hud_key_value_box.tscn"),
    hud_key_value_list_scene = \
            preload("res://addons/scaffolder/src/gui/hud/hud_key_value_list.tscn"),
    hud_key_value_list_item_manifest = [
        {
            item_class = TimeControlRow,
            settings_enablement_label = "Time",
            enabled_by_default = true,
            settings_group_key = "hud",
        },
    ],
    is_hud_visible_by_default = true,
}

const WELCOME_PANEL_ITEM_MOVE := ["Walk/Climb", "arrow key / wasd"]
const WELCOME_PANEL_ITEM_JUMP := ["Jump", "space / x"]
const WELCOME_PANEL_ITEM_GRAB := ["Grab surface", "c / arrow key"]
const WELCOME_PANEL_ITEM_DASH := ["Dash", "z"]
const WELCOME_PANEL_ITEM_ZOOM := ["Zoom in/out", "ctrl + =/-"]
const WELCOME_PANEL_ITEM_PAN := ["Pan", "ctrl + arrow key"]

var _welcome_panel_manifest := {
#    header = Sc.metadata.app_name,
#    subheader = "(Click window to give focus)",
#    is_header_shown = true,
    items = [
        WELCOME_PANEL_ITEM_MOVE,
        WELCOME_PANEL_ITEM_JUMP,
#        WELCOME_PANEL_ITEM_GRAB,
#        WELCOME_PANEL_ITEM_DASH,
#        WELCOME_PANEL_ITEM_ZOOM,
#        WELCOME_PANEL_ITEM_PAN,
    ],
}

var _screen_manifest := {
    screens = [
        preload("res://addons/scaffolder/src/gui/screens/about_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/data_agreement_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/developer_splash_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/game_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/game_over_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/godot_splash_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/level_select_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/main_menu_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/notification_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/pause_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/scaffolder_loading_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/settings_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/third_party_licenses_screen.tscn"),
        preload("res://addons/scaffolder/src/gui/screens/confirm_data_deletion_screen_local.tscn"),
#        preload("res://addons/scaffolder/src/gui/screens/scaffolder_loading_screen.tscn"),
#        preload("res://addons/scaffolder/src/gui/screens/confirm_data_deletion_screen_with_analytics.tscn"),
#        preload("res://addons/scaffolder/src/gui/screens/rate_app_screen.tscn"),
    ],
    overlay_mask_transition_fade_in_texture = preload( \
            "res://addons/scaffolder/assets/images/transition_masks/radial_mask_transition_in.png"),
    overlay_mask_transition_fade_out_texture = preload( \
            "res://addons/scaffolder/assets/images/transition_masks/radial_mask_transition_in.png"),
    screen_mask_transition_fade_texture = preload( \
            "res://addons/scaffolder/assets/images/transition_masks/checkers_mask_transition.png"),
    overlay_mask_transition_class = OverlayMaskTransition,
    screen_mask_transition_class = ScreenMaskTransition,
    slide_transition_duration = 0.3,
    fade_transition_duration = 0.3,
    overlay_mask_transition_duration = 1.2,
    screen_mask_transition_duration = 1.2,
    slide_transition_easing = "ease_in_out",
    fade_transition_easing = "ease_in_out",
    overlay_mask_transition_fade_in_easing = "ease_out",
    overlay_mask_transition_fade_out_easing = "ease_in",
    screen_mask_transition_easing = "ease_in",
    default_transition_type = ScreenTransition.FADE,
    fancy_transition_type = ScreenTransition.SCREEN_MASK,
    overlay_mask_transition_color = Color("111111"),
    overlay_mask_transition_uses_pixel_snap = false,
    overlay_mask_transition_smooth_size = 0.02,
    screen_mask_transition_uses_pixel_snap = true,
    screen_mask_transition_smooth_size = 0.0,
}

var _gui_manifest := {
    debug_window_size = ScaffolderGuiConfig.SCREEN_RESOLUTIONS.full_screen,
    moves_debug_game_window_to_other_monitor = true,
    
    default_pc_game_area_size = Vector2(1024, 768),
    default_mobile_game_area_size = Vector2(500, 600),
    aspect_ratio_max = 2.0 / 1.0,
    aspect_ratio_min = 1.0 / 2.0,
    camera_smoothing_speed = 10.0,
    gui_camera_zoom_factor = 0.4,
    button_height = 56.0,
    button_width = 230.0,
    screen_body_width = 460.0,
    
    is_data_deletion_button_shown = true,
    
    is_suggested_button_shine_line_shown = true,
    is_suggested_button_color_pulse_shown = true,
    
    third_party_license_text = ScaffolderThirdPartyLicenses.TEXT,
    special_thanks_text = """
""",
    
    main_menu_image_scale = 1.0,
    game_over_image_scale = 0.5,
    loading_image_scale = 0.5,
    
    main_menu_image_scene = preload(
        "res://addons/scaffolder/src/gui/placeholder_loading_image.tscn"),
    game_over_image_scene = preload(
        "res://addons/scaffolder/src/gui/placeholder_loading_image.tscn"),
    loading_image_scene = preload(
        "res://addons/scaffolder/src/gui/placeholder_loading_image.tscn"),
    welcome_panel_scene = preload(
        "res://addons/scaffolder/src/gui/welcome_panel.tscn"),
    debug_panel_scene = preload(
        "res://addons/scaffolder/src/gui/debug_panel.tscn"),
    
    theme = preload(
        "res://addons/scaffolder/src/config/scaffolder_default_theme.tres"),
    
    fonts_manifest_anti_aliased = _fonts_manifest_anti_aliased,
    fonts_manifest_pixelated = _fonts_manifest_pixelated,
    settings_item_manifest = _settings_item_manifest,
    pause_item_manifest = _pause_item_manifest,
    game_over_item_manifest = _game_over_item_manifest,
    level_select_item_manifest = _level_select_item_manifest,
    hud_manifest = _hud_manifest,
    welcome_panel_manifest = _welcome_panel_manifest,
    screen_manifest = _screen_manifest,
    
    splash_scale_pc = 1.0,
    splash_scale_mobile = 0.77,
}

var _notifications_manifest := {
    duration_short_sec = 2.0,
    duration_long_sec = 8.0,
    
    fade_in_duration = 0.15,
    fade_out_duration = 0.3,
    
    size_small = Vector2(200.0, 67.0),
    size_medium = Vector2(400.0, 133.0),
    size_large = Vector2(600.0, 200.0),
    
    margin_bottom = 16.0,
    margin_sides = 16.0,
    
    opacity = 0.9,
    
    slide_in_displacement = Vector2(0.0, -67.0),
}

var _slow_motion_manifest := {
    time_scale = 0.5,
    tick_tock_tempo_multiplier = 1,
    saturation = 0.5,
#    time_scale = 0.02,
#    tick_tock_tempo_multiplier = 25,
#    saturation = 0.2,
}

var _input_map := ScaffolderProjectSettings._get_input_map_schema()

var _character_scenes := [
    # FIXME: ----------- Remove this.
    preload("res://addons/squirrel_away/src/characters/squirrel/squirrel.tscn"),
]

# FIXME: ----------- Remove this.
const _SQUIRREL_CATEGORY := {
    name = "category_name",
    characters = [
        # FIXME: ----------- Remove this.
        "squirrel",
    ],
    # For a complete list of properties, see MovementParameters.
    movement_params = {
        collider_shape = [TYPE_RESOURCE, null],
        collider_rotation = PI / 2.0,
        
        can_grab_walls = true,
        can_grab_ceilings = true,
        can_jump = true,
        can_dash = false,
        can_double_jump = false,
        
        surface_speed_multiplier = 1.0,
        air_horizontal_speed_multiplier = 1.0,
        gravity_multiplier = 1.0,
        gravity_slow_rise_multiplier_multiplier = 1.0,
        gravity_double_jump_slow_rise_multiplier_multiplier = 1.0,
        walk_acceleration_multiplier = 1.4,
        in_air_horizontal_acceleration_multiplier = 1.4,
        climb_up_speed_multiplier = 1.5,
        climb_down_speed_multiplier = 1.5,
        ceiling_crawl_speed_multiplier = 1.5,
        friction_coefficient_multiplier = 1.0,
        jump_boost_multiplier = 1.2,
        wall_jump_horizontal_boost_multiplier = 1.0,
        wall_fall_horizontal_boost_multiplier = 1.0,
        max_horizontal_speed_default_multiplier = 1.4,
        max_vertical_speed_multiplier = 1.0,
        
        uses_duration_instead_of_distance_for_edge_weight = true,
        additional_edge_weight_offset_override = -1.0,
        walking_edge_weight_multiplier_override = -1.0,
        ceiling_crawling_edge_weight_multiplier_override = -1.0,
        climbing_edge_weight_multiplier_override = -1.0,
        climb_to_adjacent_surface_edge_weight_multiplier_override = -1.0,
        move_to_collinear_surface_edge_weight_multiplier_override = -1.0,
        air_edge_weight_multiplier_override = -1.0,
        
        minimizes_velocity_change_when_jumping = false,
        optimizes_edge_jump_positions_at_run_time = true,
        optimizes_edge_land_positions_at_run_time = true,
        also_optimizes_preselection_path = true,
        forces_character_position_to_match_edge_at_start = true,
        forces_character_velocity_to_match_edge_at_start = true,
        forces_character_position_to_match_path_at_end = false,
        forces_character_velocity_to_zero_at_path_end = false,
        syncs_character_position_to_edge_trajectory = true,
        syncs_character_velocity_to_edge_trajectory = true,
        includes_continuous_trajectory_positions = true,
        includes_continuous_trajectory_velocities = true,
        includes_discrete_trajectory_state = false,
        is_trajectory_state_stored_at_build_time = false,
        bypasses_runtime_physics = false,
        default_nav_interrupt_resolution_mode = \
                NavigationInterruptionResolution.FORCE_EXPECTED_STATE,
        min_intra_surface_distance_to_optimize_jump_for = 16.0,
        dist_sq_thres_for_considering_additional_jump_land_points = \
                32.0 * 32.0,
        stops_after_finding_first_valid_edge_for_a_surface_pair = false,
        calculates_all_valid_edges_for_a_surface_pair = false,
        always_includes_jump_land_positions_at_surface_ends = false,
        includes_redundant_j_l_positions_with_zero_start_velocity = true,
        normal_jump_instruction_duration_increase = 0.08,
        exceptional_jump_instruction_duration_increase = 0.2,
        recurses_when_colliding_during_horizontal_step_calculations = true,
        backtracks_for_higher_jumps_during_hor_step_calculations = true,
        collision_margin_for_edge_calculations = 1.0,
        collision_margin_for_waypoint_positions = 4.0,
        skips_less_likely_jump_land_positions = false,
        reached_in_air_destination_distance_squared_threshold = \
                16.0 * 16.0,
        max_edges_to_remove_from_path_for_opt_to_in_air_dest = 2,
        always_tries_to_face_direction_of_motion = true,
        max_distance_for_reachable_surface_tracking = 1024.0,
    },
}

var _character_categories := [
    _SQUIRREL_CATEGORY,
]

var _character_manifest := {
    default_player_character_name = "",
    character_scenes = _character_scenes,
    character_categories = _character_categories,
    omits_npcs = false,
    can_include_player_characters = true,
    is_camera_auto_assigned_to_player_character = true,
}

var _level_manifest := {
#    level_config_class = ,
#    level_session_class = ,
    default_camera_bounds_level_margin = \
        ScaffolderLevelConfig.DEFAULT_CAMERA_BOUNDS_LEVEL_MARGIN,
    default_character_bounds_level_margin = \
        ScaffolderLevelConfig.DEFAULT_CHARACTER_BOUNDS_LEVEL_MARGIN,
}

var _camera_manifest := {
    default_camera_pan_controller_class = DefaultPanController,
    snaps_camera_back_to_character = true,
    
    manual_zoom_key_step_ratio = 1.08,
    manual_pan_key_step_distance = 8.0,
    zoom_transition_duration = 0.3,
    offset_transition_duration = 0.8,
    
    pan_controller_min_zoom = 0.05,
    pan_controller_max_zoom = 1.0,
    pan_controller_also_limits_max_zoom_to_level_bounds = true,
    pan_controller_zoom_speed_multiplier = 1.08,
    
    swipe_pan_speed_multiplier = 1.5,
    swipe_pinch_zoom_speed_multiplier = 1.0,
    swipe_max_pan_speed = 1000.0,
    swipe_pan_continuation_deceleration = -6000.0,
    swipe_zoom_continuation_deceleration = -6000.0,
    swipe_pan_continuation_min_speed = 0.2,
    swipe_zoom_continuation_min_speed = 0.001,
}

var _annotation_parameters_manifest := Sc.utils.merge(
        Utils.get_direct_non_color_properties(
            ScaffolderDefaultAnnotationParameters.new()),
        Utils.get_direct_non_color_properties(
            ScaffolderDefaultColors.new()))

var _properties := {
    metadata = _metadata,
    audio_manifest = _audio_manifest,
    colors_manifest = _colors_manifest,
    styles_manifest_anti_aliased = _styles_manifest_anti_aliased,
    styles_manifest_pixelated = _styles_manifest_pixelated,
    images_manifest_anti_aliased = _images_manifest_anti_aliased,
    images_manifest_pixelated = _images_manifest_pixelated,
    gui_manifest = _gui_manifest,
    notifications_manifest = _notifications_manifest,
    slow_motion_manifest = _slow_motion_manifest,
    input_map = _input_map,
    character_manifest = _character_manifest,
    level_manifest = _level_manifest,
    camera_manifest = _camera_manifest,
    annotation_parameters_manifest = _annotation_parameters_manifest,

    annotators_class = ScaffolderAnnotators,
}

var _additive_overrides := {}

var _subtractive_overrides := {}


func _init().(
        _METADATA_SCRIPT,
        _properties,
        _additive_overrides,
        _subtractive_overrides) -> void:
    pass

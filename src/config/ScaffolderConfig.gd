class_name ScaffolderConfig
extends Node

# ---

const AGREED_TO_TERMS_SETTINGS_KEY := "agreed_to_terms"
const IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY := "is_debug_panel_shown"
const IS_DEBUG_TIME_SHOWN_SETTINGS_KEY := "is_debug_time_shown"
const IS_MUSIC_ENABLED_SETTINGS_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY := "is_sound_effects_enabled"

const DEBUG_PANEL_RESOURCE_PATH := \
        "res://addons/scaffolder/src/gui/DebugPanel.tscn"

const MIN_GUI_SCALE := 0.2

# --- Static configuration state ---

var manifest: Dictionary

var debug: bool
var playtest: bool
var test := false
var is_profiler_enabled: bool
var are_all_levels_unlocked := false
var is_splash_skipped := false
var also_prints_to_stdout := true

var debug_window_size: Vector2

# Should match Project Settings > Physics > 2d > Thread Model
var uses_threads: bool
var thread_count: int

var is_mobile_supported: bool
var is_data_deletion_button_shown: bool

var app_name: String
var app_id: String
var app_version: String
var score_version: String
var data_agreement_version: String

var theme: Theme

var cell_size: Vector2

# Should match Project Settings > Display > Window > Size > Width/Height
var default_game_area_size: Vector2

var aspect_ratio_max: float
var aspect_ratio_min: float

var uses_level_scores: bool

var must_restart_level_to_change_settings: bool

var screen_path_exclusions: Array
var screen_path_inclusions: Array
var settings_main_item_class_exclusions: Array
var settings_main_item_class_inclusions: Array
var settings_details_item_class_exclusions: Array
var settings_details_item_class_inclusions: Array
var pause_item_class_exclusions: Array
var pause_item_class_inclusions: Array
var game_over_item_class_exclusions: Array
var game_over_item_class_inclusions: Array
var level_select_item_class_exclusions: Array
var level_select_item_class_inclusions: Array

var fonts: Dictionary

var sounds_manifest: Array
var default_sounds_path_prefix: String
var default_sounds_file_suffix: String
var default_sounds_bus_index: String
var music_manifest: Array
var default_music_path_prefix: String
var default_music_file_suffix: String
var default_music_bus_index: String

var main_menu_music: String
var game_over_music: String
var godot_splash_sound := "achievement"
var developer_splash_sound: String
var level_end_sound: String

var third_party_license_text: String
var special_thanks_text: String

var app_logo: Texture
var app_logo_scale: float
var go_icon: Texture
var go_icon_scale: float
var developer_name: String
var developer_url: String

var developer_logo: Texture
var developer_splash: Texture

var godot_splash_screen_duration_sec := 0.8
var developer_splash_screen_duration_sec := 1.0

var main_menu_image_scene_path: String

var fade_in_transition_texture := \
        preload("res://addons/scaffolder/assets/images/transition_in.png")
var fade_out_transition_texture := \
        preload("res://addons/scaffolder/assets/images/transition_out.png")

# Must start with "UA-".
var google_analytics_id: String
var terms_and_conditions_url: String
var privacy_policy_url: String
var android_app_store_url: String
var ios_app_store_url: String
var support_url: String
var error_logs_url: String
var log_gestures_url: String
var app_id_query_param: String

var default_camera_zoom := 1.0

var input_vibrate_duration_sec := 0.01

var display_resize_throttle_interval_sec := 0.1

var recent_gesture_events_for_debugging_buffer_size := 1000

var checkbox_icon_path_prefix := \
        "res://addons/scaffolder/assets/images/gui/checkbox_"
var default_checkbox_icon_size := 32
var checkbox_icon_sizes := [16, 32, 64, 128]

var tree_arrow_icon_path_prefix := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow_"
var default_tree_arrow_icon_size := 16
var tree_arrow_icon_sizes := [8, 16, 32, 64]

# --- Derived configuration ---

var is_special_thanks_shown: bool
var is_third_party_licenses_shown: bool
var is_data_tracked: bool
var are_error_logs_captured: bool
var is_rate_app_shown: bool
var is_support_shown: bool
var is_gesture_logging_supported: bool
var is_developer_logo_shown: bool
var is_developer_splash_shown: bool
var is_main_menu_image_shown: bool
var original_font_sizes: Dictionary

# --- Global state ---

var is_app_configured := false
var is_app_ready := false
var agreed_to_terms: bool
var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var is_debug_time_shown: bool

var game_area_region: Rect2
var gui_scale := 1.0
var current_checkbox_icon_size := default_checkbox_icon_size
var current_tree_arrow_icon_size := default_checkbox_icon_size
var crash_reporter: CrashReporter
var audio: Audio
var colors: ScaffolderColors
var styles: ScaffolderStyles
var nav: ScaffoldNavigation
var save_state: SaveState
var analytics: Analytics
var gesture_reporter: GestureReporter
var logger: ScaffoldLog
var utils: Utils
var time: Time
var profiler: Profiler
var geometry: ScaffoldGeometry
var draw_utils: DrawUtils
var level_input: LevelInput
var level_config: ScaffolderLevelConfig
var canvas_layers: CanvasLayers
var camera_controller: CameraController
var debug_panel: DebugPanel
var gesture_record: GestureRecord
var level: ScaffolderLevel

var guis_to_scale := {}
var active_overlays := []

# ---

func _enter_tree() -> void:
    self.logger = ScaffoldLog.new()
    add_child(self.logger)
    self.logger.print("ScaffolderConfig._enter_tree")

func amend_app_manifest(manifest: Dictionary) -> void:
    if !manifest.has("screen_path_exclusions"):
        manifest.screen_path_exclusions = []
    if !manifest.has("screen_path_inclusions"):
        manifest.screen_path_inclusions = []
    
    if !manifest.has("settings_main_item_class_exclusions"):
        manifest.settings_main_item_class_exclusions = []
    if !manifest.has("settings_main_item_class_inclusions"):
        manifest.settings_main_item_class_inclusions = []
    if !manifest.has("settings_details_item_class_exclusions"):
        manifest.settings_details_item_class_exclusions = []
    if !manifest.has("settings_details_item_class_inclusions"):
        manifest.settings_details_item_class_inclusions = []
    
    if !manifest.has("pause_item_class_exclusions"):
        manifest.pause_item_class_exclusions = []
    if !manifest.has("pause_item_class_inclusions"):
        manifest.pause_item_class_inclusions = []
    if !manifest.has("game_over_item_class_exclusions"):
        manifest.game_over_item_class_exclusions = []
    if !manifest.has("game_over_item_class_inclusions"):
        manifest.game_over_item_class_inclusions = []
    if !manifest.has("level_select_item_class_exclusions"):
        manifest.level_select_item_class_exclusions = []
    if !manifest.has("level_select_item_class_inclusions"):
        manifest.level_select_item_class_inclusions = []

func register_app_manifest(manifest: Dictionary) -> void:
    self.manifest = manifest
    self.debug = manifest.debug
    self.playtest = manifest.playtest
    self.also_prints_to_stdout = manifest.also_prints_to_stdout
    self.is_profiler_enabled = manifest.is_profiler_enabled
    self.debug_window_size = manifest.debug_window_size
    self.uses_threads = manifest.uses_threads
    self.thread_count = manifest.thread_count
    self.is_mobile_supported = manifest.is_mobile_supported
    self.is_data_deletion_button_shown = manifest.is_data_deletion_button_shown
    self.app_name = manifest.app_name
    self.app_id = manifest.app_id
    self.app_version = manifest.app_version
    self.score_version = manifest.score_version
    self.theme = manifest.theme
    self.cell_size = manifest.cell_size
    self.default_game_area_size = manifest.default_game_area_size
    self.aspect_ratio_max = manifest.aspect_ratio_max
    self.aspect_ratio_min = manifest.aspect_ratio_min
    self.uses_level_scores = manifest.uses_level_scores
    self.must_restart_level_to_change_settings = \
            manifest.must_restart_level_to_change_settings
    self.screen_path_exclusions = manifest.screen_path_exclusions
    self.screen_path_inclusions = manifest.screen_path_inclusions
    self.settings_main_item_class_exclusions = \
            manifest.settings_main_item_class_exclusions
    self.settings_main_item_class_inclusions = \
            manifest.settings_main_item_class_inclusions
    self.settings_details_item_class_exclusions = \
            manifest.settings_details_item_class_exclusions
    self.settings_details_item_class_inclusions = \
            manifest.settings_details_item_class_inclusions
    self.pause_item_class_exclusions = manifest.pause_item_class_exclusions
    self.pause_item_class_inclusions = manifest.pause_item_class_inclusions
    self.game_over_item_class_exclusions = \
            manifest.game_over_item_class_exclusions
    self.game_over_item_class_inclusions = \
            manifest.game_over_item_class_inclusions
    self.level_select_item_class_exclusions = \
            manifest.level_select_item_class_exclusions
    self.level_select_item_class_inclusions = \
            manifest.level_select_item_class_inclusions
    self.fonts = manifest.fonts
    self.sounds_manifest = manifest.sounds_manifest
    self.default_sounds_path_prefix = manifest.default_sounds_path_prefix
    self.default_sounds_file_suffix = manifest.default_sounds_file_suffix
    self.default_sounds_bus_index = manifest.default_sounds_bus_index
    self.music_manifest = manifest.music_manifest
    self.default_music_path_prefix = manifest.default_music_path_prefix
    self.default_music_file_suffix = manifest.default_music_file_suffix
    self.default_music_bus_index = manifest.default_music_bus_index
    self.main_menu_music = manifest.main_menu_music
    self.third_party_license_text = \
            manifest.third_party_license_text.strip_edges()
    self.special_thanks_text = manifest.special_thanks_text.strip_edges()
    self.app_logo = manifest.app_logo
    self.app_logo_scale = manifest.app_logo_scale
    self.go_icon = manifest.go_icon
    self.go_icon_scale = manifest.go_icon_scale
    self.developer_name = manifest.developer_name
    self.developer_url = manifest.developer_url
    
    if manifest.has("test"):
        self.test = manifest.test
    if manifest.has("are_all_levels_unlocked"):
        self.are_all_levels_unlocked = manifest.are_all_levels_unlocked
    if manifest.has("is_splash_skipped"):
        self.is_splash_skipped = manifest.is_splash_skipped
    if manifest.has("developer_logo"):
        self.developer_logo = manifest.developer_logo
    if manifest.has("developer_splash"):
        self.developer_splash = manifest.developer_splash
    if manifest.has("game_over_music"):
        self.game_over_music = manifest.game_over_music
    if manifest.has("godot_splash_sound"):
        self.godot_splash_sound = manifest.godot_splash_sound
    if manifest.has("developer_splash_sound"):
        self.developer_splash_sound = manifest.developer_splash_sound
    if manifest.has("level_end_sound"):
        self.level_end_sound = manifest.level_end_sound
    if manifest.has("godot_splash_screen_duration_sec"):
        self.godot_splash_screen_duration_sec = \
                manifest.godot_splash_screen_duration_sec
    if manifest.has("developer_splash_screen_duration_sec"):
        self.developer_splash_screen_duration_sec = \
                manifest.developer_splash_screen_duration_sec
    if manifest.has("main_menu_image_scene_path"):
        self.main_menu_image_scene_path = manifest.main_menu_image_scene_path
    if manifest.has("fade_in_transition_texture"):
        self.fade_in_transition_texture = manifest.fade_in_transition_texture
    if manifest.has("fade_out_transition_texture"):
        self.fade_out_transition_texture = manifest.fade_out_transition_texture
    if manifest.has("google_analytics_id"):
        self.google_analytics_id = manifest.google_analytics_id
    if manifest.has("data_agreement_version"):
        self.data_agreement_version = manifest.data_agreement_version
    if manifest.has("terms_and_conditions_url"):
        self.terms_and_conditions_url = manifest.terms_and_conditions_url
    if manifest.has("privacy_policy_url"):
        self.privacy_policy_url = manifest.privacy_policy_url
    if manifest.has("android_app_store_url"):
        self.android_app_store_url = manifest.android_app_store_url
    if manifest.has("ios_app_store_url"):
        self.ios_app_store_url = manifest.ios_app_store_url
    if manifest.has("support_url"):
        self.support_url = manifest.support_url
    if manifest.has("error_logs_url"):
        self.error_logs_url = manifest.error_logs_url
    if manifest.has("log_gestures_url"):
        self.log_gestures_url = manifest.log_gestures_url
    if manifest.has("input_vibrate_duration_sec"):
        self.input_vibrate_duration_sec = \
                manifest.input_vibrate_duration_sec
    if manifest.has("display_resize_throttle_interval_sec"):
        self.display_resize_throttle_interval_sec = \
                manifest.display_resize_throttle_interval_sec
    if manifest.has("recent_gesture_events_for_debugging_buffer_size"):
        self.recent_gesture_events_for_debugging_buffer_size = \
                manifest.recent_gesture_events_for_debugging_buffer_size
    
    assert(manifest.level_config_class != null)
    assert(self.google_analytics_id.empty() == \
            self.privacy_policy_url.empty() and \
            self.privacy_policy_url.empty() == \
            self.terms_and_conditions_url.empty())
    assert((self.developer_splash == null) == \
            self.developer_splash_sound.empty())
    
    self.is_special_thanks_shown = !self.special_thanks_text.empty()
    self.is_third_party_licenses_shown = !self.third_party_license_text.empty()
    self.is_data_tracked = \
            !self.privacy_policy_url.empty() and \
            !self.terms_and_conditions_url.empty() and \
            !self.google_analytics_id.empty()
    self.are_error_logs_captured = \
            self.is_data_tracked and \
            !self.error_logs_url.empty()
    self.is_rate_app_shown = \
            !self.android_app_store_url.empty() and \
            !self.ios_app_store_url.empty()
    self.is_support_shown = \
            !self.support_url.empty() and \
            !self.app_id_query_param.empty()
    self.is_gesture_logging_supported = \
            !self.log_gestures_url.empty() and \
            !self.app_id_query_param.empty()
    self.is_developer_logo_shown = manifest.has("developer_logo")
    self.is_developer_splash_shown = \
            manifest.has("developer_splash") and \
            manifest.has("developer_splash_sound")
    self.is_main_menu_image_shown = manifest.has("main_menu_image_scene_path")

func initialize_crash_reporter() -> CrashReporter:
    if manifest.has("crash_reporter_class"):
        self.crash_reporter = manifest.crash_reporter_class.new()
        assert(self.crash_reporter is CrashReporter)
    else:
        self.crash_reporter = CrashReporter.new()
    return self.crash_reporter

func initialize() -> void:
    if manifest.has("audio_class"):
        self.audio = manifest.audio_class.new()
        assert(self.audio is Audio)
    else:
        self.audio = Audio.new()
    add_child(self.audio)
    if manifest.has("colors_class"):
        self.colors = manifest.colors_class.new()
        assert(self.colors is ScaffolderColors)
    else:
        self.colors = ScaffolderColors.new()
    add_child(self.colors)
    if manifest.has("styles_class"):
        self.styles = manifest.styles_class.new()
        assert(self.styles is ScaffolderStyles)
    else:
        self.styles = ScaffolderStyles.new()
    add_child(self.styles)
    if manifest.has("save_state_class"):
        self.save_state = manifest.save_state_class.new()
        assert(self.save_state is SaveState)
    else:
        self.save_state = SaveState.new()
    add_child(self.save_state)
    if manifest.has("analytics_class"):
        self.analytics = manifest.analytics_class.new()
        assert(self.analytics is Analytics)
    else:
        self.analytics = Analytics.new()
    add_child(self.analytics)
    if manifest.has("gesture_reporter_class"):
        self.gesture_reporter = manifest.gesture_reporter_class.new()
        assert(self.gesture_reporter is GestureReporter)
    else:
        self.gesture_reporter = GestureReporter.new()
    add_child(self.gesture_reporter)
    if manifest.has("utils_class"):
        self.utils = manifest.utils_class.new()
        assert(self.utils is Utils)
    else:
        self.utils = Utils.new()
    add_child(self.utils)
    if manifest.has("time_class"):
        self.time = manifest.time_class.new()
        assert(self.time is Time)
    else:
        self.time = Time.new()
    add_child(self.time)
    if manifest.has("profiler_class"):
        self.profiler = manifest.profiler_class.new()
        assert(self.profiler is Profiler)
    else:
        self.profiler = Profiler.new()
    add_child(self.profiler)
    if manifest.has("geometry_class"):
        self.geometry = manifest.geometry_class.new()
        assert(self.geometry is ScaffoldGeometry)
    else:
        self.geometry = ScaffoldGeometry.new()
    add_child(self.geometry)
    if manifest.has("draw_utils_class"):
        self.draw_utils = manifest.draw_utils_class.new()
        assert(self.draw_utils is DrawUtils)
    else:
        self.draw_utils = DrawUtils.new()
    add_child(self.draw_utils)
    if manifest.has("nav_class"):
        self.nav = manifest.nav_class.new()
        assert(self.nav is ScaffoldNavigation)
    else:
        self.nav = ScaffoldNavigation.new()
    add_child(self.nav)
    if manifest.has("level_input_class"):
        self.level_input = manifest.level_input_class.new()
        assert(self.level_input is LevelInput)
    else:
        self.level_input = LevelInput.new()
    add_child(self.level_input)
    
    # This depends on SaveState, and must be instantiated after.
    self.level_config = manifest.level_config_class.new()
    add_child(self.level_config)
    
    self.audio.register_sounds( \
            manifest.sounds_manifest, \
            manifest.default_sounds_path_prefix, \
            manifest.default_sounds_file_suffix, \
            manifest.default_sounds_bus_index)
    self.audio.register_music( \
            manifest.music_manifest, \
            manifest.default_music_path_prefix, \
            manifest.default_music_file_suffix, \
            manifest.default_music_bus_index)
    
    self.colors.register_colors(manifest.colors_manifest)
    self.styles.register_styles(manifest.styles_manifest)
    
    self.is_app_configured = true
    
    _record_original_font_sizes()
    
    _validate_project_config()

func add_gui_to_scale( \
        gui, \
        default_gui_scale: float) -> void:
    guis_to_scale[gui] = default_gui_scale
    Gs.utils._scale_gui_for_current_screen_size(gui)

func remove_gui_to_scale(gui) -> void:
    guis_to_scale.erase(gui)

func load_state() -> void:
    _clear_old_data_agreement_version()
    agreed_to_terms = Gs.save_state.get_setting( \
            AGREED_TO_TERMS_SETTINGS_KEY, \
            false)
    is_giving_haptic_feedback = Gs.save_state.get_setting( \
            IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY, \
            Gs.utils.get_is_android_device())
    is_debug_panel_shown = Gs.save_state.get_setting( \
            IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY, \
            false)
    is_debug_time_shown = Gs.save_state.get_setting( \
            IS_DEBUG_TIME_SHOWN_SETTINGS_KEY, \
            false)
    Gs.audio.is_music_enabled = Gs.save_state.get_setting( \
            IS_MUSIC_ENABLED_SETTINGS_KEY, \
            true)
    Gs.audio.is_sound_effects_enabled = Gs.save_state.get_setting( \
            IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY, \
            true)

func _clear_old_data_agreement_version() -> void:
    if Gs.data_agreement_version != Gs.save_state.get_data_agreement_version():
        Gs.save_state.set_data_agreement_version(Gs.data_agreement_version)
        set_agreed_to_terms(false)

func set_agreed_to_terms(value := true) -> void:
    agreed_to_terms = value
    Gs.save_state.set_setting( \
            Gs.AGREED_TO_TERMS_SETTINGS_KEY, \
            value)

func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible

func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown

func _record_original_font_sizes() -> void:
    for key in fonts:
        original_font_sizes[key] = fonts[key].size

func _validate_project_config() -> void:
    assert(ProjectSettings.get_setting( \
            "logging/file_logging/enable_file_logging") == true)
    
    assert(ProjectSettings.get_setting("display/window/size/width") == \
            default_game_area_size.x)
    assert(ProjectSettings.get_setting("display/window/size/height") == \
            default_game_area_size.y)
    
#    assert(geometry.are_colors_equal_with_epsilon( \
#            ProjectSettings.get_setting("application/boot_splash/bg_color"), \
#            colors.background_color, \
#            0.0001))
    assert(geometry.are_colors_equal_with_epsilon( \
            ProjectSettings.get_setting( \
                    "rendering/environment/default_clear_color"), \
            colors.background_color, \
            0.0001))
    
    var window_stretch_mode_disabled := "disabled"
    assert(ProjectSettings.get_setting("display/window/stretch/mode") == \
            window_stretch_mode_disabled)
    var window_stretch_aspect_expanded := "expand"
    assert(ProjectSettings.get_setting("display/window/stretch/aspect") == \
            window_stretch_aspect_expanded)
    
    # TODO: Figure out if this actually matters...
#    var physics_2d_thread_model_single_unsafe := 0
#    var physics_2d_thread_model_multi_threaded := 2
#    assert(!uses_threads or \
#            ProjectSettings.get_setting("physics/2d/thread_model") == \
#            physics_2d_thread_model_multi_threaded)
    
    assert(ProjectSettings.get_setting( \
                    "input_devices/pointing/emulate_touch_from_mouse") == \
            true)
    assert(ProjectSettings.get_setting( \
                    "input_devices/pointing/emulate_mouse_from_touch") == \
            true)

func get_support_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + app_id_query_param
    return Gs.support_url + params

func get_log_gestures_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + app_id_query_param
    return Gs.logger_gestures_url + params

class_name ScaffolderConfig
extends Node


# --- Constants ---

const AGREED_TO_TERMS_SETTINGS_KEY := "agreed_to_terms"
const IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY := "is_debug_panel_shown"
const IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY := "is_welcome_panel_shown"
const IS_DEBUG_TIME_SHOWN_SETTINGS_KEY := "is_debug_time_shown"
const IS_MUSIC_ENABLED_SETTINGS_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY := "is_sound_effects_enabled"
const ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY := "additional_debug_time_scale"

# --- Static configuration state ---

var manifest: Dictionary

var debug: bool
var playtest: bool
var test := false
var pauses_on_focus_out := true
var is_profiler_enabled: bool
var are_all_levels_unlocked := false
var is_splash_skipped := false
var also_prints_to_stdout := true

# Should match Project Settings > Physics > 2d > Thread Model
var uses_threads: bool
var thread_count: int

var is_mobile_supported: bool

var app_name: String
var app_id: String
var app_version: String
var score_version: String
var data_agreement_version: String

var uses_level_scores: bool

var must_restart_level_to_change_settings: bool

var app_logo: Texture
var app_logo_scale: float
var go_icon: Texture
var go_icon_scale: float
var developer_name: String
var developer_url: String

var developer_logo: Texture
var developer_splash: Texture

var godot_splash_screen_duration := 0.8
var developer_splash_screen_duration := 1.0

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

# --- Derived configuration ---

var is_data_tracked: bool
var are_error_logs_captured: bool

# --- Global state ---

var is_app_configured := false
var is_app_initialized := false
var were_screenshots_taken := false
var agreed_to_terms: bool

var crash_reporter: CrashReporter
var audio_manifest: ScaffolderAudioManifest
var audio: Audio
var colors: ScaffolderColors
var styles: ScaffolderStyles
var gui: ScaffolderGuiConfig
var json: JsonUtils
var nav: ScaffolderNavigation
var save_state: SaveState
var analytics: Analytics
var gesture_reporter: GestureReporter
var logger: ScaffolderLog
var utils: Utils
var time: Time
var profiler: Profiler
var geometry: ScaffolderGeometry
var draw_utils: DrawUtils
var level_input: LevelInput
var slow_motion: SlowMotionController
var beats: BeatTracker
var level_config: ScaffolderLevelConfig
var canvas_layers: CanvasLayers
var camera_controller: CameraController
var level: ScaffolderLevel

# ---


func _enter_tree() -> void:
    self.logger = ScaffolderLog.new()
    add_child(self.logger)
    self.logger.print("ScaffolderConfig._enter_tree")
    
    self.utils = Utils.new()
    add_child(self.utils)


func amend_app_manifest(manifest: Dictionary) -> void:
    pass


func register_app_manifest(manifest: Dictionary) -> void:
    self.manifest = manifest
    self.debug = manifest.debug
    self.playtest = manifest.playtest
    if manifest.has("test"):
        self.test = manifest.test
    if manifest.has("are_all_levels_unlocked"):
        self.are_all_levels_unlocked = manifest.are_all_levels_unlocked
    self.pauses_on_focus_out = manifest.pauses_on_focus_out
    self.also_prints_to_stdout = manifest.also_prints_to_stdout
    self.is_profiler_enabled = manifest.is_profiler_enabled
    self.uses_threads = manifest.uses_threads
    self.thread_count = manifest.thread_count
    self.is_mobile_supported = manifest.is_mobile_supported
    self.uses_level_scores = manifest.uses_level_scores
    self.must_restart_level_to_change_settings = \
            manifest.must_restart_level_to_change_settings
    if manifest.has("is_splash_skipped"):
        self.is_splash_skipped = manifest.is_splash_skipped
    
    self.app_name = manifest.app_name
    self.app_id = manifest.app_id
    self.app_version = manifest.app_version
    self.score_version = manifest.score_version
    
    self.app_logo = manifest.app_logo
    self.app_logo_scale = manifest.app_logo_scale
    self.go_icon = manifest.go_icon
    self.go_icon_scale = manifest.go_icon_scale
    self.developer_name = manifest.developer_name
    self.developer_url = manifest.developer_url
    if manifest.has("developer_logo"):
        self.developer_logo = manifest.developer_logo
    if manifest.has("developer_splash"):
        self.developer_splash = manifest.developer_splash
    if manifest.has("godot_splash_screen_duration"):
        self.godot_splash_screen_duration = \
                manifest.godot_splash_screen_duration
    if manifest.has("developer_splash_screen_duration"):
        self.developer_splash_screen_duration = \
                manifest.developer_splash_screen_duration
    
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
    if manifest.has("app_id_query_param"):
        self.app_id_query_param = manifest.app_id_query_param
    
    assert(manifest.level_config_class != null)
    assert(self.google_analytics_id.empty() == \
            self.privacy_policy_url.empty() and \
            self.privacy_policy_url.empty() == \
            self.terms_and_conditions_url.empty())
    assert((self.developer_splash == null) == \
            manifest.audio_manifest.developer_splash_sound.empty())
    
    self.is_data_tracked = \
            !self.privacy_policy_url.empty() and \
            !self.terms_and_conditions_url.empty() and \
            !self.google_analytics_id.empty()
    self.are_error_logs_captured = \
            self.is_data_tracked and \
            !self.error_logs_url.empty()


func initialize_crash_reporter() -> CrashReporter:
    if manifest.has("crash_reporter_class"):
        self.crash_reporter = manifest.crash_reporter_class.new()
        assert(self.crash_reporter is CrashReporter)
    else:
        self.crash_reporter = CrashReporter.new()
    return self.crash_reporter


func initialize() -> void:
    if manifest.has("audio_manifest_class"):
        self.audio_manifest = manifest.audio_manifest_class.new()
        assert(self.audio_manifest is ScaffolderAudioManifest)
    else:
        self.audio_manifest = ScaffolderAudioManifest.new()
    if manifest.has("audio_class"):
        self.audio = manifest.audio_class.new()
        assert(self.audio is Audio)
    else:
        self.audio = Audio.new()
    add_child(self.audio)
    if manifest.has("gui_class"):
        self.gui = manifest.gui_class.new()
        assert(self.gui is ScaffolderGuiConfig)
    else:
        self.gui = ScaffolderGuiConfig.new()
    add_child(self.gui)
    if manifest.has("colors_class"):
        self.colors = manifest.colors_class.new()
        assert(self.colors is ScaffolderColors)
    else:
        self.colors = ScaffolderColors.new()
    self.add_child(self.colors)
    if manifest.has("styles_class"):
        self.styles = manifest.styles_class.new()
        assert(self.styles is ScaffolderStyles)
    else:
        self.styles = ScaffolderStyles.new()
    self.add_child(self.styles)
    if manifest.has("json_utils_class"):
        self.json = manifest.json_utils_class.new()
        assert(self.json is JsonUtils)
    else:
        self.json = JsonUtils.new()
    add_child(self.json)
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
        assert(self.geometry is ScaffolderGeometry)
    else:
        self.geometry = ScaffolderGeometry.new()
    add_child(self.geometry)
    if manifest.has("draw_utils_class"):
        self.draw_utils = manifest.draw_utils_class.new()
        assert(self.draw_utils is DrawUtils)
    else:
        self.draw_utils = DrawUtils.new()
    add_child(self.draw_utils)
    if manifest.has("nav_class"):
        self.nav = manifest.nav_class.new()
        assert(self.nav is ScaffolderNavigation)
    else:
        self.nav = ScaffolderNavigation.new()
    add_child(self.nav)
    if manifest.has("level_input_class"):
        self.level_input = manifest.level_input_class.new()
        assert(self.level_input is LevelInput)
    else:
        self.level_input = LevelInput.new()
    add_child(self.level_input)
    if manifest.has("slow_motion_class"):
        self.slow_motion = manifest.slow_motion_class.new()
        assert(self.slow_motion is SlowMotionController)
    else:
        self.slow_motion = SlowMotionController.new()
    add_child(self.slow_motion)
    if manifest.has("beat_tracker_class"):
        self.beats = manifest.beat_tracker_class.new()
        assert(self.beats is BeatTracker)
    else:
        self.beats = BeatTracker.new()
    add_child(self.beats)
    
    # This depends on SaveState, and must be instantiated after.
    self.level_config = manifest.level_config_class.new()
    add_child(self.level_config)
    
    self.audio_manifest.register_manifest(manifest.audio_manifest)
    self.colors.register_manifest(manifest.colors_manifest)
    self.styles.register_manifest(manifest.styles_manifest)
    self.gui.register_manifest(manifest.gui_manifest)
    
    self.is_app_configured = true

    _validate_project_config()


func load_state() -> void:
    _clear_old_data_agreement_version()
    agreed_to_terms = Gs.save_state.get_setting(
            AGREED_TO_TERMS_SETTINGS_KEY,
            false)
    Gs.gui.is_giving_haptic_feedback = Gs.save_state.get_setting(
            IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY,
            Gs.utils.get_is_android_device())
    Gs.gui.is_debug_panel_shown = Gs.save_state.get_setting(
            IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY,
            false)
    Gs.gui.is_welcome_panel_shown = Gs.save_state.get_setting(
            IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY,
            true)
    Gs.gui.is_debug_time_shown = Gs.save_state.get_setting(
            IS_DEBUG_TIME_SHOWN_SETTINGS_KEY,
            false)
    Gs.audio.is_music_enabled = Gs.save_state.get_setting(
            IS_MUSIC_ENABLED_SETTINGS_KEY,
            true)
    Gs.audio.is_sound_effects_enabled = Gs.save_state.get_setting(
            IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY,
            true)
    Gs.time.additional_debug_time_scale = Gs.save_state.get_setting(
            ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY,
            1.0)


func _clear_old_data_agreement_version() -> void:
    if Gs.data_agreement_version != Gs.save_state.get_data_agreement_version():
        Gs.save_state.set_data_agreement_version(Gs.data_agreement_version)
        set_agreed_to_terms(false)


func set_agreed_to_terms(value := true) -> void:
    agreed_to_terms = value
    Gs.save_state.set_setting(
            Gs.AGREED_TO_TERMS_SETTINGS_KEY,
            value)


func _validate_project_config() -> void:
    assert(ProjectSettings.get_setting(
            "logging/file_logging/enable_file_logging") == true)
    
    assert(ProjectSettings.get_setting("display/window/size/width") == \
            Gs.gui.default_game_area_size.x)
    assert(ProjectSettings.get_setting("display/window/size/height") == \
            Gs.gui.default_game_area_size.y)
    
#    assert(geometry.are_colors_equal_with_epsilon(
#            ProjectSettings.get_setting("application/boot_splash/bg_color"),
#            colors.background,
#            0.0001))
    assert(Gs.geometry.are_colors_equal_with_epsilon(
            ProjectSettings.get_setting(
                    "rendering/environment/default_clear_color"),
            Gs.colors.background,
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
    
    assert(ProjectSettings.get_setting(
                    "input_devices/pointing/emulate_touch_from_mouse") == \
            true)
    assert(ProjectSettings.get_setting(
                    "input_devices/pointing/emulate_mouse_from_touch") == \
            true)
    
    assert(ProjectSettings.get_setting("physics/common/physics_fps") == \
            Time.PHYSICS_FPS)


func get_support_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + app_id_query_param
    return Gs.support_url + params


func get_log_gestures_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + app_id_query_param
    return Gs.logger_gestures_url + params

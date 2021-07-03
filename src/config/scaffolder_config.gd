class_name ScaffolderConfig
extends Node


var manifest: Dictionary

var logger: ScaffolderLog
var utils: Utils
var device: DeviceUtils

var crash_reporter: CrashReporter
var app_metadata: ScaffolderAppMetadata
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
var time: Time
var profiler: Profiler
var geometry: ScaffolderGeometry
var draw: DrawUtils
var level_input: LevelInput
var slow_motion: SlowMotionController
var beats: BeatTracker
var level_config: ScaffolderLevelConfig
var canvas_layers: CanvasLayers
var camera_controller: CameraController
var level: ScaffolderLevel
var level_session: ScaffolderLevelSession


func _enter_tree() -> void:
    self.logger = ScaffolderLog.new()
    add_child(self.logger)
    
    self.logger.print("ScaffolderConfig._enter_tree")
    
    self.utils = Utils.new()
    add_child(self.utils)
    
    self.device = DeviceUtils.new()
    add_child(self.device)


func amend_app_manifest(manifest: Dictionary) -> void:
    pass


func register_app_manifest(manifest: Dictionary) -> void:
    self.manifest = manifest
    
    assert((manifest.app_metadata.developer_splash == null) == \
            manifest.audio_manifest.developer_splash_sound.empty())


func initialize_app_metadata() -> void:
    if manifest.has("app_metadata_class"):
        self.app_metadata = manifest.app_metadata_class.new()
        assert(self.app_metadata is ScaffolderAppMetadata)
    else:
        self.app_metadata = ScaffolderAppMetadata.new()
    add_child(self.app_metadata)
    self.app_metadata.register_manifest(manifest.app_metadata)


func initialize_crash_reporter() -> void:
    if manifest.has("crash_reporter_class"):
        self.crash_reporter = manifest.crash_reporter_class.new()
        assert(self.crash_reporter is CrashReporter)
    else:
        self.crash_reporter = CrashReporter.new()


func initialize() -> void:
    self.level_session = manifest.level_session_class.new()
    assert(self.level_session is ScaffolderLevelSession)
    
    if manifest.has("audio_manifest_class"):
        self.audio_manifest = manifest.audio_manifest_class.new()
        assert(self.audio_manifest is ScaffolderAudioManifest)
    else:
        self.audio_manifest = ScaffolderAudioManifest.new()
    add_child(audio_manifest)
    
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
    
    if manifest.has("gui_class"):
        self.gui = manifest.gui_class.new()
        assert(self.gui is ScaffolderGuiConfig)
    else:
        self.gui = ScaffolderGuiConfig.new()
    add_child(self.gui)
    
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
        self.draw = manifest.draw_utils_class.new()
        assert(self.draw is DrawUtils)
    else:
        self.draw = DrawUtils.new()
    add_child(self.draw)
    
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
    
    if manifest.has("camera_controller_class"):
        self.camera_controller = manifest.camera_controller_class.new()
        assert(self.camera_controller is CameraController)
    else:
        self.camera_controller = CameraController.new()
    add_child(self.camera_controller)
    
    if manifest.has("canvas_layers_class"):
        self.canvas_layers = manifest.canvas_layers_class.new()
        assert(self.canvas_layers is CanvasLayers)
    else:
        self.canvas_layers = CanvasLayers.new()
    add_child(self.canvas_layers)
    
    # This depends on SaveState, and must be instantiated after.
    self.level_config = manifest.level_config_class.new()
    add_child(self.level_config)
    
    self.audio_manifest.register_manifest(manifest.audio_manifest)
    self.colors.register_manifest(manifest.colors_manifest)
    self.styles.register_manifest(manifest.styles_manifest)
    self.gui.register_manifest(manifest.gui_manifest)
    
    self.app_metadata.is_app_configured = true

    _validate_project_config()


func load_state() -> void:
    _clear_old_data_agreement_version()
    Gs.app_metadata.agreed_to_terms = Gs.save_state.get_setting(
            SaveState.AGREED_TO_TERMS_SETTINGS_KEY,
            false)
    Gs.gui.is_giving_haptic_feedback = Gs.save_state.get_setting(
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY,
            Gs.device.get_is_android_app())
    Gs.gui.is_debug_panel_shown = Gs.save_state.get_setting(
            SaveState.IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY,
            false)
    Gs.gui.is_welcome_panel_shown = Gs.save_state.get_setting(
            SaveState.IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY,
            true)
    Gs.gui.is_debug_time_shown = Gs.save_state.get_setting(
            SaveState.IS_DEBUG_TIME_SHOWN_SETTINGS_KEY,
            false)
    Gs.audio.is_music_enabled = Gs.save_state.get_setting(
            SaveState.IS_MUSIC_ENABLED_SETTINGS_KEY,
            true)
    Gs.audio.is_sound_effects_enabled = Gs.save_state.get_setting(
            SaveState.IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY,
            true)
    Gs.time.additional_debug_time_scale = Gs.save_state.get_setting(
            SaveState.ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY,
            1.0)
    Gs.camera_controller.zoom_factor = Gs.save_state.get_setting(
            SaveState.ZOOM_FACTOR_SETTINGS_KEY,
            1.0)


func _clear_old_data_agreement_version() -> void:
    if Gs.app_metadata.data_agreement_version != \
            Gs.save_state.get_data_agreement_version():
        Gs.save_state.set_data_agreement_version(
                Gs.app_metadata.data_agreement_version)
        set_agreed_to_terms(false)


func set_agreed_to_terms(value := true) -> void:
    Gs.app_metadata.agreed_to_terms = value
    Gs.save_state.set_setting(
            SaveState.AGREED_TO_TERMS_SETTINGS_KEY,
            value)


func _validate_project_config() -> void:
    assert(ProjectSettings.get_setting(
            "logging/file_logging/enable_file_logging") == true)
    
    assert(geometry.are_colors_equal_with_epsilon(
            ProjectSettings.get_setting("application/boot_splash/bg_color"),
            colors.boot_splash_background,
            0.0001))
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
    params += "&app=" + Gs.app_metadata.app_id_query_param
    return Gs.app_metadata.support_url + params


func get_log_gestures_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + Gs.app_metadata.app_id_query_param
    return Gs.logger_gestures_url + params

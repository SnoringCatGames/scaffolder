tool
extends FrameworkConfig
## -   This is a global singleton that defines a bunch of app parameters.[br]
## -   All of these parameters can be configured when bootstrapping the
##     app.[br]
## -   You will need to provide an `app_manifest` dictionary which defines some
##     of these parameters.[br]
## -   Define `Sc` as an AutoLoad (in Project Settings).[br]
## -   "Sc" is short for "Scaffolder."[br]


signal initialized
signal splashed

const _LOGS_EARLY_BOOTSTRAP_EVENTS := false

var is_initialized := false

var logger: ScaffolderLog
var utils: Utils
var device: DeviceUtils

var metadata: ScaffolderAppMetadata
var audio_manifest: ScaffolderAudioManifest
var audio: Audio
var colors: ScaffolderColors
var styles: ScaffolderStyles
var images: ScaffolderImages
var gui: ScaffolderGuiConfig
var json: JsonUtils
var save_state: SaveState
var time: Time
var profiler: Profiler
var geometry: ScaffolderGeometry
var draw: ScaffolderDrawUtils
var slow_motion: SlowMotionController
var beats: BeatTracker
var canvas_layers: CanvasLayers
var project_settings: ScaffolderProjectSettings
var camera_controller: CameraController
var level_button_input: LevelButtonInput
var characters: ScaffolderCharacterManifest
# TODO: Cleanup the annotator system.
var annotators: ScaffolderAnnotators
var level_config: ScaffolderLevelConfig
var level: ScaffolderLevel
var level_session: ScaffolderLevelSession

var nav: ScreenNavigator
var analytics: Analytics
var crash_reporter: CrashReporter
var gesture_reporter: GestureReporter

# Array<FrameworkConfig>
var _framework_configs := []
var _bootstrap: ScaffolderBootstrap
var _manifest: Dictionary


func _ready() -> void:
    self.logger = ScaffolderLog.new()
    add_child(self.logger)
    
    self.logger.on_global_init(self, "Sc")
    
    register_framework_config(self)
    
    self.utils = Utils.new()
    add_child(self.utils)
    
    self.device = DeviceUtils.new()
    add_child(self.device)


func run(app_manifest: Dictionary) -> void:
    self._manifest = app_manifest
    
    # Allow the default bootstrap class to be overridden by someone else.
    if !is_instance_valid(_bootstrap):
        self._bootstrap = ScaffolderBootstrap.new()
    assert(_bootstrap is ScaffolderBootstrap)
    add_child(_bootstrap)
    
    _bootstrap.connect("initialized", self, "emit_signal", ["initialized"])
    _bootstrap.connect("splashed", self, "emit_signal", ["splashed"])
    
    _bootstrap.run()


func register_framework_config(config: FrameworkConfig) -> void:
    _framework_configs.push_back(config)


func _amend_app_manifest(manifest: Dictionary) -> void:
    pass


func _register_app_manifest(manifest: Dictionary) -> void:
    self._manifest = manifest
    
    assert((_manifest.images_manifest.developer_splash == null) == \
            _manifest.audio_manifest.developer_splash_sound.empty())


func initialize_metadata() -> void:
    if _manifest.has("metadata_class"):
        self.metadata = _manifest.metadata_class.new()
        assert(self.metadata is ScaffolderAppMetadata)
    else:
        self.metadata = ScaffolderAppMetadata.new()
    add_child(self.metadata)
    self.metadata.register_manifest(_manifest.metadata)


func initialize_crash_reporter() -> void:
    if _manifest.has("crash_reporter_class"):
        self.crash_reporter = _manifest.crash_reporter_class.new()
        assert(self.crash_reporter is CrashReporter)
    else:
        self.crash_reporter = CrashReporter.new()


func _instantiate_sub_modules() -> void:
    self.level_session = _manifest.level_session_class.new()
    assert(self.level_session is ScaffolderLevelSession)
    
    if _manifest.has("audio_manifest_class"):
        self.audio_manifest = _manifest.audio_manifest_class.new()
        assert(self.audio_manifest is ScaffolderAudioManifest)
    else:
        self.audio_manifest = ScaffolderAudioManifest.new()
    add_child(audio_manifest)
    
    if _manifest.has("audio_class"):
        self.audio = _manifest.audio_class.new()
        assert(self.audio is Audio)
    else:
        self.audio = Audio.new()
    add_child(self.audio)
    
    if _manifest.has("colors_class"):
        self.colors = _manifest.colors_class.new()
        assert(self.colors is ScaffolderColors)
    else:
        self.colors = ScaffolderColors.new()
    add_child(self.colors)
    
    if _manifest.has("styles_class"):
        self.styles = _manifest.styles_class.new()
        assert(self.styles is ScaffolderStyles)
    else:
        self.styles = ScaffolderStyles.new()
    add_child(self.styles)
    
    if _manifest.has("images_class"):
        self.images = _manifest.images_class.new()
        assert(self.images is ScaffolderImages)
    else:
        self.images = ScaffolderImages.new()
    add_child(self.images)
    
    if _manifest.has("gui_class"):
        self.gui = _manifest.gui_class.new()
        assert(self.gui is ScaffolderGuiConfig)
    else:
        self.gui = ScaffolderGuiConfig.new()
    add_child(self.gui)
    
    if _manifest.has("json_utils_class"):
        self.json = _manifest.json_utils_class.new()
        assert(self.json is JsonUtils)
    else:
        self.json = JsonUtils.new()
    add_child(self.json)
    
    if _manifest.has("save_state_class"):
        self.save_state = _manifest.save_state_class.new()
        assert(self.save_state is SaveState)
    else:
        self.save_state = SaveState.new()
    add_child(self.save_state)
    
    if _manifest.has("analytics_class"):
        self.analytics = _manifest.analytics_class.new()
        assert(self.analytics is Analytics)
    else:
        self.analytics = Analytics.new()
    add_child(self.analytics)
    
    if _manifest.has("gesture_reporter_class"):
        self.gesture_reporter = _manifest.gesture_reporter_class.new()
        assert(self.gesture_reporter is GestureReporter)
    else:
        self.gesture_reporter = GestureReporter.new()
    add_child(self.gesture_reporter)
    
    if _manifest.has("time_class"):
        self.time = _manifest.time_class.new()
        assert(self.time is Time)
    else:
        self.time = Time.new()
    add_child(self.time)
    
    if _manifest.has("profiler_class"):
        self.profiler = _manifest.profiler_class.new()
        assert(self.profiler is Profiler)
    else:
        self.profiler = Profiler.new()
    add_child(self.profiler)
    
    if _manifest.has("geometry_class"):
        self.geometry = _manifest.geometry_class.new()
        assert(self.geometry is ScaffolderGeometry)
    else:
        self.geometry = ScaffolderGeometry.new()
    add_child(self.geometry)
    
    if _manifest.has("draw_utils_class"):
        self.draw = _manifest.draw_utils_class.new()
        assert(self.draw is ScaffolderDrawUtils)
    else:
        self.draw = ScaffolderDrawUtils.new()
    add_child(self.draw)
    
    if _manifest.has("nav_class"):
        self.nav = _manifest.nav_class.new()
        assert(self.nav is ScreenNavigator)
    else:
        self.nav = ScreenNavigator.new()
    add_child(self.nav)
    
    if _manifest.has("level_button_input_class"):
        self.level_button_input = _manifest.level_button_input_class.new()
        assert(self.level_button_input is LevelButtonInput)
    else:
        self.level_button_input = LevelButtonInput.new()
    add_child(self.level_button_input)
    
    if _manifest.has("slow_motion_class"):
        self.slow_motion = _manifest.slow_motion_class.new()
        assert(self.slow_motion is SlowMotionController)
    else:
        self.slow_motion = SlowMotionController.new()
    add_child(self.slow_motion)
    
    if _manifest.has("beat_tracker_class"):
        self.beats = _manifest.beat_tracker_class.new()
        assert(self.beats is BeatTracker)
    else:
        self.beats = BeatTracker.new()
    add_child(self.beats)
    
    if _manifest.has("camera_controller_class"):
        self.camera_controller = _manifest.camera_controller_class.new()
        assert(self.camera_controller is CameraController)
    else:
        self.camera_controller = CameraController.new()
    add_child(self.camera_controller)
    
    if _manifest.has("canvas_layers_class"):
        self.canvas_layers = _manifest.canvas_layers_class.new()
        assert(self.canvas_layers is CanvasLayers)
    else:
        self.canvas_layers = CanvasLayers.new()
    add_child(self.canvas_layers)
    
    if _manifest.has("project_settings_class"):
        self.project_settings = _manifest.project_settings_class.new()
        assert(self.project_settings is ScaffolderProjectSettings)
    else:
        self.project_settings = ScaffolderProjectSettings.new()
    add_child(self.project_settings)
    
    if _manifest.has("character_manifest_class"):
        self.characters = _manifest.character_manifest_class.new()
        assert(self.characters is ScaffolderCharacterManifest)
    else:
        self.characters = ScaffolderCharacterManifest.new()
    add_child(self.characters)
    
    if _manifest.has("annotators_class"):
        self.annotators = _manifest.annotators_class.new()
        assert(self.annotators is ScaffolderAnnotators)
    else:
        self.annotators = ScaffolderAnnotators.new()
    add_child(self.annotators)
    
    # This depends on SaveState, and must be instantiated after.
    self.level_config = _manifest.level_config_class.new()
    add_child(self.level_config)


func _configure_sub_modules() -> void:
    self.audio_manifest.register_manifest(_manifest.audio_manifest)
    self.colors.register_manifest(_manifest.colors_manifest)
    self.styles.register_manifest(_manifest.styles_manifest)
    self.images.register_manifest(_manifest.images_manifest)
    self.gui.register_manifest(_manifest.gui_manifest)
    self.slow_motion.register_manifest(_manifest.slow_motion_manifest)
    self.characters.register_manifest(_manifest.character_manifest)
    
    self.metadata.is_app_configured = true
    
    self.project_settings._override_project_settings()
    self.project_settings._override_input_map(_manifest.input_map)


func _load_state() -> void:
    Sc.metadata._clear_old_data_agreement_version()
    Sc.metadata.agreed_to_terms = Sc.save_state.get_setting(
            SaveState.AGREED_TO_TERMS_SETTINGS_KEY,
            false)
    Sc.metadata.are_button_controls_enabled = Sc.save_state.get_setting(
            SaveState.ARE_BUTTON_CONTROLS_ENABLED_SETTINGS_KEY,
            Sc.metadata.are_button_controls_enabled_by_default)
    Sc.gui.is_giving_haptic_feedback = Sc.save_state.get_setting(
            SaveState.IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY,
            Sc.device.get_is_android_app())
    Sc.gui.is_debug_panel_shown = Sc.save_state.get_setting(
            SaveState.IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY,
            false)
    Sc.gui.is_welcome_panel_shown = Sc.save_state.get_setting(
            SaveState.IS_WELCOME_PANEL_SHOWN_SETTINGS_KEY,
            true)
    Sc.gui.is_debug_time_shown = Sc.save_state.get_setting(
            SaveState.IS_DEBUG_TIME_SHOWN_SETTINGS_KEY,
            false)
    Sc.audio.is_music_enabled = Sc.save_state.get_setting(
            SaveState.IS_MUSIC_ENABLED_SETTINGS_KEY,
            true)
    Sc.audio.is_sound_effects_enabled = Sc.save_state.get_setting(
            SaveState.IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY,
            true)
    Sc.time.additional_debug_time_scale = Sc.save_state.get_setting(
            SaveState.ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY,
            1.0)
    Sc.camera_controller.zoom_factor = Sc.save_state.get_setting(
            SaveState.ZOOM_FACTOR_SETTINGS_KEY,
            1.0)

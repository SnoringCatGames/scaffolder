tool
class_name ScInterface
extends FrameworkGlobal
## -   This is a global singleton that defines a bunch of app parameters.[br]
## -   All of these parameters can be configured when bootstrapping the
##     app.[br]
## -   You will need to provide an `app_manifest` dictionary which defines some
##     of these parameters.[br]
## -   Define `Sc` as an AutoLoad (in Project Settings).[br]
## -   "Sc" is short for "Scaffolder".[br]


signal splashed

const _SCHEMA_PATH := "res://addons/scaffolder/src/config/scaffolder_schema.gd"
const _DEFAULT_MANIFEST_PATH := "res://manifest.json"

const _LOGS_EARLY_BOOTSTRAP_EVENTS := false

var logger: ScaffolderLog
var utils: Utils
var device: DeviceUtils
var modes: FrameworkSchemaModes

var manifest_controller: FrameworkManifestController
var metadata: ScaffolderAppMetadata
var audio_manifest: ScaffolderAudioManifest
var audio: Audio
var styles: ScaffolderStyles
var images: ScaffolderImages
var gui: ScaffolderGuiConfig
var json: JsonUtils
var save_state: SaveState
var time: ScaffolderTime
var profiler: Profiler
var geometry: ScaffolderGeometry
var draw: ScaffolderDrawUtils
var palette: ColorPalette
var notify: Notifications
var info_panel: InfoPanelController
var slow_motion: SlowMotionController
var beats: BeatTracker
var canvas_layers: CanvasLayers
var project_settings: ScaffolderProjectSettings
var level_button_input: LevelButtonInput
var characters: ScaffolderCharacterManifest
var camera: ScaffolderCameraManifest
# TODO: Cleanup the annotator system.
var annotators: ScaffolderAnnotators
var levels: ScaffolderLevelConfig
var level: ScaffolderLevel
var legend: Legend

var nav: ScreenNavigator
var analytics: Analytics
var crash_reporter: CrashReporter
var gesture_reporter: GestureReporter

# Array<FrameworkPlugin>
var _framework_plugins := []
# Array<FrameworkGlobal>
var _framework_globals := []
var _bootstrap: FrameworkBootstrap
var manifest_path := _DEFAULT_MANIFEST_PATH


func _init().(_SCHEMA_PATH) -> void:
    pass


func _enter_tree() -> void:
    self.logger = ScaffolderLog.new()
    add_child(self.logger)


func _ready() -> void:
    self.utils = Utils.new()
    add_child(self.utils)
    
    self.device = DeviceUtils.new()
    add_child(self.device)
    
    self.json = JsonUtils.new()
    add_child(self.json)
    
    self.modes = FrameworkSchemaModes.new()
    add_child(self.modes)


func _trigger_debounced_run() -> void:
    # Trigger Sc.run with a debounce.
    if !has_meta("debounced_run_timer"):
        var timer := Timer.new()
        timer.one_shot = true
        timer.wait_time = _RUN_AFTER_FRAMEWORK_REGISTERED_DEBOUNCE_DELAY
        timer.connect(
                "timeout",
                self,
                "_run",
                [timer])
        add_child(timer)
        set_meta("debounced_run_timer", timer)
    var timer: Timer = get_meta("debounced_run_timer")
    timer.start()


func _run(timer: Timer) -> void:
    set_meta("debounced_run_timer", null)
    timer.queue_free()
    _sort_registered_frameworks()
    _apply_schema_overrides()
    Sc.run()
    # FIXME: ---------
    # - Add support for calling Sc.run more than once.
    #   - This should be needed when resetting frameworks in-editor.
    # - Clear any preexisting app state.


func _check_plugin_enablement() -> void:
    if !Engine.editor_hint:
        return
    var enabled_plugin_names := {}
    for plugin in _framework_plugins:
        enabled_plugin_names[plugin._metadata.auto_load_name] = true
    for global in Sc._framework_globals:
        assert(enabled_plugin_names.has(global.schema.auto_load_name),
                "Required plugin is not enabled: %s" % \
                global.schema.auto_load_name)


func _apply_schema_overrides() -> void:
    for global in Sc._framework_globals:
        for overridden_schema_script in global.schema.subtractive_overrides:
            var overridden_schema: FrameworkSchema = \
                    Singletons.instance(overridden_schema_script)
            var original_schema_properties: Dictionary = \
                    overridden_schema.properties
            var overriding_properties: Dictionary = \
                    global.schema.subtractive_overrides[ \
                        overridden_schema_script]
            Sc.utils.subtract_nested_arrays(
                    original_schema_properties,
                    overriding_properties,
                    true)
        for overridden_schema_script in global.schema.additive_overrides:
            var overridden_schema: FrameworkSchema = \
                    Singletons.instance(overridden_schema_script)
            var original_schema_properties: Dictionary = \
                    overridden_schema.properties
            var overriding_properties: Dictionary = \
                    global.schema.additive_overrides[overridden_schema_script]
            Sc.utils.merge(
                    original_schema_properties,
                    overriding_properties,
                    true,
                    true)


func run() -> void:
    reset()
    
    # Allow the default bootstrap class to be overridden by someone else.
    if !is_instance_valid(_bootstrap):
        self._bootstrap = FrameworkBootstrap.new()
    assert(_bootstrap is FrameworkBootstrap)
    if !self._bootstrap.is_inside_tree():
        add_child(_bootstrap)
    
    _bootstrap.run()


func reset() -> void:
    for framework in _framework_globals:
        framework._destroy()


func register_framework_global(global: FrameworkGlobal) -> void:
    _framework_globals.push_back(global)


func register_framework_plugin(plugin) -> void:
    _framework_plugins.push_back(plugin)
    call_deferred("_check_plugin_enablement")


func _sort_registered_frameworks() -> void:
    # Create framework nodes.
    var nodes := {}
    for global in _framework_globals:
        var node := {}
        node.global = global
        node.name = global.schema.auto_load_name
        node.parents = []
        node.children = []
        node.i = -1
        nodes[global.schema.auto_load_name] = node
    
    # Collect parent dependencies.
    for node in nodes.values():
        for name in node.global.schema.auto_load_deps:
            node.parents.push_back(nodes[name])
    
    # Collect children dependencies.
    for node in nodes.values():
        for parent in node.parents:
            parent.children.push_back(node)
    
    # Create an array and store indices on nodes.
    var node_array := nodes.values()
    for i in node_array.size():
        node_array[i].i = i
    
    # Sort nodes.
    var i := 0
    var swap_count := 0
    while i < node_array.size():
        var node: Dictionary = node_array[i]
        var swapped := false
        for parent in node.parents:
            if parent.i > i:
                var swap_i: int = node.i
                node.i = parent.i
                parent.i = swap_i
                node_array[parent.i] = parent
                node_array[node.i] = node
                swapped = true
                swap_count += 1
        if !swapped:
            i += 1
            swap_count = 0
        if swap_count > node_array.size():
            Sc.logger.error(
                    "Framework AutoLoads contain circular dependencies: %s" % \
                    node.name)
            return
    
    # Record sorted frameworks.
    for j in node_array.size():
        _framework_globals[j] = node_array[j].global


func _destroy() -> void:
    ._destroy()
    modes._clear()


func _get_members_to_destroy() -> Array:
    return [
        # NOTE: These are persisted between framework resets.
#        logger,
#        utils,
#        device,
#        json,
#        _bootstrap,
        
        manifest_controller,
        metadata,
        audio_manifest,
        audio,
        styles,
        images,
        gui,
        save_state,
        time,
        profiler,
        geometry,
        draw,
        palette,
        notify,
        info_panel,
        slow_motion,
        beats,
        canvas_layers,
        project_settings,
        level_button_input,
        characters,
        camera,
        annotators,
        levels,
        level,
        legend,
        
        nav,
        analytics,
        crash_reporter,
        gesture_reporter,
    ]


func _amend_manifest() -> void:
    ._amend_manifest()
    
    Sc.manifest.metadata.debug = \
            Sc.modes.get_is_active("release", "local_dev")
    Sc.manifest.metadata.playtest = \
            Sc.modes.get_is_active("release", "playtest")
    Sc.manifest.metadata.recording = \
            Sc.modes.get_is_active("release", "recording")
    Sc.manifest.metadata.is_using_threads = \
            Sc.modes.get_is_active("threading", "enabled")
    Sc.manifest.metadata.is_using_pixel_style = \
            Sc.modes.get_is_active("ui_smoothness", "pixelated")
    Sc.manifest.metadata.are_annotations_emphasized = \
            Sc.modes.get_is_active("annotations", "emphasized")
    
    if Sc.manifest.metadata.is_using_pixel_style:
        Sc.manifest.gui_manifest.fonts_manifest = \
                Sc.manifest.gui_manifest.fonts_manifest_pixelated
        Sc.manifest.styles_manifest = Sc.manifest.styles_manifest_pixelated
        Sc.manifest.images_manifest = Sc.manifest.images_manifest_pixelated
    else:
        Sc.manifest.gui_manifest.fonts_manifest = \
                Sc.manifest.gui_manifest.fonts_manifest_anti_aliased
        Sc.manifest.styles_manifest = Sc.manifest.styles_manifest_anti_aliased
        Sc.manifest.images_manifest = Sc.manifest.images_manifest_anti_aliased


func _parse_manifest() -> void:
    assert((manifest.images_manifest.developer_splash == null) == \
            manifest.audio_manifest.developer_splash_sound.empty())


func initialize_metadata() -> void:
    if manifest.has("metadata_class"):
        self.metadata = manifest.metadata_class.new()
        assert(self.metadata is ScaffolderAppMetadata)
    else:
        self.metadata = ScaffolderAppMetadata.new()
    add_child(self.metadata)
    self.metadata._parse_manifest(manifest.metadata)


func initialize_crash_reporter() -> void:
    if manifest.has("crash_reporter_class"):
        self.crash_reporter = manifest.crash_reporter_class.new()
        assert(self.crash_reporter is CrashReporter)
    else:
        self.crash_reporter = CrashReporter.new()


func _instantiate_sub_modules() -> void:
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
    
    if manifest.has("styles_class"):
        self.styles = manifest.styles_class.new()
        assert(self.styles is ScaffolderStyles)
    else:
        self.styles = ScaffolderStyles.new()
    add_child(self.styles)
    
    if manifest.has("images_class"):
        self.images = manifest.images_class.new()
        assert(self.images is ScaffolderImages)
    else:
        self.images = ScaffolderImages.new()
    add_child(self.images)
    
    if manifest.has("gui_class"):
        self.gui = manifest.gui_class.new()
        assert(self.gui is ScaffolderGuiConfig)
    else:
        self.gui = ScaffolderGuiConfig.new()
    add_child(self.gui)
    
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
        assert(self.time is ScaffolderTime)
    else:
        self.time = ScaffolderTime.new()
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
    
    if manifest.has("draw_class"):
        self.draw = manifest.draw_class.new()
        assert(self.draw is ScaffolderDrawUtils)
    else:
        self.draw = ScaffolderDrawUtils.new()
    add_child(self.draw)
    
    if manifest.has("palette_class"):
        self.palette = manifest.palette_class.new()
        assert(self.palette is ColorPalette)
    else:
        self.palette = ColorPalette.new()
    add_child(self.palette)
    
    if manifest.has("notify_class"):
        self.notify = manifest.notify_class.new()
        assert(self.notify is Notifications)
    else:
        self.notify = Notifications.new()
    add_child(self.notify)
    
    if manifest.has("info_panel_class"):
        self.info_panel = manifest.info_panel_class.new()
        assert(self.info_panel is InfoPanelController)
    else:
        self.info_panel = InfoPanelController.new()
    add_child(self.info_panel)
    
    if manifest.has("nav_class"):
        self.nav = manifest.nav_class.new()
        assert(self.nav is ScreenNavigator)
    else:
        self.nav = ScreenNavigator.new()
    add_child(self.nav)
    
    if manifest.has("level_button_input_class"):
        self.level_button_input = manifest.level_button_input_class.new()
        assert(self.level_button_input is LevelButtonInput)
    else:
        self.level_button_input = LevelButtonInput.new()
    add_child(self.level_button_input)
    
    if manifest.has("slow_motion_class"):
        self.slow_motion = manifest.slow_motion_class.new()
        assert(self.slow_motion is SlowMotionController)
    else:
        self.slow_motion = SlowMotionController.new()
    add_child(self.slow_motion)
    
    if manifest.has("beats_class"):
        self.beats = manifest.beats_class.new()
        assert(self.beats is BeatTracker)
    else:
        self.beats = BeatTracker.new()
    add_child(self.beats)
    
    if manifest.has("canvas_layers_class"):
        self.canvas_layers = manifest.canvas_layers_class.new()
        assert(self.canvas_layers is CanvasLayers)
    else:
        self.canvas_layers = CanvasLayers.new()
    add_child(self.canvas_layers)
    
    if manifest.has("project_settings_class"):
        self.project_settings = manifest.project_settings_class.new()
        assert(self.project_settings is ScaffolderProjectSettings)
    else:
        self.project_settings = ScaffolderProjectSettings.new()
    add_child(self.project_settings)
    
    if manifest.has("characters_class"):
        self.characters = manifest.characters_class.new()
        assert(self.characters is ScaffolderCharacterManifest)
    else:
        self.characters = ScaffolderCharacterManifest.new()
    add_child(self.characters)
    
    if manifest.has("camera_manifest_class"):
        self.camera = manifest.camera_manifest_class.new()
        assert(self.camera is ScaffolderCameraManifest)
    else:
        self.camera = ScaffolderCameraManifest.new()
    add_child(self.camera)
    
    if manifest.has("annotators_class"):
        self.annotators = manifest.annotators_class.new()
        assert(self.annotators is ScaffolderAnnotators)
    else:
        self.annotators = ScaffolderAnnotators.new()
    add_child(self.annotators)
    
    # This depends on SaveState, and must be instantiated after.
    self.levels = manifest.level_manifest.level_config_class.new()
    add_child(self.levels)
    
    self.levels.session = manifest.level_manifest.level_session_class.new()
    assert(self.levels.session is ScaffolderLevelSession)


func _configure_sub_modules() -> void:
    self.levels._parse_manifest(manifest.level_manifest)
    self.audio_manifest._parse_manifest(manifest.audio_manifest)
    self.styles._parse_manifest(manifest.styles_manifest)
    self.images._parse_manifest(manifest.images_manifest)
    self.gui._parse_manifest(manifest.gui_manifest)
    self.palette._parse_manifest(manifest.colors_manifest)
    self.annotators._parse_manifest(manifest.annotation_parameters_manifest)
    self.notify._parse_manifest(manifest.notifications_manifest)
    self.info_panel._parse_manifest(manifest.info_panel_manifest)
    self.slow_motion._parse_manifest(manifest.slow_motion_manifest)
    self.characters._parse_manifest(manifest.character_manifest)
    self.camera._parse_manifest(manifest.camera_manifest)
    
    self.metadata.is_app_configured = true
    
    self.project_settings._override_project_settings()
    self.project_settings._override_input_map(manifest.input_map)


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
    Sc.camera.manual_zoom = Sc.save_state.get_setting(
            SaveState.ZOOM_FACTOR_SETTINGS_KEY,
            1.0)

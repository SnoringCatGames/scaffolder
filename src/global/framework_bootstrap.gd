tool
class_name FrameworkBootstrap
extends Node


var _throttled_size_changed: FuncRef
var _is_global_visibility_disabled_for_resize := false
var _has_initial_input_happened := false


func _init(name := "FrameworkBootstrap") -> void:
    Sc.logger.on_global_init(self, name)


func run() -> void:
    _log_bootstrap_event("FrameworkBootstrap.run")
    
    call_deferred("_load_modes")
    call_deferred("_load_manifest")
    call_deferred("_amend_manifest")
    call_deferred("_parse_manifest")


func _load_modes() -> void:
    # Register all possible modes from each framework.
    for global in Sc._framework_globals:
        for mode_name in global.schema.modes:
            var mode_config = global.schema.modes[mode_name]
            assert(mode_name is String)
            assert(mode_config is Dictionary and \
                    mode_config.has("options") and \
                    mode_config.has("default"))
            assert(mode_config.options is Array)
            assert(mode_config.default is String)
            Sc.modes.register_mode(
                    mode_name,
                    mode_config.options,
                    mode_config.default,
                    mode_config.color)
    Sc.modes.load_from_json()


func _load_manifest() -> void:
    Sc.manifest_controller = FrameworkManifestController.new()
    Sc.manifest_controller.load_manifest()
    _log_app_name()


func _amend_manifest() -> void:
    for global in Sc._framework_globals:
        global._amend_manifest()


func _parse_manifest() -> void:
    _log_bootstrap_event("FrameworkBootstrap._parse_manifest")
    
    for global in Sc._framework_globals:
        global._parse_manifest()
    
    Sc.initialize_metadata()
    
    if _report_any_previous_crash():
        return
    else:
        call_deferred("_initialize_framework")


func _initialize_framework() -> void:
    _log_bootstrap_event("FrameworkBootstrap._initialize_framework")
    
    for global in Sc._framework_globals:
        global._instantiate_sub_modules()
    
    for global in Sc._framework_globals:
        Sc.profiler.preregister_metric_keys(global.schema.metric_keys)
    
    for global in Sc._framework_globals:
        global._configure_sub_modules()
    
    Sc.nav.connect("app_quit", self, "_on_app_quit")
    
    for global in Sc._framework_globals:
        global._load_state()
    
    Sc.styles.configure_theme()
    
    Sc.nav._parse_manifest(Sc.manifest.gui_manifest.screen_manifest)
    
    seed(Sc.metadata.rng_seed)
    
    _log_in_editor_initialization()
    
    if Engine.editor_hint:
        _on_app_initialized()
        return
    
    Sc.gui.debug_panel = Sc.utils.add_scene(
            Sc.canvas_layers.layers.top,
            Sc.gui.debug_panel_scene,
            true,
            true)
    Sc.gui.debug_panel.z_index = 1000
    Sc.gui.debug_panel.visible = Sc.gui.is_debug_panel_shown
    
    if Sc.metadata.debug or \
            Sc.metadata.playtest:
        Sc.gui.gesture_record = GestureRecord.new()
        Sc.canvas_layers.layers.top \
                .add_child(Sc.gui.gesture_record)
    
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    
    _throttled_size_changed = Sc.time.throttle(
            self,
            "_on_throttled_size_changed",
            Sc.gui.display_resize_throttle_interval)
    get_viewport().connect(
            "size_changed",
            self,
            "_on_resized")
    
    _set_window_debug_size_and_position()
    
    _log_device_settings()
    
    # Wait until the first resize event has propogated.
    Sc.time.set_timeout(
            self,
            "_on_window_size_set",
            Sc.gui.display_resize_throttle_interval + 0.01)


func _on_window_size_set() -> void:
    _log_bootstrap_event(
            "FrameworkBootstrap._on_window_size_set: %8.3f" % \
            Sc.time.get_play_time())
    
    if Sc.device.get_is_browser_app():
        JavaScript.eval("window.onAppReady()")
        
        _on_resized()
        
        # Initialize the app after a second resize event has propogated. For
        # some reason, the HTML export seems to need this additional resize.
        Sc.time.set_timeout(
                self,
                "_on_app_initialized",
                Sc.gui.display_resize_throttle_interval + 0.01)
    else:
        _on_app_initialized()


func _on_app_initialized() -> void:
    _log_bootstrap_event(
            "FrameworkBootstrap._on_app_initialized: %8.3f" % \
            Sc.time.get_play_time())
    
    for global in Sc._framework_globals:
        global._set_initialized()
    
    if Engine.editor_hint:
        return
    
    call_deferred("_splash")


func _splash() -> void:
    if !Sc.metadata.is_splash_skipped:
        Sc.nav.connect("splash_finished", self, "_on_splash_finished")
        Sc.nav.splash()
    else:
        _on_splash_finished()


func _on_splash_finished() -> void:
    _log_bootstrap_event(
            "FrameworkBootstrap._on_splash_finished: %8.3f" % \
            Sc.time.get_play_time())
    
    if Sc.nav.is_connected("splash_finished", self, "_on_splash_finished"):
        Sc.nav.disconnect("splash_finished", self, "_on_splash_finished")
    
    # Start playing the default music for the menu screen.
    Sc.audio.play_music(Sc.audio_manifest.main_menu_music, true)
    if Sc.metadata.opens_directly_to_level_id != "":
        Sc.nav.open(
                "loading",
                ScreenTransition.DEFAULT,
                {level_id = Sc.metadata.opens_directly_to_level_id})
    else:
        var post_splash_screen := \
                "main_menu" if \
                Sc.metadata.agreed_to_terms or \
                !Sc.metadata.is_data_tracked else \
                "data_agreement"
        Sc.nav.open(post_splash_screen)
    
    Sc.emit_signal("splashed")


func _on_app_quit() -> void:
    _log_bootstrap_event(
            "FrameworkBootstrap._on_app_quit: %8.3f" % \
            Sc.time.get_play_time())
    get_tree().call_deferred("quit")


func _report_any_previous_crash() -> bool:
    Sc.initialize_crash_reporter()
    Sc.crash_reporter.connect(
            "upload_finished",
            self,
            "_initialize_framework")
    Sc.add_child(Sc.crash_reporter)
    return Sc.crash_reporter.report_any_previous_crash()


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    
    if !Sc.is_initialized:
        return
    
    if Sc.metadata.debug or \
            Sc.metadata.playtest or \
            Sc.metadata.recording:
        if Input.is_action_just_pressed("screenshot"):
            Sc.metadata.were_screenshots_taken = true
            Sc.utils.take_screenshot()
        
        if Input.is_action_just_pressed("toggle_hud"):
            if is_instance_valid(Sc.gui.hud):
                Sc.gui.hud.visible = !Sc.gui.hud.visible


func _notification(notification: int) -> void:
    if Engine.editor_hint:
        return
    
    if !Sc.is_initialized:
        return
    
    if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
            is_instance_valid(Sc.nav) and \
            is_instance_valid(Sc.level) and \
            Sc.metadata.pauses_on_focus_out:
        Sc.level.pause()


func _input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    if !Sc.is_initialized:
        return
    
    # Listen for a touch event, which indicates that the device definitely
    # supports touch.
    if !Sc.device._is_definitely_touch_device and \
            event is InputEventScreenTouch and \
            !Sc.device._is_emulating_touch_from_mouse:
        Sc.device._is_definitely_touch_device = true
    
    # Listen for the first input that indicates the player is interacting with
    # the window.
    if !_has_initial_input_happened and \
            (event is InputEventKey or \
            event is InputEventMouseButton or \
            event is InputEventScreenTouch):
        _on_initial_input()


func _on_initial_input() -> void:
    _log_bootstrap_event(
            ("FrameworkBootstrap._on_initial_input: " +
            "%8.3f; is_definitely_touch=%s") % [
                Sc.time.get_play_time(),
                str(Sc.device.get_is_definitely_touch_device()),
            ])
    _has_initial_input_happened = true
    if Sc.device.get_is_browser_app() and \
            Sc.device.get_is_mobile_device():
        # TODO:
        #     - This doesn't actually work on mobile-web yet, but maybe it will
        #       in a future version of Godot?
        #     - If I want to make this work sooner, I can always call-through
        #       to a custom JavaScript function that hides the browser address
        #       bar.
        #     - https://developers.google.com/web/fundamentals/native-hardware/fullscreen
        OS.window_fullscreen = true


func _on_resized() -> void:
    _set_global_visibility_for_resize(false)
    _throttled_size_changed.call_func()


func _on_throttled_size_changed() -> void:
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    Sc.logger.print(
            "Window size changed: %8.3f; %s" % [
                Sc.time.get_play_time(),
                Sc.utils.get_vector_string(viewport_size, 0),
            ])
    call_deferred("_on_gui_scale_changed")


func _on_gui_scale_changed(is_first_call := true) -> void:
    Sc.gui._update_game_area_region_and_gui_scale()
    Sc.gui._update_font_sizes()
    Sc.images._update_icon_sizes()
    Sc.gui._scale_guis()
    
    Sc.device.emit_signal("display_resized")
    
    if is_first_call and \
            Sc.device.get_is_mobile_device():
        call_deferred("_on_gui_scale_changed", false)
    else:
        Sc.time.set_timeout(
                self,
                "_set_global_visibility_for_resize",
                0.05,
                [true])


func _set_global_visibility_for_resize(is_visible: bool) -> void:
    if is_visible:
        if _is_global_visibility_disabled_for_resize:
            _is_global_visibility_disabled_for_resize = false
            Sc.canvas_layers.set_global_visibility(true)
    else:
        # NOTE: For some reason, the show/hide breaks in full-screen mode.
        if !OS.window_fullscreen and \
                !_is_global_visibility_disabled_for_resize:
            _is_global_visibility_disabled_for_resize = true
            Sc.canvas_layers.set_global_visibility(false)


func _set_window_debug_size_and_position() -> void:
    if (Sc.metadata.debug or \
            Sc.metadata.recording) and \
            (Sc.device.get_is_windows_app() or \
            Sc.device.get_is_mac_app()):
        # Useful for getting screenshots at specific resolutions.
        if Sc.gui.debug_window_size == Vector2.INF:
            OS.window_fullscreen = true
            OS.window_borderless = true
        else:
            OS.window_size = Sc.gui.debug_window_size
            # Center the window.
            OS.window_position = \
                    (OS.get_screen_size() - Sc.gui.debug_window_size) / 2.0
        
        # Show the game window on the other monitor, rather than over-top the
        # editor.
        if OS.get_screen_count() > 1 and \
                Sc.gui.moves_debug_game_window_to_other_monitor:
            OS.current_screen = \
                    (OS.current_screen + 1) % OS.get_screen_count()
    _on_resized()


func _log_bootstrap_event(message: String) -> void:
    if Sc.manifest.empty() and \
            Sc._LOGS_EARLY_BOOTSTRAP_EVENTS or \
            !Sc.manifest.empty() and \
            Sc.manifest.metadata.logs_bootstrap_events:
        Sc.logger.print(message)


func _log_app_name() -> void:
    Sc.logger.print("")
    Sc.logger.print("App name: %s" % Sc.manifest.metadata.app_name)
    Sc.logger.print("App version: %s" % Sc.manifest.metadata.app_version)
    Sc.logger.print("")


func _log_in_editor_initialization() -> void:
    if Engine.editor_hint:
        print("")
        print("***************************************************************")
        print("**** Initialized Scaffolder for the in-editor environment. ****")
        print("* (Any errors above this line are likely due to already-open  *")
        print("* scenes trying to access AutoLoads before Godot has          *")
        print("* instantiated them.)                                         *")
        print("***************************************************************")
        print("")
        return


func _log_device_settings() -> void:
    if !Sc.metadata.logs_device_settings:
        return
    
    var device_model_name: String = Sc.device.get_model_name()
    var is_mobile_device: bool = Sc.device.get_is_mobile_device()
    var is_definitely_touch_device: bool = \
            Sc.device.get_is_definitely_touch_device()
    var device_screen_scale: float = Sc.device.get_screen_scale()
    var ios_resolution: String = \
            Sc.device._get_ios_screen_ppi() if \
            Sc.device.get_is_ios_app() else \
            "N/A"
    Sc.logger.print(
            ("Device settings:" +
            "\n    OS.get_name()=%s" +
            "\n    OS.get_model_name()=%s" +
            "\n    Sc.device.get_model_name()=%s" +
            "\n    Sc.device.get_is_mobile_device()=%s" +
            "\n    Sc.device.get_is_definitely_touch_device()=%s" +
            "\n    Sc.device.get_viewport_size()=%s" +
            "\n    OS.window_size=%s" +
            "\n    OS.get_real_window_size()=%s" +
            "\n    OS.get_screen_size()=%s" +
            "\n    Sc.device.get_screen_scale()=%s" +
            "\n    OS.get_screen_scale()=%s" +
            "\n    Sc.device.get_screen_ppi()=%s" +
            "\n    Sc.device.get_viewport_ppi()=%s" +
            "\n    OS.get_screen_dpi()=%s" +
            "\n    IosResolutions.get_screen_ppi()=%s" +
            "\n    Sc.device.get_viewport_size_inches()=%s" +
            "\n    Sc.device.get_viewport_diagonal_inches()=%s" +
            "\n    Sc.device.get_viewport_safe_area()=%s" +
            "\n    OS.get_window_safe_area()=%s" +
            "\n    Sc.device.get_safe_area_margin_top()=%s" +
            "\n    Sc.device.get_safe_area_margin_bottom()=%s" +
            "\n    Sc.device.get_safe_area_margin_left()=%s" +
            "\n    Sc.device.get_safe_area_margin_right()=%s" +
            "") % [
                OS.get_name(),
                OS.get_model_name(),
                device_model_name,
                is_mobile_device,
                is_definitely_touch_device,
                Sc.utils.get_vector_string(Sc.device.get_viewport_size(), 0),
                OS.window_size,
                OS.get_real_window_size(),
                OS.get_screen_size(),
                device_screen_scale,
                OS.get_screen_scale(),
                Sc.device.get_screen_ppi(),
                Sc.device.get_viewport_ppi(),
                OS.get_screen_dpi(),
                ios_resolution,
                Sc.device.get_viewport_size_inches(),
                Sc.device.get_viewport_diagonal_inches(),
                Sc.device.get_viewport_safe_area(),
                OS.get_window_safe_area(),
                Sc.device.get_safe_area_margin_top(),
                Sc.device.get_safe_area_margin_bottom(),
                Sc.device.get_safe_area_margin_left(),
                Sc.device.get_safe_area_margin_right(),
            ])

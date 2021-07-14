class_name ScaffolderBootstrap
extends Node


signal initialized
signal splashed

var _throttled_size_changed: FuncRef
var _is_global_visibility_disabled_for_resize := false
var _has_initial_input_happened := false


func _init(name := "ScaffolderBootstrap") -> void:
    Gs.logger.on_global_init(self, name)


func run() -> void:
    Gs.logger.print("ScaffolderBootstrap.run")
    Gs.logger.print("\nApp version: %s\n" % \
            Gs._manifest.metadata.app_version)
    
    call_deferred("_amend_app_manifest")
    call_deferred("_register_app_manifest")


func _amend_app_manifest() -> void:
    for config in Gs._framework_configs:
        config.amend_app_manifest(Gs._manifest)


func _register_app_manifest() -> void:
    Gs.logger.print("ScaffolderBootstrap._register_app_manifest")
    
    for config in Gs._framework_configs:
        config.register_app_manifest(Gs._manifest)
    
    Gs.initialize_metadata()
    
    if _report_any_previous_crash():
        return
    else:
        call_deferred("_initialize_framework")


func _initialize_framework() -> void:
    Gs.logger.print("ScaffolderBootstrap._initialize_framework")
    
    for config in Gs._framework_configs:
        if config.has_method("initialize"):
            config.initialize()
    
    Gs.nav.connect("app_quit", self, "_on_app_quit")
    
    for config in Gs._framework_configs:
        if config.has_method("load_state"):
            config.load_state()
    
    Gs.styles.configure_theme()
    
    Gs.nav.register_manifest(Gs._manifest.gui_manifest.screen_manifest)
    
    if Engine.editor_hint:
        return
    
    Gs.gui.debug_panel = Gs.utils.add_scene(
            Gs.canvas_layers.layers.top,
            Gs.gui.debug_panel_scene,
            true,
            true)
    Gs.gui.debug_panel.z_index = 1000
    Gs.gui.debug_panel.visible = Gs.gui.is_debug_panel_shown
    
    if Gs.metadata.debug or \
            Gs.metadata.playtest:
        Gs.gui.gesture_record = GestureRecord.new()
        Gs.canvas_layers.layers.top \
                .add_child(Gs.gui.gesture_record)
    
    Gs.metadata.is_app_initialized = true
    
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    
    _throttled_size_changed = Gs.time.throttle(
            funcref(self, "_on_throttled_size_changed"),
            Gs.gui.display_resize_throttle_interval)
    get_viewport().connect(
            "size_changed",
            self,
            "_on_resized")
    
    _set_window_debug_size_and_position()
    
    _log_device_settings()
    
    # Wait until the first resize event has propogated.
    Gs.time.set_timeout(
            funcref(self, "_on_window_size_set"),
            Gs.gui.display_resize_throttle_interval + 0.01)


func _on_window_size_set() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_window_size_set")
    
    if Gs.device.get_is_browser_app():
        JavaScript.eval("window.onAppReady()")
        
        _on_resized()
        
        # Initialize the app after a second resize event has propogated. For
        # some reason, the HTML export seems to need this additional resize.
        Gs.time.set_timeout(
                funcref(self, "_on_app_initialized"),
                Gs.gui.display_resize_throttle_interval + 0.01)
    else:
        _on_app_initialized()


func _on_app_initialized() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_app_initialized")
    
    emit_signal("initialized")
    
    call_deferred("_splash")


func _splash() -> void:
    if !Gs.metadata.is_splash_skipped:
        Gs.nav.connect("splash_finished", self, "_on_splash_finished")
        Gs.nav.splash()
    else:
        _on_splash_finished()


func _on_splash_finished() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_splash_finished")
    
    if Gs.nav.is_connected("splash_finished", self, "_on_splash_finished"):
        Gs.nav.disconnect("splash_finished", self, "_on_splash_finished")
    
    # Start playing the default music for the menu screen.
    Gs.audio.play_music(Gs.audio_manifest.main_menu_music, true)
    var post_splash_screen := \
            "main_menu" if \
            Gs.metadata.agreed_to_terms or \
            !Gs.metadata.is_data_tracked else \
            "data_agreement"
    Gs.nav.open(post_splash_screen)
    
    emit_signal("splashed")


func _on_app_quit() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_app_quit")
    get_tree().call_deferred("quit")


func _report_any_previous_crash() -> bool:
    Gs.initialize_crash_reporter()
    Gs.crash_reporter.connect(
            "upload_finished",
            self,
            "_initialize_framework")
    Gs.add_child(Gs.crash_reporter)
    return Gs.crash_reporter.report_any_previous_crash()


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    
    if Gs.metadata.debug or \
            Gs.metadata.playtest:
        if Input.is_action_just_pressed("screenshot"):
            Gs.metadata.were_screenshots_taken = true
            Gs.utils.take_screenshot()


func _notification(notification: int) -> void:
    if Engine.editor_hint:
        return
    
    if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
            is_instance_valid(Gs.nav) and \
            is_instance_valid(Gs.level) and \
            Gs.metadata.pauses_on_focus_out:
        Gs.level.pause()


func _input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    # Listen for a touch event, which indicates that the device definitely
    # supports touch.
    if !Gs.device._is_definitely_touch_device and \
            event is InputEventScreenTouch and \
            !Gs.device._is_emulating_touch_from_mouse:
        Gs.device._is_definitely_touch_device = true
    
    # Listen for the first input that indicates the user is interacting with
    # the window.
    if !_has_initial_input_happened and \
            (event is InputEventKey or \
            event is InputEventMouseButton or \
            event is InputEventScreenTouch):
        _on_initial_input()


func _on_initial_input() -> void:
    Gs.logger.print(
            "ScaffolderBootstrap._on_initial_input: is_definitely_touch=%s" %
            str(Gs.device.get_is_definitely_touch_device()))
    _has_initial_input_happened = true
    if Gs.device.get_is_browser_app() and \
            Gs.device.get_is_mobile_device():
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
    var viewport_size := get_viewport().size
    Gs.logger.print(
        (
            "ScaffolderBootstrap._on_throttled_size_changed: (%.1f,%.1f)"
        ) % [
            viewport_size.x,
            viewport_size.y,
        ])
    call_deferred("_on_gui_scale_changed")


func _on_gui_scale_changed(is_first_call := true) -> void:
    Gs.gui._update_game_area_region_and_gui_scale()
    Gs.gui._update_font_sizes()
    Gs.icons._update_icon_sizes()
    Gs.gui._scale_guis()
    
    Gs.device.emit_signal("display_resized")
    
    if is_first_call and \
            Gs.device.get_is_mobile_device():
        call_deferred("_on_gui_scale_changed", false)
    else:
        Gs.time.set_timeout(
                funcref(self, "_set_global_visibility_for_resize"),
                0.05,
                [true])


func _set_global_visibility_for_resize(is_visible: bool) -> void:
    if is_visible:
        if _is_global_visibility_disabled_for_resize:
            _is_global_visibility_disabled_for_resize = false
            Gs.canvas_layers.set_global_visibility(true)
    else:
        # NOTE: For some reason, the show/hide breaks in full-screen mode.
        if !OS.window_fullscreen and \
                !_is_global_visibility_disabled_for_resize:
            _is_global_visibility_disabled_for_resize = true
            Gs.canvas_layers.set_global_visibility(false)


func _set_window_debug_size_and_position() -> void:
    if Gs.metadata.debug and \
            (Gs.device.get_is_windows_app() or \
            Gs.device.get_is_mac_app()):
        # Show the game window on the other window, rather than over-top the
        # editor.
        if OS.get_screen_count() > 1:
            OS.current_screen = \
                    (OS.current_screen + 1) % OS.get_screen_count()
        
        # Useful for getting screenshots at specific resolutions.
        if Gs.gui.debug_window_size == Vector2.INF:
            OS.window_fullscreen = true
            OS.window_borderless = true
        else:
            OS.window_size = Gs.gui.debug_window_size
    
    _on_resized()


func _log_device_settings() -> void:
    var device_model_name: String = Gs.device.get_model_name()
    var is_mobile_device: bool = Gs.device.get_is_mobile_device()
    var is_definitely_touch_device: bool = \
            Gs.device.get_is_definitely_touch_device()
    var device_screen_scale: float = Gs.device.get_screen_scale()
    var ios_resolution: String = \
            Gs.device._get_ios_screen_ppi() if \
            Gs.device.get_is_ios_app() else \
            "N/A"
    Gs.logger.print(
            ("Device settings:" +
            "\n    OS.get_name()=%s" +
            "\n    OS.get_model_name()=%s" +
            "\n    Gs.device.get_model_name()=%s" +
            "\n    Gs.device.get_is_mobile_device()=%s" +
            "\n    Gs.device.get_is_definitely_touch_device()=%s" +
            "\n    get_viewport().size=(%4d,%4d)" +
            "\n    OS.window_size=%s" +
            "\n    OS.get_real_window_size()=%s" +
            "\n    OS.get_screen_size()=%s" +
            "\n    Gs.device.get_screen_scale()=%s" +
            "\n    OS.get_screen_scale()=%s" +
            "\n    Gs.device.get_screen_ppi()=%s" +
            "\n    Gs.device.get_viewport_ppi()=%s" +
            "\n    OS.get_screen_dpi()=%s" +
            "\n    IosResolutions.get_screen_ppi()=%s" +
            "\n    Gs.device.get_viewport_size_inches()=%s" +
            "\n    Gs.device.get_viewport_diagonal_inches()=%s" +
            "\n    Gs.device.get_viewport_safe_area()=%s" +
            "\n    OS.get_window_safe_area()=%s" +
            "\n    Gs.device.get_safe_area_margin_top()=%s" +
            "\n    Gs.device.get_safe_area_margin_bottom()=%s" +
            "\n    Gs.device.get_safe_area_margin_left()=%s" +
            "\n    Gs.device.get_safe_area_margin_right()=%s" +
            "") % [
                OS.get_name(),
                OS.get_model_name(),
                device_model_name,
                is_mobile_device,
                is_definitely_touch_device,
                get_viewport().size.x,
                get_viewport().size.y,
                OS.window_size,
                OS.get_real_window_size(),
                OS.get_screen_size(),
                device_screen_scale,
                OS.get_screen_scale(),
                Gs.device.get_screen_ppi(),
                Gs.device.get_viewport_ppi(),
                OS.get_screen_dpi(),
                ios_resolution,
                Gs.device.get_viewport_size_inches(),
                Gs.device.get_viewport_diagonal_inches(),
                Gs.device.get_viewport_safe_area(),
                OS.get_window_safe_area(),
                Gs.device.get_safe_area_margin_top(),
                Gs.device.get_safe_area_margin_bottom(),
                Gs.device.get_safe_area_margin_left(),
                Gs.device.get_safe_area_margin_right(),
            ])

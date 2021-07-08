class_name ScaffolderBootstrap
extends Node


var app_manifest: Dictionary
var main: Node

var _throttled_size_changed: FuncRef
var _is_global_visibility_disabled_for_resize := false
var _has_initial_input_happened := false


func _init() -> void:
    name = "ScaffolderBootstrap"


func run(
        app_manifest: Dictionary,
        main: Node) -> void:
    Gs.logger.print("ScaffolderBootstrap.run")
    Gs.logger.print("\nApp version: %s\n" % \
            app_manifest.app_metadata.app_version)
    
    self.main = main
    self.app_manifest = app_manifest
    call_deferred("_amend_app_manifest")
    call_deferred("_register_app_manifest")


func _amend_app_manifest() -> void:
    Gs.amend_app_manifest(app_manifest)


func _register_app_manifest() -> void:
    Gs.logger.print("ScaffolderBootstrap._register_app_manifest")
    
    Gs.register_app_manifest(app_manifest)
    Gs.initialize_app_metadata()
    if _report_any_previous_crash():
        return
    else:
        call_deferred("_initialize_framework")


func _initialize_framework() -> void:
    Gs.logger.print("ScaffolderBootstrap._initialize_framework")
    
    Gs.initialize()
    Gs.nav.connect("app_quit", self, "_on_app_quit")
    Gs.load_state()
    Gs.styles.configure_theme()
    
    if main != self:
        main.add_child(self)
    
    Gs.nav.register_manifest(Gs.manifest.gui_manifest.screen_manifest)
    
    Gs.gui.debug_panel = Gs.utils.add_scene(
            Gs.canvas_layers.layers.top,
            Gs.gui.debug_panel_scene,
            true,
            true)
    Gs.gui.debug_panel.z_index = 1000
    Gs.gui.debug_panel.visible = Gs.gui.is_debug_panel_shown
    
    if Gs.app_metadata.debug or \
            Gs.app_metadata.playtest:
        Gs.gui.gesture_record = GestureRecord.new()
        Gs.canvas_layers.layers.top \
                .add_child(Gs.gui.gesture_record)
    
    Gs.app_metadata.is_app_initialized = true
    
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
    
    if !Gs.app_metadata.is_splash_skipped:
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
            Gs.app_metadata.agreed_to_terms or \
            !Gs.app_metadata.is_data_tracked else \
            "data_agreement"
    Gs.nav.open(post_splash_screen)


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
    if Gs.app_metadata.debug or Gs.app_metadata.playtest:
        if Input.is_action_just_pressed("screenshot"):
            Gs.app_metadata.were_screenshots_taken = true
            Gs.utils.take_screenshot()


func _notification(notification: int) -> void:
    if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
            is_instance_valid(Gs.nav) and \
            is_instance_valid(Gs.level) and \
            Gs.app_metadata.pauses_on_focus_out:
        Gs.level.pause()


func _input(event: InputEvent) -> void:
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
    _update_game_area_region_and_gui_scale()
    _update_font_sizes()
    _update_checkbox_size()
    _update_tree_arrow_size()
    _scale_guis()
    
    Gs.utils.emit_signal("display_resized")
    
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


func _update_font_sizes() -> void:
    # First, update the fonts that don't have size overrides.
    for font_name in Gs.gui.fonts:
        if Gs.gui.font_size_overrides.has(font_name):
            continue
        _update_sizes_for_font(font_name)
    
    # Second, update the fonts with size overrides.
    for font_name in Gs.gui.font_size_overrides:
        _update_sizes_for_font(font_name)


func _update_sizes_for_font(font_name: String) -> void:
    var original_dimensions: Dictionary = \
            Gs.gui.original_font_dimensions[font_name]
    for dimension_name in original_dimensions:
        Gs.gui.fonts[font_name].set(
                dimension_name,
                original_dimensions[dimension_name] * Gs.gui.scale)


func _update_checkbox_size() -> void:
    var target_icon_size: float = \
            Gs.gui.default_checkbox_icon_size * Gs.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Gs.gui.checkbox_icon_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Gs.gui.current_checkbox_icon_size = closest_icon_size
    
    var checked_icon_path: String = \
            Gs.gui.checkbox_icon_path_prefix + "checked_" + \
            str(Gs.gui.current_checkbox_icon_size) + ".png"
    var unchecked_icon_path: String = \
            Gs.gui.checkbox_icon_path_prefix + "unchecked_" + \
            str(Gs.gui.current_checkbox_icon_size) + ".png"
    
    var checked_icon := load(checked_icon_path)
    var unchecked_icon := load(unchecked_icon_path)
    
    Gs.gui.theme.set_icon("checked", "CheckBox", checked_icon)
    Gs.gui.theme.set_icon("unchecked", "CheckBox", unchecked_icon)


func _update_tree_arrow_size() -> void:
    var target_icon_size: float = \
            Gs.gui.default_tree_arrow_icon_size * Gs.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Gs.gui.tree_arrow_icon_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Gs.gui.current_tree_arrow_icon_size = closest_icon_size
    
    var open_icon_path: String = \
            Gs.gui.tree_arrow_icon_path_prefix + "open_" + \
            str(Gs.gui.current_tree_arrow_icon_size) + ".png"
    var closed_icon_path: String = \
            Gs.gui.tree_arrow_icon_path_prefix + "closed_" + \
            str(Gs.gui.current_tree_arrow_icon_size) + ".png"
    
    var open_icon := load(open_icon_path)
    var closed_icon := load(closed_icon_path)
    
    Gs.gui.theme.set_icon("arrow", "Tree", open_icon)
    Gs.gui.theme.set_icon("arrow_collapsed", "Tree", closed_icon)
    Gs.gui.theme.set_constant(
            "item_margin", "Tree", Gs.gui.current_tree_arrow_icon_size)


func _update_game_area_region_and_gui_scale() -> void:
    var viewport_size := get_viewport().size
    var aspect_ratio := viewport_size.x / viewport_size.y
    var game_area_position := Vector2.INF
    var game_area_size := Vector2.INF
    
    if !Gs.app_metadata.is_app_configured:
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    if aspect_ratio < Gs.gui.aspect_ratio_min:
        # Show vertical margin around game area.
        game_area_size = Vector2(
                viewport_size.x,
                viewport_size.x / Gs.gui.aspect_ratio_min)
        game_area_position = Vector2(
                0.0,
                (viewport_size.y - game_area_size.y) * 0.5)
    elif aspect_ratio > Gs.gui.aspect_ratio_max:
        # Show horizontal margin around game area.
        game_area_size = Vector2(
                viewport_size.y * Gs.gui.aspect_ratio_max,
                viewport_size.y)
        game_area_position = Vector2(
                (viewport_size.x - game_area_size.x) * 0.5,
                0.0)
    else:
        # Show no margins around game area.
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    
    Gs.gui.game_area_region = Rect2(game_area_position, game_area_size)
    
    if Gs.app_metadata.is_app_configured:
        var default_game_area_size := \
                Gs.gui.default_mobile_game_area_size if \
                Gs.device.get_is_mobile_device() else \
                Gs.gui.default_pc_game_area_size
        var default_aspect_ratio: float = \
                default_game_area_size.x / default_game_area_size.y
        Gs.gui.previous_scale = Gs.gui.scale
        Gs.gui.scale = \
                viewport_size.x / default_game_area_size.x if \
                aspect_ratio < default_aspect_ratio else \
                viewport_size.y / default_game_area_size.y
        Gs.gui.scale = \
                max(Gs.gui.scale, Gs.gui.MIN_GUI_SCALE)


func _scale_guis() -> void:
    if Gs.gui.previous_scale != Gs.gui.scale:
        for gui in Gs.gui.guis_to_scale:
            Gs.utils._scale_gui_for_current_screen_size(gui)


func _set_window_debug_size_and_position() -> void:
    if Gs.app_metadata.debug and \
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

class_name ScaffolderBootstrap
extends Node

var app_manifest: Dictionary
var main: Node

var _throttled_size_change_count := 0
var _throttled_size_changed: FuncRef

func _init() -> void:
    name = "ScaffolderBootstrap"

func run(
        app_manifest: Dictionary,
        main: Node) -> void:
    Gs.logger.print("ScaffolderBootstrap.run")
    
    self.main = main
    self.app_manifest = app_manifest
    call_deferred("_amend_app_manifest")
    call_deferred("_register_app_manifest")

func _amend_app_manifest() -> void:
    Gs.amend_app_manifest(app_manifest)

func _register_app_manifest() -> void:
    Gs.logger.print("ScaffolderBootstrap._register_app_manifest")
    
    Gs.register_app_manifest(app_manifest)
    if _report_any_previous_crash():
        return
    else:
        call_deferred("_initialize_framework")

func _initialize_framework() -> void:
    Gs.logger.print("ScaffolderBootstrap._initialize_framework")
    
    Gs.initialize()
    Gs.load_state()
    Gs.styles.configure_theme()
    
    if main != self:
        main.add_child(self)
    
    Gs.camera_controller = CameraController.new()
    main.add_child(Gs.camera_controller)
    
    Gs.canvas_layers = CanvasLayers.new()
    main.add_child(Gs.canvas_layers)
    
    Gs.debug_panel = Gs.utils.add_scene(
            Gs.canvas_layers.layers.top,
            Gs.DEBUG_PANEL_RESOURCE_PATH,
            true,
            true)
    Gs.debug_panel.z_index = 1000
    Gs.debug_panel.visible = Gs.is_debug_panel_shown
    
    if Gs.debug or Gs.playtest:
        Gs.gesture_record = GestureRecord.new()
        Gs.canvas_layers.layers.top \
                .add_child(Gs.gesture_record)
    
    Gs.is_app_initialized = true
    
    get_tree().root.set_pause_mode(Node.PAUSE_MODE_PROCESS)
    
    _throttled_size_changed = Gs.time.throttle(
            funcref(self, "_on_throttled_size_changed"),
            Gs.display_resize_throttle_interval_sec)
    get_viewport().connect(
            "size_changed",
            self,
            "_on_resized")
    
    _set_window_debug_size_and_position()
    
    _log_device_settings()

func _on_app_initialized() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_app_initialized")
    
    if Gs.utils.get_is_browser():
        JavaScript.eval("window.onAppReady()")
    
    if !Gs.is_splash_skipped:
        Gs.nav.connect("splash_finished", self, "_on_splash_finished")
        Gs.nav.splash()
    else:
        _on_splash_finished()

func _on_splash_finished() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_splash_finished")
    
    if Gs.nav.is_connected("splash_finished", self, "_on_splash_finished"):
        Gs.nav.disconnect("splash_finished", self, "_on_splash_finished")
    
    # Start playing the default music for the menu screen.
    Gs.audio.play_music(Gs.main_menu_music, true)
    var post_splash_screen := \
            "main_menu" if \
            Gs.agreed_to_terms or \
            !Gs.is_data_tracked else \
            "data_agreement"
    Gs.nav.open(post_splash_screen)

func _report_any_previous_crash() -> bool:
    Gs.initialize_crash_reporter()
    Gs.crash_reporter.connect(
            "upload_finished",
            self,
            "_initialize_framework")
    add_child(Gs.crash_reporter)
    return Gs.crash_reporter.report_any_previous_crash()

func _process(_delta_sec: float) -> void:
    if Gs.debug or Gs.playtest:
        if Input.is_action_just_pressed("screenshot"):
            Gs.were_screenshots_taken = true
            Gs.utils.take_screenshot()

func _notification(notification: int) -> void:
    if notification == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
            is_instance_valid(Gs.nav) and \
            is_instance_valid(Gs.level):
        Gs.level.pause()

func _on_resized() -> void:
    _throttled_size_changed.call_func()

func _on_throttled_size_changed() -> void:
    Gs.logger.print("ScaffolderBootstrap._on_throttled_size_changed")
    
    _update_game_area_region_and_gui_scale()
    _update_font_sizes()
    _update_checkbox_size()
    _update_tree_arrow_size()
    _scale_guis()
    Gs.utils.emit_signal("display_resized")
    # TODO: Fix the underlying dependency, instead of this double-call hack.
    #       (To repro the problem: run, maximize window, unmaximize window,
    #        Screen hasn't shrunk back to the correct size.)
    _scale_guis()
    Gs.utils.emit_signal("display_resized")
    
    _throttled_size_change_count += 1
    if _throttled_size_change_count == 2:
        Gs.nav.create_screens()
        call_deferred("_on_app_initialized")

func _update_font_sizes() -> void:
    for key in Gs.fonts:
        Gs.fonts[key].size = \
                Gs.original_font_sizes[key] * \
                Gs.gui_scale

func _update_checkbox_size() -> void:
    var target_icon_size := Gs.default_checkbox_icon_size * Gs.gui_scale
    var closest_icon_size := Gs.default_checkbox_icon_size
    for icon_size in Gs.checkbox_icon_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Gs.current_checkbox_icon_size = closest_icon_size
    
    var checked_icon_path := \
            Gs.checkbox_icon_path_prefix + "checked_" + \
            str(Gs.current_checkbox_icon_size) + ".png"
    var unchecked_icon_path := \
            Gs.checkbox_icon_path_prefix + "unchecked_" + \
            str(Gs.current_checkbox_icon_size) + ".png"
    
    var checked_icon := load(checked_icon_path)
    var unchecked_icon := load(unchecked_icon_path)
    
    Gs.theme.set_icon("checked", "CheckBox", checked_icon)
    Gs.theme.set_icon("unchecked", "CheckBox", unchecked_icon)

func _update_tree_arrow_size() -> void:
    var target_icon_size := Gs.default_tree_arrow_icon_size * Gs.gui_scale
    var closest_icon_size := Gs.default_tree_arrow_icon_size
    for icon_size in Gs.tree_arrow_icon_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Gs.current_tree_arrow_icon_size = closest_icon_size
    
    var open_icon_path := \
            Gs.tree_arrow_icon_path_prefix + "open_" + \
            str(Gs.current_tree_arrow_icon_size) + ".png"
    var closed_icon_path := \
            Gs.tree_arrow_icon_path_prefix + "closed_" + \
            str(Gs.current_tree_arrow_icon_size) + ".png"
    
    var open_icon := load(open_icon_path)
    var closed_icon := load(closed_icon_path)
    
    Gs.theme.set_icon("arrow", "Tree", open_icon)
    Gs.theme.set_icon("arrow_collapsed", "Tree", closed_icon)
    Gs.theme.set_constant(
            "item_margin", "Tree", Gs.current_tree_arrow_icon_size)

func _update_game_area_region_and_gui_scale() -> void:
    var viewport_size := get_viewport().size
    var aspect_ratio := viewport_size.x / viewport_size.y
    var game_area_position := Vector2.INF
    var game_area_size := Vector2.INF
    
    if !Gs.is_app_configured:
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    if aspect_ratio < Gs.aspect_ratio_min:
        # Show vertical margin around game area.
        game_area_size = Vector2(
                viewport_size.x,
                viewport_size.x / Gs.aspect_ratio_min)
        game_area_position = Vector2(
                0.0,
                (viewport_size.y - game_area_size.y) * 0.5)
    elif aspect_ratio > Gs.aspect_ratio_max:
        # Show horizontal margin around game area.
        game_area_size = Vector2(
                viewport_size.y * Gs.aspect_ratio_max,
                viewport_size.y)
        game_area_position = Vector2(
                (viewport_size.x - game_area_size.x) * 0.5,
                0.0)
    else:
        # Show no margins around game area.
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    
    Gs.game_area_region = Rect2(game_area_position, game_area_size)
    
    if Gs.is_app_configured:
        var default_aspect_ratio: float = \
                Gs.default_game_area_size.x / \
                Gs.default_game_area_size.y
        Gs.gui_scale = \
                viewport_size.x / Gs.default_game_area_size.x if \
                aspect_ratio < default_aspect_ratio else \
                viewport_size.y / Gs.default_game_area_size.y
        Gs.gui_scale = \
                max(Gs.gui_scale, Gs.MIN_GUI_SCALE)

func _scale_guis() -> void:
    for gui in Gs.guis_to_scale:
        Gs.utils._scale_gui_for_current_screen_size(gui)

func _set_window_debug_size_and_position() -> void:
    if Gs.debug and \
            (Gs.utils.get_is_windows_device() or \
            Gs.utils.get_is_mac_device()):
        # Show the game window on the other window, rather than over-top the
        # editor.
        if OS.get_screen_count() > 1:
            OS.current_screen = \
                    (OS.current_screen + 1) % OS.get_screen_count()
        
        # Useful for getting screenshots at specific resolutions.
        if Gs.debug_window_size == Vector2.INF:
            OS.window_fullscreen = true
            OS.window_borderless = true
        else:
            OS.window_size = Gs.debug_window_size
    
    _on_resized()
    Gs.time.set_timeout(
            funcref(self, "_on_resized"), 
            Gs.display_resize_throttle_interval_sec * 2.0)

func _log_device_settings() -> void:
    var utils_model_name: String = Gs.utils.get_model_name()
    var utils_screen_scale: float = Gs.utils.get_screen_scale()
    var ios_resolution: String = \
            Gs.utils._get_ios_screen_ppi() if \
            Gs.utils.get_is_ios_device() else \
            "N/A"
    Gs.logger.print(
            ("Device settings:" +
            "\n    OS.get_name()=%s" +
            "\n    OS.get_model_name()=%s" +
            "\n    Gs.utils.get_model_name()=%s" +
            "\n    get_viewport().size=(%4d,%4d)" +
            "\n    OS.window_size=%s" +
            "\n    OS.get_real_window_size()=%s" +
            "\n    OS.get_screen_size()=%s" +
            "\n    Gs.utils.get_screen_scale()=%s" +
            "\n    OS.get_screen_scale()=%s" +
            "\n    Gs.utils.get_screen_ppi()=%s" +
            "\n    Gs.utils.get_viewport_ppi()=%s" +
            "\n    OS.get_screen_dpi()=%s" +
            "\n    IosResolutions.get_screen_ppi()=%s" +
            "\n    Gs.utils.get_viewport_size_inches()=%s" +
            "\n    Gs.utils.get_viewport_diagonal_inches()=%s" +
            "\n    Gs.utils.get_viewport_safe_area()=%s" +
            "\n    OS.get_window_safe_area()=%s" +
            "\n    Gs.utils.get_safe_area_margin_top()=%s" +
            "\n    Gs.utils.get_safe_area_margin_bottom()=%s" +
            "\n    Gs.utils.get_safe_area_margin_left()=%s" +
            "\n    Gs.utils.get_safe_area_margin_right()=%s" +
            "") % [
                OS.get_name(),
                OS.get_model_name(),
                utils_model_name,
                get_viewport().size.x,
                get_viewport().size.y,
                OS.window_size,
                OS.get_real_window_size(),
                OS.get_screen_size(),
                utils_screen_scale,
                OS.get_screen_scale(),
                Gs.utils.get_screen_ppi(),
                Gs.utils.get_viewport_ppi(),
                OS.get_screen_dpi(),
                ios_resolution,
                Gs.utils.get_viewport_size_inches(),
                Gs.utils.get_viewport_diagonal_inches(),
                Gs.utils.get_viewport_safe_area(),
                OS.get_window_safe_area(),
                Gs.utils.get_safe_area_margin_top(),
                Gs.utils.get_safe_area_margin_bottom(),
                Gs.utils.get_safe_area_margin_left(),
                Gs.utils.get_safe_area_margin_right(),
            ])

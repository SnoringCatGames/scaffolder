class_name ScaffolderNavigation
extends Node


signal splash_finished

const SCREEN_SLIDE_DURATION := 0.3
const SCREEN_FADE_DURATION := 1.2
const SESSION_END_TIMEOUT := 2.0

var _is_debugging_active_screen_stack := false

# Dictionary<String, PackedScene>
var _screen_scenes := {}
# Dictionary<String, Screen>
var screens := {}
# Array<String>
var _active_screen_name_stack := []
var current_screen: Screen

var fade_transition: FadeTransition


func _init() -> void:
    Gs.logger.print("Navigation._init")


func _ready() -> void:
    get_tree().set_auto_accept_quit(false)
    Gs.analytics.connect(
            "session_ended",
            self,
            "_on_session_end")
    Gs.analytics.start_session()


func _notification(notification: int) -> void:
    if notification == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        # Handle the Android back button to navigate within the app instead of
        # quitting the app.
        if current_screen is MainMenuScreen:
            close_app()
        else:
            call_deferred("close_current_screen")
    elif notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        close_app()


func close_app() -> void:
    Gs.analytics.end_session()
    Gs.time.set_timeout(
            funcref(self, "_on_session_end"),
            SESSION_END_TIMEOUT)


func _on_session_end() -> void:
    if Gs.app_metadata.were_screenshots_taken:
        Gs.utils.open_screenshot_folder()
    get_tree().quit()


func _create_screen(screen_name: String) -> Screen:
    var screen: Screen
    if screens.has(screen_name):
        screen = screens[screen_name]
    else:
        screen = _screen_scenes[screen_name].instance()
    screen.pause_mode = Node.PAUSE_MODE_STOP
    Gs.canvas_layers.layers[screen.layer_name].add_child(screen)
    return screen


func register_manifest(screen_manifest: Dictionary) -> void:
    var screen_scenes: Array = \
            Gs.utils.get_collection_from_exclusions_and_inclusions(
                    Gs.gui.DEFAULT_SCREEN_SCENES,
                    screen_manifest.exclusions,
                    screen_manifest.inclusions)
    
    for screen_scene in screen_scenes:
        assert(screen_scene is PackedScene)
        var scene_state: SceneState = screen_scene.get_state()
        assert(scene_state.get_node_type(0) == "Node2D")
        assert(scene_state.get_node_property_name(0, 0) == "script")
        var screen_class = scene_state.get_node_property_value(0, 0)
        assert(screen_class.get("NAME") is String)
        assert(screen_class.get("IS_ALWAYS_ALIVE") is bool)
        
        self._screen_scenes[screen_class.NAME] = screen_scene
        if screen_class.IS_ALWAYS_ALIVE:
            var screen: Screen = _create_screen(screen_class.NAME)
            screen.visible = false
            self.screens[screen_class.NAME] = screen
    
    fade_transition = screen_manifest.fade_transition.instance()
    Gs.canvas_layers.layers.top.add_child(fade_transition)
    fade_transition.visible = false
    fade_transition.duration = SCREEN_FADE_DURATION
    fade_transition.connect(
            "fade_completed",
            self,
            "_on_fade_complete")


func open(
        screen_name: String,
        includes_fade := false,
        params = null) -> void:
    var previous_name := \
            current_screen.screen_name if \
            is_instance_valid(current_screen) else \
            "_"
    Gs.logger.print("Nav.open: %s => %s" % [
        previous_name,
        screen_name,
    ])
    
    var old_stack_string := get_active_screen_stack_string()
    
    _set_screen_is_open(
            screen_name,
            true,
            includes_fade,
            params)
    
    if _is_debugging_active_screen_stack:
        var new_stack_string := get_active_screen_stack_string()
        Gs.logger.print(
                "Nav._active_screen_name_stack: BEFORE=%s, AFTER=%s" % [
                    old_stack_string,
                    new_stack_string,
                ])


func close_current_screen(includes_fade := false) -> void:
    assert(!_active_screen_name_stack.empty())
    
    var previous_name := get_current_screen_name()
    var previous_index := _active_screen_name_stack.find(previous_name)
    assert(previous_index >= 0)
    var next_name = \
            _active_screen_name_stack[previous_index - 1] if \
            previous_index > 0 else \
            "_"
    Gs.logger.print("Nav.close_current_screen: %s => %s" % [
        previous_name,
        next_name,
    ])
    
    var old_stack_string := get_active_screen_stack_string()
    
    _set_screen_is_open(
            previous_name,
            false,
            includes_fade,
            null)
    
    if _is_debugging_active_screen_stack:
        var new_stack_string := get_active_screen_stack_string()
        Gs.logger.print(
                "Nav._active_screen_name_stack: BEFORE=%s, AFTER=%s" % [
                    old_stack_string,
                    new_stack_string,
                ])


func get_active_screen_stack_string() -> String:
    var stack_string := ""
    for screen_name in _active_screen_name_stack:
        stack_string += ">" + screen_name
    return stack_string


func get_current_screen_name() -> String:
    return current_screen.screen_name if \
            is_instance_valid(current_screen) else \
            ""


func _set_screen_is_open(
        screen_name: String,
        is_open: bool,
        includes_fade := false,
        params = null) -> void:
    var previous_screen := current_screen
    var next_screen: Screen
    if is_open:
        if is_instance_valid(current_screen) and \
                current_screen.screen_name == screen_name:
            # The screen is already open.
            return
        next_screen = _create_screen(screen_name)
    else:
        var index_to_close := _active_screen_name_stack.find(screen_name)
        assert(index_to_close >= 0)
        if index_to_close > 0:
            var next_screen_name: String = \
                    _active_screen_name_stack[index_to_close - 1]
            next_screen = _create_screen(next_screen_name)
        else:
            next_screen = null
    current_screen = next_screen
    
    var next_screen_name := \
            next_screen.screen_name if \
            is_instance_valid(next_screen) else \
            ""
    var previous_screen_name := \
            previous_screen.screen_name if \
            is_instance_valid(previous_screen) else \
            ""
    
    var is_paused: bool = !(next_screen is GameScreen)
    var is_first_screen := is_open and _active_screen_name_stack.empty()
    
    get_tree().paused = is_paused
    if is_instance_valid(next_screen):
        next_screen.visible = true
    
    var next_screen_was_already_shown := false
    if is_open:
        if !_active_screen_name_stack.has(next_screen_name):
            _active_screen_name_stack.push_back(next_screen_name)
        else:
            next_screen_was_already_shown = true
    
    # Remove all (potential) following screens from the stack.
    var index := _active_screen_name_stack.find(next_screen_name)
    while index < _active_screen_name_stack.size() - 1:
        _active_screen_name_stack.pop_back()
    
    # Ensure the correct screen shows on top.
    if previous_screen != null:
        previous_screen.z_index = \
                -100 + _active_screen_name_stack.find(
                        previous_screen_name) if \
                _active_screen_name_stack.has(previous_screen_name) else \
                -100 + _active_screen_name_stack.size()
    if next_screen != null:
        next_screen.z_index = \
                -100 + _active_screen_name_stack.find(next_screen_name)
    
    if !is_first_screen:
        var start_position: Vector2
        var end_position: Vector2
        var tween_screen: Screen
        if screen_name == "game":
            start_position = Vector2.ZERO
            end_position = Vector2(
                    -get_viewport().size.x,
                    0.0)
            tween_screen = previous_screen
        elif next_screen_was_already_shown:
            start_position = Vector2(
                    get_viewport().size.x,
                    0.0)
            end_position = Vector2.ZERO
            tween_screen = next_screen
            var swap_z_index := next_screen.z_index
            next_screen.z_index = previous_screen.z_index
            previous_screen.z_index = swap_z_index
        elif is_open:
            start_position = Vector2(
                    get_viewport().size.x,
                    0.0)
            end_position = Vector2.ZERO
            tween_screen = next_screen
        else:
            start_position = Vector2.ZERO
            end_position = Vector2(
                    get_viewport().size.x,
                    0.0)
            tween_screen = previous_screen
        
        var slide_duration := SCREEN_SLIDE_DURATION
        var slide_delay := 0.0
        if includes_fade:
            fade()
            slide_duration = SCREEN_SLIDE_DURATION / 2.0
            slide_delay = (SCREEN_FADE_DURATION - slide_duration) / 2.0
        
        tween_screen.position = start_position
        Gs.time.tween_property(
                tween_screen,
                "position",
                start_position,
                end_position,
                SCREEN_SLIDE_DURATION,
                "ease_in_out",
                slide_delay,
                TimeType.APP_PHYSICS,
                funcref(self, "_on_screen_slide_completed"),
                [previous_screen, next_screen])
    else:
        _on_screen_slide_completed(
                null,
                "",
                previous_screen,
                next_screen)
    
    if previous_screen != null:
        previous_screen._on_deactivated(next_screen)
        previous_screen.pause_mode = Node.PAUSE_MODE_STOP
    
    if next_screen != null:
        next_screen.set_params(params)
        
        # FIXME: ---------------------
        # - Implement a way to remember scroll position?
#        # If opening a new screen, auto-scroll to the top. Otherwise, if
#        # navigating back to a previous screen, maintain the scroll position,
#        # so the user can remember where they were.
#        if is_open:
#            next_screen._scroll_to_top()
        
        Gs.analytics.screen(next_screen_name)


func _on_screen_slide_completed(
        _object: Object,
        _key: NodePath,
        previous_screen: Screen,
        next_screen: Screen) -> void:
    if previous_screen != null:
        previous_screen.visible = false
        previous_screen.position = Vector2.ZERO
        if !previous_screen.is_always_alive:
            previous_screen._destroy()
    if next_screen != null:
        next_screen.visible = true
        next_screen.position = Vector2.ZERO
        next_screen.pause_mode = Node.PAUSE_MODE_PROCESS
        next_screen._on_activated(previous_screen)


func fade() -> void:
    fade_transition.visible = true
    fade_transition.fade()


func _on_fade_complete() -> void:
    if !fade_transition.is_transitioning:
        fade_transition.visible = false


func splash() -> void:
    call_deferred("_splash_helper")


func _splash_helper() -> void:
    open("godot_splash")
    Gs.audio.play_sound(Gs.audio_manifest.godot_splash_sound)
    yield(get_tree() \
            .create_timer(Gs.app_metadata.godot_splash_screen_duration),
            "timeout")
    
    if Gs.gui.is_developer_splash_shown:
        open("developer_splash")
        Gs.audio.play_sound(Gs.audio_manifest.developer_splash_sound)
        yield(get_tree() \
                .create_timer(
                        Gs.app_metadata.developer_splash_screen_duration),
                "timeout")
    
    emit_signal("splash_finished")

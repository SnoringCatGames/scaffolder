class_name ScaffolderNavigation
extends Node


signal splash_finished
signal app_quit

const SCREEN_CONTAINER_SCENE := \
        preload("res://addons/scaffolder/src/gui/screen_container.tscn")
const SESSION_END_TIMEOUT := 2.0

var transition_handler: ScreenTransitionHandler

var _is_debugging_active_screen_stack := false

# Dictionary<String, PackedScene>
var _screen_scenes := {}
# Dictionary<String, ScreenContainer>
var screen_containers := {}
# Dictionary<String, Screen>
var screens := {}
# Array<String>
var _active_screen_name_stack := []
var current_screen_container: ScreenContainer
var current_screen: Screen


func _init() -> void:
    Gs.logger.on_global_init(self, "Navigation")


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
        if get_current_screen_name() == "main_menu":
            close_app()
        else:
            call_deferred("close_current_screen")
    elif notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        close_app()


func close_app() -> void:
    transition_handler.clear_transitions()
    Gs.analytics.end_session()
    Gs.time.set_timeout(
            funcref(self, "_on_session_end"),
            SESSION_END_TIMEOUT)


func _on_session_end() -> void:
    if Gs.app_metadata.were_screenshots_taken:
        Gs.utils.open_screenshot_folder()
    _on_app_quit()


func _on_app_quit() -> void:
    emit_signal("app_quit")


func _create_screen_container(screen_name: String) -> ScreenContainer:
    var screen_container: ScreenContainer
    if screen_containers.has(screen_name):
        screen_container = screen_containers[screen_name]
    else:
        screen_container = SCREEN_CONTAINER_SCENE.instance()
        screen_container.pause_mode = Node.PAUSE_MODE_STOP
        var screen: Screen = _screen_scenes[screen_name].instance()
        Gs.canvas_layers.layers[screen.layer].add_child(screen_container)
        screen_container.set_up(screen)
    return screen_container


func register_manifest(screen_manifest: Dictionary) -> void:
    var screen_scenes: Array = \
            Gs.utils.get_collection_from_exclusions_and_inclusions(
                    Gs.gui.DEFAULT_SCREEN_SCENES,
                    screen_manifest.exclusions,
                    screen_manifest.inclusions)
    
    for screen_scene in screen_scenes:
        assert(screen_scene is PackedScene)
        var scene_state: SceneState = screen_scene.get_state()
        assert(scene_state.get_node_type(0) == "VBoxContainer")
        
        var screen_name := ""
        var is_always_alive := false
        for i in scene_state.get_node_property_count(0):
            var property_name := scene_state.get_node_property_name(0, i)
            var property_value = scene_state.get_node_property_value(0, i)
            if property_name == "is_always_alive":
                is_always_alive = property_value
            elif property_name == "screen_name":
                screen_name = property_value
        assert(screen_name != "")
        
        self._screen_scenes[screen_name] = screen_scene
        if is_always_alive:
            var screen_container := _create_screen_container(screen_name)
            screen_container.visible = false
            screen_containers[screen_name] = screen_container
            screens[screen_name] = screen_container.contents
    
    if screen_manifest.has("screen_transition_handler_class"):
        transition_handler = \
                screen_manifest.screen_transition_handler_class.new()
        assert(transition_handler is ScreenTransitionHandler)
    else:
        transition_handler = ScreenTransitionHandler.new()
    add_child(transition_handler)
    transition_handler.register_manifest(screen_manifest)


func open(
        screen_name: String,
        transition_type := ScreenTransition.DEFAULT,
        screen_params := {},
        transition_params := {}) -> void:
    var previous_name := \
            current_screen.screen_name if \
            is_instance_valid(current_screen) else \
            "_"
    Gs.logger.print("Nav.open: %s => %s (%s)" % [
        previous_name,
        screen_name,
        ScreenTransition.type_to_string(transition_type),
    ])
    
    var old_stack_string := get_active_screen_stack_string()
    
    _set_screen_is_open(
            screen_name,
            true,
            transition_type,
            screen_params,
            transition_params)
    
    if _is_debugging_active_screen_stack:
        var new_stack_string := get_active_screen_stack_string()
        Gs.logger.print(
                "Nav._active_screen_name_stack: BEFORE=%s, AFTER=%s" % [
                    old_stack_string,
                    new_stack_string,
                ])


func close_current_screen(
        transition_type := ScreenTransition.DEFAULT,
        transition_params := {}) -> void:
    assert(!_active_screen_name_stack.empty())
    
    var previous_name := get_current_screen_name()
    var previous_index := _active_screen_name_stack.find(previous_name)
    assert(previous_index >= 0)
    var next_name = \
            _active_screen_name_stack[previous_index - 1] if \
            previous_index > 0 else \
            "_"
    Gs.logger.print("Nav.close_current_screen: %s => %s (%s)" % [
        previous_name,
        next_name,
        ScreenTransition.type_to_string(transition_type),
    ])
    
    var old_stack_string := get_active_screen_stack_string()
    
    _set_screen_is_open(
            previous_name,
            false,
            transition_type,
            {},
            transition_params)
    
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
        transition_type := ScreenTransition.DEFAULT,
        screen_params := {},
        transition_params := {}) -> void:
    var previous_screen := current_screen
    var previous_screen_container := current_screen_container
    
    var next_screen_container: ScreenContainer
    if is_open:
        if is_instance_valid(current_screen) and \
                current_screen.screen_name == screen_name:
            # The screen is already open.
            return
        next_screen_container = _create_screen_container(screen_name)
    else:
        var index_to_close := _active_screen_name_stack.find(screen_name)
        assert(index_to_close >= 0)
        if index_to_close > 0:
            var next_screen_name: String = \
                    _active_screen_name_stack[index_to_close - 1]
            next_screen_container = _create_screen_container(next_screen_name)
        else:
            next_screen_container = null
    
    var next_screen: Screen = \
            next_screen_container.contents if \
            next_screen_container != null else \
            null
    
    current_screen = next_screen
    current_screen_container = next_screen_container
    
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
    
    if next_screen_container != null:
        next_screen.set_params(screen_params)
        
        # FIXME: ---------------------
        # - Implement a way to remember scroll position?
#        # If opening a new screen, auto-scroll to the top. Otherwise, if
#        # navigating back to a previous screen, maintain the scroll position,
#        # so the user can remember where they were.
#        if is_open:
#            next_screen._scroll_to_top()
        
        Gs.analytics.screen(next_screen_name)
    
    if is_first_screen:
        transition_handler.show_first_screen(next_screen_container)
    else:
        transition_handler.start_transition(
                previous_screen_container,
                next_screen_container,
                transition_type,
                transition_params,
                is_open or next_screen_was_already_shown)


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

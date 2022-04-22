tool
class_name ScreenNavigator
extends Node


signal splash_finished
signal app_quit

const SCREEN_CONTAINER_SCENE := \
        preload("res://addons/scaffolder/src/gui/screen_container.tscn")
const SESSION_END_TIMEOUT := 2.0

var transitions: ScreenTransitionHandler

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
    Sc.logger.on_global_init(self, "Navigation")


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    Sc.analytics.connect(
            "session_ended",
            self,
            "_on_session_end")
    Sc.analytics.start_session()


func _notification(notification: int) -> void:
    if Engine.editor_hint:
        return
    
    if notification == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
        # Handle the Android back button to navigate within the app instead of
        # quitting the app.
        if get_current_screen_name() == "main_menu" or \
                get_current_screen_name() == "data_agreement":
            close_app()
        else:
            call_deferred("close_current_screen")
    elif notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        close_app()


func close_app() -> void:
    transitions.clear_transitions()
    Sc.analytics.end_session()
    Sc.time.set_timeout(
            self,
            "_on_session_end",
            SESSION_END_TIMEOUT)


func _on_session_end() -> void:
    if Sc.metadata.were_screenshots_taken:
        Sc.utils.open_screenshot_folder()
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
        Sc.canvas_layers.layers[screen.layer].add_child(screen_container)
        screen_container.set_up(screen)
    return screen_container


func _parse_manifest(screen_manifest: Dictionary) -> void:
    if Engine.editor_hint:
        return
    
    for screen_scene in screen_manifest.screens:
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
        transitions = \
                screen_manifest.screen_transition_handler_class.new()
        assert(transitions is ScreenTransitionHandler)
    else:
        transitions = ScreenTransitionHandler.new()
    add_child(transitions)
    transitions._parse_manifest(screen_manifest)


func open(
        screen_name: String,
        transition_type := ScreenTransition.DEFAULT,
        screen_params := {},
        transition_params := {}) -> void:
    var previous_name := \
            current_screen.screen_name if \
            is_instance_valid(current_screen) else \
            "_"
    Sc.logger.print("Nav.open: %s => %s (%s)" % [
        previous_name,
        screen_name,
        ScreenTransition.get_string(transition_type),
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
        Sc.logger.print(
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
    Sc.logger.print("Nav.close_current_screen: %s => %s (%s)" % [
        previous_name,
        next_name,
        ScreenTransition.get_string(transition_type),
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
        Sc.logger.print(
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
        
        # TODO: Implement a way to remember and preserve scroll position when
        #       re-visiting.
        
        Sc.analytics.screen(next_screen_name)
    
    if is_first_screen:
        transitions.show_first_screen(next_screen_container)
    else:
        transitions.start_transition(
                previous_screen_container,
                next_screen_container,
                transition_type,
                transition_params,
                is_open or next_screen_was_already_shown)


func splash() -> void:
    call_deferred("_splash_helper")


func _splash_helper() -> void:
    open("godot_splash")
    Sc.audio.play_sound(Sc.audio_manifest.godot_splash_sound)
    yield(get_tree() \
            .create_timer(Sc.metadata.godot_splash_screen_duration),
            "timeout")
    
    if Sc.gui.is_developer_splash_shown:
        open("developer_splash")
        Sc.audio.play_sound(Sc.audio_manifest.developer_splash_sound)
        yield(get_tree() \
                .create_timer(
                        Sc.metadata.developer_splash_screen_duration),
                "timeout")
    
    emit_signal("splash_finished")

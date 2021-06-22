class_name ScaffolderNavigation
extends Node


signal splash_finished

const _DEFAULT_SCREEN_PATH_PREFIX := "res://addons/scaffolder/src/gui/screens/"
const _DEFAULT_SCREEN_FILENAMES := [
    "confirm_data_deletion_screen.tscn",
    "credits_screen.tscn",
    "data_agreement_screen.tscn",
    "developer_splash_screen.tscn",
    "game_screen.tscn",
    "game_over_screen.tscn",
    "godot_splash_screen.tscn",
    "level_select_screen.tscn",
    "main_menu_screen.tscn",
    "notification_screen.tscn",
    "pause_screen.tscn",
    "rate_app_screen.tscn",
    "settings_screen.tscn",
    "third_party_licenses_screen.tscn",
]
const FADE_TRANSITION_PATH := \
        _DEFAULT_SCREEN_PATH_PREFIX + "fade_transition.tscn"

const SCREEN_SLIDE_DURATION := 0.3
const SCREEN_FADE_DURATION := 1.2
const SESSION_END_TIMEOUT := 2.0

var is_debugging_active_screen_stack := false

# Dictionary<String, Screen>
var screens := {}
# Array<Screen>
var active_screen_stack := []

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
        if get_active_screen_name() == "main_menu":
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


func _create_screen(path: String) -> void:
    var screen: Screen = Gs.utils.add_scene(
            null,
            path,
            false,
            false)
    screen.pause_mode = Node.PAUSE_MODE_STOP
    screens[screen.screen_name] = screen
    Gs.canvas_layers.layers[screen.layer_name].add_child(screen)


func create_screens() -> void:
    var default := []
    for filename in _DEFAULT_SCREEN_FILENAMES:
        default.push_back(_DEFAULT_SCREEN_PATH_PREFIX + filename)
    
    var screen_paths: Array = \
            Gs.utils.get_collection_from_exclusions_and_inclusions(
                    default,
                    Gs.gui.screen_manifest.path_exclusions,
                    Gs.gui.screen_manifest.path_inclusions)
                    
    for path in screen_paths:
        _create_screen(path)
    
    fade_transition = Gs.utils.add_scene(
            Gs.canvas_layers.layers.top,
            FADE_TRANSITION_PATH,
            true,
            false)
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
            get_active_screen_name() if \
            !active_screen_stack.empty() else \
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
    
    if is_debugging_active_screen_stack:
        var new_stack_string := get_active_screen_stack_string()
        Gs.logger.print("Nav.active_screen_stack: BEFORE=%s, AFTER=%s" % [
            old_stack_string,
            new_stack_string,
        ])


func close_current_screen(includes_fade := false) -> void:
    assert(!active_screen_stack.empty())
    
    var previous_name := get_active_screen_name()
    var previous_index := active_screen_stack.find(screens[previous_name])
    assert(previous_index >= 0)
    var next_name = \
            active_screen_stack[previous_index - 1].screen_name if \
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
    
    if is_debugging_active_screen_stack:
        var new_stack_string := get_active_screen_stack_string()
        Gs.logger.print("Nav.active_screen_stack: BEFORE=%s, AFTER=%s" % [
            old_stack_string,
            new_stack_string,
        ])


func get_active_screen_stack_string() -> String:
    var stack_string := ""
    for screen in active_screen_stack:
        stack_string += ">" + screen.screen_name
    return stack_string


func get_active_screen() -> Screen:
    return active_screen_stack.back()


func get_active_screen_name() -> String:
    return get_active_screen().screen_name


func _set_screen_is_open(
        screen_name: String,
        is_open: bool,
        includes_fade := false,
        params = null) -> void:
    var next_screen: Screen
    var previous_screen: Screen
    if is_open:
        next_screen = screens[screen_name]
        previous_screen = \
                active_screen_stack.back() if \
                !active_screen_stack.empty() else \
                null
    else:
        previous_screen = screens[screen_name]
        var index := active_screen_stack.find(previous_screen)
        assert(index >= 0)
        next_screen = \
                active_screen_stack[index - 1] if \
                index > 0 else \
                null
    
    var next_screen_name := \
            next_screen.screen_name if \
            next_screen != null else \
            "_"
    var is_paused: bool = next_screen_name != "game"
    var is_first_screen := is_open and active_screen_stack.empty()
    
    var next_screen_was_already_shown := false
    if is_open:
        if !active_screen_stack.has(next_screen):
            active_screen_stack.push_back(next_screen)
        else:
            next_screen_was_already_shown = true
    
    # Remove all (potential) following screens from the stack.
    var index := active_screen_stack.find(next_screen)
    while index + 1 < active_screen_stack.size():
        var removed_screen: Screen = active_screen_stack.back()
        active_screen_stack.pop_back()
        removed_screen.visible = false
    
    get_tree().paused = is_paused
    
    if previous_screen != null:
        previous_screen.visible = true
        previous_screen.z_index = \
                -100 + active_screen_stack.find(previous_screen) if \
                active_screen_stack.has(previous_screen) else \
                -100 + active_screen_stack.size()
    if next_screen != null:
        next_screen.visible = true
        next_screen.z_index = -100 + active_screen_stack.find(next_screen)
    
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
        previous_screen._on_deactivated(next_screen_name)
        previous_screen.pause_mode = Node.PAUSE_MODE_STOP
    
    if next_screen != null:
        next_screen.set_params(params)
        
        # If opening a new screen, auto-scroll to the top. Otherwise, if
        # navigating back to a previous screen, maintain the scroll position,
        # so the user can remember where they were.
        if is_open:
            next_screen._scroll_to_top()
        
        Gs.analytics.screen(next_screen.screen_name)


func _on_screen_slide_completed(
        _object: Object,
        _key: NodePath,
        previous_screen: Screen,
        next_screen: Screen) -> void:
    var previous_screen_name := \
            previous_screen.screen_name if \
            previous_screen != null else \
            "_"
    
    if previous_screen != null:
        previous_screen.visible = false
        previous_screen.position = Vector2.ZERO
    if next_screen != null:
        next_screen.visible = true
        next_screen.position = Vector2.ZERO
        next_screen.pause_mode = Node.PAUSE_MODE_PROCESS
        next_screen._on_activated(previous_screen_name)


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

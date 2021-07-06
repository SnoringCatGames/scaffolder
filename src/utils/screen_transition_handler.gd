class_name ScreenTransitionHandler
extends Node


const SCREEN_SLIDE_TRANSITION_DURATION := 0.3
const SCREEN_FADE_TRANSITION_DURATION := 0.3
const SCREEN_MASK_TRANSITION_DURATION := 1.2

var _default_transition_type := ScreenTransition.IMMEDIATE
var _fancy_transition_type := ScreenTransition.OVERLAY_MASK

var _overlay_mask_transition: OverlayMaskTransition

var _start_transition_helper_timeout_id := -1
var _start_immediate_transition_timeout_id := -1
var _slide_transition_tween_id := -1
var _fade_transition_tween_id := -1


func _init() -> void:
    Gs.logger.on_global_init(self, "ScreenTransitionHandler")


func register_manifest(screen_manifest: Dictionary) -> void:
    assert(screen_manifest.has("default_transition_type") and \
            screen_manifest.default_transition_type != \
                    ScreenTransition.DEFAULT and \
            screen_manifest.default_transition_type != \
                    ScreenTransition.FANCY)
    _default_transition_type = screen_manifest.default_transition_type
    
    assert(screen_manifest.has("fancy_transition_type") and \
            screen_manifest.fancy_transition_type != \
                    ScreenTransition.DEFAULT and \
            screen_manifest.fancy_transition_type != \
                    ScreenTransition.FANCY)
    _fancy_transition_type = screen_manifest.fancy_transition_type
    
    _overlay_mask_transition = \
            screen_manifest.overlay_mask_transition.instance()
    Gs.canvas_layers.layers.top.add_child(_overlay_mask_transition)
    _overlay_mask_transition.visible = false
    _overlay_mask_transition.connect(
            "completed",
            self,
            "_on_overlay_mask_transition_complete")


func start_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_type: int,
        transition_params: Dictionary,
        is_forward: bool) -> void:
    var transition_method_name: String
    var default_duration: float
    match transition_type:
        ScreenTransition.DEFAULT:
            start_transition(
                    previous_screen_container,
                    next_screen_container,
                    _default_transition_type,
                    transition_params,
                    is_forward)
            return
        ScreenTransition.FANCY:
            start_transition(
                    previous_screen_container,
                    next_screen_container,
                    _fancy_transition_type,
                    transition_params,
                    is_forward)
            return
        ScreenTransition.IMMEDIATE:
            transition_method_name = "_start_immediate_transition"
            default_duration = 0.0
        ScreenTransition.SLIDE:
            transition_method_name = "_start_slide_transition"
            default_duration = SCREEN_SLIDE_TRANSITION_DURATION
        ScreenTransition.FADE:
            transition_method_name = "_start_fade_transition"
            default_duration = SCREEN_FADE_TRANSITION_DURATION
        ScreenTransition.OVERLAY_MASK:
            transition_method_name = "_start_overlay_mask_transition"
            default_duration = SCREEN_MASK_TRANSITION_DURATION
        ScreenTransition.SCREEN_MASK:
            transition_method_name = "_start_screen_mask_transition"
            default_duration = SCREEN_MASK_TRANSITION_DURATION
        _:
            Gs.utils.error()
            transition_method_name = "_start_immediate_transition"
            default_duration = INF
    
    # Assign z-indices according to whether we're transitioning "forward" or
    # "backward" between screens.
    var previous_z_index: int
    var next_z_index: int
    if is_forward:
        previous_z_index = 0
        next_z_index = 1
    else:
        previous_z_index = 1
        next_z_index = 0
    if is_instance_valid(previous_screen_container):
        previous_screen_container.z_index = previous_z_index
    if is_instance_valid(next_screen_container):
        next_screen_container.z_index = next_z_index
    
    var is_game_screen_next := \
            next_screen_container.contents.screen_name == "game" if \
            is_instance_valid(next_screen_container) else \
            false
    
    var duration: float = \
            transition_params.duration if \
            transition_params.has("duration") else \
            default_duration
    
    var delay: float = \
            transition_params.delay if \
            transition_params.has("delay") else \
            0.0
    
    clear_transitions()
    
    call(transition_method_name,
            previous_screen_container,
            next_screen_container,
            transition_params,
            is_forward,
            is_game_screen_next,
            duration,
            delay)


func _start_immediate_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float) -> void:
    if delay > 0.0:
        _start_immediate_transition_timeout_id = Gs.time.set_timeout( \
                funcref(self, "on_transition_completed"), \
                delay,
                [
                    null,
                    "",
                    previous_screen_container,
                    next_screen_container,
                ])
    else:
        on_transition_completed(
                null,
                "",
                previous_screen_container,
                next_screen_container)


func _start_slide_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float) -> void:
    var tween_screen_container: ScreenContainer
    var start_position: Vector2
    var end_position: Vector2
    if is_game_screen_next:
        tween_screen_container = previous_screen_container
        if is_forward:
            start_position = Vector2.ZERO
            end_position = Vector2(
                    -get_viewport().size.x,
                    0.0)
        else:
            start_position = Vector2.ZERO
            end_position = Vector2(
                    get_viewport().size.x,
                    0.0)
    elif is_forward:
        tween_screen_container = next_screen_container
        start_position = Vector2(
                get_viewport().size.x,
                0.0)
        end_position = Vector2.ZERO
    else:
        tween_screen_container = previous_screen_container
        start_position = Vector2.ZERO
        end_position = Vector2(
                get_viewport().size.x,
                0.0)
    
    tween_screen_container.position = start_position
    _slide_transition_tween_id = Gs.time.tween_property(
            tween_screen_container,
            "position",
            start_position,
            end_position,
            duration,
            "ease_in_out",
            delay,
            TimeType.APP_PHYSICS,
            funcref(self, "on_transition_completed"),
            [previous_screen_container, next_screen_container])


func _start_fade_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float) -> void:
    var tween_screen_container: ScreenContainer
    var start_opacity: float
    var end_opacity: float
    if is_game_screen_next:
        tween_screen_container = previous_screen_container
        start_opacity = 1.0
        end_opacity = 0.0
    elif is_forward:
        tween_screen_container = next_screen_container
        start_opacity = 0.0
        end_opacity = 1.0
    else:
        tween_screen_container = previous_screen_container
        start_opacity = 1.0
        end_opacity = 0.0
    
    tween_screen_container.modulate.a = start_opacity
    _fade_transition_tween_id = Gs.time.tween_property(
            tween_screen_container,
            "modulate:a",
            start_opacity,
            end_opacity,
            duration,
            "ease_in_out",
            delay,
            TimeType.APP_PHYSICS,
            funcref(self, "on_transition_completed"),
            [previous_screen_container, next_screen_container])


func _start_overlay_mask_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float) -> void:
    _overlay_mask_transition.duration = duration
    
    _start_transition_helper_timeout_id = Gs.time.set_timeout( \
            funcref(self, "_start_overlay_mask_transition_helper"), \
            delay)
    
    _start_immediate_transition(
            previous_screen_container,
            next_screen_container,
            transition_params,
            is_forward,
            is_game_screen_next,
            0.0,
            duration / 2.0 + delay)


func _start_overlay_mask_transition_helper() -> void:
    _overlay_mask_transition.visible = true
    _overlay_mask_transition.start()


func _on_overlay_mask_transition_complete() -> void:
    if !_overlay_mask_transition.is_transitioning:
        _overlay_mask_transition.visible = false


func _start_screen_mask_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float) -> void:
    # FIXME: ----------------
    pass


func on_transition_completed(
        _object: Object,
        _key: NodePath,
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer) -> void:
    if is_instance_valid(previous_screen_container):
        previous_screen_container.visible = false
        previous_screen_container.position = Vector2.ZERO
        if !previous_screen_container.contents.is_always_alive:
            previous_screen_container._destroy()
    if is_instance_valid(next_screen_container):
        if next_screen_container == Gs.nav.current_screen_container:
            next_screen_container.visible = true
            next_screen_container.position = Vector2.ZERO
            next_screen_container.pause_mode = Node.PAUSE_MODE_PROCESS
            next_screen_container._on_activated(previous_screen_container)
        else:
            # We already navigated to a different screen while this one was
            # activating.
            if !next_screen_container.contents.is_always_alive:
                next_screen_container._destroy()


func clear_transitions() -> void:
    Gs.time.clear_timeout(_start_transition_helper_timeout_id, true)
    Gs.time.clear_timeout(_start_immediate_transition_timeout_id, true)
    Gs.time.clear_tween(_slide_transition_tween_id, true)
    Gs.time.clear_tween(_fade_transition_tween_id, true)

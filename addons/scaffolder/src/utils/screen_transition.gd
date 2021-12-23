class_name ScreenTransition
extends Reference


enum {
    DEFAULT,
    FANCY,
    IMMEDIATE,
    SLIDE,
    FADE,
    OVERLAY_MASK,
    SCREEN_MASK,
}

var previous_screen_container
var next_screen_container

var transition_params: Dictionary
var is_forward: bool
var is_game_screen_next: bool

var duration: float
var delay: float
var easing: String

var start_transition_helper_timeout_id := -1
var start_immediate_transition_timeout_id := -1
var slide_transition_tween_id := -1
var fade_transition_tween_id := -1


static func get_string(type: int) -> String:
    match type:
        DEFAULT:
            return "DEFAULT"
        FANCY:
            return "FANCY"
        IMMEDIATE:
            return "IMMEDIATE"
        SLIDE:
            return "SLIDE"
        FADE:
            return "FADE"
        OVERLAY_MASK:
            return "OVERLAY_MASK"
        SCREEN_MASK:
            return "SCREEN_MASK"
        _:
            ScaffolderLog.static_error("Invalid ScreenTransition: %d" % type)
            return ""

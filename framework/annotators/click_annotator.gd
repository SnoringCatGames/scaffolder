extends Node2D
class_name ClickAnnotator

const CLICK_END_RADIUS := 58.0
var CLICK_COLOR := Color.from_hsv(0.5, 0.2, 0.99, 0.8)
const CLICK_DURATION := 200.0

var level # FIXME: Add type back
var click_position: Vector2
var start_time := -CLICK_DURATION
var end_time := -CLICK_DURATION
var progress := 1.0
var is_a_click_currently_rendered := false

func _init(level) -> void:
    self.level = level

func _process(delta: float) -> void:
    var current_time := OS.get_ticks_msec()
    
    if Input.is_action_just_released("left_click"):
        click_position = level.get_global_mouse_position()
        start_time = current_time
        end_time = start_time + CLICK_DURATION
        is_a_click_currently_rendered = true
    
    if end_time > current_time or is_a_click_currently_rendered:
        progress = (current_time - start_time) / CLICK_DURATION
        update()

func _draw() -> void:
    if progress >= 1:
        is_a_click_currently_rendered = false
        return
    
    var alpha := CLICK_COLOR.a * (1 - progress)
    var color := Color(CLICK_COLOR.r, CLICK_COLOR.g, CLICK_COLOR.b, alpha)
    var radius := CLICK_END_RADIUS * progress
    draw_circle(click_position, radius, color)
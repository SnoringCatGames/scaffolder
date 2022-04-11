class_name LevelPointerListener
extends Node2D


signal dragged(pointer_position)
signal released(pointer_position)

var previous_drag_position := Vector2.INF
var current_drag_position := Vector2.INF
var release_position := Vector2.INF


func _init() -> void:
    assert(Sc.gui.is_player_interaction_enabled)


func _unhandled_input(event: InputEvent) -> void:
    var pointer_up_position := Vector2.INF
    var pointer_drag_position := Vector2.INF
    var event_type := "UNKNOWN_INP"
    
    # NOTE: Shouldn't need to handle mouse events, since we should be emulating
    #       touch events.
    
#    # Mouse-up: Position selection.
#    if event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            !event.pressed and \
#            !event.control:
#        event_type = "MOUSE_UP   "
#        pointer_up_position = Sc.utils.get_level_touch_position(event)
#
#    # Mouse-down: Position pre-selection.
#    if event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            event.pressed and \
#            !event.control:
#        event_type = "MOUSE_DOWN "
#        pointer_drag_position = \
#                Sc.utils.get_level_touch_position(event)
#
#    # Mouse-move: Position pre-selection.
#    if event is InputEventMouseMotion and \
#            _last_pointer_drag_position != Vector2.INF:
#        event_type = "MOUSE_DRAG "
#        pointer_drag_position = \
#                Sc.utils.get_level_touch_position(event)
    
    var is_control_pressed: bool = \
            Sc.level_button_input.is_key_pressed(KEY_CONTROL) or \
            Sc.level_button_input.is_key_pressed(KEY_META)
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed and \
            !is_control_pressed:
        event_type = "TOUCH_UP   "
        pointer_up_position = Sc.utils.get_level_touch_position(event)
    
    # Touch-down: Position pre-selection.
    if event is InputEventScreenTouch and \
            event.pressed and \
            !is_control_pressed:
        event_type = "TOUCH_DOWN "
        pointer_drag_position = Sc.utils.get_level_touch_position(event)
    
    # Touch-move: Position pre-selection.
    if event is InputEventScreenDrag and \
            !is_control_pressed:
        event_type = "TOUCH_DRAG "
        pointer_drag_position = Sc.utils.get_level_touch_position(event)
    
#    if pointer_up_position != Vector2.INF or \
#            pointer_drag_position != Vector2.INF:
#        _character._log(
#                event_type,
#                "",
#                CharacterLogType.ACTION,
#                true)
    
    if pointer_up_position != Vector2.INF:
        _on_pointer_released(pointer_up_position)
    elif pointer_drag_position != Vector2.INF:
        _on_pointer_moved(pointer_drag_position)


func _on_pointer_moved(pointer_position: Vector2) -> void:
    self.release_position = Vector2.INF
    self.previous_drag_position = current_drag_position
    self.current_drag_position = pointer_position
    emit_signal("dragged", pointer_position)


func _on_pointer_released(pointer_position: Vector2) -> void:
    self.previous_drag_position = Vector2.INF
    self.current_drag_position = Vector2.INF
    self.release_position = pointer_position
    emit_signal("released", pointer_position)

tool
class_name GestureRecord
extends Node2D


# Array<GestureEventForDebugging>
var recent_gesture_events_for_debugging := []


func _init() -> void:
    Sc.logger.on_global_init(self, "GestureRecord")


func _input(event: InputEvent) -> void:
    if (Sc.metadata.debug or Sc.metadata.playtest) and \
            (event is InputEventScreenTouch or event is InputEventScreenDrag):
        _record_new_gesture_event(event)


func _record_new_gesture_event(event: InputEvent) -> void:
    var gesture_name: String
    if event is InputEventScreenTouch:
        gesture_name = "do" if event.pressed else "up"
    elif event is InputEventScreenDrag:
        gesture_name = "dr"
    else:
        Sc.logger.error("GestureRecord._record_new_gesture_event")
        return
    var gesture_event := GestureEventForDebugging.new(
            event.position,
            gesture_name,
            Sc.time.get_play_time())
    recent_gesture_events_for_debugging.push_front(gesture_event)
    while recent_gesture_events_for_debugging.size() > \
            Sc.gui.recent_gesture_events_for_debugging_buffer_size:
        recent_gesture_events_for_debugging.pop_back()


class GestureEventForDebugging extends Reference:
    
    
    var position: Vector2
    var name: String
    var time: float
    
    
    func _init(
            position: Vector2,
            name: String,
            time: float) -> void:
        self.position = position
        self.name = name
        self.time = time
    
    
    func to_string() -> String:
        return "{%s;%s;%.3f}" % [
            name,
            Sc.utils.get_vector_string(position, 2),
            time,
        ]

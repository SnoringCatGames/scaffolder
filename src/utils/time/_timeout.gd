tool
class_name _Timeout
extends Reference


var time_tracker
var elapsed_time_key: String
var callback: FuncRef
var time: float
var arguments: Array
var id: int
var parent


func _init(
        parent,
        time_type: int,
        callback: FuncRef,
        delay: float,
        arguments: Array) -> void:
    self.parent = parent
    self.time_tracker = Sc.time._get_time_tracker_for_time_type(time_type)
    self.elapsed_time_key = \
            Sc.time._get_elapsed_time_key_for_time_type(time_type)
    self.callback = callback
    self.time = time_tracker.get(elapsed_time_key) + delay
    self.arguments = arguments
    self.id = Sc.time.get_next_task_id()


func get_has_expired() -> bool:
    var elapsed_time: float = time_tracker.get(elapsed_time_key)
    return elapsed_time >= time


func trigger() -> void:
    if !callback.is_valid():
        return
    callback.call_funcv(arguments)

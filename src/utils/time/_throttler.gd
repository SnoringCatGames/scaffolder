tool
class_name _Throttler
extends Reference


var time_type: int
var time_tracker
var elapsed_time_key: String
var callback: FuncRef
var interval: float
var invokes_at_end: bool
var parent

var last_timeout_id := -1

var last_call_time := -INF
var is_callback_scheduled := false


func _init(
        parent,
        time_type: int,
        callback: FuncRef,
        interval: float,
        invokes_at_end: bool) -> void:
    self.parent = parent
    self.time_type = time_type
    self.time_tracker = Sc.time._get_time_tracker_for_time_type(time_type)
    self.elapsed_time_key = \
            Sc.time._get_elapsed_time_key_for_time_type(time_type)
    self.callback = callback
    self.interval = interval
    self.invokes_at_end = invokes_at_end


func on_call() -> void:
    if !is_callback_scheduled:
        var current_call_time: float = \
                time_tracker.get(elapsed_time_key)
        var next_call_time := last_call_time + interval
        if current_call_time > next_call_time:
            _trigger_callback()
        elif invokes_at_end:
            last_timeout_id = Sc.time.set_timeout(
                    self,
                    "_trigger_callback",
                    next_call_time - current_call_time,
                    [],
                    time_type)
            is_callback_scheduled = true


func cancel() -> void:
    Sc.time.clear_timeout(last_timeout_id)
    is_callback_scheduled = false


func _trigger_callback() -> void:
    last_call_time = time_tracker.get(elapsed_time_key)
    is_callback_scheduled = false
    if callback.is_valid():
        callback.call_func()

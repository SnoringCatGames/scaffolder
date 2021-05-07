class_name Time
extends Node

const PHYSICS_FPS := 60.0
const PHYSICS_TIME_STEP_SEC := 1.0 / PHYSICS_FPS

const _DEFAULT_TIME_SCALE := 1.0

const _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE := 1.0
#const _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE := 0.1

# The different types of time that are tracked.
# 
# -   Fixed-interval/physics-based tracking vs clock and render-based tracking:
#     -   In general, use fixed-interval/physics-based tracking for most cases,
#         unless you know you need something else.
#         -   Fixed-interval tracking is deterministic, which means you should
#             see the same results each time you run the app.
#     -   "Clock" and "render"-based tracking should represent actual time more
#         accurately than fixed-interval/physics-based tracking, since the
#         latter under-counts if a frame actually takes longer than the
#         expected fixed-interval duration.
#         -   This is useful if you want to actual track and display real
#             elapsed time to the user.
# -   App time vs play time:
#     -   App time tracks total time elapsed while the app has been running.
#     -   Play time tracks elapsed **unpaused** time.
# -   Scaled vs un-scaled time:
#     -   Scaled time is modified by the combination of the `time_scale` and
#         `additional_debug_time_scale` properties.
#         -   The current scale is applied to each individual frame's delta and
#             this is added to a running total.
#         -   So this accounts for changes in time scale.
enum {
    # -   Elapsed time from deterministic fixed-interval _physics_process calls.
    # -   Total app run time; not affected by pausing.
    # -   Not affected by current time_scale or additional_debug_time_scale.
    APP_PHYSICS_TIME,
    # -   Elapsed **real-world time**, according to the OS.
    # -   Total app run time; not affected by pausing.
    # -   Not affected by current time_scale or additional_debug_time_scale.
    APP_CLOCK_TIME,
    # -   Elapsed time from deterministic fixed-interval _physics_process calls.
    # -   Total app run time; not affected by pausing.
    # -   **Scaled** according to the current time_scale and
    #     additional_debug_time_scale.
    APP_PHYSICS_SCALED_TIME,
    # -   Elapsed **real-world time**, according to the OS.
    # -   Total app run time; not affected by pausing.
    # -   **Scaled** according to the current time_scale and
    #     additional_debug_time_scale.
    APP_CLOCK_SCALED_TIME,
    # -   Elapsed time from deterministic fixed-interval _physics_process calls.
    # -   Total **un-paused** run time.
    # -   Not affected by current time_scale or additional_debug_time_scale.
    PLAY_PHYSICS_TIME,
    # -   Elapsed time from nondeterministic variable-interval _process calls.
    # -   Total **un-paused** run time.
    # -   Not affected by current time_scale or additional_debug_time_scale.
    PLAY_RENDER_TIME,
    # -   Elapsed time from deterministic fixed-interval _physics_process calls.
    # -   Total **un-paused** run time.
    # -   **Scaled** according to the current time_scale and
    #     additional_debug_time_scale.
    PLAY_PHYSICS_SCALED_TIME,
    # -   Elapsed time from nondeterministic variable-interval _process calls.
    # -   Total **un-paused** run time.
    # -   **Scaled** according to the current time_scale and
    #     additional_debug_time_scale.
    PLAY_RENDER_SCALED_TIME,
}

var time_scale := _DEFAULT_TIME_SCALE setget _set_time_scale
var additional_debug_time_scale := _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE \
        setget _set_additional_debug_time_scale

var _app_time: _TimeTracker
var _play_time: _TimeTracker

# Dictionary<int, _Timeout>
var _timeouts := {}
# Dictionary<int, _Interval>
var _intervals := {}
var _last_timeout_id := -1
# Dictionary<FuncRef, _Throttler>
var _throttled_callbacks := {}

func _init() -> void:
    Gs.logger.print("Time._init")
    pause_mode = Node.PAUSE_MODE_PROCESS

func _enter_tree() -> void:
    _app_time = _TimeTracker.new()
    _app_time.pause_mode = Node.PAUSE_MODE_PROCESS
    add_child(_app_time)
    
    _play_time = _TimeTracker.new()
    _play_time.pause_mode = Node.PAUSE_MODE_STOP
    add_child(_play_time)

func get_app_time_sec() -> float:
    return get_elapsed_time_sec(APP_PHYSICS_TIME)

func get_play_time_sec() -> float:
    return get_elapsed_time_sec(PLAY_PHYSICS_TIME)

func get_scaled_play_time_sec() -> float:
    return get_elapsed_time_sec(PLAY_PHYSICS_SCALED_TIME)

func get_elapsed_time_sec(time_type: int) -> float:
    var tracker := _get_time_tracker_for_time_type(time_type)
    var key := _get_elapsed_time_key_for_time_type(time_type)
    return tracker.get(key)

func _get_time_tracker_for_time_type(time_type: int) -> _TimeTracker:
    match time_type:
        APP_PHYSICS_TIME, \
        APP_CLOCK_TIME, \
        APP_PHYSICS_SCALED_TIME, \
        APP_CLOCK_SCALED_TIME:
            return _app_time
        PLAY_PHYSICS_TIME, \
        PLAY_RENDER_TIME, \
        PLAY_PHYSICS_SCALED_TIME, \
        PLAY_RENDER_SCALED_TIME:
            return _play_time
        _:
            Gs.utils.error("Unrecognized time_type: %d" % time_type)
            return null

func _get_elapsed_time_key_for_time_type(time_type: int) -> String:
    match time_type:
        APP_PHYSICS_TIME, \
        PLAY_PHYSICS_TIME:
            return "elapsed_physics_time_sec"
        APP_PHYSICS_SCALED_TIME, \
        PLAY_PHYSICS_SCALED_TIME:
            return "elapsed_physics_scaled_time_sec"
        APP_CLOCK_TIME:
            return "elapsed_clock_time_sec"
        APP_CLOCK_SCALED_TIME:
            return "elapsed_clock_scaled_time_sec"
        PLAY_RENDER_TIME:
            return "elapsed_render_time_sec"
        PLAY_RENDER_SCALED_TIME:
            return "elapsed_render_scaled_time_sec"
        _:
            Gs.utils.error("Unrecognized time_type: %d" % time_type)
            return ""

func get_combined_scale() -> float:
    return time_scale * additional_debug_time_scale

func scale_delta(duration: float) -> float:
    return duration * get_combined_scale()

func _set_time_scale(value: float) -> void:
    time_scale = value
    _app_time.time_scale = get_combined_scale()
    _play_time.time_scale = get_combined_scale()

func _set_additional_debug_time_scale(value: float) -> void:
    additional_debug_time_scale = value
    _app_time.time_scale = get_combined_scale()
    _play_time.time_scale = get_combined_scale()

func set_timeout(
        callback: FuncRef,
        delay_sec: float,
        arguments := [],
        time_type := APP_PHYSICS_TIME) -> int:
    var tracker := _get_time_tracker_for_time_type(time_type)
    var key := _get_elapsed_time_key_for_time_type(time_type)
    var timeout := _Timeout.new(
            tracker,
            key,
            callback,
            delay_sec,
            arguments)
    _timeouts[timeout.id] = timeout
    return timeout.id

func clear_timeout(timeout_id: int) -> bool:
    return _timeouts.erase(timeout_id)

func set_interval(
        callback: FuncRef,
        interval_sec: float,
        arguments := [],
        time_type := APP_PHYSICS_TIME) -> int:
    var tracker := _get_time_tracker_for_time_type(time_type)
    var key := _get_elapsed_time_key_for_time_type(time_type)
    var interval := _Interval.new(
            tracker,
            key,
            callback,
            interval_sec,
            arguments)
    _intervals[interval.id] = interval
    return interval.id

func clear_interval(interval_id: int) -> bool:
    return _intervals.erase(interval_id)

func throttle(
        callback: FuncRef,
        interval_sec: float,
        invokes_at_end := true,
        time_type := APP_PHYSICS_TIME) -> FuncRef:
    var throttler := _Throttler.new(
            time_type,
            callback,
            interval_sec,
            invokes_at_end)
    var throttled_callback := funcref(
            throttler,
            "on_call")
    _throttled_callbacks[throttled_callback] = throttler
    return throttled_callback

func cancel_pending_throttle(throttled_callback: FuncRef) -> void:
    assert(_throttled_callbacks.has(throttled_callback))
    _throttled_callbacks[throttled_callback].cancel()

func erase_throttle(throttled_callback: FuncRef) -> bool:
    return _throttled_callbacks.erase(throttled_callback)

# Keeps track of elapsed time.
class _TimeTracker extends Node:
    var time_scale := _DEFAULT_TIME_SCALE
    
    var start_clock_time_sec: float
    var elapsed_clock_time_sec: float
    var elapsed_physics_time_sec: float
    var elapsed_render_time_sec: float
    var elapsed_clock_scaled_time_sec: float
    var elapsed_physics_scaled_time_sec: float
    var elapsed_render_scaled_time_sec: float
    
    func _ready() -> void:
        start_clock_time_sec = OS.get_ticks_usec() / 1000000.0
        elapsed_clock_time_sec = 0.0
        elapsed_physics_time_sec = 0.0
        elapsed_render_time_sec = 0.0
        elapsed_clock_scaled_time_sec = 0.0
        elapsed_physics_scaled_time_sec = 0.0
        elapsed_render_scaled_time_sec = 0.0
    
    func _process(delta_sec: float) -> void:
        elapsed_render_time_sec += delta_sec
        elapsed_render_scaled_time_sec += delta_sec * time_scale
        _handle_timeouts()
        _handle_intervals()
    
    func _physics_process(delta_sec: float) -> void:
        elapsed_physics_time_sec += delta_sec
        elapsed_physics_scaled_time_sec += delta_sec * time_scale
        _update_clock_time()
    
    func _update_clock_time() -> void:
        var next_elapsed_clock_time_sec := \
                OS.get_ticks_usec() / 1000000.0 - start_clock_time_sec
        var delta_clock_time_sec := \
                next_elapsed_clock_time_sec - elapsed_clock_time_sec
        elapsed_clock_time_sec = next_elapsed_clock_time_sec
        elapsed_clock_scaled_time_sec += delta_clock_time_sec * time_scale
    
    func _handle_timeouts() -> void:
        var expired_timeout_id := -1
        for id in Gs.time._timeouts:
            if Gs.time._timeouts[id].get_has_expired():
                expired_timeout_id = id
                break
        
        if expired_timeout_id >= 0:
            Gs.time._timeouts[expired_timeout_id].trigger()
            Gs.time._timeouts.erase(expired_timeout_id)
    
    func _handle_intervals() -> void:
        var triggered_interval_id := -1
        for id in Gs.time._intervals:
            if Gs.time._intervals[id].get_has_reached_next_trigger_time():
                triggered_interval_id = id
                break
        
        if triggered_interval_id >= 0:
            Gs.time._intervals[triggered_interval_id].trigger()

class _Timeout extends Reference:
    var time_tracker: _TimeTracker
    var elapsed_time_key: String
    var callback: FuncRef
    var time_sec: float
    var arguments: Array
    var id: int
    
    func _init(
            time_tracker: _TimeTracker,
            elapsed_time_key: String,
            callback: FuncRef,
            time_sec: float,
            arguments: Array) -> void:
        self.time_tracker = time_tracker
        self.elapsed_time_key = elapsed_time_key
        self.callback = callback
        self.time_sec = time_sec
        self.arguments = arguments
        
        Gs.time._last_timeout_id += 1
        self.id = Gs.time._last_timeout_id
    
    func get_has_expired() -> bool:
        var elapsed_time_sec: float = time_tracker.get(elapsed_time_key)
        return elapsed_time_sec >= time_sec
    
    func trigger() -> void:
        if !callback.is_valid():
            return
        
        match arguments.size():
            0:
                callback.call_func()
            1:
                callback.call_func(arguments[0])
            2:
                callback.call_func(arguments[0], arguments[1])
            3:
                callback.call_func(arguments[0], arguments[1], arguments[2])
            4:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3])
            5:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4])
            6:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5])
            7:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5], arguments[6])
            _:
                Gs.logger.error()

class _Interval extends Reference:
    var time_tracker: _TimeTracker
    var elapsed_time_key: String
    var callback: FuncRef
    var interval_sec: float
    var arguments: Array
    var next_trigger_time_sec: float
    var id: int
    
    func _init(
            time_tracker: _TimeTracker,
            elapsed_time_key: String,
            callback: FuncRef,
            interval_sec: float,
            arguments: Array) -> void:
        self.time_tracker = time_tracker
        self.elapsed_time_key = elapsed_time_key
        self.callback = callback
        self.interval_sec = interval_sec
        self.arguments = arguments
        self.next_trigger_time_sec = \
                time_tracker.get(elapsed_time_key) + interval_sec
        
        Gs.time._last_timeout_id += 1
        self.id = Gs.time._last_timeout_id
    
    func get_has_reached_next_trigger_time() -> bool:
        var elapsed_time_sec: float = time_tracker.get(elapsed_time_key)
        return elapsed_time_sec >= next_trigger_time_sec
    
    func trigger() -> void:
        if !callback.is_valid():
            return
        
        next_trigger_time_sec = \
                time_tracker.get(elapsed_time_key) + interval_sec
        match arguments.size():
            0:
                callback.call_func()
            1:
                callback.call_func(arguments[0])
            2:
                callback.call_func(arguments[0], arguments[1])
            3:
                callback.call_func(arguments[0], arguments[1], arguments[2])
            4:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3])
            5:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4])
            6:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5])
            7:
                callback.call_func(arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5], arguments[6])
            _:
                Gs.logger.error()

class _Throttler extends Reference:
    var time_type: int
    var time_tracker: _TimeTracker
    var elapsed_time_key: String
    var callback: FuncRef
    var interval_sec: float
    var invokes_at_end: bool
    
    var trigger_callback_callback := funcref(self, "_trigger_callback")
    var last_timeout_id := -1
    
    var last_call_time_sec := -INF
    var is_callback_scheduled := false
    
    func _init(
            time_type: int,
            callback: FuncRef,
            interval_sec: float,
            invokes_at_end: bool) -> void:
        self.time_type = time_type
        self.time_tracker = Gs.time._get_time_tracker_for_time_type(time_type)
        self.elapsed_time_key = \
                Gs.time._get_elapsed_time_key_for_time_type(time_type)
        self.callback = callback
        self.interval_sec = interval_sec
        self.invokes_at_end = invokes_at_end
    
    func on_call() -> void:
        if !is_callback_scheduled:
            var current_call_time_sec: float = \
                    time_tracker.get(elapsed_time_key)
            var next_call_time_sec := last_call_time_sec + interval_sec
            if current_call_time_sec > next_call_time_sec:
                _trigger_callback()
            elif invokes_at_end:
                last_timeout_id = Gs.time.set_timeout(
                        trigger_callback_callback,
                        next_call_time_sec - current_call_time_sec,
                        [],
                        time_type)
                is_callback_scheduled = true
    
    func cancel() -> void:
        Gs.time.clear_timeout(last_timeout_id)
        is_callback_scheduled = false
    
    func _trigger_callback() -> void:
        last_call_time_sec = time_tracker.get(elapsed_time_key)
        is_callback_scheduled = false
        if callback.is_valid():
            callback.call_func()

class_name TimeScaleControlRow
extends SliderControlRow


const LABEL := "Time scale"
const DESCRIPTION := ""

const MIN_RESULT_VALUE := 0.25
const MAX_RESULT_VALUE := 4.0
const MID_RESULT_VALUE := 1.0

const STEP := (MAX_CONTROL_VALUE - MIN_CONTROL_VALUE) / 16.0
const WIDTH := 128.0
const TICK_COUNT := 3


func _init(__ = null).(
        LABEL,
        DESCRIPTION,
        MIN_RESULT_VALUE,
        MID_RESULT_VALUE,
        MAX_RESULT_VALUE,
        STEP,
        WIDTH,
        TICK_COUNT
        ) -> void:
    pass


func on_value_changed(control_value: float) -> void:
    var result_value := _control_value_to_result_value(control_value)
    Sc.time.additional_debug_time_scale = result_value
    Sc.save_state.set_setting(
            SaveState.ADDITIONAL_DEBUG_TIME_SCALE_SETTINGS_KEY,
            result_value)


func get_value() -> float:
    return _result_value_to_control_value(Sc.time.additional_debug_time_scale)


func get_is_enabled() -> bool:
    return true

class_name SliderControlRow
extends ControlRow


var TYPE := ControlRow.SLIDER

const MIN_CONTROL_VALUE := 0.0
const MAX_CONTROL_VALUE := 1.0
const MID_CONTROL_VALUE := 0.5

var value: float
var min_result_value: float
var mid_result_value: float
var max_result_value: float
var step: float
var width: float
var tick_count: int

var _is_change_triggered_indirectly := false


func _init(
        label: String,
        description: String,
        min_result_value: float,
        mid_result_value: float,
        max_result_value: float,
        step := 0.0,
        width := 64.0,
        tick_count := 0,
        is_control_on_right_side := true
        ).(
        TYPE,
        label,
        description,
        is_control_on_right_side
        ) -> void:
    self.min_result_value = min_result_value
    self.mid_result_value = mid_result_value
    self.max_result_value = max_result_value
    self.step = step
    self.width = width
    self.tick_count = tick_count


func on_value_changed(value: float) -> void:
    Sc.logger.error(
            "Abstract SliderControlRow.on_value_changed " +
            "is not implemented")


func get_value() -> float:
    Sc.logger.error(
            "Abstract SliderControlRow.get_value " +
            "is not implemented")
    return INF


func _update_control() -> void:
    value = get_value()
    if is_instance_valid(control):
        control.value = value


func create_control() -> Control:
    var slider: ScaffolderSlider = Sc.utils.add_scene(
            null,
            Sc.gui.SCAFFOLDER_SLIDER_SCENE,
            false,
            true)
    slider.editable = enabled
    slider.size_override.x = width
    slider.step = step
    slider.tick_count = tick_count
    slider.min_value = MIN_CONTROL_VALUE
    slider.max_value = MAX_CONTROL_VALUE
    slider.value = value
    slider.connect(
            "value_changed",
            self,
            "_on_slider_value_changed")
    return slider


func _on_slider_value_changed(_value: float) -> void:
    if !_is_change_triggered_indirectly:
        Sc.utils.give_button_press_feedback()
    _is_change_triggered_indirectly = false
    value = control.value
    on_value_changed(value)
    emit_signal("changed")


func set_original_size(original_size: Vector2) -> void:
    width = original_size.x
    control.size_override.x = width


func _control_value_to_result_value(control_value: float) -> float:
    if control_value < MID_CONTROL_VALUE:
        var weight := \
                (control_value - MIN_CONTROL_VALUE) / \
                (MID_CONTROL_VALUE - MIN_CONTROL_VALUE)
        return lerp(min_result_value, mid_result_value, weight)
    else:
        var weight := \
                (control_value - MID_CONTROL_VALUE) / \
                (MAX_CONTROL_VALUE - MID_CONTROL_VALUE)
        return lerp(mid_result_value, max_result_value, weight)


func _result_value_to_control_value(result_value: float) -> float:
    if result_value < mid_result_value:
        var weight := \
                (result_value - min_result_value) / \
                (mid_result_value - min_result_value)
        return lerp(MIN_CONTROL_VALUE, MID_CONTROL_VALUE, weight)
    else:
        var weight := \
                (result_value - mid_result_value) / \
                (max_result_value - mid_result_value)
        return lerp(MID_CONTROL_VALUE, MAX_CONTROL_VALUE, weight)

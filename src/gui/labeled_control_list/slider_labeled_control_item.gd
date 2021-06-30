class_name SliderLabeledControlItem
extends LabeledControlItem


var TYPE := LabeledControlItem.SLIDER

var value: float
var min_value: float
var max_value: float
var step: float
var width: float
var tick_count: int


func _init(
        label: String,
        description: String,
        min_value: float,
        max_value: float,
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
    self.min_value = min_value
    self.max_value = max_value
    self.step = step
    self.width = width
    self.tick_count = tick_count


func on_value_changed(value: float) -> void:
    Gs.logger.error(
            "Abstract SliderLabeledControlItem.on_value_changed " +
            "is not implemented")


func get_value() -> float:
    Gs.logger.error(
            "Abstract SliderLabeledControlItem.get_value " +
            "is not implemented")
    return INF


func _update_control() -> void:
    value = get_value()
    if is_instance_valid(control):
        control.value = value


func create_control() -> Control:
    var slider: ScaffolderSlider = Gs.utils.add_scene(
            null,
            Gs.gui.SCAFFOLDER_SLIDER_SCENE,
            false,
            true)
    slider.editable = enabled
    slider.size_override.x = width
    slider.step = step
    slider.tick_count = tick_count
    slider.min_value = min_value
    slider.max_value = max_value
    slider.value = value
    slider.connect(
            "value_changed",
            self,
            "_on_slider_value_changed")
    return slider


func _on_slider_value_changed(_value: float) -> void:
    Gs.utils.give_button_press_feedback()
    value = control.value
    on_value_changed(value)
    emit_signal("item_changed")


func set_original_size(original_size: Vector2) -> void:
    width = original_size.x
    control.size_override.x = width

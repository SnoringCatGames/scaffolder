class_name SliderLabeledControlItem
extends LabeledControlItem

var TYPE := LabeledControlItem.SLIDER

var value: float
var min_value: float
var max_value: float
var step := 0.0

func _init(
        label: String,
        description: String \
        ).(
        TYPE,
        label,
        description \
        ) -> void:
    pass

func on_value_changed(value: float) -> void:
    Gs.logger.error(
            "Abstract SliderLabeledControlItem.on_value_changed " +
            "is not implemented")

func get_value() -> bool:
    Gs.logger.error(
            "Abstract SliderLabeledControlItem.get_value " +
            "is not implemented")
    return false

func update_control() -> void:
    value = get_value()

func _create_control() -> Control:
    var slider := Slider.new()
    slider.min_value = min_value
    slider.max_value = max_value
    slider.value = value
    slider.editable = enabled
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

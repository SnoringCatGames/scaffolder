class_name DropdownLabeledControlItem
extends LabeledControlItem


var TYPE := LabeledControlItem.DROPDOWN

# Array<String>
var options: Array
var selected_index := -1


func _init(
        label: String,
        description: String,
        is_control_on_right_side := true
        ).(
        TYPE,
        label,
        description,
        is_control_on_right_side
        ) -> void:
    pass


func on_selected(
        selected_index: int,
        selected_text: String) -> void:
    Gs.logger.error(
            "Abstract DropdownLabeledControlItem.on_selected " +
            "is not implemented")


func get_selected_index() -> int:
    Gs.logger.error(
            "Abstract DropdownLabeledControlItem.get_selected_index " +
            "is not implemented")
    return -1


func _update_control() -> void:
    selected_index = get_selected_index()
    if is_instance_valid(control):
        control.select(selected_index)


func create_control() -> Control:
    var dropdown := OptionButton.new()
    dropdown.flat = true
    for option in options:
        dropdown.add_item(option)
    dropdown.select(selected_index)
    dropdown.disabled = !enabled
    dropdown.connect(
            "pressed",
            self,
            "_on_control_pressed")
    dropdown.connect(
            "item_selected",
            self,
            "_on_dropdown_item_selected")
    return dropdown


func _on_dropdown_item_selected(_option_index: int) -> void:
    Gs.utils.give_button_press_feedback()
    selected_index = control.selected
    on_selected(
            selected_index,
            options[selected_index])
    emit_signal("changed")

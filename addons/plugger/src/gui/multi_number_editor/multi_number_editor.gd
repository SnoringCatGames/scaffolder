tool
class_name MultiNumberEditor
extends VBoxContainer


signal property_changed

var keys: Array
var rounded := false
var step := 0.0
var label_width := 32.0
var padding_y := 0.0
var padding_x := 2.0

var values := {} setget _set_values
var _controls := {}

var _is_set_up := false


func set_up() -> void:
    _is_set_up = true
    
    self.add_constant_override("separation", padding_y)
    
    # Create the control for each number.
    for key in keys:
        var hbox := HBoxContainer.new()
        hbox.add_constant_override("separation", padding_x)
        self.add_child(hbox)
        
        var label := Label.new()
        label.text = key
        label.hint_tooltip = key
        label.mouse_filter = Control.MOUSE_FILTER_PASS
        label.rect_min_size.x = label_width
        label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        hbox.add_child(label)
        
        var control := SpinBox.new()
        control.rounded = rounded
        control.step = step
        control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        control.connect("value_changed", self, "_on_property_changed")
        hbox.add_child(control)
        
        _controls[key] = control
    
    _update_controls()


func _update_controls() -> void:
    if !_is_set_up:
        return
    for key in values:
        _controls[key].value = values[key]


func _set_values(new_values: Dictionary) -> void:
    values = new_values
    _update_controls()


func _get_values() -> Dictionary:
    var values := {}
    for key in _controls:
        values[key] = _controls[key].value
    return values


func _on_property_changed(value: float) -> void:
    emit_signal("property_changed")

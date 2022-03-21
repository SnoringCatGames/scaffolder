tool
class_name MultiNumberEditor
extends VBoxContainer


# FIXME: LEFT OFF HERE: ---------------------------------------------
# - Get things rendering and test what this control looks like.


signal property_changed

var keys: Array
var rounded := false
var step := 0.0
var default_value = 0.0
# FIXME: LEFT OFF HERE: -----------------------------
#var label_width := 32.0
#var padding := 2.0

var _controls := {}


func set_up() -> void:
    # Parse the default value.
    assert(default_value is int or \
            default_value is float or \
            default_value is Dictionary)
    var default_values := {}
    if default_value is Dictionary:
        assert(keys.size() == default_value.size())
        for key in keys:
            assert(default_value.has(key))
            default_values[key] = default_value[key]
    else:
        for key in keys:
            default_values[key] = default_value
    
    # Create the control for each number.
    for key in keys:
        # FIXME: LEFT OFF HERE: -----------------------------
#        var hbox := HBoxContainer.new()
#        hbox.add_constant_override("separation", padding)
#        self.add_child(hbox)
#
#        var label := Label.new()
#        label.rect_min_size.x = label_width
#        label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
#        hbox.add_child(label)
        
        var control := SpinBox.new()
        control.rounded = rounded
        control.step = step
        control.value = default_values[key]
        control.prefix = key
        control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        control.connect("value_changed", self, "_on_property_changed")
        self.add_child(control)
        
        _controls[key] = control


func _get_values() -> Dictionary:
    var values := {}
    for key in _controls:
        values[key] = _controls[key].value
    return values


func _on_property_changed(value: float) -> void:
    emit_signal("property_changed")

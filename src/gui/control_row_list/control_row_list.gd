tool
class_name LabeledControlList, \
"res://addons/scaffolder/assets/images/editor_icons/control_row_list.png"
extends VBoxContainer


signal item_changed(item)

export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var row_height := 48.0 setget _set_row_height
export var padding_horizontal := 10.0 setget _set_padding_horizontal
export var is_even_odd_color_swapped := false setget \
        _set_is_even_odd_color_swapped

# Array<ControlRow>
var items := [] setget _set_items
var even_row_color_override := Color.black setget _set_even_row_color_override

var _odd_row_style: StyleBoxEmpty
var _even_row_style: StyleBoxFlat


func _init() -> void:
    _odd_row_style = StyleBoxEmpty.new()
    
    _even_row_style = StyleBoxFlat.new()
    _set_even_row_color_override(even_row_color_override)


func _ready() -> void:
    _update_children()


func _update_children() -> void:
    for child in get_children():
        child.queue_free()
    
    for index in items.size():
        var style: StyleBox = \
                _odd_row_style if \
                (index % 2 == 0) == (!is_even_odd_color_swapped) else \
                _even_row_style
        var item: ControlRow = items[index]
        add_child(item.create_row(
                style,
                row_height,
                padding_horizontal,
                padding_horizontal))
    
    Sc.utils.set_mouse_filter_recursively(
            self,
            Control.MOUSE_FILTER_PASS)
    
    _set_font_size(font_size)


func find_index(label: String) -> int:
    for index in items.size():
        if items[index].label == label:
            return index
    Sc.logger.error("LabeledControlList.find_index")
    return -1


func find_item(label: String) -> Dictionary:
    return items[find_index(label)]


func _connect_item_changed_listeners() -> void:
    for item in items:
        item.connect("changed", self, "emit_signal", ["item_changed", item])


func _disconnect_item_changed_listeners() -> void:
    for item in items:
        item.disconnect("changed", self, "emit_signal")


func _set_items(value: Array) -> void:
    _disconnect_item_changed_listeners()
    items = value
    _connect_item_changed_listeners()
    for item in items:
        item.update_item()
    _update_children()


func _set_row_height(value: float) -> void:
    row_height = value
    _update_children()


func _set_padding_horizontal(value: float) -> void:
    padding_horizontal = value
    _update_children()


func _set_is_even_odd_color_swapped(value: bool) -> void:
    is_even_odd_color_swapped = value
    _update_children()


func _set_even_row_color_override(value: Color) -> void:
    even_row_color_override = value
    _even_row_style.bg_color = \
            even_row_color_override if \
            even_row_color_override != Color.black else \
            Sc.palette.get_color("zebra_stripe_even_row")


func _set_font_size(value: String) -> void:
    font_size = value
    for item in items:
        item.font_size = font_size

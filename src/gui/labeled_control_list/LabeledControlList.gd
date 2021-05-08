tool
class_name LabeledControlList, "res://addons/scaffolder/assets/images/editor_icons/LabeledControlList.png"
extends VBoxContainer

signal item_changed(item)

# Array<LabeledControlItem>
var items := [] setget _set_items,_get_items
var even_row_color := Gs.colors.zebra_stripe_even_row setget \
        _set_even_row_color,_get_even_row_color

export var font: Font setget _set_font,_get_font
export var row_height := 0.0 setget _set_row_height,_get_row_height
export var padding_horizontal := 8.0 setget \
        _set_padding_horizontal,_get_padding_horizontal

var _odd_row_style: StyleBoxEmpty
var _even_row_style: StyleBoxFlat

func _init() -> void:
    _odd_row_style = StyleBoxEmpty.new()
    
    _even_row_style = StyleBoxFlat.new()
    _even_row_style.bg_color = even_row_color

func _ready() -> void:
    _update_children()

func _update_children() -> void:
    for child in get_children():
        child.queue_free()
    
    for index in items.size():
        var style: StyleBox = \
                _odd_row_style if \
                index % 2 == 0 else \
                _even_row_style
        var item: LabeledControlItem = items[index]
        add_child(item.create_row(style, row_height, padding_horizontal))
    
    Gs.utils.set_mouse_filter_recursively(
            self,
            Control.MOUSE_FILTER_PASS)
    
    if font != null:
        _set_font_recursively(font, self)

func find_index(label: String) -> int:
    for index in items.size():
        if items[index].label == label:
            return index
    Gs.logger.error()
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

func _get_items() -> Array:
    return items

func _set_row_height(value: float) -> void:
    row_height = value
    _update_children()

func _get_row_height() -> float:
    return row_height

func _set_padding_horizontal(value: float) -> void:
    padding_horizontal = value
    _update_children()

func _get_padding_horizontal() -> float:
    return padding_horizontal

func _set_even_row_color(value: Color) -> void:
    even_row_color = value
    _even_row_style.bg_color = even_row_color

func _get_even_row_color() -> Color:
    return even_row_color

func _set_font(value: Font) -> void:
    var old_font := font
    if old_font != value:
        font = value
        if font != null:
            _set_font_recursively(font, self)

func _get_font() -> Font:
    return font

static func _set_font_recursively(
        font: Font,
        control: Node) -> void:
    if !(control is Control):
        return
    
    if control is Label or \
            control is CheckBox or \
            control is OptionButton:
        control.add_font_override("font", font)
    
    for child in control.get_children():
        _set_font_recursively(font, child)

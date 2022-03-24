tool
class_name FrameworkManifestRowGroup, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends FrameworkManifestAccordionPanel


const _ACCORDION_THEME := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_accordion_theme.tres")

var node: FrameworkManifestEditorNode
var indent_level: int
var indent_width: float

var group_body: Container
var group_buttons: FrameworkManifestArrayButtons


func set_up(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        row_height: float,
        indent_width: float,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    self.indent_level = indent_level
    self.indent_width = indent_width
    
    group_buttons = $AccordionHeader/MarginContainer/HBoxContainer/Buttons
    group_body = $AccordionBody/HBoxContainer/Body
    
    $AccordionBody/HBoxContainer/Indent.rect_min_size.x = indent_width
    $AccordionHeader.size_override = Vector2(0.0, row_height)
    
    var text: String
    if node.key is int:
        text = "[%d]" % node.key
    else:
        text = node.key.capitalize()
    $AccordionHeader/MarginContainer/HBoxContainer/Label.text = text
    $AccordionHeader/MarginContainer/HBoxContainer/Label.hint_tooltip = text
    $AccordionHeader/MarginContainer/HBoxContainer/Label \
            .rect_min_size.y = row_height
    
    self.is_open = false
    
    if node.type == TYPE_ARRAY:
        group_buttons.set_up(
                node,
                self,
                label_width,
                control_width,
                padding)
    else:
        group_buttons.queue_free()


func update_zebra_stripes(index: int) -> int:
    index += 1
    
    _set_up_styles(index % 2 == 0)
    
    if _get_is_open():
        for row in group_body.get_children():
            if is_instance_valid(row):
                index = row.update_zebra_stripes(index)
    
    return index


func _set_up_styles(is_odd: bool) -> void:
    var modes := ["normal", "hover", "pressed", "focus", "disabled"]
    for mode in modes:
        var odd_style := _ACCORDION_THEME.get_stylebox(mode, "Button")
        var singleton_key: String = \
                "framework_manifest_row_group_even_%s" % mode
        if !Singletons.has_value(singleton_key):
            var even_style := StyleBoxFlat.new()
            even_style.bg_color = Color(
                    odd_style.bg_color.r,
                    odd_style.bg_color.g,
                    odd_style.bg_color.b,
                    odd_style.bg_color.a + 0.05)
            Singletons.set_value(singleton_key, even_style)
        var even_style: StyleBoxFlat = Singletons.get_value(singleton_key)
        
        var current_style := \
                odd_style if \
                is_odd else \
                even_style
        $AccordionHeader.add_stylebox_override(mode, current_style)

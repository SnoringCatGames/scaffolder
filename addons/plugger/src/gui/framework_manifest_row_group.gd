tool
class_name FrameworkManifestRowGroup, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends PluginAccordionPanel


const _ACCORDION_THEME := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/accordion/plugin_accordion_theme.tres")

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
    
    node.connect("is_changed_changed", self, "_on_is_changed_changed")
    
    group_buttons = $AccordionHeader/MarginContainer/HBoxContainer/Buttons
    group_body = $AccordionBody/HBoxContainer/Body
    
    $AccordionBody/HBoxContainer/Indent.rect_min_size.x = indent_width
    $AccordionHeader.size_override = Vector2(0.0, row_height)
    
    $AccordionHeader/MarginContainer/HBoxContainer/ResetButton \
            .button_size = row_height * Vector2.ONE
    $AccordionHeader/MarginContainer/HBoxContainer/ResetButton \
            .texture_size = row_height * Vector2.ONE * 0.5
    $AccordionHeader/MarginContainer/HBoxContainer/ResetButton \
            .visible = node.is_changed
    
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


func open_recursively() -> void:
    self._set_is_open(true)
    for child in group_body.get_children():
        child.open_recursively()


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


func load_open_rows(open_rows: Dictionary) -> void:
    for open_row_key in open_rows:
        var row = _get_row_with_key(open_row_key)
        if is_instance_valid(row) and \
                row.has_method("load_open_rows"):
            row.is_open = true
            row.load_open_rows(open_rows[open_row_key])


func get_open_rows() -> Dictionary:
    var open_rows := {}
    for row in group_body.get_children():
        if is_instance_valid(row) and \
                row.has_method("load_open_rows") and \
                row.is_open:
            open_rows[row.node.key] = row.get_open_rows()
    return open_rows


func _get_row_with_key(key):
    for row in group_body.get_children():
        if is_instance_valid(row) and \
                row.node.key == key:
            return row
    return null


func _on_is_changed_changed(is_changed: bool) -> void:
    $AccordionHeader/MarginContainer/HBoxContainer/ResetButton \
            .visible = is_changed


func _on_reset_changes_pressed() -> void:
    node.reset_changes()
    $AccordionHeader/MarginContainer/HBoxContainer/ResetButton.visible = false

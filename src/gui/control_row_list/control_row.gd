class_name ControlRow
extends Reference


signal changed

enum {
    TEXT,
    CHECKBOX,
    DROPDOWN,
    SLIDER,
    HEADER,
    CUSTOM,
}

const ENABLED_ALPHA := 1.0
const DISABLED_ALPHA := 0.3

var font_size := "M" setget _set_font_size

var control: Control
var description_button: ScaffolderTextureButton
var label_control: ScaffolderLabel

var label: String
var type: int
var description: String
var is_control_on_right_side: bool
var renders_label: bool
var enabled := true
var is_in_hud := false


func _init(
        type: int,
        label: String,
        description: String,
        is_control_on_right_side := true,
        renders_label := true) -> void:
    self.type = type
    self.label = label
    self.description = description
    self.is_control_on_right_side = is_control_on_right_side
    self.renders_label = renders_label


func get_is_enabled() -> bool:
    Sc.logger.error(
            "Abstract ControlRow.get_is_enabled is not implemented")
    return false


func _update_control() -> void:
    Sc.logger.error(
            "Abstract ControlRow._update_control is not implemented")


func create_control() -> Control:
    Sc.logger.error(
            "Abstract ControlRow.create_control is not implemented")
    return null


func update_item() -> void:
    enabled = get_is_enabled()
    _update_control()


func create_row(
        style: StyleBox,
        height: float,
        inner_padding_horizontal: float,
        outer_padding_horizontal: float,
        includes_description := true) -> PanelContainer:
    var row := PanelContainer.new()
    row.add_stylebox_override("panel", style)
    
    var hbox := HBoxContainer.new()
    hbox.add_constant_override("separation", 0)
    row.add_child(hbox)
    
    var spacer1: Spacer = Sc.utils.add_scene(
            hbox, Sc.gui.SPACER_SCENE, true, true)
    spacer1.size = Vector2(outer_padding_horizontal, height)
    
    if renders_label:
        label_control = Sc.utils.add_scene(
                null, Sc.gui.SCAFFOLDER_LABEL_SCENE, false, true)
        label_control.text = label
        label_control.modulate.a = \
                ENABLED_ALPHA if \
                self.enabled else \
                DISABLED_ALPHA
        label_control.align = Label.ALIGN_LEFT
        label_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        label_control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    if description != "" and \
            includes_description:
        description_button = Sc.utils.add_scene(
                null, Sc.gui.SCAFFOLDER_TEXTURE_BUTTON_SCENE, false, true)
        description_button.texture_key = "about_circle"
        description_button.texture_scale = Vector2(2.0, 2.0)
        description_button.size_override = \
                Sc.images.about_circle_normal.get_size() * \
                description_button.texture_scale
        description_button.expands_texture = false
        description_button.connect(
                "pressed",
                self,
                "_on_description_button_pressed",
                [
                    label,
                    description
                ])
        description_button.size_flags_horizontal = \
                Control.SIZE_SHRINK_CENTER
        description_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    var spacer3: Spacer = Sc.utils.add_scene(
            null, Sc.gui.SPACER_SCENE, false, true)
    spacer3.size = Vector2(inner_padding_horizontal * 2.0, height)
    
    if self.type != HEADER:
        var control := create_control()
        control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        self.control = control
    else:
        if is_instance_valid(label_control):
            label_control.align = Label.ALIGN_CENTER
    
    if is_control_on_right_side:
        if is_instance_valid(label_control):
            hbox.add_child(label_control)
        if is_instance_valid(description_button):
            hbox.add_child(description_button)
        if is_instance_valid(label_control) or \
                is_instance_valid(description_button):
            hbox.add_child(spacer3)
        if is_instance_valid(control):
            control.size_flags_horizontal = Control.SIZE_SHRINK_END
            hbox.add_child(control)
    else:
        if is_instance_valid(control):
            control.size_flags_horizontal = 0
            hbox.add_child(control)
        if is_instance_valid(label_control) or \
                is_instance_valid(description_button):
            hbox.add_child(spacer3)
        if is_instance_valid(label_control):
            hbox.add_child(label_control)
        if is_instance_valid(description_button):
            hbox.add_child(description_button)
    
    var spacer2: Spacer = Sc.utils.add_scene(
            hbox, Sc.gui.SPACER_SCENE, true, true)
    spacer2.size = Vector2(outer_padding_horizontal, height)
    
    # Set mouse-filter to pass, so the player can still scroll with dragging.
    for node in [
                row,
                hbox,
                label_control,
                description_button,
                spacer1,
                spacer2,
                spacer3,
            ]:
        if is_instance_valid(node):
            node.mouse_filter = Control.MOUSE_FILTER_PASS
    
    _set_font_size(font_size)
    
    return row


func _on_control_pressed() -> void:
    pass


func _on_description_button_pressed(
        label: String,
        description: String) -> void:
    Sc.nav.open(
            "notification",
            ScreenTransition.DEFAULT,
            {
                header_text = label,
                is_back_button_shown = true,
                body_text = description,
                close_button_text = "OK",
                body_alignment = BoxContainer.ALIGN_BEGIN,
            })


func _get_alpha() -> float:
    return ENABLED_ALPHA if \
            enabled else \
            DISABLED_ALPHA


func _set_font_size(value: String) -> void:
    font_size = value
    
    var font: Font = Sc.gui.get_font(
            font_size,
            false,
            false,
            false)
    
    if is_instance_valid(control):
        if control is ScaffolderLabel or \
                control is ScaffolderButton:
            control.font_size = font_size
        else:
            control.add_font_override("font", font)
    
    if is_instance_valid(label_control):
        label_control.font_size = font_size

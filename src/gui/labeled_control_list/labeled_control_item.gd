class_name LabeledControlItem
extends Reference


signal changed

enum {
    TEXT,
    CHECKBOX,
    DROPDOWN,
    SLIDER,
    HEADER,
}

const ABOUT_ICON_NORMAL := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_normal.png")
const ABOUT_ICON_HOVER := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_hover.png")
const ABOUT_ICON_ACTIVE := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_active.png")

const ENABLED_ALPHA := 1.0
const DISABLED_ALPHA := 0.3

var control: Control
var label: String
var type: int
var description: String
var is_control_on_right_side: bool
var enabled := true


func _init(
        type: int,
        label: String,
        description: String,
        is_control_on_right_side := true) -> void:
    self.type = type
    self.label = label
    self.description = description
    self.is_control_on_right_side = is_control_on_right_side


func get_is_enabled() -> bool:
    Gs.logger.error(
            "Abstract LabeledControlItem.get_is_enabled is not implemented")
    return false


func _update_control() -> void:
    Gs.logger.error(
            "Abstract LabeledControlItem._update_control is not implemented")


func create_control() -> Control:
    Gs.logger.error(
            "Abstract LabeledControlItem.create_control is not implemented")
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
    
    var spacer1: Spacer = Gs.utils.add_scene(
            hbox, Gs.gui.SPACER_SCENE, true, true)
    spacer1.size = Vector2(outer_padding_horizontal, height)
    
    var label := Label.new()
    label.text = self.label
    label.modulate.a = \
            ENABLED_ALPHA if \
            self.enabled else \
            DISABLED_ALPHA
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    var description_button: ScaffolderTextureButton
    if self.description != "" and \
            includes_description:
        description_button = Gs.utils.add_scene(
                null, Gs.gui.SCAFFOLDER_TEXTURE_BUTTON_SCENE, false, true)
        description_button.texture_normal = ABOUT_ICON_NORMAL
        description_button.texture_hover = ABOUT_ICON_HOVER
        description_button.texture_pressed = ABOUT_ICON_ACTIVE
        description_button.size_override = ABOUT_ICON_NORMAL.get_size()
        description_button.texture_scale = Vector2.ONE
        description_button.expands_texture = false
        description_button.connect(
                "pressed",
                self,
                "_on_description_button_pressed",
                [
                    self.label,
                    self.description
                ])
        description_button.size_flags_horizontal = \
                Control.SIZE_SHRINK_CENTER
        description_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    var spacer3: Spacer = Gs.utils.add_scene(
            null, Gs.gui.SPACER_SCENE, false, true)
    spacer3.size = Vector2(inner_padding_horizontal * 2.0, height)
    
    if self.type != HEADER:
        var control := create_control()
        control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        self.control = control
    else:
        label.align = Label.ALIGN_CENTER
    
    if is_control_on_right_side:
        hbox.add_child(label)
        if is_instance_valid(description_button):
            hbox.add_child(description_button)
        hbox.add_child(spacer3)
        if is_instance_valid(control):
            control.size_flags_horizontal = Control.SIZE_SHRINK_END
            hbox.add_child(control)
    else:
        if is_instance_valid(control):
            control.size_flags_horizontal = 0
            hbox.add_child(control)
        hbox.add_child(spacer3)
        hbox.add_child(label)
        if is_instance_valid(description_button):
            hbox.add_child(description_button)
    
    var spacer2: Spacer = Gs.utils.add_scene(
            hbox, Gs.gui.SPACER_SCENE, true, true)
    spacer2.size = Vector2(outer_padding_horizontal, height)
    
    # Set mouse-filter to pass, so the user can still scroll with dragging.
    for node in [
                row,
                hbox,
                label,
                description_button,
                control,
                spacer1,
            ]:
        if is_instance_valid(node):
            node.mouse_filter = Control.MOUSE_FILTER_PASS
    
    return row


func _on_control_pressed() -> void:
    pass


func _on_description_button_pressed(
        label: String,
        description: String) -> void:
    Gs.nav.open(
            "notification",
            false,
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

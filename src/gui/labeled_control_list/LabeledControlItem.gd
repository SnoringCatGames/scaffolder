class_name LabeledControlItem
extends Reference

signal changed

const ABOUT_ICON_NORMAL := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_normal.png")
const ABOUT_ICON_HOVER := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_hover.png")
const ABOUT_ICON_ACTIVE := \
        preload("res://addons/scaffolder/assets/images/gui/about_icon_active.png")

const SCAFFOLDER_TEXTURE_BUTTON_SCENE_PATH := \
        "res://addons/scaffolder/src/gui/ScaffolderTextureButton.tscn"

const ENABLED_ALPHA := 1.0
const DISABLED_ALPHA := 0.3

enum {
    TEXT,
    CHECKBOX,
    DROPDOWN,
    SLIDER,
    HEADER,
}

var control: Control
var label: String
var type: int
var description: String
var enabled := true

func _init(
        type: int,
        label: String,
        description: String) -> void:
    self.type = type
    self.label = label
    self.description = description

func get_is_enabled() -> bool:
    Gs.logger.error(
            "Abstract LabeledControlItem.get_is_enabled is not implemented")
    return false

func _update_control() -> void:
    Gs.logger.error(
            "Abstract LabeledControlItem._update_control is not implemented")

func _create_control() -> Control:
    Gs.logger.error(
            "Abstract LabeledControlItem._create_control is not implemented")
    return null

func update_item() -> void:
    enabled = get_is_enabled()
    _update_control()

func create_row(
        style: StyleBox,
        height: float,
        padding_horizontal: float) -> PanelContainer:
    var row := PanelContainer.new()
    row.add_stylebox_override("panel", style)
    
    var hbox := HBoxContainer.new()
    hbox.rect_min_size.y = height * Gs.gui_scale
    hbox.add_constant_override("separation", 0)
    row.add_child(hbox)
    
    var spacer1 := Control.new()
    spacer1.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    spacer1.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    spacer1.rect_min_size.x = padding_horizontal
    hbox.add_child(spacer1)
    
    var label := Label.new()
    label.text = self.label
    label.modulate.a = \
            ENABLED_ALPHA if \
            self.enabled else \
            DISABLED_ALPHA
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    hbox.add_child(label)
    
    if self.description != "":
        var description_button: ScaffolderTextureButton = \
                Gs.utils.add_scene(
                        hbox, 
                        SCAFFOLDER_TEXTURE_BUTTON_SCENE_PATH,
                        true,
                        true)
        description_button.texture_normal = ABOUT_ICON_NORMAL
        description_button.texture_hover = ABOUT_ICON_HOVER
        description_button.texture_pressed = ABOUT_ICON_ACTIVE
        description_button.rect_min_size = \
                ABOUT_ICON_NORMAL.get_size() * Gs.gui_scale
        description_button.texture_scale = \
                Vector2(Gs.gui_scale, Gs.gui_scale)
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
        
        var spacer3 := Control.new()
        spacer3.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        spacer3.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        spacer3.rect_min_size.x = padding_horizontal * 2.0 * Gs.gui_scale
        hbox.add_child(spacer3)
    
    if self.type != HEADER:
        var control := _create_control()
        self.control = control
        control.size_flags_horizontal = Control.SIZE_SHRINK_END
        control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        hbox.add_child(control)
    else:
        label.align = Label.ALIGN_CENTER
    
    var spacer2 := Control.new()
    spacer2.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    spacer2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    spacer2.rect_min_size.x = padding_horizontal
    hbox.add_child(spacer2)
    
    return row

func _on_control_pressed() -> void:
    Gs.utils.give_button_press_feedback()

func _on_description_button_pressed(
        label: String,
        description: String) -> void:
    Gs.utils.give_button_press_feedback()
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

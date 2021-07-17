tool
class_name LevelSelectItemUnlockedHeader
extends Button


const PADDING := Vector2(16.0, 8.0)

var level_id: String

var normal_stylebox: StyleBoxFlatScalable
var hover_stylebox: StyleBoxFlatScalable
var pressed_stylebox: StyleBoxFlatScalable


func _enter_tree() -> void:
    _init_children()


func _exit_tree() -> void:
    _destroy()


func _destroy() -> void:
    if is_instance_valid(normal_stylebox):
        normal_stylebox._destroy()
    if is_instance_valid(hover_stylebox):
        hover_stylebox._destroy()
    if is_instance_valid(pressed_stylebox):
        pressed_stylebox._destroy()


func _init_children() -> void:
    _destroy()
    
    $HBoxContainer/Caret.texture = Sc.icons.left_caret_normal
    $HBoxContainer/Caret.texture_scale = Vector2(3.0, 3.0)
    $HBoxContainer/Caret/TextureRect.rect_pivot_offset = \
            AccordionPanel.CARET_SIZE_DEFAULT / 2.0
    $HBoxContainer/Caret/TextureRect.rect_rotation = \
            AccordionPanel.CARET_ROTATION_CLOSED
    
    add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("normal", "OptionButton"))
    add_stylebox_override(
            "hover",
            Sc.gui.theme.get_stylebox("hover", "OptionButton"))
    add_stylebox_override(
            "pressed",
            Sc.gui.theme.get_stylebox("pressed", "OptionButton"))
    add_stylebox_override(
            "disabled",
            Sc.gui.theme.get_stylebox("disabled", "OptionButton"))
    add_stylebox_override(
            "focus",
            Sc.gui.theme.get_stylebox("focus", "OptionButton"))
    
    Sc.utils.set_mouse_filter_recursively(
            self,
            Control.MOUSE_FILTER_IGNORE)


func update_size(header_size: Vector2) -> void:
    rect_min_size = header_size
    
    $HBoxContainer.add_constant_override(
            "separation",
            PADDING.x * Sc.gui.scale)
    $HBoxContainer.rect_min_size = header_size
    $HBoxContainer.rect_size = header_size
    
    $HBoxContainer/Caret.texture_scale = AccordionPanel.CARET_SCALE
    
    rect_size = header_size


func update_is_unlocked(is_unlocked: bool) -> void:
    visible = is_unlocked
    
    var config: Dictionary = \
            Sc.level_config.get_level_config(level_id)
    var display_number_offset: int = \
            -Sc.level_config.test_level_count - 1 if \
            config.is_test_level else \
            -Sc.level_config.test_level_count
    var display_number: int = config.number + display_number_offset
    $HBoxContainer/LevelNumber.text = str(display_number) + "."
    $HBoxContainer/LevelName.text = config.name


func update_caret_rotation(rotation: float) -> void:
    $HBoxContainer/Caret/TextureRect.rect_rotation = rotation

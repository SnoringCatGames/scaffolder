tool
class_name LevelSelectItemUnlockedHeader, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends Button


const PADDING := Vector2(16.0, 8.0)

var level_id: String


func _ready() -> void:
    _init_children()


func _init_children() -> void:
    $HBoxContainer/Caret.texture_scale = Vector2(3.0, 3.0)
    $HBoxContainer/Caret/TextureRect.rect_pivot_offset = \
            AccordionHeader.CARET_SIZE_DEFAULT / 2.0
    $HBoxContainer/Caret/TextureRect.rect_rotation = \
            AccordionHeader.CARET_ROTATION_CLOSED
    
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
    
    $HBoxContainer/Caret.texture_scale = AccordionHeader.CARET_SCALE
    
    for child in $HBoxContainer.get_children():
        Sc.gui.scale_gui_recursively(child)
    
    rect_size = header_size


func update_is_unlocked(is_unlocked: bool) -> void:
    visible = is_unlocked
    
    var config: Dictionary = \
            Sc.levels.get_level_config(level_id)
    var display_number_offset: int = \
            -Sc.levels.test_level_count - 1 if \
            config.is_test_level else \
            -Sc.levels.test_level_count
    var display_number: int = config.number + display_number_offset
    $HBoxContainer/LevelNumber.text = str(display_number) + "."
    $HBoxContainer/LevelName.text = config.name


func update_caret_rotation(rotation: float) -> void:
    $HBoxContainer/Caret/TextureRect.rect_rotation = rotation

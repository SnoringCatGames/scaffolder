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
    
    $HBoxContainer/Caret.texture = Gs.icons.left_caret_normal
    $HBoxContainer/Caret.texture_scale = Vector2(3.0, 3.0)
    $HBoxContainer/Caret/TextureRect.rect_pivot_offset = \
            AccordionPanel.CARET_SIZE_DEFAULT / 2.0
    $HBoxContainer/Caret/TextureRect.rect_rotation = \
            AccordionPanel.CARET_ROTATION_CLOSED
    
    normal_stylebox = Gs.styles.create_stylebox_scalable({
        bg_color = Gs.colors.dropdown_normal,
        corner_radius = Gs.styles.dropdown_corner_radius,
        corner_detail = Gs.styles.dropdown_corner_detail,
        shadow_size = Gs.styles.dropdown_shadow_size,
        border_width = Gs.styles.dropdown_border_width,
        border_color = Gs.colors.dropdown_border,
    })
    hover_stylebox = Gs.styles.create_stylebox_scalable({
        bg_color = Gs.colors.dropdown_hover,
        corner_radius = Gs.styles.dropdown_corner_radius,
        corner_detail = Gs.styles.dropdown_corner_detail,
        shadow_size = Gs.styles.dropdown_shadow_size,
        border_width = Gs.styles.dropdown_border_width,
        border_color = Gs.colors.dropdown_border,
    })
    pressed_stylebox = Gs.styles.create_stylebox_scalable({
        bg_color = Gs.colors.dropdown_pressed,
        corner_radius = Gs.styles.dropdown_corner_radius,
        corner_detail = Gs.styles.dropdown_corner_detail,
        shadow_size = Gs.styles.dropdown_shadow_size,
        border_width = Gs.styles.dropdown_border_width,
        border_color = Gs.colors.dropdown_border,
    })
    
    add_stylebox_override("normal", normal_stylebox)
    add_stylebox_override("hover", hover_stylebox)
    add_stylebox_override("pressed", pressed_stylebox)
    
    Gs.utils.set_mouse_filter_recursively(
            self,
            Control.MOUSE_FILTER_IGNORE)


func update_size(header_size: Vector2) -> void:
    rect_min_size = header_size
    
    $HBoxContainer.add_constant_override(
            "separation",
            PADDING.x * Gs.gui.scale)
    $HBoxContainer.rect_min_size = header_size
    $HBoxContainer.rect_size = header_size
    
    $HBoxContainer/Caret.texture_scale = AccordionPanel.CARET_SCALE
    
    rect_size = header_size


func update_is_unlocked(is_unlocked: bool) -> void:
    visible = is_unlocked
    
    var config: Dictionary = \
            Gs.level_config.get_level_config(level_id)
    var display_number_offset: int = \
            -Gs.level_config.test_level_count - 1 if \
            config.is_test_level else \
            -Gs.level_config.test_level_count
    var display_number: int = config.number + display_number_offset
    $HBoxContainer/LevelNumber.text = str(display_number) + "."
    $HBoxContainer/LevelName.text = config.name


func update_caret_rotation(rotation: float) -> void:
    $HBoxContainer/Caret/TextureRect.rect_rotation = rotation

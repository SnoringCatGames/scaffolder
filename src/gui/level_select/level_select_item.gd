tool
class_name LevelSelectItem
extends Control


signal toggled
signal pressed

const HEADER_HEIGHT := 56.0
const FADE_TWEEN_DURATION := 0.3

export var level_id := "" setget _set_level_id,_get_level_id
export var is_open: bool setget _set_is_open,_get_is_open

var locked_header: LevelSelectItemLockedHeader
var unlocked_header: LevelSelectItemUnlockedHeader
var accordion: AccordionPanel
var body: LevelSelectItemBody

var is_unlocked := false
var is_new_unlocked_item := false


func _ready() -> void:
    _init_children()
    call_deferred("update")


func _process(_delta: float) -> void:
    rect_min_size.y = \
            $HeaderWrapper.rect_min_size.y + \
            $AccordionPanel.rect_min_size.y


func _init_children() -> void:
    locked_header = $HeaderWrapper/LevelSelectItemLockedHeader
    unlocked_header = $HeaderWrapper/LevelSelectItemUnlockedHeader
    accordion = $AccordionPanel
    body = $AccordionPanel/LevelSelectItemBody
    
    locked_header.init_children()
    unlocked_header.init_children()
    
    accordion.extra_scroll_height_for_custom_header = HEADER_HEIGHT
    
    rect_min_size.x = Gs.gui.screen_body_width
    set_meta("gs_rect_min_size", rect_min_size)
    
    update_gui_scale()


func update_gui_scale() -> bool:
    var original_rect_min_size: Vector2 = get_meta("gs_rect_min_size")
    
    rect_min_size = original_rect_min_size * Gs.gui.scale
    rect_size = rect_min_size
    
    var header_size := Vector2(
            rect_min_size.x,
            HEADER_HEIGHT * Gs.gui.scale)
    $HeaderWrapper.rect_min_size = header_size
    $HeaderWrapper.rect_size = header_size
    locked_header.update_size(header_size)
    unlocked_header.update_size(header_size)
    
    accordion.rect_min_size.x = Gs.gui.screen_body_width
    body.rect_min_size.x = Gs.gui.screen_body_width
    accordion.set_meta("gs_rect_min_size", accordion.rect_min_size)
    body.set_meta("gs_rect_min_size", accordion.rect_min_size)
    
    accordion.update_gui_scale()
    
    return true


func update() -> void:
    if level_id == "":
        return
    
    locked_header.level_id = level_id
    unlocked_header.level_id = level_id
    body.level_id = level_id
    
    is_unlocked = \
            Gs.save_state.get_level_is_unlocked(level_id) and \
            !is_new_unlocked_item
    
    locked_header.update_is_unlocked(is_unlocked)
    unlocked_header.update_is_unlocked(is_unlocked)
    accordion.update()
    body.update()


func focus() -> void:
    if is_unlocked:
        $HeaderWrapper/LevelSelectItemUnlockedHeader.grab_focus()
    else:
        $HeaderWrapper/LevelSelectItemLockedHeader.grab_focus()


func toggle() -> void:
    if Gs.nav.get_current_screen_name() == "level_select":
        accordion.toggle()


func unlock() -> void:
    unlocked_header.visible = false
    unlocked_header.modulate.a = 0.0
    locked_header.unlock()


func _on_unlock_fade_finished(
        _object: Object,
        _key: NodePath,
        fade_tween: ScaffolderTween) -> void:
    fade_tween.queue_free()
    locked_header.visible = false
    unlocked_header.visible = true
    emit_signal("pressed")


func _set_level_id(value: String) -> void:
    level_id = value
    update()


func _get_level_id() -> String:
    return level_id


func _set_is_open(value: bool) -> void:
    accordion.is_open = value
    update()


func _get_is_open() -> bool:
    return accordion.is_open


func get_button() -> ScaffolderButton:
    return body.get_button()


func _on_LevelSelectItemUnlockedHeader_pressed() -> void:
    Gs.utils.give_button_press_feedback()
    emit_signal("pressed")


func _on_AccordionPanel_toggled() -> void:
    emit_signal("toggled")


func _on_AccordionPanel_caret_rotated(rotation: float) -> void:
    unlocked_header.update_caret_rotation(rotation)


func _on_LevelSelectItemLockedHeader_unlock_finished() -> void:
    locked_header.visible = true
    unlocked_header.visible = true
    var fade_tween := ScaffolderTween.new()
    locked_header.add_child(fade_tween)
    fade_tween.connect(
            "tween_completed",
            self,
            "_on_unlock_fade_finished",
            [fade_tween])
    fade_tween.interpolate_property(
            locked_header,
            "modulate:a",
            1.0,
            0.0,
            FADE_TWEEN_DURATION,
            "ease_in_out")
    fade_tween.interpolate_property(
            unlocked_header,
            "modulate:a",
            0.0,
            1.0,
            FADE_TWEEN_DURATION,
            "ease_in_out")
    fade_tween.start()
    Gs.time.set_timeout(funcref(Gs.audio, "play_sound"), 0.3, ["achievement"])

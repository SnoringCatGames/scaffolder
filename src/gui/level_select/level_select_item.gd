tool
class_name LevelSelectItem, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends Control


signal toggled
signal pressed

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
            $AccordionPanel.rect_size.y if \
            is_unlocked else \
            $LevelSelectItemLockedHeader.rect_size.y
    rect_size = rect_min_size


func _init_children() -> void:
    locked_header = $LevelSelectItemLockedHeader
    unlocked_header = \
            $AccordionPanel/AccordionHeader/LevelSelectItemUnlockedHeader
    accordion = $AccordionPanel
    body = $AccordionPanel/AccordionBody/LevelSelectItemBody
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    rect_min_size.x = Sc.gui.screen_body_width * Sc.gui.scale
    rect_size = rect_min_size
    
    accordion._on_gui_scale_changed()
    
    var header_size := Vector2(
            Sc.gui.screen_body_width * Sc.gui.scale,
            Sc.gui.button_height * Sc.gui.scale)
    locked_header.update_size(header_size)
    unlocked_header.update_size(header_size)
    
    return true


func update() -> void:
    if level_id == "":
        return
    
    locked_header.level_id = level_id
    unlocked_header.level_id = level_id
    body.level_id = level_id
    
    is_unlocked = \
            Sc.save_state.get_level_is_unlocked(level_id) and \
            !is_new_unlocked_item
    
    locked_header.update_is_unlocked(is_unlocked)
    unlocked_header.update_is_unlocked(is_unlocked)
    accordion.update()
    body.update()
    
    locked_header.visible = !is_unlocked
    accordion.visible = is_unlocked


func focus() -> void:
    if is_unlocked:
        unlocked_header.grab_focus()
    else:
        locked_header.grab_focus()


func toggle() -> void:
    if Sc.nav.get_current_screen_name() == "level_select":
        accordion.toggle()


func unlock() -> void:
    accordion.visible = false
    unlocked_header.modulate.a = 0.0
    locked_header.unlock()


func _on_unlock_fade_finished(fade_tween: ScaffolderTween) -> void:
    fade_tween.queue_free()
    locked_header.visible = false
    accordion.visible = true
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


func _on_AccordionHeader_pressed() -> void:
    Sc.utils.give_button_press_feedback()
    emit_signal("pressed")


func _on_AccordionPanel_toggled() -> void:
    emit_signal("toggled")


func _on_AccordionPanel_caret_rotated(rotation: float) -> void:
    unlocked_header.update_caret_rotation(rotation)


func _on_LevelSelectItemLockedHeader_unlock_finished() -> void:
    is_new_unlocked_item = false
    update()
    locked_header.visible = true
    accordion.visible = true
    
    var fade_tween := ScaffolderTween.new(locked_header)
    fade_tween.connect(
            "tween_all_completed",
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
    Sc.time.set_timeout(Sc.audio, "play_sound", 0.3, ["achievement"])

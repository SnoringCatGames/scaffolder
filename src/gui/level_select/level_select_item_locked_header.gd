tool
class_name LevelSelectItemLockedHeader, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends Control


signal unlock_finished

const LOCK_LOW_PART_DELAY := 0.2
const LOCK_HIGH_PART_DELAY := 0.15
const HINT_PULSE_DURATION := 2.0

var level_id: String
var hint_tween: ScaffolderTween

var previous_gui_scale: float

var header_stylebox: StyleBoxFlatScalable
var hint_stylebox: StyleBoxFlatScalable


func _enter_tree() -> void:
    _init_children()


func _ready() -> void:
    hint_tween = ScaffolderTween.new($HintWrapper/Hint)


func _exit_tree() -> void:
    _destroy()


func _destroy() -> void:
    if is_instance_valid(header_stylebox):
        header_stylebox._destroy()
    if is_instance_valid(hint_stylebox):
        hint_stylebox._destroy()


func _init_children() -> void:
    _destroy()
    
    $HintWrapper.modulate.a = 0.0
    previous_gui_scale = Sc.gui.scale
    
    header_stylebox = Sc.styles.create_stylebox_scalable({
        stylebox = get_stylebox("panel"),
        corner_radius = Sc.styles.dropdown_corner_radius,
        corner_detail = Sc.styles.dropdown_corner_detail,
        shadow_size = Sc.styles.dropdown_shadow_size,
        border_width = Sc.styles.dropdown_border_width,
        border_color = Sc.palette.get_color("dropdown_border"),
    }, true)
    add_stylebox_override("panel", header_stylebox)
    
    hint_stylebox = Sc.styles.create_stylebox_scalable({
        stylebox = get_stylebox("panel"),
        corner_radius = Sc.styles.dropdown_corner_radius,
        corner_detail = Sc.styles.dropdown_corner_detail,
        shadow_size = Sc.styles.dropdown_shadow_size,
        border_width = Sc.styles.dropdown_border_width,
        border_color = Sc.palette.get_color("dropdown_border"),
    }, true)
    $HintWrapper.add_stylebox_override("panel", hint_stylebox)


func update_size(header_size: Vector2) -> bool:
    if !$HintWrapper/Hint.has_meta("sc_rect_min_size"):
        $HintWrapper/Hint.set_meta(
                "sc_rect_min_size", $HintWrapper/Hint.rect_min_size)
    var original_hint_rect_min_size: Vector2 = \
            $HintWrapper/Hint.get_meta("sc_rect_min_size")
    
    rect_min_size = header_size
    
    $HintWrapper/Hint.rect_min_size = \
            original_hint_rect_min_size * Sc.gui.scale
    $HintWrapper/Hint.rect_size = header_size
    $HintWrapper.rect_size = header_size
    $LockAnimation._on_gui_scale_changed()
    
    rect_size = header_size
    
    return true


func update_is_unlocked(is_unlocked: bool) -> void:
    var unlock_hint_message: String = \
            Sc.levels.get_unlock_hint(level_id)
    var is_next_level_to_unlock: bool = \
            Sc.levels.get_next_level_to_unlock() == level_id
    
    $HintWrapper/Hint.text = unlock_hint_message
    visible = !is_unlocked
    
    # TODO: Remove?
    var is_unlock_pulse_auto_shown := false
#    var is_unlock_pulse_auto_shown := \
#            unlock_hint_message != "" and \
#            is_next_level_to_unlock
    if is_unlock_pulse_auto_shown:
        # Finish the unlock animation for the previous item before showing the
        # unlock hint for this item.
        var delay := 0.0
#        var delay := \
#                0.0 if \
#                !Sc.save_state.get_new_unlocked_levels().empty() else \
#                (0.3 + \
#                LOCK_LOW_PART_DELAY + \
#                LockAnimation.UNLOCK_DURATION + \
#                FADE_TWEEN_DURATION)
        Sc.time.set_timeout(self, "pulse_unlock_hint", delay)


func unlock() -> void:
    visible = true
    
    Sc.time.set_timeout($LockAnimation, "unlock", LOCK_LOW_PART_DELAY)
    
    Sc.time.set_timeout(
            Sc.audio, "play_sound", LOCK_LOW_PART_DELAY, ["lock_low"])
    Sc.time.set_timeout(
            Sc.audio,
            "play_sound",
            LOCK_LOW_PART_DELAY + LOCK_HIGH_PART_DELAY,
            ["lock_high"])


func pulse_unlock_hint() -> void:
    hint_tween.stop_all()
    var fade_in_duration := 0.3
    hint_tween.interpolate_property(
            $HintWrapper,
            "modulate:a",
            0.0,
            1.0,
            fade_in_duration,
            "ease_in_out")
    hint_tween.interpolate_property(
            $HintWrapper,
            "modulate:a",
            1.0,
            0.0,
            fade_in_duration,
            "ease_in_out",
            HINT_PULSE_DURATION - fade_in_duration)
    hint_tween.start()


func _on_LevelSelectItemLockedHeader_gui_input(event: InputEvent) -> void:
    var is_mouse_up: bool = \
            event is InputEventMouseButton and \
            !event.pressed and \
            event.button_index == BUTTON_LEFT
    var is_touch_up: bool = \
            (event is InputEventScreenTouch and \
                    !event.pressed)
    
    if is_mouse_up or is_touch_up:
        pulse_unlock_hint()


func _on_LockAnimation_unlock_finished() -> void:
    emit_signal("unlock_finished")

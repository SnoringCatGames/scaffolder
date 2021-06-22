class_name LockAnimation
extends Control


signal unlock_finished

const UNLOCK_DURATION := 0.8
const LOCK_SIZE := Vector2(32.0, 32.0)
const LOCK_SCALE := 1.0


func _ready() -> void:
    $Control/Node2D/AnimationPlayer.connect(
            "animation_finished",
            self,
            "_on_lock_animation_finished")


func update_gui_scale() -> bool:
    if !has_meta("gs_rect_size"):
        set_meta("gs_rect_position", rect_position)
        set_meta("gs_rect_size", rect_size)
        set_meta("gs_rect_min_size", rect_min_size)
    var original_rect_position: Vector2 = get_meta("gs_rect_position")
    var original_rect_size: Vector2 = get_meta("gs_rect_size")
    var original_rect_min_size: Vector2 = get_meta("gs_rect_min_size")

    rect_position.x = original_rect_position.x * Gs.gui.scale
    rect_min_size = original_rect_min_size * Gs.gui.scale
    rect_size = original_rect_size * Gs.gui.scale
    $Control.rect_position = -LOCK_SIZE * LOCK_SCALE * 0.5 * Gs.gui.scale
    $Control/Node2D.position = LOCK_SIZE * LOCK_SCALE * 0.5 * Gs.gui.scale
    $Control/Node2D/Lock.scale = \
            Vector2(LOCK_SCALE * Gs.gui.scale, LOCK_SCALE * Gs.gui.scale)
    return true


func play(name: String) -> void:
    assert(name == "Locked" or \
            name == "Unlocked" or \
            name == "Unlock")
    $Control/Node2D/AnimationPlayer.play(name)


func unlock() -> void:
    play("Unlock")


func _on_lock_animation_finished(name: String) -> void:
    if name == "Unlock":
        emit_signal("unlock_finished")

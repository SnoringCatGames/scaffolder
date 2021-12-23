tool
class_name LockAnimation, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
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
    
    set_meta("sc_rect_min_size", rect_min_size)


func _on_gui_scale_changed() -> bool:
    var original_rect_min_size: Vector2 = get_meta("sc_rect_min_size")

    rect_min_size = original_rect_min_size * Sc.gui.scale
    rect_size = rect_min_size
    $Control.rect_position = -LOCK_SIZE * LOCK_SCALE * 0.5 * Sc.gui.scale
    $Control/Node2D.position = LOCK_SIZE * LOCK_SCALE * 0.5 * Sc.gui.scale
    $Control/Node2D/Lock.scale = \
            Vector2(LOCK_SCALE * Sc.gui.scale, LOCK_SCALE * Sc.gui.scale)
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

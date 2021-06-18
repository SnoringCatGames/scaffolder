class_name FadeTransition
extends ColorRect


signal fade_completed

var _tween_id: int
var duration := 0.3
var is_transitioning := false


func _ready() -> void:
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()
    
    _set_cutoff(0)


func _on_resized() -> void:
    rect_size = get_viewport().size


func fade() -> void:
    is_transitioning = true
    _fade_out()


func _fade_out() -> void:
    Gs.time.clear_tween(_tween_id)
    _set_mask(Gs.gui.fade_out_transition_texture)
    _tween_id = Gs.time.tween_method(
            self,
            "_set_cutoff",
            1.0,
            0.0,
            duration / 2.0,
            "ease_in_weak",
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_fade_in"))


func _fade_in(
        _object: Object,
        _key: NodePath) -> void:
    Gs.time.clear_tween(_tween_id)
    _set_mask(Gs.gui.fade_in_transition_texture)
    _tween_id = Gs.time.tween_method(
            self,
            "_set_cutoff",
            0.0,
            1.0,
            duration / 2.0,
            "ease_out_weak",
            0.0,
            TimeType.APP_PHYSICS)


func _set_mask(value: Texture) -> void:
    material.set_shader_param(
            "mask",
            value)


func _set_cutoff(value: float) -> void:
    material.set_shader_param(
            "cutoff",
            value)


func _on_tween_complete(
        _object: Object,
        _key: NodePath) -> void:
    is_transitioning = false
    emit_signal("fade_completed")

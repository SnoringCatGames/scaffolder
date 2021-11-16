tool
class_name NotificationPanel
extends ScaffolderPanelContainer


# FIXME: LEFT OFF HERE: ----------------
# - Hook-up other closing conditions.
# - Fix HUD styling...


signal faded_in
signal faded_out
signal fade_out_started

var _data: NotificationData
var _target_position: Vector2


func _init() -> void:
    modulate.a = 0.0


func _ready() -> void:
    Sc.gui.record_gui_original_size_recursively(self)
    
    theme = Sc.gui.theme
    
    Sc.gui.add_gui_to_scale(self)
    
    _on_gui_scale_changed()


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    for child in Sc.utils.get_children_by_type(self, Control):
        Sc.gui.scale_gui_recursively(child)
    
    var min_size: Vector2 = \
            Sc.notify.get_panel_size(_data.size) if \
            _data != null else \
            Vector2.ZERO
    rect_min_size = min_size
    rect_size.x = rect_min_size.x
    
    var height := 0.0
    if $VBoxContainer/Header.visible:
        height += $VBoxContainer/Header.rect_size.y
    if $VBoxContainer/Body.visible:
        height += $VBoxContainer/Body.rect_size.y
    if $VBoxContainer/Spacer.visible:
        height += $VBoxContainer/Spacer.rect_size.y
    rect_size.y = height
    
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    _target_position.x = (viewport_size.x - rect_size.x) / 2.0
    _target_position.y = viewport_size.y - rect_size.y
    if _data != null and \
            _data.size != NotificationSize.FULL_WIDTH and \
            _data.size != NotificationSize.FULL_SCREEN:
        _target_position.y -= Sc.notify.margin_bottom
    rect_position = _target_position
    
    return true


func set_up(data: NotificationData) -> void:
    self._data = data
    
    $VBoxContainer/Header.text = _data.header_text
    $VBoxContainer/Body.text = _data.body_text
    
    $VBoxContainer/Header.visible = _data.header_text != ""
    $VBoxContainer/Body.visible = _data.body_text != ""
    $VBoxContainer/Spacer.visible = \
            _data.header_text != "" and \
            _data.body_text != ""
    
    _on_gui_scale_changed()


func open() -> void:
    var start_position: Vector2 = \
            _target_position - Sc.notify.slide_in_displacement
    var end_position := _target_position
    Sc.time.tween_property(
            self,
            "rect_position",
            start_position,
            end_position,
            Sc.notify.fade_in_duration,
            "ease_out",
            0.0,
            TimeType.APP_PHYSICS)
    Sc.time.tween_property(
            self,
            "modulate:a",
            0.0,
            Sc.notify.opacity,
            Sc.notify.fade_in_duration,
            "ease_in_out",
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_faded_in"))
    
    if _data.duration == NotificationDuration.SHORT:
        Sc.time.set_timeout(
                funcref(self, "close"),
                Sc.notify.fade_in_duration + Sc.notify.duration_short_sec)
    elif _data.duration == NotificationDuration.LONG:
        Sc.time.set_timeout(
                funcref(self, "close"),
                Sc.notify.fade_in_duration + Sc.notify.duration_long_sec)


func close() -> void:
    var start_position := _target_position
    var end_position: Vector2 = \
            _target_position - Sc.notify.slide_in_displacement
    Sc.time.tween_property(
            self,
            "rect_position",
            start_position,
            end_position,
            Sc.notify.fade_in_duration,
            "ease_in",
            0.0,
            TimeType.APP_PHYSICS)
    Sc.time.tween_property(
            self,
            "modulate:a",
            Sc.notify.opacity,
            0.0,
            Sc.notify.fade_out_duration,
            "ease_in_out",
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_faded_out"))
    emit_signal("fade_out_started")


func _on_faded_in() -> void:
    emit_signal("faded_in")


func _on_faded_out() -> void:
    emit_signal("faded_out")

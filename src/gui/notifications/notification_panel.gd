tool
class_name NotificationPanel
extends ScaffolderPanelContainer


signal faded_in
signal faded_out
signal fade_out_started

var _data: NotificationData
var _open_time := INF
var _target_position: Vector2


func _init() -> void:
    modulate.a = 0.0


func _ready() -> void:
    Sc.gui.add_gui_to_scale(self)
    _on_gui_scale_changed()


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    if (event is InputEventMouseButton or \
            event is InputEventScreenTouch or \
            event is InputEventKey) and \
            _data != null and \
            _data.duration == \
                NotificationDuration.CLOSED_WITH_TAP_ANYWHERE and \
            get_is_open() and \
            Sc.time.get_app_time() > \
                _open_time + Sc.notify.CLOSED_WITH_TAP_ANYWHERE_MIN_DELAY:
        close()


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
    if $VBoxContainer/HeaderWithCloseButton.visible:
        height += $VBoxContainer/HeaderWithCloseButton.rect_size.y
    if $VBoxContainer/HeaderWithoutCloseButton.visible:
        height += $VBoxContainer/HeaderWithoutCloseButton.rect_size.y
    if $VBoxContainer/Body.visible:
        height += $VBoxContainer/Body.rect_size.y
    if $VBoxContainer/Spacer.visible:
        height += $VBoxContainer/Spacer.rect_size.y
    rect_size.y = height
    
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    var size_type := _data.size if _data != null else NotificationsSize.MEDIUM
    match size_type:
        NotificationsSize.SMALL, \
        NotificationsSize.MEDIUM, \
        NotificationsSize.LARGE:
            _target_position.x = (viewport_size.x - rect_size.x) / 2.0
            _target_position.y = \
                    viewport_size.y - rect_size.y - Sc.notify.margin_bottom
        NotificationsSize.TOP_SIDE:
            _target_position.x = (viewport_size.x - rect_size.x) / 2.0
            _target_position.y = 0.0
        NotificationsSize.BOTTOM_SIDE:
            _target_position.x = (viewport_size.x - rect_size.x) / 2.0
            _target_position.y = viewport_size.y - rect_size.y
        NotificationsSize.LEFT_SIDE:
            _target_position.x = 0.0
            _target_position.y = (viewport_size.y - rect_size.y) / 2.0
        NotificationsSize.RIGHT_SIDE:
            _target_position.x = viewport_size.x - rect_size.x
            _target_position.y = (viewport_size.y - rect_size.y) / 2.0
        NotificationsSize.FULL_SCREEN:
            _target_position.x = 0.0
            _target_position.y = 0.0
        _:
            Sc.logger.print("NotificationPanel._on_gui_scale_changed")
    
    rect_position = _target_position
    
    return true


func set_up(data: NotificationData) -> void:
    self._data = data
    
    var active_header: Control
    var inactive_header: Control
    if _data.duration == NotificationDuration.CLOSED_WITH_CLOSE_BUTTON:
        active_header = $VBoxContainer/HeaderWithCloseButton
        inactive_header = $VBoxContainer/HeaderWithoutCloseButton
    else:
        active_header = $VBoxContainer/HeaderWithoutCloseButton
        inactive_header = $VBoxContainer/HeaderWithCloseButton
    
    $VBoxContainer/HeaderWithoutCloseButton.text = _data.header_text
    $VBoxContainer/HeaderWithCloseButton/ScaffolderLabel.text = \
            _data.header_text
    $VBoxContainer/Body.text = _data.body_text
    
    inactive_header.visible = false
    active_header.visible = _data.header_text != ""
    $VBoxContainer/Body.visible = _data.body_text != ""
    $VBoxContainer/Spacer.visible = \
            _data.header_text != "" and \
            _data.body_text != ""
    
    _on_gui_scale_changed()


func open() -> void:
    _open_time = Sc.time.get_app_time()
    
    var start_position: Vector2 = \
            _target_position - Sc.notify.slide_in_displacement * Sc.gui.scale
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
                self,
                "close",
                Sc.notify.fade_in_duration + Sc.notify.duration_short_sec)
    elif _data.duration == NotificationDuration.LONG:
        Sc.time.set_timeout(
                self,
                "close",
                Sc.notify.fade_in_duration + Sc.notify.duration_long_sec)


func close() -> void:
    if !get_is_open():
        return
    
    _open_time = INF
    
    var start_position := _target_position
    var end_position: Vector2 = \
            _target_position - Sc.notify.slide_in_displacement * Sc.gui.scale
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


func get_is_open() -> bool:
    return !is_inf(_open_time)


func _on_faded_in() -> void:
    emit_signal("faded_in")


func _on_faded_out() -> void:
    emit_signal("faded_out")


func _on_ScaffolderTextureButton_pressed() -> void:
    close()

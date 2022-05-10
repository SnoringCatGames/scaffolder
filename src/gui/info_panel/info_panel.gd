tool
class_name InfoPanel
extends ScaffolderPanelContainer


# FIXME: LEFT OFF HERE: -------------------------------------------
# - Set placement based on screen aspect ratio.
# - Listen for aspect ratio change.
# - Make width/height be one-third that of the screen, or a min value.
# - Header, close button, command buttons, cost per command button,
#   description text, some stats (health current/max, current energy rate
#   (+/-)), bot/station name, flavor text?.
# - Update manifest to use distinct values, rather than notification's values.


signal faded_in
signal faded_out
signal fade_out_started

var _data: InfoPanelData
var _target_position: Vector2
var _slide_in_displacement: Vector2
var _tween: ScaffolderTween

var is_open := false


func _init() -> void:
    modulate.a = 0.0
    _tween = ScaffolderTween.new(self)
    _tween.connect("tween_all_completed", self, "_on_transitioned")


func _ready() -> void:
    Sc.gui.add_gui_to_scale(self)
    _on_gui_scale_changed()


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    for child in Sc.utils.get_children_by_type(self, Control):
        Sc.gui.scale_gui_recursively(child)
    
    _set_content_margin_left_override(Sc.info_panel.past_screen_edge_overhang)
    _set_content_margin_top_override(Sc.info_panel.past_screen_edge_overhang)
    _set_content_margin_right_override(Sc.info_panel.past_screen_edge_overhang)
    _set_content_margin_bottom_override(Sc.info_panel.past_screen_edge_overhang)
    
    $VBoxContainer/ScaffolderPanelContainer.content_margin_left_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer.content_margin_top_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer.content_margin_right_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer.content_margin_bottom_override = \
            Sc.info_panel.content_margin
    
    $VBoxContainer/ScaffolderPanelContainer2.content_margin_left_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer2.content_margin_top_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer2.content_margin_right_override = \
            Sc.info_panel.content_margin
    $VBoxContainer/ScaffolderPanelContainer2.content_margin_bottom_override = \
            Sc.info_panel.content_margin
    
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    var is_screen_horizontal := viewport_size.x >= viewport_size.y
    
    var scaled_overhang: float = \
            Sc.info_panel.past_screen_edge_overhang * \
            Sc.styles.overlay_panel_nine_patch_scale * \
            Sc.gui.scale
    var scaled_border_width: float = \
            Sc.styles.overlay_panel_nine_patch_border_width * Sc.gui.scale
    var scaled_slide_in_distance: float = \
            Sc.info_panel.slide_in_distance * Sc.gui.scale
    
    var size: Vector2
    if is_screen_horizontal:
        size = Vector2(
                max(Sc.info_panel.min_depth * Sc.gui.scale,
                        viewport_size.x / 3.0) + scaled_overhang,
                viewport_size.y + scaled_overhang * 2.0)
        _target_position = Vector2(
                viewport_size.x - size.x + scaled_overhang,
                -scaled_overhang)
        _slide_in_displacement = Vector2(
                -scaled_slide_in_distance,
                0.0)
        _set_content_margin_left_override(scaled_border_width)
    else:
        size = Vector2(
                viewport_size.x + scaled_overhang * 2.0,
                max(Sc.info_panel.min_depth * Sc.gui.scale,
                        viewport_size.y / 3.0) + scaled_overhang)
        _target_position = Vector2(
                -scaled_overhang,
                viewport_size.y - size.y + scaled_overhang)
        _slide_in_displacement = Vector2(
                0.0,
                -scaled_slide_in_distance)
        _set_content_margin_top_override(scaled_border_width)
    
    rect_min_size = size
    rect_size = size
    rect_position = _target_position
    
    return true


func set_up(data: InfoPanelData) -> void:
    self._data = data
    
    var active_header: Control
    var inactive_header: Control
    if _data.includes_close_button:
        active_header = \
            $VBoxContainer/ScaffolderPanelContainer/HeaderWithCloseButton
        inactive_header = \
            $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/HeaderWithoutCloseButton
    else:
        active_header = \
            $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/HeaderWithoutCloseButton
        inactive_header = \
            $VBoxContainer/ScaffolderPanelContainer/HeaderWithCloseButton
    
    $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/HeaderWithoutCloseButton \
            .text = _data.header_text
    $VBoxContainer/ScaffolderPanelContainer/HeaderWithCloseButton/ScaffolderLabel \
            .text = _data.header_text
    
    $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/HeaderWithoutCloseButton \
            .add_color_override("font_color", Sc.palette.get_color("info_panel_header"))
    $VBoxContainer/ScaffolderPanelContainer/HeaderWithCloseButton/ScaffolderLabel \
            .add_color_override("font_color", Sc.palette.get_color("info_panel_header"))
    
    Sc.utils.clear_children(
            $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/ScrollContainer/Body)
    $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/ScrollContainer/Body \
            .add_child(_data.contents)
    
    inactive_header.visible = false
    active_header.visible = _data.header_text != ""
    $VBoxContainer/ScaffolderPanelContainer2/VBoxContainer/Spacer \
            .visible = _data.header_text != ""
    
    _on_gui_scale_changed()


func open() -> void:
    is_open = true
    
    var start_position := _target_position - _slide_in_displacement
    var end_position := _target_position
    _tween.stop_all()
    _tween.interpolate_property(
            self,
            "rect_position",
            start_position,
            end_position,
            Sc.info_panel.fade_in_duration,
            "ease_out",
            0.0,
            TimeType.APP_PHYSICS)
    _tween.interpolate_property(
            self,
            "modulate:a",
            0.0,
            Sc.info_panel.opacity,
            Sc.info_panel.fade_in_duration,
            "ease_in_out",
            0.0,
            TimeType.APP_PHYSICS)
    _tween.start()


func close() -> void:
    if !is_open:
        return
    
    is_open = false
    
    var start_position := _target_position
    var end_position := _target_position - _slide_in_displacement
    _tween.stop_all()
    _tween.interpolate_property(
            self,
            "rect_position",
            start_position,
            end_position,
            Sc.info_panel.fade_in_duration,
            "ease_in",
            0.0,
            TimeType.APP_PHYSICS)
    _tween.interpolate_property(
            self,
            "modulate:a",
            Sc.info_panel.opacity,
            0.0,
            Sc.info_panel.fade_out_duration,
            "ease_in_out",
            0.0,
            TimeType.APP_PHYSICS)
    _tween.start()
    emit_signal("fade_out_started")


func get_is_transitioning() -> bool:
    return _tween.is_active()


func _on_transitioned() -> void:
    if is_open:
        emit_signal("faded_in")
    else:
        emit_signal("faded_out")


func _on_ScaffolderTextureButton_pressed() -> void:
    close()

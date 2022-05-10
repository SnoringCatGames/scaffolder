class_name RadialMenuItem
extends Reference


var texture: Texture

var id = ""
var description := ""

var is_visible := true
var disabled_message := "" setget _set_disabled_message

var _hover_progress := 0.0

var _menu
var _index: int
var _angle: float
var _control: ShapedLevelControl
var _tween: ScaffolderTween

var _is_ready := false


func set_up(
        menu,
        index: int,
        angular_spread: float) -> void:
    _is_ready = true
    
    _menu = menu
    _index = index
    _angle = angular_spread * index
    
    var item_radius: float = Sc.gui.hud.radial_menu_item_radius * Sc.gui.scale
    var offset := Vector2(0.0, -Sc.gui.hud.radial_menu_radius * Sc.gui.scale) \
        .rotated(_angle)
    
    _control = _create_item_level_control()
    _control.position = offset
    _control.screen_radius = 0.0
    _control.shape_circle_radius = item_radius
    _control.connect("touch_entered", self, "_on_item_touch_entered")
    _control.connect("touch_exited", self, "_on_item_touch_exited")
    _control.connect("touch_up", self, "_on_item_touch_up")
    _menu.add_child(_control)
    Sc.level.level_control_press_controller \
        .included_exclusively_control(_control)
    
    _tween = ScaffolderTween.new(_menu)
    _tween.connect("tween_all_completed", self, "_on_item_tween_completed")


func _create_item_level_control() -> ShapedLevelControl:
    Sc.logger.error("Abstract RadialMenuItem._create_item_level_control " +
        "is not implemented")
    return null


func _interpolate_item_hover(progress: float) -> void:
    _hover_progress = progress
    
    var scale: float = lerp(
            1.0, Sc.gui.hud.radial_menu_item_hovered_scale, progress)
    
    if disabled_message != "":
        scale = 1.0
    
    var radius: float = \
            scale * Sc.gui.hud.radial_menu_item_radius * Sc.gui.scale
    var menu_radius: float = \
            (Sc.gui.hud.radial_menu_radius + \
            scale * Sc.gui.hud.radial_menu_item_radius - \
            Sc.gui.hud.radial_menu_item_radius) * Sc.gui.scale
    var offset := Vector2(0.0, -menu_radius).rotated(_angle)
    
    _control.shape_circle_radius = radius
    _control.position = offset


func _on_item_touch_entered() -> void:
    _tween.stop_all()
    _tween.interpolate_method(
            self,
            "_interpolate_item_hover",
            _hover_progress,
            1.0,
            Sc.gui.hud.radial_menu_item_hover_duration,
            "ease_out_strong",
            0.0,
            TimeType.PLAY_PHYSICS)
    _tween.start()
    _menu.set_label(description, disabled_message)


func _on_item_touch_exited() -> void:
    _tween.stop_all()
    _tween.interpolate_method(
            self,
            "_interpolate_item_hover",
            _hover_progress,
            0.0,
            Sc.gui.hud.radial_menu_item_hover_duration,
            "ease_in_strong",
            0.0,
            TimeType.PLAY_PHYSICS)
    _tween.start()
    _menu.set_label("", "")


func _on_item_touch_up(
        touch_position: Vector2,
        is_already_handled: bool) -> void:
    _menu._close(self, false)


func _on_item_tween_completed() -> void:
    pass


func _set_disabled_message(value: String) -> void:
    disabled_message = value

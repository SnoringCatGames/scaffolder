tool
class_name RadialMenu
extends Node2D


# FIXME: LEFT OFF HERE: -----------------------
# - Show the description for the current item above the radial menu.
# - For the meteor-power menu subclass, also show the cost above the
#   description.
# - Update item border on hover, on disabled, (and on-highlighted for the
#   meteor-power subclass).


signal closed()
signal touch_up_item(item)
signal touch_up_center()
signal touch_up_outside()

const _SPRITE_MODULATION_BUTTON_SCENE := preload(
    "res://addons/scaffolder/src/gui/level_button/sprite_modulation_button.tscn")

var metadata

var is_transitioning_open := true

# Array<RadialMenuItem>
var _items := []

var _center_area_control: LevelControl

var _label: RadialMenuLabel

var _destroyed := false

var _openness_tween: ScaffolderTween
var _position_tween: ScaffolderTween


func _ready() -> void:
    _openness_tween = ScaffolderTween.new(self)
    _openness_tween.connect("tween_all_completed", self, "_on_menu_tween_completed")
    _position_tween = ScaffolderTween.new(self)
    
    Sc.level.touch_listener.connect(
        "single_unhandled_touch_released", self, "_on_level_touch_up")
    
    _label = Sc.utils.add_scene(self, Sc.gui.hud.radial_menu_label_scene)
    _label.color = Sc.gui.hud.radial_menu_item_normal_color_modulate.sample()
    _label.visible = false


func _destroy() -> void:
    for item in _items:
        if is_instance_valid(item._control):
            item._control._destroy()
        if is_instance_valid(item._tween):
            item._tween._destroy()
    if is_instance_valid(_center_area_control):
        _center_area_control._destroy()
    if is_instance_valid(_label):
        _label._destroy()
    queue_free()


func set_items(items: Array) -> void:
    for item in _items:
        if is_instance_valid(item._control):
            item._control._destroy()
        if is_instance_valid(item._tween):
            item._tween._destroy()
    _items = items
    var angular_spread := PI * 2.0 / items.size()
    for i in _items.size():
        var item: RadialMenuItem = _items[i]
        assert(is_instance_valid(item.texture))
        assert(!(item.id is String) or item.id != "")
        item.set_up(self, i, angular_spread)


func open(screen_position: Vector2) -> void:
    self.position = screen_position
    
    _center_area_control = ShapedLevelControl.new()
    _center_area_control.screen_radius = 0.0
    _center_area_control.shape_circle_radius = \
            (Sc.gui.hud.radial_menu_radius - \
            Sc.gui.hud.radial_menu_item_radius) * \
            Sc.gui.scale
    _center_area_control.connect("touch_up", self, "_on_center_area_touch_up")
    add_child(_center_area_control)
    
    # -   Adjust the position so the radial-menu will fit in the screen.
    # -   Adjust the camera so the level will still line-up with the
    #     radial-menu.
    var screen_margin: float = \
            (Sc.gui.hud.radial_menu_radius + \
            Sc.gui.hud.radial_menu_item_radius) * \
            Sc.gui.scale
    var position_boundaries := \
            Rect2(Vector2.ZERO, Sc.device.get_viewport_size()) \
                .grow(-screen_margin)
    var clamped_screen_position := Vector2(
            clamp(screen_position.x,
                    position_boundaries.position.x,
                    position_boundaries.end.x),
            clamp(screen_position.y,
                    position_boundaries.position.y,
                    position_boundaries.end.y))
    if clamped_screen_position != screen_position:
        var screen_displacement := clamped_screen_position - screen_position
        var level_displacement: Vector2 = \
                screen_displacement * Sc.level.camera.zoom.x
        Sc.level.camera.nudge_offset(-level_displacement)
        _transition_position(
                screen_displacement, Sc.camera.offset_transition_duration)
    
    Sc.level.level_control_press_controller.included_exclusively_control(
            _center_area_control)
    _transition_open()


func close() -> void:
    _close(null, false)


func _close(
        touch_up_item: RadialMenuItem,
        is_touch_in_center: bool) -> void:
    if _destroyed:
        return
    _destroyed = true
    for item in _items:
        Sc.level.level_control_press_controller.reset_control_exclusivity(
                item._control)
    Sc.level.level_control_press_controller.reset_control_exclusivity(
            _center_area_control)
    if is_instance_valid(touch_up_item):
        if touch_up_item.disabled_message != "":
            emit_signal("touch_up_outside")
        else:
            emit_signal("touch_up_item", touch_up_item)
    elif is_touch_in_center:
        emit_signal("touch_up_center")
    else:
        emit_signal("touch_up_outside")
    emit_signal("closed")
    _label.visible = false
    _transition_closed()


func _transition_open() -> void:
    is_transitioning_open = true
    _openness_tween.stop_all()
    _openness_tween.interpolate_method(
            self,
            "_interpolate_openness",
            0.0,
            1.0,
            Sc.gui.hud.radial_menu_open_duration,
            "ease_out_strong",
            0.0,
            TimeType.PLAY_PHYSICS)
    _openness_tween.start()


func _transition_closed() -> void:
    is_transitioning_open = true
    _openness_tween.stop_all()
    _openness_tween.interpolate_method(
            self,
            "_interpolate_openness",
            1.0,
            0.0,
            Sc.gui.hud.radial_menu_close_duration,
            "ease_in_strong",
            0.0,
            TimeType.PLAY_PHYSICS)
    _openness_tween.start()


func _transition_position(
        screen_displacement: Vector2,
        duration: float) -> void:
    _position_tween.stop_all()
    _position_tween.interpolate_property(
            self,
            "position",
            position,
            position + screen_displacement,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS)
    _position_tween.start()


func set_label(
        text: String,
        disabled_message: String) -> void:
    _label.visible = text != "" and !is_transitioning_open
    _label.text = text
    _label.disablement_explanation = disabled_message


func _on_level_touch_up(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2,
        has_corresponding_touch_down: bool) -> void:
    close()


func _on_center_area_touch_up(
        touch_position: Vector2,
        is_already_handled: bool) -> void:
    _close(null, true)


func _interpolate_openness(progress: float) -> void:
    var scale: float = lerp(0.0001, 1.0, progress)
    self.scale = Vector2.ONE * scale
    
    var item_angular_offset: float = lerp(
            Sc.gui.hud.radial_menu_closed_item_angular_offset, 0.0, progress)
    self.rotation = item_angular_offset


func _on_menu_tween_completed() -> void:
    if _destroyed:
        _destroy()
    is_transitioning_open = false
    set_label(_label.text, _label.disablement_explanation)

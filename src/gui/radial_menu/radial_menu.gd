tool
class_name RadialMenu
extends Node2D


# FIXME: LEFT OFF HERE: ----------------------
# - Show the description for the current item above the radial menu.
# - For the meteor-power menu subclass, also show the cost above the
#   description.
# - Update item border on hover, on disabled, (and on-highlighted for the
#   meteor-power subclass).


signal touch_up_item(item_data)
signal touch_up_center()
signal touch_up_outside()

# Array<RadialMenuItemData>
var _items := []

var _center_area_control: LevelControl

var _destroyed := false

var _tween: ScaffolderTween


func _ready() -> void:
    _tween = ScaffolderTween.new(self)
    _tween.connect("tween_all_completed", self, "_on_menu_tween_completed")
    
    Sc.level.touch_listener.connect("single_touch_released", self, "close")


func _destroy() -> void:
    for item in _items:
        if is_instance_valid(item._control):
            item._control._destroy()
    if is_instance_valid(_center_area_control):
        _center_area_control._destroy()
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
        var item: RadialMenuItemData = _items[i]
        assert(is_instance_valid(item.texture))
        assert(!(item.id is String) or item.id != "")
        _create_item_level_control(item, i, angular_spread)


func open(position: Vector2) -> void:
    self.position = position
    _center_area_control = ShapedLevelControl.new()
    _center_area_control.screen_radius = 0.0
    _center_area_control.shape_circle_radius = Sc.gui.hud.radial_menu_radius
    _center_area_control.connect("touch_up", self, "_on_center_area_touch_up")
    add_child(_center_area_control)
    _transition_open()


func close() -> void:
    if _destroyed:
        return
    _destroyed = true
    call_deferred("_deferred_close", null, false)


func _deferred_close(
        touch_up_item_data: RadialMenuItemData,
        is_touch_in_center: bool) -> void:
    _destroyed = true
    if is_instance_valid(touch_up_item_data):
        emit_signal("touch_up_item", touch_up_item_data)
    elif is_touch_in_center:
        emit_signal("touch_up_center")
    else:
        emit_signal("touch_up_outside")
    _transition_closed()


func _transition_open() -> void:
    _tween.stop_all()
    _tween.interpolate_method(
            self,
            "_interpolate_openness",
            0.0,
            1.0,
            Sc.gui.hud.radial_menu_open_duration,
            "ease_out_strong",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    _tween.start()


func _transition_closed() -> void:
    _tween.stop_all()
    _tween.interpolate_method(
            self,
            "_interpolate_openness",
            1.0,
            0.0,
            Sc.gui.hud.radial_menu_close_duration,
            "ease_in_strong",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    _tween.start()


func _create_item_level_control(
        item: RadialMenuItemData,
        index: int,
        angular_spread: float) -> void:
    var item_radius: float = Sc.gui.hud.radial_menu_item_radius * Sc.gui.scale
    var angle := angular_spread * index
    var offset := Vector2(0.0, -Sc.gui.hud.radial_menu_radius * Sc.gui.scale) \
            .rotated(angle)
    
    var control := ShapedLevelControl.new()
    control.position = offset
    control.screen_radius = 0.0
    control.shape_circle_radius = item_radius
    control.connect("touch_entered", self, "_on_item_touch_entered", [item])
    control.connect("touch_exited", self, "_on_item_touch_exited", [item])
    control.connect("touch_up", self, "_on_item_touch_up", [item])
    add_child(control)
    
    var sprite := item._create_outlineable_sprite()
    sprite.scale = \
            Vector2.ONE * \
            Sc.gui.hud.radial_menu_item_radius * 2.0 / \
            item.texture.get_size() * \
            Sc.gui.scale
    control.add_child(sprite)
    
    var item_tween := ScaffolderTween.new(self)
    item_tween.connect("tween_all_completed", self, "_on_item_tween_completed")
    
    item._menu = self
    item._control = control
    item._sprite = sprite
    item._tween = item_tween
    item._index = index
    item._angle = angle


func update_item_control(item: RadialMenuItemData) -> void:
    item._control.is_disabled = item.is_disabled


func _on_item_touch_entered(item: RadialMenuItemData) -> void:
    item._tween.stop_all()
    item._tween.interpolate_method(
            item,
            "_interpolate_item_hover",
            0.0,
            1.0,
            Sc.gui.hud.radial_menu_item_hover_duration,
            "ease_out_strong",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    item._tween.start()


func _on_item_touch_exited(item: RadialMenuItemData) -> void:
    item._tween.stop_all()
    item._tween.interpolate_method(
            item,
            "_interpolate_item_hover",
            1.0,
            0.0,
            Sc.gui.hud.radial_menu_item_hover_duration,
            "ease_in_strong",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    item._tween.start()


func _on_item_touch_up(item: RadialMenuItemData) -> void:
    _deferred_close(item, false)


func _on_center_area_touch_up() -> void:
    _deferred_close(null, true)


func _interpolate_openness(progress: float) -> void:
    var scale: float = lerp(0.0001, 1.0, progress)
    self.scale = Vector2.ONE * scale
    
    var item_angular_offset: float = lerp(
            Sc.gui.hud.radial_menu_closed_item_angular_offset, 0.0, progress)
    self.rotation = item_angular_offset


func _interpolate_item_hover(
        item: RadialMenuItemData,
        progress: float) -> void:
    var scale: float = lerp(
            1.0, Sc.gui.hud.radial_menu_item_hovered_scale, progress)
    var radius: float = \
            scale * Sc.gui.hud.radial_menu_item_radius * Sc.gui.scale
    item._control.shape_circle_radius = radius
    
    item._sprite.scale = \
            Vector2.ONE * \
            scale * \
            Sc.gui.hud.radial_menu_item_radius * 2.0 / \
            item.texture.get_size() * \
            Sc.gui.scale
    
    var menu_radius: float = \
            (Sc.gui.hud.radial_menu_radius + \
            scale * Sc.gui.hud.radial_menu_item_radius - \
            Sc.gui.hud.radial_menu_item_radius) * Sc.gui.scale
    var offset := Vector2(0.0, -menu_radius).rotated(item._angle)
    item._control.position = offset
    
    var hovered_color: Color = \
            Sc.gui.hud.radial_menu_item_hover_outline_color.sample()
    var normal_color := ColorFactory.opacify(hovered_color, 0.0).sample()
    var color: Color = lerp(normal_color, hovered_color, progress)
    item._sprite.outline_color = color


func _on_menu_tween_completed() -> void:
    if _destroyed:
        _destroy()


func _on_item_tween_completed() -> void:
    pass

class_name GameScreen
extends Screen


var _is_first_activation_with_level := true


func _ready() -> void:
    move_canvas_layer_to_game_viewport("annotation")
    
    _on_resized()


func move_canvas_layer_to_game_viewport(name: String) -> void:
    var layer: CanvasLayer = Gs.canvas_layers.layers[name]
    layer.get_parent().remove_child(layer)
    $ViewportContainer/Viewport.add_child(layer)


func _process(_delta: float) -> void:
    if !is_instance_valid(Gs.level):
        return
    
    # Transform the annotation layer to follow the camera within the
    # game-screen viewport.
    Gs.canvas_layers.layers.annotation.transform = \
            Gs.level.get_canvas_transform()


func _on_resized() -> void:
    ._on_resized()
    _update_viewport_region_helper()
    
    # TODO: This hack seems to be needed in order for the viewport to actually
    #       update its dimensions correctly.
    Gs.time.set_timeout(funcref(self, "_update_viewport_region_helper"), 1.0)


func _on_transition_in_started(previous_screen: Screen) -> void:
    ._on_transition_in_started(previous_screen)
    
    if !_is_first_activation_with_level and \
            is_instance_valid(Gs.level):
        Gs.level.on_unpause()
    
    _is_first_activation_with_level = false
    
    if !Gs.level_session.has_started:
        Gs.level._start()


func _on_transition_out_ended(next_screen: Screen) -> void:
    ._on_transition_out_ended(next_screen)
    
    if next_screen.screen_name != "pause":
        if is_instance_valid(Gs.level):
            Gs.level._destroy()


func _update_viewport_region_helper() -> void:
    var viewport_size: Vector2 = Gs.device.get_viewport_size()
    var game_area_position: Vector2 = \
            (viewport_size - Gs.gui.game_area_region.size) * 0.5
    
    rect_size = viewport_size
    $ViewportContainer.rect_position = game_area_position
    $ViewportContainer/Viewport.size = Gs.gui.game_area_region.size
    
    _fix_viewport_dimensions_hack()


func _fix_viewport_dimensions_hack() -> void:
    if visible:
        # TODO: This hack seems to be needed in order for the viewport to
        #       actually update its dimensions correctly.
        visible = false
        Gs.time.set_timeout(funcref(self, "set_visible"), 0.4, [true])


func add_level(level: ScaffolderLevel) -> void:
    _is_first_activation_with_level = true
    $ViewportContainer/Viewport.add_child(level)

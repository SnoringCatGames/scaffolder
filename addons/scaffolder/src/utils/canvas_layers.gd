tool
class_name CanvasLayers
extends Node2D


const _DEFAULT_LAYERS_CONFIG := [
    {
        name = "top",
        z_index = 70,
        pause_mode = Node.PAUSE_MODE_PROCESS,
    },
    {
        name = "notification",
        z_index = 60,
        pause_mode = Node.PAUSE_MODE_PROCESS,
    },
    {
        name = "menu",
        z_index = 50,
        pause_mode = Node.PAUSE_MODE_PROCESS,
    },
    {
        name = "in_game_dialog",
        z_index = 40,
        pause_mode = Node.PAUSE_MODE_STOP,
    },
    {
        name = "hud",
        z_index = 30,
        pause_mode = Node.PAUSE_MODE_STOP,
    },
    {
        name = "annotation",
        z_index = 20,
        pause_mode = Node.PAUSE_MODE_STOP,
    },
    {
        name = "game",
        z_index = 10,
        pause_mode = Node.PAUSE_MODE_STOP,
    },
]

# Dictionary<String, CanvasLayer>
var layers := {}


func _init() -> void:
    Sc.logger.on_global_init(self, "CanvasLayers")


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    for config in _DEFAULT_LAYERS_CONFIG:
        create_layer(config.name, config.z_index, config.pause_mode)


func _destroy() -> void:
    for layer_name in layers:
        layers[layer_name].queue_free()
    if !is_queued_for_deletion():
        queue_free()


func create_layer(
        name: String,
        z_index: int,
        pause_mode: int) -> CanvasLayer:
    var canvas_layer := CanvasLayer.new()
    canvas_layer.name = name
    canvas_layer.layer = z_index
    canvas_layer.pause_mode = pause_mode
    Sc.utils.add_overlay_to_current_scene(canvas_layer)
    layers[name] = canvas_layer
    return canvas_layer


func set_global_visibility(visible: bool) -> void:
    for layer_name in layers:
        set_layer_visibility(layer_name, visible)


func set_layer_visibility(layer_name: String, visible: bool) -> void:
    for child in layers[layer_name].get_children():
        if child is CanvasItem:
            if visible:
                child.visible = \
                        child.get_meta("sc_visible") if \
                        child.has_meta("sc_visible") else \
                        true
            else:
                child.set_meta("sc_visible", child.visible)
                child.visible = false

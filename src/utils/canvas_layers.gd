class_name CanvasLayers
extends Node2D


const _DEFAULT_LAYERS_CONFIG := [
    {
        name = "menu",
        z_index = 40,
        pause_mode = Node.PAUSE_MODE_PROCESS,
    },
    {
        name = "top",
        z_index = 50,
        pause_mode = Node.PAUSE_MODE_PROCESS,
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

var layers := {}


func _init() -> void:
    Gs.logger.on_global_init(self, "CanvasLayers")


func _enter_tree() -> void:
    for config in _DEFAULT_LAYERS_CONFIG:
        create_layer(config.name, config.z_index, config.pause_mode)


func _exit_tree() -> void:
    for layer_name in layers:
        layers[layer_name].queue_free()


func create_layer(
        name: String,
        z_index: int,
        pause_mode: int) -> CanvasLayer:
    var canvas_layer := CanvasLayer.new()
    canvas_layer.name = name
    canvas_layer.layer = z_index
    canvas_layer.pause_mode = pause_mode
    Gs.utils.add_overlay_to_current_scene(canvas_layer)
    layers[name] = canvas_layer
    return canvas_layer


func set_global_visibility(visible: bool) -> void:
    for layer in layers.values():
        for child in layer.get_children():
            if child is CanvasItem:
                if visible:
                    child.visible = \
                            child.get_meta("gs_visible") if \
                            child.has_meta("gs_visible") else \
                            true
                else:
                    child.set_meta("gs_visible", child.visible)
                    child.visible = false

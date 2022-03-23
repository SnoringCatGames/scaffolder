tool
extends Node


const _MAIN_SCREEN_SCENE := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_plugin_main_screen.tscn")

var editor: EditorInterface

var main_screen



func _set_up(editor: EditorInterface) -> void:
    self.editor = editor
    
    if !is_instance_valid(main_screen):
        main_screen = _MAIN_SCREEN_SCENE.instance()
        editor.get_editor_viewport().add_child(main_screen)


func _destroy() -> void:
    if is_instance_valid(main_screen):
        main_screen.queue_free()


func make_visible(visible: bool) -> void:
    if is_instance_valid(main_screen):
        main_screen.visible = visible


# FIXME: LEFT OFF HERE: ----------------------------------------
func scale_dimension(value):
    var scale := editor.get_editor_scale()
    return value * scale

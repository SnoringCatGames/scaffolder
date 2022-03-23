tool
class_name ScaffolderPlugin
extends FrameworkPlugin


const _AUTO_LOAD_NAME := "Sc"
const _AUTO_LOAD_PATH := "res://addons/scaffolder/src/config/sc.gd"
const _SCHEMA_PATH := "res://addons/scaffolder/src/plugin/scaffolder_schema.gd"


func _init().(
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_PATH,
        _SCHEMA_PATH) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    if !_get_is_ready():
        return
    
    make_visible(false)


func _exit_tree() -> void:
    Pl._destroy()


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    Pl.make_visible(visible)

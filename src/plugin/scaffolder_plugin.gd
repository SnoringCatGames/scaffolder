tool
class_name ScaffolderPlugin
extends FrameworkPlugin


const _METADATA_SCRIPT := ScaffolderMetadata


func _init().(_METADATA_SCRIPT) -> void:
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

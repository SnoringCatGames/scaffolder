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
    
    Pl._set_up()
    
    make_visible(false)


func _exit_tree() -> void:
    if is_instance_valid(Pl):
        Pl._destroy()


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    if is_instance_valid(Pl):
        Pl.make_visible(visible)

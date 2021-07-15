tool
class_name SettingsScreen
extends Screen


const SETTINGS_GROUP_SCENE := \
        preload("res://addons/scaffolder/src/gui/settings_group.tscn")


func _on_transition_in_started(previous_screen: Screen) -> void:
    ._on_transition_in_started(previous_screen)
    _instantiate_settings_groups()


func _on_transition_out_started(next_screen: Screen) -> void:
    ._on_transition_out_started(next_screen)
    _clear_groups()
    if Sc.level != null and \
            next_screen is PauseScreen and \
            Sc.metadata.must_restart_level_to_change_settings:
        Sc.level.restart()


func _instantiate_settings_groups() -> void:
    _clear_groups()
    for group_name in Sc.gui.settings_item_manifest.groups:
        var group: SettingsGroup = Sc.utils.add_scene(
                null,
                SETTINGS_GROUP_SCENE,
                false,
                true)
        group.group_name = group_name
        $VBoxContainer.add_child(group)


func _clear_groups() -> void:
    for child in $VBoxContainer.get_children():
        child.queue_free()

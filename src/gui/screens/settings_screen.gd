tool
class_name SettingsScreen
extends Screen


const SETTINGS_GROUP_SCENE := \
        preload("res://addons/scaffolder/src/gui/settings_group.tscn")


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    _instantiate_settings_groups()


func _on_deactivated(next_screen: Screen) -> void:
    ._on_deactivated(next_screen)
    _clear_groups()
    if Gs.level != null and \
            next_screen is PauseScreen and \
            Gs.app_metadata.must_restart_level_to_change_settings:
        Gs.level.restart()


func _instantiate_settings_groups() -> void:
    _clear_groups()
    for group_name in Gs.gui.settings_item_manifest.groups:
        var group: SettingsGroup = Gs.utils.add_scene(
                null,
                SETTINGS_GROUP_SCENE,
                false,
                true)
        group.group_name = group_name
        $VBoxContainer.add_child(group)


func _clear_groups() -> void:
    for child in $VBoxContainer.get_children():
        $VBoxContainer.remove_child(child)

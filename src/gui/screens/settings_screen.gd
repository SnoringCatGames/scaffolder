tool
class_name SettingsScreen
extends Screen


const SETTINGS_GROUP_RESOURCE_PATH := "res://addons/scaffolder/src/gui/settings_group.tscn"
const NAME := "settings"
const LAYER_NAME := "menu_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true


func _init().(
        NAME,
        LAYER_NAME,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


func _on_activated(previous_screen_name: String) -> void:
    ._on_activated(previous_screen_name)
    _instantiate_settings_groups()


func _on_deactivated(next_screen_name: String) -> void:
    ._on_deactivated(next_screen_name)
    if Gs.level != null and \
            next_screen_name == "pause" and \
            Gs.must_restart_level_to_change_settings:
        Gs.level.restart()


func _instantiate_settings_groups() -> void:
    for group_name in Gs.settings_item_manifest.groups:
        var group: SettingsGroup = Gs.utils.add_scene(
                null,
                SETTINGS_GROUP_RESOURCE_PATH,
                false,
                true)
        group.group_name = group_name
        $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                ScrollContainer/CenterContainer/VBoxContainer.add_child(group)

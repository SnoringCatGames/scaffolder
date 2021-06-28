tool
class_name SettingsScreen
extends Screen


const SETTINGS_GROUP_SCENE := \
        preload("res://addons/scaffolder/src/gui/settings_group.tscn")
const NAME := "settings"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true


func _init().(
        NAME,
        LAYER_NAME,
        IS_ALWAYS_ALIVE,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


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
        $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                ScrollContainer/CenterContainer/VBoxContainer.add_child(group)


func _clear_groups() -> void:
    var group_container := $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer
    for child in group_container.get_children():
        group_container.remove_child(child)

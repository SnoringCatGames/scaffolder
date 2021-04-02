tool
class_name SettingsScreen
extends Screen

const NAME := "settings"
const LAYER_NAME := "menu_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

func _init().( \
        NAME, \
        LAYER_NAME, \
        AUTO_ADAPTS_GUI_SCALE, \
        INCLUDES_STANDARD_HIERARCHY, \
        INCLUDES_NAV_BAR, \
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _on_activated(previous_screen_name: String) -> void:
    ._on_activated(previous_screen_name)
    $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/MainList.items = \
            _get_main_items()
    $FullScreenPanel/VBoxContainer/CenteredPanel/ \
            ScrollContainer/CenterContainer/VBoxContainer/AccordionPanel/ \
            VBoxContainer/DetailsList.items = _get_details_items()

func _on_deactivated(next_screen_name: String) -> void:
    ._on_deactivated(next_screen_name)
    if Gs.level != null and \
            next_screen_name == "pause" and \
            Gs.must_restart_level_to_change_settings:
        Gs.level.restart()

func _get_main_items() -> Array:
    var item_classes := \
            Gs.utils.get_collection_from_exclusions_and_inclusions( \
                    _get_default_main_items(), \
                    Gs.settings_main_item_class_exclusions, \
                    Gs.settings_main_item_class_inclusions)
    var items := []
    for item_class in item_classes:
        items.push_back(item_class.new())
    return items

func _get_details_items() -> Array:
    var item_classes := \
            Gs.utils.get_collection_from_exclusions_and_inclusions( \
                    _get_default_details_items(), \
                    Gs.settings_details_item_class_exclusions, \
                    Gs.settings_details_item_class_inclusions)
    var items := []
    for item_class in item_classes:
        items.push_back(item_class.new(Gs.level))
    return items

func _get_default_main_items() -> Array:
    var defaults := [
        MusicSettingsLabeledControlItem,
        SoundEffectsSettingsLabeledControlItem,
    ]
    if Gs.is_mobile_supported:
        defaults.push_back(HapticFeedbackSettingsLabeledControlItem)
    return defaults

func _get_default_details_items() -> Array:
    return [
        DebugPanelSettingsLabeledControlItem,
    ]

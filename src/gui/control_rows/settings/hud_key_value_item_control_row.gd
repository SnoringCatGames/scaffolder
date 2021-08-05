class_name HudKeyValueItemControlRow
extends CheckboxControlRow


const DESCRIPTION := ""

var item_config: Dictionary


func _init(item_config: Dictionary).(
        item_config.settings_enablement_label,
        DESCRIPTION \
        ) -> void:
    self.item_config = item_config


func on_pressed(pressed: bool) -> void:
    item_config.enabled = pressed
    Sc.save_state.set_setting(
            item_config.settings_key,
            item_config.enabled)


func get_is_pressed() -> bool:
    return item_config.enabled


func get_is_enabled() -> bool:
    return true

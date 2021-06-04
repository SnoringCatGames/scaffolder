class_name TimeLabeledControlItem
extends TextLabeledControlItem


const LABEL := "Time:"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func get_text() -> String:
    return Gs.utils.get_time_string_from_seconds(
            Gs.time.get_play_time() - \
            Gs.level.level_start_play_time_unscaled) if \
            is_instance_valid(Gs.level) else \
            "—"

class_name TimeLabeledControlItem
extends TextLabeledControlItem


const LABEL := "Time:"
const DESCRIPTION := ""
const BLANK_TIME_STRING := "--:--:--"


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func get_text() -> String:
    return Gs.utils.get_time_string_from_seconds(
            Gs.level_session.level_play_time_unscaled) if \
            Gs.level_session.has_started else \
            BLANK_TIME_STRING

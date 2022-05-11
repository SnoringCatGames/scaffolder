class_name TimeControlRow
extends TextControlRow


const LABEL := "Time:"
const DESCRIPTION := ""
const BLANK_TIME_STRING := "--:--:--"


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func get_text() -> String:
    return Sc.utils.get_time_string_from_seconds(
            Sc.levels.session.get_level_display_time(),
            false,
            false) if \
            Sc.levels.session.has_started else \
            BLANK_TIME_STRING

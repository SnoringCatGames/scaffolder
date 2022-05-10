class_name LongestTimeControlRow
extends TextControlRow


const LABEL := "Longest time:"
const DESCRIPTION := ""

var level_id: String


func _init(level_session_or_id).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    self.level_id = \
            level_session_or_id.id if \
            level_session_or_id is ScaffolderLevelSession else \
            (level_session_or_id if \
            level_session_or_id is String else \
            "")


func get_text() -> String:
    if level_id == "":
        return TimeControlRow.BLANK_TIME_STRING
    else:
        var longest_time: float = \
                Sc.save_state.get_level_longest_time(level_id)
        if longest_time == Utils.MAX_INT:
            return TimeControlRow.BLANK_TIME_STRING
        else:
            return Sc.utils.get_time_string_from_seconds(longest_time)

class_name FastestTimeControlRow
extends TextControlRow


const LABEL := "Fastest time:"
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
        var fastest_time: float = \
                Sc.save_state.get_level_fastest_time(level_id)
        if fastest_time == Utils.MAX_INT:
            return TimeControlRow.BLANK_TIME_STRING
        else:
            return Sc.utils.get_time_string_from_seconds(fastest_time)

class_name FastestTimeLabeledControlItem
extends TextLabeledControlItem


const LABEL := "Fastest time:"
const DESCRIPTION := ""

var level_id: String


func _init(level_session_or_id).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    self.level_id = \
            level_session_or_id.id if \
            level_session_or_id is ScaffolderLevel else \
            (level_session_or_id if \
            level_session_or_id is String else \
            "")


func get_text() -> String:
    if level_id == "":
        return "—"
    else:
        var fastest_time: float = \
                Gs.save_state.get_level_fastest_time(level_id)
        if fastest_time == Utils.MAX_INT:
            return "—"
        else:
            return str(fastest_time)

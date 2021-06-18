class_name FastestTimeLabeledControlItem
extends TextLabeledControlItem


const LABEL := "Fastest time:"
const DESCRIPTION := ""

var level_id: String


func _init(level_or_id).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    self.level_id = \
            level_or_id.id if \
            level_or_id is ScaffolderLevel else \
            (level_or_id if \
            level_or_id is String else \
            "")


func get_text() -> String:
    if level_id == "":
        return "—"
    else:
        var settings_key := \
                SaveState.get_level_fastest_time_settings_key(level_id)
        var fastest_time: float = Gs.save_state.get_setting(settings_key, INF)
        if fastest_time == INF:
            return "—"
        else:
            return Gs.utils.get_time_string_from_seconds(fastest_time)

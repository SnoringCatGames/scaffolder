class_name TotalPlaysControlRow
extends TextControlRow


const LABEL := "Total plays:"
const DESCRIPTION := ""

var level_id: String


func _init(level_id: String).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    self.level_id = level_id


func get_text() -> String:
    return str(Sc.save_state.get_level_total_plays(level_id))

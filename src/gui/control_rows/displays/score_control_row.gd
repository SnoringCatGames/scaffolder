class_name ScoreControlRow
extends TextControlRow


const LABEL := "Current score:"
const DESCRIPTION := ""


func _init(__ = null).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    pass


func get_text() -> String:
    return str(int(Sc.levels.session.score)) if \
            is_instance_valid(Sc.levels.session) else \
            "—"

class_name CustomControlRow
extends ControlRow


var TYPE := ControlRow.CUSTOM


func _init(
        label: String,
        description: String
        ).(
        TYPE,
        label,
        description,
        true,
        false
        ) -> void:
    pass


func create_row(
        style: StyleBox,
        height: float,
        inner_padding_horizontal: float,
        outer_padding_horizontal: float,
        includes_description := true) -> PanelContainer:
    var result := .create_row(
        style,
        height,
        inner_padding_horizontal,
        outer_padding_horizontal,
        includes_description)
    control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return result


func get_is_enabled() -> bool:
    return true


func _update_control() -> void:
    Sc.logger.error(
            "Abstract CustomControlRow._update_control is not implemented")


func create_control() -> Control:
    Sc.logger.error(
            "Abstract CustomControlRow.create_control is not implemented")
    return null

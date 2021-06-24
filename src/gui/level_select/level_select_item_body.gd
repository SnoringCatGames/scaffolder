class_name LevelSelectItemBody
extends Node


var go_icon_scale_multiplier := 0.75

var level_id: String


func _ready() -> void:
    $PlayButton.texture = Gs.app_metadata.go_icon
    $PlayButton.texture_scale = \
            Vector2(Gs.app_metadata.go_icon_scale,
                    Gs.app_metadata.go_icon_scale) * \
            go_icon_scale_multiplier


func update() -> void:
    $LabeledControlList.items = _get_items()


func _get_items() -> Array:
    var items := []
    for item_class in Gs.gui.level_select_item_manifest:
        items.push_back(item_class.new(level_id))
    return items


func get_button() -> ScaffolderButton:
    return $PlayButton as ScaffolderButton


func _on_PlayButton_pressed():
    Gs.utils.give_button_press_feedback(true)
    Gs.nav.open("game")
    Gs.nav.screens["game"].start_level(level_id)

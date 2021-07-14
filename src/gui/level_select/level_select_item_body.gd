tool
class_name LevelSelectItemBody
extends Node


var go_scale_multiplier := 0.75

var level_id: String


func _ready() -> void:
    $PlayButton.texture = Gs.icons.go_normal
    $PlayButton.texture_scale = \
            Vector2(Gs.icons.go_scale, Gs.icons.go_scale) * \
            go_scale_multiplier


func update() -> void:
    $LabeledControlList.items = _get_items()


func _get_items() -> Array:
    var items := []
    for item_class in Gs.gui.level_select_item_manifest:
        items.push_back(item_class.new(level_id))
    return items


func get_button() -> ScaffolderButton:
    return $PlayButton as ScaffolderButton


func _on_PlayButton_pressed() -> void:
    Gs.nav.open(
            "loading",
            ScreenTransition.DEFAULT,
            {level_id = level_id})

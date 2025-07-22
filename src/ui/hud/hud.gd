@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name ScaffolderHud
extends PanelContainer


func _ready() -> void:
    S.hud = self

    self.visible = S.scaffolder_settings.flag_show_hud


func _on_pause_pressed() -> void:
    S.level.pause()

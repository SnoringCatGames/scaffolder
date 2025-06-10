@icon("res://addons/scaffolder2/assets/editor_icons/ScaffolderNode.svg")
class_name ScaffolderSuperHud
extends MarginContainer


func _ready() -> void:
    S.super_hud = self

    self.visible = S.scaffolder_settings.get("show_hud")

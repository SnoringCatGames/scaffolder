@icon("res://addons/scaffolder/assets/editor_icons/ScaffolderNode.svg")
class_name ScaffolderSuperHud
extends MarginContainer


func _ready() -> void:
    S.super_hud = self

    self.visible = S.scaffolder_settings.flag_show_hud

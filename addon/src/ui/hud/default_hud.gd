@icon("res://addons/scaffolder/assets/editor_icons/ScaffolderNode.svg")
class_name DefaultHud
extends PanelContainer


func _on_pause_pressed() -> void:
	S.level.pause()

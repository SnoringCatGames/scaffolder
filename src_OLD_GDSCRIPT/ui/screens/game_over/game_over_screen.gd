class_name ScaffolderGameOverScreen
extends ScaffolderScreen


# TODO: Configure game-over music in the manifest.
# TODO: Also, configure main-menu and pause music.


func _ready() -> void:
    super ()


func _on_play_button_pressed() -> void:
    _play()


func _play() -> void:
    S.screens.open("game")
    S.screens.close(self)

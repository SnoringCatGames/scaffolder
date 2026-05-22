class_name ScaffolderGameOverScreen
extends ScaffolderScreen


# TODO: Configure game-over music in the manifest.
# TODO: Also, configure main-menu and pause music.


func _ready() -> void:
    # TODO: Re-enable super() once C++ ScaffolderScreen exposes
    # _ready via _bind_methods. See game_screen.gd for context.
    pass


func _on_play_button_pressed() -> void:
    _play()


func _play() -> void:
    S.screens.open("game")
    S.screens.close(self)

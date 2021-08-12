tool
class_name SpawnPosition, \
"res://addons/scaffolder/assets/images/editor_icons/spawn_position.png"
extends Position2D


const PLAYER_OPACITY := 0.5

var PLAYER_NAME_PROPERTY_CONFIG := {
    name = "player_name",
    type = TYPE_STRING,
    usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    hint = PROPERTY_HINT_ENUM,
    hint_string = "",
}

var player_name := "" setget _set_player_name

var _property_list_addendum = [
    PLAYER_NAME_PROPERTY_CONFIG,
]
var _player: ScaffolderPlayer
var _configuration_warning := ""


func _init() -> void:
    _update_property_list_addendum()


func _ready() -> void:
    # Walk up the scene tree in order to find the active level, and register
    # this spawn position with it.
    var ancestor := get_parent()
    while is_instance_valid(ancestor) and \
            !(ancestor is ScaffolderLevel):
        ancestor = ancestor.get_parent()
    if ancestor is ScaffolderLevel:
        ancestor.register_spawn_position(player_name, position)


# -   This makes the `player_name` property exported for editing in the
#     inspector panel.
# -   This also defines the `player_name` property as an enum of all the
#     player names that are registered in the app manifest.
func _update_property_list_addendum() -> void:
    var player_names := Sc.players.player_scenes.keys()
    player_names.push_front("")
    PLAYER_NAME_PROPERTY_CONFIG.hint_string = Sc.utils.join(player_names, ",")


func _get_property_list() -> Array:
    return _property_list_addendum


func _update_editor_configuration() -> void:
    if !Engine.editor_hint:
        return
    
    if player_name == "":
        _set_configuration_warning("Must choose a player_name.")
        return
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _set_player_name(value: String) -> void:
    player_name = value
    if Engine.editor_hint:
        if is_instance_valid(_player):
            _player.queue_free()
        if player_name != "":
            _player = Sc.utils.add_scene(
                    self,
                    Sc.players.player_scenes[player_name])
            _player.modulate.a = PLAYER_OPACITY
    _update_editor_configuration()

tool
class_name ScaffolderPlayerManifest
extends Node


const GROUP_NAME_HUMAN_PLAYERS := "human_players"
const GROUP_NAME_COMPUTER_PLAYERS := "computer_players"
const GROUP_NAME_SURFACER_PLAYERS := "surfacer_players"

var default_player_name: String

# Dictionary<String, PackedScene>
var player_scenes := {}

# Array<PackedScene>
var _player_scenes_list: Array


func register_manifest(manifest: Dictionary) -> void:
    self._player_scenes_list = manifest.player_scenes
    self.default_player_name = manifest.default_player_name
    
    _parse_player_scenes(self._player_scenes_list)


func _parse_player_scenes(scenes_array: Array) -> void:
    for scene in scenes_array:
        assert(scene is PackedScene)
        var state: SceneState = scene.get_state()
        assert(state.get_node_type(0) == "KinematicBody2D")
        
        var player_name: String = \
                Sc.utils.get_property_value_from_scene_state_node(
                        state,
                        0,
                        "player_name",
                        !Engine.editor_hint)
        
        Sc.players.player_scenes[player_name] = scene


func get_human_player() -> ScaffolderPlayer:
    return Sc.level.human_player if \
            is_instance_valid(Sc.level) and \
                    is_instance_valid(Sc.level.human_player) else \
            null

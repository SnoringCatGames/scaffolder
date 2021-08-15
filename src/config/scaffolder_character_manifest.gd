tool
class_name ScaffolderCharacterManifest
extends Node


const GROUP_NAME_HUMAN_CHARACTERS := "human_characters"
const GROUP_NAME_NPCS := "npcs"
const GROUP_NAME_SURFACER_CHARACTERS := "surfacer_characters"

var default_character_name: String

# Dictionary<String, PackedScene>
var character_scenes := {}

# Array<PackedScene>
var _character_scenes_list: Array


func register_manifest(manifest: Dictionary) -> void:
    self._character_scenes_list = manifest.character_scenes
    self.default_character_name = manifest.default_character_name
    
    _parse_character_scenes(self._character_scenes_list)


func _parse_character_scenes(scenes_array: Array) -> void:
    for scene in scenes_array:
        assert(scene is PackedScene)
        var state: SceneState = scene.get_state()
        assert(state.get_node_type(0) == "KinematicBody2D")
        
        var character_name: String = \
                Sc.utils.get_property_value_from_scene_state_node(
                        state,
                        0,
                        "character_name",
                        !Engine.editor_hint)
        
        Sc.characters.character_scenes[character_name] = scene


func get_human_character() -> ScaffolderCharacter:
    return Sc.level.human_character if \
            is_instance_valid(Sc.level) and \
                    is_instance_valid(Sc.level.human_character) else \
            null

tool
class_name ScaffolderCharacterManifest
extends Node


const GROUP_NAME_PLAYERS := "players"
const GROUP_NAME_NPCS := "npcs"
const GROUP_NAME_CHARACTERS := "characters"

var default_player_character_name: String

# Dictionary<String, ScaffolderCharacterCategory>
var categories := {}

var omits_npcs := false

var can_include_player_characters := true

# Dictionary<String, PackedScene>
var character_scenes := {}

# Array<PackedScene>
var _character_scenes_list: Array

# Dictionary<String, ScaffolderCharacterCategory>
var _character_name_to_category: Dictionary


func _parse_manifest(manifest: Dictionary) -> void:
    self._character_scenes_list = manifest.character_scenes
    self.default_player_character_name = manifest.default_player_character_name
    if manifest.has("omits_npcs"):
        self.omits_npcs = manifest.omits_npcs
    if manifest.has("can_include_player_characters"):
        self.can_include_player_characters = \
                manifest.can_include_player_characters
    
    _parse_character_scenes(self._character_scenes_list)
    _parse_character_categories(manifest.character_categories)
    _map_characters_to_categories()


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


func _parse_character_categories(categories_config: Array) -> void:
    for category_config in categories_config:
        assert(category_config.has("name"))
        assert(category_config.has("characters"))
        
        var category := ScaffolderCharacterCategory.new()
        category.name = category_config.name
        category.characters = category_config.characters
        categories[category_config.name] = category


func _map_characters_to_categories() -> void:
    for category_name in categories:
        var category: ScaffolderCharacterCategory = categories[category_name]
        for character_name in category.characters:
            _character_name_to_category[character_name] = category


func get_active_player_character() -> ScaffolderCharacter:
    return Sc.level.active_player_character if \
            is_instance_valid(Sc.level) and \
                    is_instance_valid(Sc.level.active_player_character) else \
            null


func get_category_for_character(
        character_name: String) -> ScaffolderCharacterCategory:
    return _character_name_to_category[character_name] if \
            _character_name_to_category.has(character_name) else \
            null

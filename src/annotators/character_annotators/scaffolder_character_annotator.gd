class_name ScaffolderCharacterAnnotator
extends Node2D


var character: ScaffolderCharacter

var recent_movement_annotator: ScaffolderCharacterRecentMovementAnnotator
var position_annotator: ScaffolderCharacterPositionAnnotator


func _init(character: ScaffolderCharacter) -> void:
    self.character = character
    self.z_index = 2


func _physics_process(_delta: float) -> void:
    if is_instance_valid(recent_movement_annotator):
        recent_movement_annotator.check_for_update()
    if is_instance_valid(position_annotator):
        position_annotator.check_for_update()


func set_annotator_enabled(
        annotator_type: int,
        is_enabled: bool) -> void:
    if is_annotator_enabled(annotator_type) == is_enabled:
        # Do nothing. The annotator is already correct.
        return
    
    if is_enabled:
        _create_annotator(annotator_type)
    else:
        _destroy_annotator(annotator_type)


func is_annotator_enabled(annotator_type: int) -> bool:
    match annotator_type:
        AnnotatorType.CHARACTER:
            return character.get_is_sprite_visible()
        AnnotatorType.CHARACTER_POSITION:
            return is_instance_valid(position_annotator)
        AnnotatorType.RECENT_MOVEMENT:
            return is_instance_valid(recent_movement_annotator)
        _:
            Sc.logger.error("ScaffolderCharacterAnnotator.is_annotator_enabled")
            return false


func _create_annotator(annotator_type: int) -> void:
    assert(!is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.CHARACTER:
            character.set_is_sprite_visible(true)
        AnnotatorType.CHARACTER_POSITION:
            position_annotator = \
                    ScaffolderCharacterPositionAnnotator.new(character)
            add_child(position_annotator)
        AnnotatorType.RECENT_MOVEMENT:
            recent_movement_annotator = \
                    ScaffolderCharacterRecentMovementAnnotator.new(character)
            add_child(recent_movement_annotator)
        _:
            Sc.logger.error("ScaffolderCharacterAnnotator._create_annotator")


func _destroy_annotator(annotator_type: int) -> void:
    assert(is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.CHARACTER:
            character.set_is_sprite_visible(false)
        AnnotatorType.CHARACTER_POSITION:
            position_annotator.queue_free()
            position_annotator = null
        AnnotatorType.RECENT_MOVEMENT:
            recent_movement_annotator.queue_free()
            recent_movement_annotator = null
        _:
            Sc.logger.error("ScaffolderCharacterAnnotator._destroy_annotator")

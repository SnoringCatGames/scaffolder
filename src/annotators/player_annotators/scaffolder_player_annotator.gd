class_name ScaffolderPlayerAnnotator
extends Node2D


var player: ScaffolderPlayer

var recent_movement_annotator: ScaffolderPlayerRecentMovementAnnotator
var position_annotator: ScaffolderPlayerPositionAnnotator


func _init(player: ScaffolderPlayer) -> void:
    self.player = player
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
        AnnotatorType.PLAYER:
            return player.get_is_sprite_visible()
        AnnotatorType.PLAYER_POSITION:
            return is_instance_valid(position_annotator)
        AnnotatorType.RECENT_MOVEMENT:
            return is_instance_valid(recent_movement_annotator)
        _:
            Sc.logger.error()
            return false


func _create_annotator(annotator_type: int) -> void:
    assert(!is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.PLAYER:
            player.set_is_sprite_visible(true)
        AnnotatorType.PLAYER_POSITION:
            position_annotator = ScaffolderPlayerPositionAnnotator.new(player)
            add_child(position_annotator)
        AnnotatorType.RECENT_MOVEMENT:
            recent_movement_annotator = \
                    ScaffolderPlayerRecentMovementAnnotator.new(player)
            add_child(recent_movement_annotator)
        _:
            Sc.logger.error()


func _destroy_annotator(annotator_type: int) -> void:
    assert(is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.PLAYER:
            player.set_is_sprite_visible(false)
        AnnotatorType.PLAYER_POSITION:
            position_annotator.queue_free()
            position_annotator = null
        AnnotatorType.RECENT_MOVEMENT:
            recent_movement_annotator.queue_free()
            recent_movement_annotator = null
        _:
            Sc.logger.error()

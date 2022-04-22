tool
class_name ScaffolderAnnotators
extends Node2D


var _SCAFFOLDER_CHARACTER_SUB_ANNOTATORS := [
    AnnotatorType.CHARACTER,
    AnnotatorType.CHARACTER_POSITION,
    AnnotatorType.RECENT_MOVEMENT,
]

var _SCAFFOLDER_LEVEL_SPECIFIC_ANNOTATORS := [
    AnnotatorType.RULER,
    AnnotatorType.LEVEL,
]

# Dictionary<AnnotatorType, bool>
const _SCAFFOLDER_DEFAULT_ENABLEMENT := {
    AnnotatorType.RULER: false,
    AnnotatorType.LEVEL: true,
    AnnotatorType.CHARACTER: true,
    AnnotatorType.CHARACTER_POSITION: false,
    AnnotatorType.RECENT_MOVEMENT: true,
}

# NOTE: This only stores non-Color/ColorConfig values.
#       Color values are instead stored in Sc.palette.
# Dictionary<String, Variant>
var params := {}

var character_sub_annotators: Array
var level_specific_annotators: Array
var default_enablement: Dictionary
var character_annotation_class: Script

var ruler_annotator: RulerAnnotator

# Dictonary<ScaffolderCharacter, CharacterAnnotator>
var character_annotators := {}

var element_annotator: ElementAnnotator

var transient_annotator_registry: TransientAnnotatorRegistry

var _annotator_enablement := {}

var annotation_layer: CanvasLayer
var ruler_layer: CanvasLayer

var _throttled_frame_rate_notification: FuncRef = Sc.time.throttle(
        self,
        "_show_reduced_frame_rate_notification_throttled",
        4.0,
        false,
        TimeType.APP_PHYSICS)


func _init(
        character_sub_annotators := _SCAFFOLDER_CHARACTER_SUB_ANNOTATORS,
        level_specific_annotators := _SCAFFOLDER_LEVEL_SPECIFIC_ANNOTATORS,
        default_enablement := _SCAFFOLDER_DEFAULT_ENABLEMENT,
        character_annotation_class: Script = \
                ScaffolderCharacterAnnotator) -> void:
    Sc.logger.on_global_init(self, "ScaffolderAnnotators")
    self.character_sub_annotators = character_sub_annotators
    self.level_specific_annotators = level_specific_annotators
    self.default_enablement = default_enablement
    self.character_annotation_class = character_annotation_class
    if Engine.editor_hint:
        return
    annotation_layer = Sc.canvas_layers.layers.annotation


func _parse_manifest(manifest: Dictionary) -> void:
    for value in manifest.values():
        assert(!value is Color and !value is ColorConfig)
    Sc.utils.merge(params, manifest)


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    ruler_layer = Sc.canvas_layers.create_layer(
            "ruler",
            annotation_layer.layer + 5,
            Node.PAUSE_MODE_STOP)
    
    element_annotator = ElementAnnotator.new()
    annotation_layer.add_child(element_annotator)
    
    transient_annotator_registry = TransientAnnotatorRegistry.new()
    annotation_layer.add_child(transient_annotator_registry)
    
    for annotator_type in default_enablement:
        var is_enabled: bool = Sc.save_state.get_setting(
                AnnotatorType.get_settings_key(annotator_type),
                default_enablement[annotator_type])
        set_annotator_enabled(
                annotator_type,
                is_enabled)


func _on_app_initialized() -> void:
    if Engine.editor_hint:
        return
    
    Sc.nav.screens["game"].move_canvas_layer_to_game_viewport("ruler")


func on_level_ready() -> void:
    # Ensure any enabled annotators that depend on the level get drawn, now
    # that the level is available.
    for annotator_type in level_specific_annotators:
        if is_annotator_enabled(annotator_type):
            set_annotator_enabled(
                    annotator_type,
                    false)
            set_annotator_enabled(
                    annotator_type,
                    true)


func on_level_destroyed() -> void:
    element_annotator.clear()
    transient_annotator_registry.clear()
    for annotator_type in level_specific_annotators:
        if is_annotator_enabled(annotator_type):
            _destroy_annotator(annotator_type)
    for character in character_annotators.keys():
        destroy_character_annotator(character)


func create_character_annotator(character: ScaffolderCharacter) -> void:
    var character_annotator: ScaffolderCharacterAnnotator = \
            character_annotation_class.new(character)
    annotation_layer.add_child(character_annotator)
    character_annotators[character] = character_annotator
    
    for annotator_type in character_sub_annotators:
        character_annotator.set_annotator_enabled(
                annotator_type,
                _annotator_enablement[annotator_type])


func destroy_character_annotator(character: ScaffolderCharacter) -> void:
    if !character_annotators.has(character):
        return
    character_annotators[character].queue_free()
    character_annotators.erase(character)


func get_character_annotator(
        character: ScaffolderCharacter) -> ScaffolderCharacterAnnotator:
    return character_annotators[character]


func set_annotator_enabled(
        annotator_type: int,
        is_enabled: bool) -> void:
    if is_annotator_enabled(annotator_type) == is_enabled:
        # Do nothing. The annotator is already correct.
        return
    
    if is_enabled and \
            Sc.is_initialized:
        _show_reduced_frame_rate_notification()
    
    if character_sub_annotators.find(annotator_type) >= 0:
        for character_annotator in character_annotators.values():
            character_annotator.set_annotator_enabled(
                    annotator_type,
                    is_enabled)
    else:
        if is_enabled:
            _create_annotator(annotator_type)
        else:
            _destroy_annotator(annotator_type)
    
    _annotator_enablement[annotator_type] = is_enabled


func is_annotator_enabled(annotator_type: int) -> bool:
    if !_annotator_enablement.has(annotator_type):
        _annotator_enablement[annotator_type] = false
    return _annotator_enablement[annotator_type]


func _create_annotator(annotator_type: int) -> void:
    assert(!is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.RULER:
            if Sc.level != null:
                ruler_annotator = RulerAnnotator.new()
                ruler_layer.add_child(ruler_annotator)
        AnnotatorType.LEVEL:
            if Sc.level != null:
                Sc.level.set_tilemap_visibility(true)
                Sc.level.set_background_visibility(true)
        _:
            Sc.logger.error("ScaffolderAnnotators._create_annotator")


func _destroy_annotator(annotator_type: int) -> void:
    assert(is_annotator_enabled(annotator_type))
    match annotator_type:
        AnnotatorType.RULER:
            if ruler_annotator != null:
                ruler_annotator.queue_free()
                ruler_annotator = null
        AnnotatorType.LEVEL:
            if Sc.level != null:
                Sc.level.set_tilemap_visibility(false)
                Sc.level.set_background_visibility(false)
        _:
            Sc.logger.error("ScaffolderAnnotators._create_annotator")


func add_transient(annotator: TransientAnnotator) -> void:
    transient_annotator_registry.add(annotator)


func _show_reduced_frame_rate_notification() -> void:
    _throttled_frame_rate_notification.call_func()


func _show_reduced_frame_rate_notification_throttled() -> void:
    var toast_data := NotificationData.new(
            "Frame rates are reduced\nwhen showing annotations.")
    Sc.notify.show_toast(toast_data)

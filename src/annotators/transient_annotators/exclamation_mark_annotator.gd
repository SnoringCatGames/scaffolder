class_name ExclamationMarkAnnotator
extends TransientAnnotator


var character
var character_half_height: float
var color: Color
var border_color: Color
var width_start: float
var length_start: float
var stroke_width_start: float
var scale_end: float
var vertical_offset: float
var opacity_delay: float

var mark_scale: float
var opacity: float


func _init(
        character,
        character_half_height := INF,
        color = Color.white,
        border_color = Color.white,
        width_start := Sc.annotators.params.exclamation_mark_width_start,
        length_start := Sc.annotators.params.exclamation_mark_length_start,
        stroke_width_start := Sc.annotators.params.exclamation_mark_stroke_width_start,
        duration := Sc.annotators.params.exclamation_mark_duration,
        scale_end := Sc.annotators.params.exclamation_mark_scale_end,
        vertical_offset := Sc.annotators.params.exclamation_mark_vertical_offset,
        opacity_delay := Sc.annotators.params.exclamation_mark_opacity_delay) \
        .(duration) -> void:
    self.character = character
    self.character_half_height = \
            character_half_height if \
            !is_inf(character_half_height) else \
            character.collider.half_width_height.y
    if color is ColorConfig:
        self.color = color.sample()
    elif color != Color.white:
        self.color = color
    else:
        self.color = character.primary_annotation_color.sample()
    if border_color is ColorConfig:
        self.border_color = border_color.sample()
    elif border_color != Color.white:
        self.border_color = border_color
    else:
        self.border_color = character.secondary_annotation_color.sample()
    self.width_start = width_start
    self.length_start = length_start
    self.stroke_width_start = stroke_width_start
    self.scale_end = scale_end
    self.vertical_offset = vertical_offset
    self.opacity_delay = opacity_delay
    _update()


func _update() -> void:
    if !is_instance_valid(character):
        emit_signal("stopped")
        return
    
    ._update()
    
    var scale_progress := (current_time - start_time) / duration
    scale_progress = min(scale_progress, 1.0)
    scale_progress = Sc.utils.ease_by_name(
            scale_progress, "ease_out_very_strong")
    mark_scale = lerp(
            1.0,
            scale_end,
            scale_progress)
    
    var opacity_progress := \
            (current_time - start_time - opacity_delay) / \
            (duration - opacity_delay)
    opacity_progress = clamp(
            opacity_progress,
            0.0,
            1.0)
    opacity_progress = Sc.utils.ease_by_name(
            opacity_progress, "ease_out_very_strong")
    opacity = lerp(
            1.0,
            0.0,
            opacity_progress)


func _draw() -> void:
    if !is_instance_valid(character):
        return
    
    var width := width_start * mark_scale
    var length := length_start * mark_scale
    var stroke_width := stroke_width_start * mark_scale
    var arc_length := clamp(width / 4.0, 2.0, 6.0)
    
    var center: Vector2 = character.position + \
            Vector2(0.0,
                    -character_half_height - \
                    length_start * scale_end / 2.0 + \
                    vertical_offset)
    
    self.modulate.a = opacity
    
    Sc.draw.draw_exclamation_mark(
            self,
            center,
            width,
            length,
            border_color,
            false,
            stroke_width,
            arc_length)
    Sc.draw.draw_exclamation_mark(
            self,
            center,
            width,
            length,
            color,
            true,
            0.0,
            arc_length)

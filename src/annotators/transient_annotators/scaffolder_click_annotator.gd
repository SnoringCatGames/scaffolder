class_name ScaffolderClickAnnotator
extends TransientAnnotator


var click_position: Vector2

var inner_progress: float
var outer_progress: float


func _init(
        click_position: Vector2,
        duration_override = -1
        ).(
        duration_override if \
        duration_override > 0 else \
        max(Sc.annotators.params.click_inner_duration,
                Sc.annotators.params.click_outer_duration)
        ) -> void:
    self.click_position = click_position
    _update()


func _update() -> void:
    ._update()
    
    inner_progress = \
            (current_time - start_time) / \
            Sc.annotators.params.click_inner_duration
    inner_progress = Sc.utils.ease_by_name(inner_progress, "ease_out")
    
    outer_progress = \
            (current_time - start_time) / \
            Sc.annotators.params.click_outer_duration
    outer_progress = Sc.utils.ease_by_name(outer_progress, "ease_out")


func _draw() -> void:
    var is_inner_animation_complete := inner_progress >= 1.0
    var is_outer_animation_complete := outer_progress >= 1.0
    
    if !is_inner_animation_complete:
        var alpha: float = \
                Sc.palette.get_color("click_inner_color").a * (1 - inner_progress)
        var color := Color(
                Sc.palette.get_color("click_inner_color").r,
                Sc.palette.get_color("click_inner_color").g,
                Sc.palette.get_color("click_inner_color").b,
                alpha)
        var radius: float = \
                Sc.annotators.params.click_inner_end_radius * inner_progress
        
        draw_circle(
                click_position,
                radius,
                color)
    
    if !is_outer_animation_complete:
        var alpha: float = \
                Sc.palette.get_color("click_outer_color").a * (1 - outer_progress)
        var color := Color(
                Sc.palette.get_color("click_outer_color").r,
                Sc.palette.get_color("click_outer_color").g,
                Sc.palette.get_color("click_outer_color").b,
                alpha)
        var radius: float = \
                Sc.annotators.params.click_outer_end_radius * outer_progress
        
        draw_circle(
                click_position,
                radius,
                color)

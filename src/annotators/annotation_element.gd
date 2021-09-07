class_name AnnotationElement
extends Reference


var type := AnnotationElementType.UNKNOWN

# Array<LegendItem>
var _legend_items: Array


func _init(type: int) -> void:
    self.type = type


func get_legend_items() -> Array:
    if _legend_items.empty():
        _legend_items = _create_legend_items()
    return _legend_items


func _create_legend_items() -> Array:
    Sc.logger.error(
            "Abstract AnnotationElement._create_legend_items is not " +
            "implemented")
    return []


func draw(canvas: CanvasItem) -> void:
    Sc.logger.error("Abstract AnnotationElement.draw is not implemented")


func _destroy() -> void:
    # Do nothing unless the sub-class implements this.
    pass


func _draw_from_surface(
        canvas: CanvasItem,
        surface: Surface,
        color_params: ColorParams,
        depth := Sc.ann_params.surface_depth) -> void:
    var color := color_params.get_color()
    Sc.draw.draw_surface(
            canvas,
            surface,
            color,
            depth)

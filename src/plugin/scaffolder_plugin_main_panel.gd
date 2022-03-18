tool
class_name ScaffolderPluginMainPanel
extends CenterContainer


const _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS := 144.0


var _throttled_on_resize: FuncRef = Sc.time.throttle(
        funcref(self, "_adjust_size"),
        0.001,
        false,
        TimeType.APP_PHYSICS)


func _ready() -> void:
    _adjust_size()
    connect("resized", _throttled_on_resize, "call_func")
    
    # FIXME: LEFT OFF HERE: --------------------------------------------
    $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer/ \
            AccordionPanel/AccordionHeader.header_text = \
                St.manifest_controller.schema.display_name
    $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer/ \
            AccordionPanel/AccordionBody/FrameworkManifestPanel \
            .set_up(St.manifest_controller)


func _adjust_size() -> void:
    var size: Vector2 = get_parent().rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    $VBoxContainer/CenterContainer/ScrollContainer.rect_min_size = \
            size - _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS * Vector2.ONE

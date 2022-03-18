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
    var foo_manifest_controller := FrameworkManifestController.new(St.schema)
    $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer/ \
            AccordionPanel/AccordionHeader.header_text = \
                foo_manifest_controller.schema.display_name
    $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer/ \
            FrameworkManifestPanel \
            .set_up(foo_manifest_controller)
    $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer/ \
            AccordionPanel/AccordionBody/FrameworkManifestPanel \
            .set_up(foo_manifest_controller)


func _adjust_size() -> void:
    # FIXME: LEFT OFF HERE: ------------------------------
#    var size: Vector2 = get_parent().rect_size
    var size: Vector2 = self.rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    $VBoxContainer/CenterContainer/ScrollContainer.rect_min_size = \
            size - _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS * Vector2.ONE

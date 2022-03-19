tool
class_name ScaffolderPluginMainPanel
extends CenterContainer


const _FRAMEWORK_MANIFEST_PANEL_SCENE := preload(
        "res://addons/scaffolder/src/plugin/framework_manifest_panel.tscn")

const _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS := 144.0


var _throttled_on_resize: FuncRef = Sc.time.throttle(
        funcref(self, "_adjust_size"),
        0.001,
        false,
        TimeType.APP_PHYSICS)


func _ready() -> void:
    self.connect("resized", _throttled_on_resize, "call_func")
    _adjust_size()
    
    Sc.connect("initialized", self, "_reset_panels")
    if Sc.is_initialized:
        _reset_panels()


func _reset_panels() -> void:
    var container := \
            $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer
    Sc.utils.clear_children(container)
    for framework in Sc._framework_globals:
        var panel: FrameworkManifestPanel = \
                Sc.utils.add_scene(container, _FRAMEWORK_MANIFEST_PANEL_SCENE)
        panel.set_up(framework.manifest_controller)


func _adjust_size() -> void:
    # FIXME: LEFT OFF HERE: ------------------------------
#    var size: Vector2 = get_parent().rect_size
    var size: Vector2 = self.rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    $VBoxContainer/CenterContainer/ScrollContainer.rect_min_size = \
            size - _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS * Vector2.ONE

tool
class_name FrameworkManifestAccordionHeader, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_header.png"
extends Button


signal pressed

const _TEXTURE_PATH_PREFIX := \
        "res://addons/scaffolder/addons/plugger/assets/images/caret_right"

const _OPEN_ROTATION := -90.0
const _CLOSED_ROTATION := 0

export var is_open: bool setget _set_is_open,_get_is_open

var contents: Control
var caret: TextureRect
var _is_ready := false

var current_style: StyleBoxFlat
var normal_style: StyleBoxFlat
var hover_style: StyleBoxFlat
var active_style: StyleBoxFlat


func _ready() -> void:
    _is_ready = true
    
    _set_up_styles()
    _set_style(normal_style)
    
    var texture: Texture = Pl.get_icon(_TEXTURE_PATH_PREFIX)
    
    var children := self.get_children()
    assert(children.size() <= 2 and children.size() > 0)
    if children.size() == 1:
        assert(children[0] is Control)
        contents = children[0]
    
        caret = TextureRect.new()
        caret.texture = texture
        caret.rect_rotation = _OPEN_ROTATION
        self.add_child(caret)
        self.move_child(caret, 0)
    else:
        var is_first_child_caret := _get_is_caret(children[0])
        var is_second_child_caret := _get_is_caret(children[1])
        assert(is_first_child_caret or is_second_child_caret)
        if is_first_child_caret:
            caret = children[0]
            contents = children[1]
        else:
            caret = children[1]
            contents = children[0]
        caret.texture = texture


func _set_up_styles() -> void:
    var style_configs := [
        ["normal_style", Color("#11DDDDDD")],
        ["hover_style", Color("#88DDDDDD")],
        ["active_style", Color("#00DDDDDD")],
    ]
    for config in style_configs:
        var style_name: String = style_configs[0]
        var color: String = style_configs[1]
        var singleton_key := "Pl_accordion_header_%s" % style_name
        if !Singletons.has_value(singleton_key):
            var style := StyleBoxFlat.new()
            style.bg_color = color
            Singletons.set_value(singleton_key, style)
        set(style_name, Singletons.get_value(singleton_key))


func _get_is_caret(control: Node) -> bool:
    return control is TextureRect and \
            control.texture.resource_path.find("caret") >= 0


func _set_is_open(value: bool) -> void:
    if !_is_ready:
        return
    caret.rect_rotation = _OPEN_ROTATION if value else _CLOSED_ROTATION


func _get_is_open() -> bool:
    if !_is_ready:
        return false
    return caret.rect_rotation == _OPEN_ROTATION


func _set_style(style: StyleBoxFlat) -> void:
    current_style = style
    


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and \
            event.button_index == BUTTON_LEFT:
        if event.pressed
            _on_mouse_down()
        else:
            _on_mouse_up()


func _on_mouse_entered() -> void:
    pass


func _on_mouse_exited() -> void:
    pass


func _on_mouse_down() -> void:
    emit_signal("pressed")


func _on_mouse_up() -> void:
    pass

tool
class_name PlInterface
extends Node


const _MAIN_SCREEN_SCENE := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_plugin_main_screen.tscn")

var editor: EditorInterface

var main_screen



func _set_up() -> void:
    if !is_instance_valid(main_screen):
        main_screen = _MAIN_SCREEN_SCENE.instance()
        editor.get_editor_viewport().add_child(main_screen)


func _destroy() -> void:
    if is_instance_valid(main_screen):
        main_screen.queue_free()


func make_visible(visible: bool) -> void:
    if is_instance_valid(main_screen):
        main_screen.visible = visible


func scale_dimension(value):
    var scale := editor.get_editor_scale()
    return value * scale


func get_icon(path_prefix: String) -> Texture:
    return _static_get_icon(path_prefix, editor)


func validate_icons(path_prefix: String) -> void:
    var file := File.new()
    for theme in ["light", "dark"]:
        for scale in [0.75, 1.0, 1.5, 2.0]:
            var icon_path := _get_icon_path(path_prefix, theme, scale)
            assert(file.file_exists(icon_path),
                    "Plugin icon version is missing: " +
                    "theme=%s, scale=%s, path=%s" % [
                        theme,
                        str(scale),
                        icon_path,
                    ])


static func _static_get_icon(
        path_prefix: String,
        editor: EditorInterface) -> Texture:
    # TODO: We need better support for updating icon colors based on theme: 
    # https://github.com/godotengine/godot-proposals/issues/572
    var is_light_theme: bool = editor.get_editor_settings() \
            .get_setting("interface/theme/base_color").v > 0.5
    var theme := "light" if is_light_theme else "dark"
    var scale := editor.get_editor_scale()
    var icon_path := _get_icon_path(path_prefix, theme, scale)
    return load(icon_path) as Texture


static func _get_icon_path(
        path_prefix: String,
        theme := "dark",
        scale := 1.0) -> String:
    return ("%s_%s_theme_%s.png") % [
        path_prefix,
        theme,
        str(scale),
    ]

tool
class_name PlInterface
extends Node


const _MAIN_SCREEN_PATH := \
        "res://addons/scaffolder/addons/plugger/src/gui/framework_plugin_main_screen.tscn"

# EditorInterface
var editor

var main_screen

var _sc_auto_load


func _set_up() -> void:
    if !Engine.editor_hint:
        Sc.logger.error(
                "Pl._set_up should not be called from an exported game!")
        return
    assert(!is_instance_valid(main_screen))
    main_screen = load(_MAIN_SCREEN_PATH).instance()
    editor.get_editor_viewport().add_child(main_screen)


func _destroy() -> void:
    if is_instance_valid(main_screen):
        main_screen.queue_free()


func make_visible(visible: bool) -> void:
    if is_instance_valid(main_screen):
        main_screen.visible = visible


func save_manifest() -> void:
    _sc_auto_load.manifest_controller.save_manifest()
    

func scale_dimension(value):
    var scale: float = editor.get_editor_scale()
    return value * scale


func get_icon(path_prefix: String) -> Texture:
    return _static_get_icon(path_prefix, editor)


func get_editor_icon(icon_name: String) -> Texture:
    return editor.get_base_control().get_icon(icon_name, "EditorIcons")


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
        editor) -> Texture:
    # TODO: We need better support for updating icon colors based on theme: 
    # https://github.com/godotengine/godot-proposals/issues/572
    var is_light_theme: bool = editor.get_editor_settings() \
            .get_setting("interface/theme/base_color").v > 0.5
    var theme := "light" if is_light_theme else "dark"
    var scale: float = editor.get_editor_scale()
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

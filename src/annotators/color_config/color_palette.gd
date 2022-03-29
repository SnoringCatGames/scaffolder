tool
class_name ColorPalette
extends Node
## -   This is a mapping from color names to color values.[br]
## -   These color mappings are referenced by PaletteColorConfig instances.
## -   The registered values could be either Color or ColorConfig instances.


const _MAX_PALETTE_REDIRECT_DEPTH := 5

# Dictionary<String, Color|ColorConfig>
var _colors := {}


func _parse_manifest(manifest: Dictionary) -> void:
    for value in manifest.values():
        assert(value is Color or value is ColorConfig)
    Sc.utils.merge(_colors, manifest)


func set_color(
        key: String,
        color: Color) -> void:
    _colors[key] = color


func get_color(
        key: String,
        _redirect_depth := 0) -> Color:
    if _redirect_depth > _MAX_PALETTE_REDIRECT_DEPTH:
        Sc.logger.error(
            ("ColorPalette contains a redirect chain that is too long: " +
            "key=%s") % key)
        return ColorConfig.TRANSPARENT
    assert(_colors.has(key), "Key is not in ColorPalette: %s" % key)
    var color = _colors[key]
    if color is ColorConfig:
        return color.sample(_redirect_depth + 1)
    else:
        return color


func _destroy() -> void:
    _colors.clear()

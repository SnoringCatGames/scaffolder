tool
class_name NavBar, "res://addons/scaffolder/assets/images/editor_icons/nav_bar.png"
extends PanelContainer


const HEIGHT := 160.0
const SINGLE_ROW_WITH_LOGO_MIN_WIDTH_WIGGLE_ROOM := 32.0
const SINGLE_ROW_WITH_TEXT_MIN_WIDTH_WIGGLE_ROOM := 96.0

export var text := "" setget _set_text
export var shows_back := true setget _set_shows_back
export var shows_about := false setget _set_shows_about
export var shows_settings := false setget _set_shows_settings
export var shows_logo := false setget _set_shows_logo

var is_using_two_rows := false


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    set_meta("gs_rect_min_size", Vector2(0.0, HEIGHT))
    $MarginContainer/VBoxContainer/ButtonRow/RightContainer \
            .set_meta("gs_rect_min_size", Vector2(HEIGHT, HEIGHT))
    $MarginContainer/VBoxContainer/ButtonRow/LeftContainer \
            .set_meta("gs_rect_min_size", Vector2(HEIGHT, HEIGHT))
    
    $MarginContainer.set(
            "custom_constants/margin_top",
            Gs.utils.get_safe_area_margin_top())
    $MarginContainer.set(
            "custom_constants/margin_left",
            Gs.utils.get_safe_area_margin_left())
    $MarginContainer.set(
            "custom_constants/margin_right",
            Gs.utils.get_safe_area_margin_right())
    
    $MarginContainer/TopRow/Header \
            .add_color_override("font_color", Gs.colors.header)
    $MarginContainer/VBoxContainer/BottomRow/Header \
            .add_color_override("font_color", Gs.colors.header)
    
    $MarginContainer/TopRow/Logo \
            .texture = Gs.app_metadata.app_logo
    $MarginContainer/TopRow/Logo \
            .texture_scale = Vector2(
                    Gs.app_metadata.app_logo_scale,
                    Gs.app_metadata.app_logo_scale)
    $MarginContainer/VBoxContainer/BottomRow/Logo \
            .texture = Gs.app_metadata.app_logo
    $MarginContainer/VBoxContainer/BottomRow/Logo \
            .texture_scale = Vector2(
                    Gs.app_metadata.app_logo_scale,
                    Gs.app_metadata.app_logo_scale)
    
    update_gui_scale()


func update_gui_scale() -> bool:
    _update_visiblity()
    
    for child in get_children():
        Gs.utils.scale_gui_recursively(child)
    
    return true


func _update_visiblity() -> void:
    assert(text == "" or \
            !shows_logo)
    
    $MarginContainer/TopRow/Header \
            .text = text
    $MarginContainer/VBoxContainer/BottomRow/Header \
            .text = text
    
    call_deferred("_update_visibility_after_setting_text")


func _update_visibility_after_setting_text() -> void:
    var min_width_for_single_row: float
    if shows_logo:
        min_width_for_single_row = \
                (Gs.app_metadata.app_logo.get_size().x * \
                        Gs.app_metadata.app_logo_scale + \
                HEIGHT * 2) * Gs.gui.scale - \
                SINGLE_ROW_WITH_LOGO_MIN_WIDTH_WIGGLE_ROOM * Gs.gui.scale
    else:
        min_width_for_single_row = \
                $MarginContainer/TopRow/Header.rect_size.x + \
                        HEIGHT * 2 * Gs.gui.scale if \
                shows_back or shows_about or shows_settings else \
                -INF
        min_width_for_single_row -= \
                SINGLE_ROW_WITH_TEXT_MIN_WIDTH_WIGGLE_ROOM * Gs.gui.scale
    is_using_two_rows = get_viewport().size.x < min_width_for_single_row
    
    $MarginContainer/VBoxContainer/ButtonRow/RightContainer/BackButton \
            .visible = shows_back
    $MarginContainer/VBoxContainer/ButtonRow/RightContainer/AboutButton \
            .visible = shows_about
    $MarginContainer/VBoxContainer/ButtonRow/LeftContainer/SettingsButton \
            .visible = shows_settings
    
    $MarginContainer/TopRow \
            .visible = !is_using_two_rows
    $MarginContainer/VBoxContainer/BottomRow \
            .visible = is_using_two_rows
    $MarginContainer/VBoxContainer/Spacer \
            .visible = is_using_two_rows
    
    $MarginContainer/TopRow/Header \
            .visible = !shows_logo
    $MarginContainer/VBoxContainer/BottomRow/Header \
            .visible = !shows_logo
    $MarginContainer/TopRow/Logo \
            .visible = shows_logo
    $MarginContainer/VBoxContainer/BottomRow/Logo \
            .visible = shows_logo


func _set_text(value: String) -> void:
    text = value
    _update_visiblity()


func _set_shows_back(value: bool) -> void:
    shows_back = value
    _update_visiblity()


func _set_shows_about(value: bool) -> void:
    shows_about = value
    _update_visiblity()


func _set_shows_settings(value: bool) -> void:
    shows_settings = value
    _update_visiblity()


func _set_shows_logo(value: bool) -> void:
    shows_logo = value
    _update_visiblity()


func _on_BackButton_pressed() -> void:
    Gs.nav.close_current_screen()


func _on_AboutButton_pressed() -> void:
    Gs.nav.open("about")


func _on_SettingsButton_pressed() -> void:
    if Gs.level != null and \
            Gs.app_metadata.must_restart_level_to_change_settings:
        var description := (
                "The level must be restarted in order to change settings." +
                "\n\nAre you sure you want to restart the level?")
        Gs.nav.open(
                "notification",
                false,
                {
                    header_text = "Reset level?",
                    is_back_button_shown = true,
                    body_text = description,
                    close_button_text = "Yes",
                    body_alignment = BoxContainer.ALIGN_BEGIN,
                    next_screen = "settings",
                })
    else:
        Gs.nav.open("settings")

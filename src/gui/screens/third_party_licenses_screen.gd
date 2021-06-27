class_name ThirdPartyLicensesScreen
extends Screen


const NAME := "third_party_licenses"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := false

const BODY_WIDTH_SCALE := 2.0


func _init().(
        NAME,
        LAYER_NAME,
        IS_ALWAYS_ALIVE,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


func _ready() -> void:
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer \
            /VBoxContainer/Label.text = Gs.gui.third_party_license_text


func _on_resized() -> void:
    ._on_resized()
    
    var width := min(
            Gs.gui.screen_body_width * Gs.gui.scale * BODY_WIDTH_SCALE,
            get_viewport().size.x)
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            VBoxContainer/Label.rect_min_size.x = width

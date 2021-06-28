class_name DataAgreementScreen
extends Screen


const NAME := "data_agreement"
const LAYER_NAME := "menu_screen"
const IS_ALWAYS_ALIVE := false
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true


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
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/ \
            TermsAndConditionsLink.url = \
            Gs.app_metadata.terms_and_conditions_url
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/ \
            PrivacyPolicyLink.url = \
            Gs.app_metadata.privacy_policy_url


func _get_focused_button() -> ScaffolderButton:
    return $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AgreeButton as ScaffolderButton


func _on_AgreeButton_pressed() -> void:
    Gs.set_agreed_to_terms()
    Gs.nav.open("main_menu")

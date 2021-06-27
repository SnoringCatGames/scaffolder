class_name CreditsScreen
extends Screen


const GODOT_URL := "https://godotengine.org"

const NAME := "credits"
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
    var title_logo := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/Title
    var developer_logo_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/DeveloperLogoLink
    var developer_name_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/DeveloperNameLink
    var developer_url_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/DeveloperUrlLink
    var godot_logo_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer3/GodotLogoLink
    var godot_text_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer3/GodotTextLink
    var terms_and_conditions_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/TermsAndConditionsLink
    var privacy_policy_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/PrivacyPolicyLink
    var support_link := \
            $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/SupportLink
    
    title_logo.texture = Gs.app_metadata.app_logo
    title_logo.texture_scale = Vector2(
            Gs.app_metadata.app_logo_scale,
            Gs.app_metadata.app_logo_scale)
    
    developer_logo_link.visible = Gs.gui.is_developer_logo_shown
    developer_logo_link.texture = Gs.app_metadata.developer_logo
    developer_logo_link.url = Gs.app_metadata.developer_url
    developer_name_link.text = "Created by " + Gs.app_metadata.developer_name
    developer_name_link.url = Gs.app_metadata.developer_url
    developer_url_link.text = Gs.app_metadata.developer_url
    developer_url_link.url = Gs.app_metadata.developer_url
    
    godot_logo_link.url = GODOT_URL
    godot_text_link.url = GODOT_URL
    
    terms_and_conditions_link.url = Gs.app_metadata.terms_and_conditions_url
    privacy_policy_link.url = Gs.app_metadata.privacy_policy_url
    support_link.url = Gs.get_support_url_with_params()
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/SpecialThanksContainer/ \
            SpecialThanks.text = Gs.gui.special_thanks_text
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/SpecialThanksContainer.visible = \
            Gs.gui.is_special_thanks_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            TermsAndConditionsLink.visible = Gs.app_metadata.is_data_tracked
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            PrivacyPolicyLink.visible = Gs.app_metadata.is_data_tracked
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            DataDeletionButton.visible = \
                    Gs.app_metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            DataDeletionButtonPadding.visible = \
                    Gs.app_metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            SupportLink.visible = Gs.gui.is_support_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            ThirdPartyLicensesButton.visible = \
            Gs.gui.is_third_party_licenses_shown


func _on_DataDeletionButton_pressed() -> void:
    Gs.nav.open("confirm_data_deletion")


func _on_ThirdPartyLicensesButton_pressed() -> void:
    Gs.nav.open("third_party_licenses")

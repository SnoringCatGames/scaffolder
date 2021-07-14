class_name AboutScreen
extends Screen


const GODOT_URL := "https://godotengine.org"


func _ready() -> void:
    var title_logo := $VBoxContainer/Title
    var developer_logo_link := $VBoxContainer/VBoxContainer4/DeveloperLogoLink
    var developer_name_link := $VBoxContainer/VBoxContainer4/DeveloperNameLink
    var developer_url_link := $VBoxContainer/VBoxContainer4/DeveloperUrlLink
    var godot_logo_link := $VBoxContainer/VBoxContainer3/GodotLogoLink
    var godot_text_link := $VBoxContainer/VBoxContainer3/GodotTextLink
    var terms_and_conditions_link := \
            $VBoxContainer/VBoxContainer2/TermsAndConditionsLink
    var privacy_policy_link := $VBoxContainer/VBoxContainer2/PrivacyPolicyLink
    var support_link := $VBoxContainer/VBoxContainer2/SupportLink
    
    title_logo.texture = Gs.metadata.app_logo
    title_logo.texture_scale = Vector2(
            Gs.metadata.app_logo_scale,
            Gs.metadata.app_logo_scale)
    
    developer_logo_link.visible = Gs.gui.is_developer_logo_shown
    developer_logo_link.texture = Gs.metadata.developer_logo
    developer_logo_link.url = Gs.metadata.developer_url
    developer_name_link.text = "Created by " + Gs.metadata.developer_name
    developer_name_link.url = Gs.metadata.developer_url
    developer_url_link.text = Gs.metadata.developer_url
    developer_url_link.url = Gs.metadata.developer_url
    
    godot_logo_link.url = GODOT_URL
    godot_text_link.url = GODOT_URL
    
    terms_and_conditions_link.url = Gs.metadata.terms_and_conditions_url
    privacy_policy_link.url = Gs.metadata.privacy_policy_url
    support_link.url = Gs.get_support_url_with_params()
    
    $VBoxContainer/SpecialThanksContainer/SpecialThanks.text = \
            Gs.gui.special_thanks_text
    $VBoxContainer/SpecialThanksContainer.visible = \
            Gs.gui.is_special_thanks_shown
    
    $VBoxContainer/VBoxContainer2/TermsAndConditionsLink.visible = \
            Gs.metadata.is_data_tracked
    $VBoxContainer/VBoxContainer2/PrivacyPolicyLink.visible = \
            Gs.metadata.is_data_tracked
    $VBoxContainer/AccordionPanel/VBoxContainer/DataDeletionButton.visible = \
                    Gs.metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    $VBoxContainer/AccordionPanel/VBoxContainer/DataDeletionButtonPadding \
            .visible = \
                    Gs.metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    
    $VBoxContainer/VBoxContainer2/SupportLink.visible = \
            Gs.gui.is_support_shown
    
    $VBoxContainer/AccordionPanel/VBoxContainer/ThirdPartyLicensesButton \
            .visible = Gs.gui.is_third_party_licenses_shown


func _on_DataDeletionButton_pressed() -> void:
    Gs.nav.open("confirm_data_deletion")


func _on_ThirdPartyLicensesButton_pressed() -> void:
    Gs.nav.open("third_party_licenses")

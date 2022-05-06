tool
class_name AboutScreen
extends Screen


const GODOT_URL := "https://godotengine.org"


func _ready() -> void:
    var title_logo := $VBoxContainer/Title
    var developer_logo_link := $VBoxContainer/DeveloperSection/DeveloperLogoLink
    var developer_name_link := $VBoxContainer/DeveloperSection/DeveloperNameLink
    var developer_url_link := $VBoxContainer/DeveloperSection/DeveloperUrlLink
    var godot_logo_link := $VBoxContainer/HBoxContainer/GodotSection/GodotLogoLink
    var godot_text_link := $VBoxContainer/HBoxContainer/GodotSection/GodotTextLink
    var github_section := $VBoxContainer/HBoxContainer/GithubSection
    var github_logo_link := $VBoxContainer/HBoxContainer/GithubSection/GithubLogoLink
    var github_text_link := $VBoxContainer/HBoxContainer/GithubSection/GithubTextLink
    var terms_and_conditions_link := \
            $VBoxContainer/VBoxContainer2/TermsAndConditionsLink
    var privacy_policy_link := $VBoxContainer/VBoxContainer2/PrivacyPolicyLink
    var support_link := $VBoxContainer/VBoxContainer2/SupportLink
    
    title_logo.texture_scale = Vector2(
            Sc.images.app_logo_scale,
            Sc.images.app_logo_scale)
    
    developer_logo_link.visible = Sc.gui.is_developer_logo_shown
    developer_logo_link.url = Sc.metadata.developer_url
    developer_name_link.text = "Created by " + Sc.metadata.developer_name
    developer_name_link.url = Sc.metadata.developer_url
    developer_url_link.text = Sc.metadata.developer_url
    developer_url_link.url = Sc.metadata.developer_url
    
    godot_logo_link.url = GODOT_URL
    godot_text_link.url = GODOT_URL
    
    github_section.visible = Sc.metadata.github_url != ""
    github_logo_link.url = Sc.metadata.github_url
    github_text_link.url = Sc.metadata.github_url
    
    terms_and_conditions_link.url = Sc.metadata.terms_and_conditions_url
    privacy_policy_link.url = Sc.metadata.privacy_policy_url
    support_link.url = Sc.metadata.get_support_url_with_params()
    
    $VBoxContainer/SpecialThanksContainer/SpecialThanks.text = \
            Sc.gui.special_thanks_text
    $VBoxContainer/SpecialThanksContainer.visible = \
            Sc.gui.is_special_thanks_shown
    
    $VBoxContainer/VBoxContainer2/TermsAndConditionsLink.visible = \
            Sc.metadata.is_data_tracked
    $VBoxContainer/VBoxContainer2/PrivacyPolicyLink.visible = \
            Sc.metadata.is_data_tracked
    $VBoxContainer/AccordionPanel/AccordionBody/VBoxContainer/ \
            DataDeletionButton \
            .visible = \
                    Sc.metadata.is_data_tracked and \
                    Sc.gui.is_data_deletion_button_shown
    $VBoxContainer/AccordionPanel/AccordionBody/VBoxContainer/ \
            DataDeletionButtonPadding \
            .visible = \
                    Sc.metadata.is_data_tracked and \
                    Sc.gui.is_data_deletion_button_shown
    
    $VBoxContainer/VBoxContainer2/SupportLink.visible = \
            Sc.gui.is_support_shown
    
    $VBoxContainer/AccordionPanel/AccordionBody/VBoxContainer/ \
            ThirdPartyLicensesButton \
            .visible = Sc.gui.is_third_party_licenses_shown


func _on_DataDeletionButton_pressed() -> void:
    Sc.nav.open("confirm_data_deletion")


func _on_ThirdPartyLicensesButton_pressed() -> void:
    Sc.nav.open("third_party_licenses")

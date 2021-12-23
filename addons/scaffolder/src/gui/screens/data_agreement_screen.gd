tool
class_name DataAgreementScreen
extends Screen


func _ready() -> void:
    $VBoxContainer/VBoxContainer/HBoxContainer/TermsAndConditionsLink.url = \
            Sc.metadata.terms_and_conditions_url
    $VBoxContainer/VBoxContainer/HBoxContainer/PrivacyPolicyLink.url = \
            Sc.metadata.privacy_policy_url


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/AgreeButton as ScaffolderButton


func _on_AgreeButton_pressed() -> void:
    Sc.metadata.set_agreed_to_terms()
    Sc.nav.open("main_menu")

class_name DataAgreementScreen
extends Screen


func _ready() -> void:
    $VBoxContainer/VBoxContainer/HBoxContainer/TermsAndConditionsLink.url = \
            Gs.metadata.terms_and_conditions_url
    $VBoxContainer/VBoxContainer/HBoxContainer/PrivacyPolicyLink.url = \
            Gs.metadata.privacy_policy_url


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/AgreeButton as ScaffolderButton


func _on_AgreeButton_pressed() -> void:
    Gs.set_agreed_to_terms()
    Gs.nav.open("main_menu")

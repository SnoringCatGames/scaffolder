class_name ThirdPartyLicensesScreen
extends Screen


const BODY_WIDTH_SCALE := 2.0


func _ready() -> void:
    width_override = Gs.gui.screen_body_width * BODY_WIDTH_SCALE
    $Label.text = Gs.gui.third_party_license_text

tool
class_name ThirdPartyLicensesScreen
extends Screen


const BODY_WIDTH_SCALE := 2.0


func _init() -> void:
    width_override = Sc.gui.screen_body_width * BODY_WIDTH_SCALE


func _ready() -> void:
    $Label.text = Sc.gui.third_party_license_text

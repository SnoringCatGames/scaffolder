tool
class_name NotificationScreen
extends Screen


func set_params(params) -> void:
    .set_params(params)
    
    if params == null:
        return
    
    var body_text: ScaffolderLabel = $VBoxContainer/BodyText
    var link: ScaffolderLabelLink = $VBoxContainer/NotificationLink
    var close_button: ScaffolderButton = $VBoxContainer/CloseButton
    
    assert(params.has("header_text"))
    container.nav_bar.text = params["header_text"]
    assert(params.has("is_back_button_shown"))
    container.nav_bar.shows_back = params["is_back_button_shown"]
    assert(params.has("body_text"))
    body_text.text = params["body_text"]
    assert(params.has("close_button_text"))
    close_button.label = params["close_button_text"]
    
    if params.has("header_font_size"):
        container.nav_bar.font_size = params["header_font_size"]
    if params.has("body_font_size"):
        body_text.font_size = params["body_font_size"]
    
    if params.has("body_alignment"):
        body_text.align = params["body_alignment"]
    
    if params.has("link_text") or \
            params.has("link_href"):
        assert(params.has("link_text"))
        assert(params.has("link_href"))
        link.visible = true
        link.text = params["link_text"]
        link.url = params["link_href"]
    else:
        link.visible = false


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/CloseButton as ScaffolderButton


func _on_CloseButton_pressed() -> void:
    if params.has("close_callback"):
        params["close_callback"].call_func()
    
    if params.has("next_screen"):
        Sc.nav.close_current_screen()
        Sc.nav.open(params["next_screen"])
    else:
        Sc.nav.close_current_screen()

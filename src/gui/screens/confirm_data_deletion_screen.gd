class_name ConfirmDataDeletionScreen
extends Screen


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    $VBoxContainer/ClientIdNumber.text = str(Gs.analytics.client_id)


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/CancelButton as ScaffolderButton


func _on_ConfirmButton_pressed() -> void:
    Gs.save_state.erase_all_state()
    
    # Erase user files.
    Gs.utils.clear_directory("user://")
    
    var url: String = Gs.get_support_url_with_params()
    url += "&request-data-deletion=true&client-id=" + \
            str(Gs.analytics.client_id)
    OS.shell_open(url)
    
    quit()


func quit() -> void:
    get_tree().quit()
    Gs.nav.open("data_agreement")


func _on_CancelButton_pressed() -> void:
    Gs.nav.close_current_screen()

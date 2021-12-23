tool
class_name ConfirmDataDeletionScreenWithAnalytics
extends Screen


func _ready() -> void:
    $VBoxContainer/ClientIdNumber.text = str(Sc.analytics.client_id)


func quit() -> void:
    Sc.nav._on_app_quit()
    var next_screen := \
            "main_menu" if \
            !Sc.metadata.is_data_tracked else \
            "data_agreement"
    Sc.nav.open(next_screen)


func _get_focused_button() -> ScaffolderButton:
    return $VBoxContainer/CancelButton as ScaffolderButton


func _on_ConfirmButton_pressed() -> void:
    Sc.save_state.erase_all_state()
    
    # Erase user files.
    Sc.utils.clear_directory("user://")
    
    var url: String = Sc.metadata.get_support_url_with_params()
    url += "&request-data-deletion=true&client-id=" + \
            str(Sc.analytics.client_id)
    OS.shell_open(url)
    
    quit()


func _on_CancelButton_pressed() -> void:
    Sc.nav.close_current_screen()

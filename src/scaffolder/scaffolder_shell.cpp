#include "scaffolder/scaffolder_shell.h"

#include "scaffolder/scaffolder_level.h"
#include "scaffolder/scaffolder_module.h"
#include "scaffolder/screen_handler.h"
#include "scaffolder/screen_name.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/internal/ref_utils.h"
#include "snore_core/logger.h"
#include "snore_core/snore_core_main_settings.h"
#include "snore_core/snore_core_utils.h"

#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/scene_tree.hpp>

using namespace godot;

// TODO: Make sure all of this logic is overridable from GDSCript.

Ref<ScaffolderShell> ScaffolderShell::get() {
	return Scaffolder::get()->get_shell();
}

void ScaffolderShell::_ready() {
	Logger::get()->report_submodule_initialized(name);

	// Make the container fill the screen.
	set_anchors_and_offsets_preset(Control::PRESET_FULL_RECT);
	set_h_size_flags(Control::SIZE_EXPAND_FILL);
	set_v_size_flags(Control::SIZE_EXPAND_FILL);

	call_deferred("deferred_ready");
}

void ScaffolderShell::deferred_ready() {
	ScreenHandler::get()->open(ScaffolderSettings::get()->get_initial_screen());

	if (ScaffolderSettings::get()->get_full_screen()) {
		DisplayServer::get_singleton()->window_set_mode(
				DisplayServer::WINDOW_MODE_FULLSCREEN);
	}
}

void ScaffolderShell::_unhandled_input(const Ref<InputEvent> &p_event) {
	if (!SnoreCoreMainSettings::get()->get_dev_mode()) {
		return;
	}

	Ref<InputEventKey> key_event =
			Object::cast_to<InputEventKey>(p_event.ptr());
	if (!key_event.is_valid()) {
		return;
	}

	const Key key = key_event->get_physical_keycode();
	if (key == KEY_NONE) {
		return;
	}

	Scaffolder *scaffolder = Scaffolder::get();
	const ScaffolderSettings *settings = ScaffolderSettings::get();

	if (key == settings->get_screenshot_hotkey()) {
		SnoreCoreUtils::take_screenshot();
	}

	if (key == settings->get_toggle_hud_visibility_hotkey()) {
		Ref<Node> hud = scaffolder->get_hud();
		Ref<Node> super_hud = scaffolder->get_super_hud();
		// FIXME: LEFT OFF HERE: Lookup how to set visibility.
		if (is_instance_valid(hud)) {
			hud->visible = !hud->visible;
			Log::print(
					"Toggled HUD visibility: %s",
					(hud->visible ? "visible" : "hidden"));
		}
		if (is_instance_valid(super_hud)) {
			super_hud->visible = !super_hud->visible;
			Log::print(
					"Toggled SuperHUD visibility: %s",
					(super_hud->visible ? "visible" : "hidden"));
		}
	}

	if (key == settings->get_pause_hotkey()) {
		if (is_instance_valid(scaffolder->get_level()) &&
			settings->get_pauses_on_focus_out()) {
			scaffolder->get_level()->pause();
		}
	}

	if (key == settings->get_quit_hotkey()) {
		close_app();
	}
}

void ScaffolderShell::_notification(int p_notification) {
	switch (p_notification) {
		case NOTIFICATION_WM_GO_BACK_REQUEST: {
			if (ScreenHandler::get()->is_top_screen(ScreenName::main_menu())) {
				// Handle the Android back button to navigate within the app
				// instead of quitting the app.
				close_app();
			} else if (!ScreenHandler::get()->is_top_screen(
							   ScreenName::game())) {
				// Close the current screen if it's not game_screen.
				ScreenHandler::get()->close(
						ScreenHandler::get()->get_top_screen());
			}
			break;
		}
		case NOTIFICATION_WM_CLOSE_REQUEST: {
			close_app();
			break;
		}
		case NOTIFICATION_WM_WINDOW_FOCUS_OUT: {
			Ref<ScaffolderLevel> level = Scaffolder::get()->get_level();
			if (is_instance_valid(level) &&
				ScaffolderSettings::get()->get_pauses_on_focus_out()) {
				level->pause();
			}
			break;
		}
		default:
			break;
	}
}

void ScaffolderShell::close_app() {
	if (SnoreCoreUtils::get_were_screenshots_taken()) {
		SnoreCoreUtils::open_screenshot_folder();
	}

	Log::print("Closing the app");
	SnoreCore::get()->get_scene_tree()->call_deferred("quit");
}

void ScaffolderShell::_bind_methods() {
	ClassDB::bind_method(D_METHOD("close_app"), &ScaffolderShell::close_app);
}

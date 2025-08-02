#include "scaffolder/scaffolder_shell.h"

#include "snore_core/canvas_layer_config.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/logger.h"
#include "snore_core/snore_core_utils.h"

#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

// FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------

void ScaffolderShell::_enter_tree() {
	_create_canvas_layers();

	// TODO: Implement access to S.utils and S.scaffolder_settings.
	// This requires the global singleton system to be ported from GDScript.
	// For now, this is a placeholder implementation.

	/*
	if (!SnoreCoreUtils::is_running_in_isolated_scene_mode() ||
		Object::cast_to<ScaffolderLevel>(get_tree()->get_current_scene())) {

		Node *super_hud =
	S.scaffolder_settings.super_hud_scene.instantiate();
		add_to_canvas_layer("super_hud", super_hud);

		Node *hud = S.scaffolder_settings.hud_scene.instantiate();
		add_to_canvas_layer("hud", hud);
	}
	*/
}

void ScaffolderShell::_ready() {
	// Wait for a frame - this will need to be handled differently in C++.
	// In GDScript this was: await get_tree().process_frame
	// In C++ we might need to use a signal or defer the next operations.

	// TODO: Implement screen management.
	/*
	S.screens.open(S.scaffolder_settings.initial_screen);

	if (S.scaffolder_settings.full_screen) {
		DisplayServer::get_singleton()->window_set_mode(DisplayServer::WINDOW_MODE_FULLSCREEN);
	}
	*/
}

void ScaffolderShell::set_up() {
	// Make the container fill the screen.
	node->set_anchors_and_offsets_preset(Control::PRESET_FULL_RECT);
	node->set_h_size_flags(Control::SIZE_EXPAND_FILL);
	node->set_v_size_flags(Control::SIZE_EXPAND_FILL);
}

void ScaffolderShell::reset() {}

void ScaffolderShell::_notification(int p_notification) {
	switch (p_notification) {
		case NOTIFICATION_WM_GO_BACK_REQUEST: {
			// Handle the Android back button to navigate within the app instead
			// of quitting the app.
			// TODO: Implement screen management check.
			/*
			if (S.screens.is_top_screen("main_menu")) {
				close_app();
			} else {
				// TODO: Close the current screen if it's not game_screen.
			}
			*/
			break;
		}
		case NOTIFICATION_WM_CLOSE_REQUEST: {
			close_app();
			break;
		}
		case NOTIFICATION_WM_WINDOW_FOCUS_OUT: {
			// TODO: Implement level and settings access.
			/*
			if (is_instance_valid(S.level) &&
			S.scaffolder_settings.pauses_on_focus_out) { S.level.pause();
			}
			*/
			break;
		}
		default:
			break;
	}
}

void ScaffolderShell::_unhandled_input(const Ref<InputEvent> &p_event) {
	// TODO: Implement dev_mode check from scaffolder_settings.
	bool dev_mode = true; // Placeholder

	if (dev_mode) {
		Ref<InputEventKey> key_event =
				Object::cast_to<InputEventKey>(p_event.ptr());
		if (key_event.is_valid()) {
			switch (key_event->get_physical_keycode()) {
				case KEY_P: {
					// TODO: Implement screenshot hotkey flag check.
					// if
					// (S.scaffolder_settings.is_screenshot_hotkey_enabled)
					// {
					//     SnoreCoreUtils::take_screenshot();
					// }
					break;
				}
				case KEY_O: {
					// TODO: Implement HUD visibility toggle.
					/*
					if (is_instance_valid(S.hud)) {
						S.hud.visible = !S.hud.visible;
						Log::print(
							"Toggled HUD visibility: %s",
							S.hud.visible ? "visible" : "hidden");
					}
					*/
					break;
				}
				case KEY_ESCAPE: {
					// TODO: Implement level pause functionality.
					/*
					if (is_instance_valid(S.level) &&
					S.scaffolder_settings.pauses_on_focus_out) {
						S.level.pause();
					}
					*/
					break;
				}
				default:
					break;
			}
		}
	}
}

void ScaffolderShell::close_app() {
	// TODO: Implement screenshot check.
	/*
	if (SnoreCoreUtils::were_screenshots_taken()) {
		SnoreCoreUtils::open_screenshot_folder();
	}
	*/
	Log::print("Shell.close_app");
	get_tree()->call_deferred("quit");
}

void ScaffolderShell::_create_canvas_layers() {
	// TODO: Implement access to S.snore_core_settings.
	// This requires the settings system to be ported.
	// For now, we'll create a basic set of canvas layers as a placeholder.

	// Create common canvas layers that are typically used.
	Array default_layer_names;
	default_layer_names.append("background");
	default_layer_names.append("world");
	default_layer_names.append("hud");
	default_layer_names.append("super_hud");
	default_layer_names.append("overlay");

	for (int index = 0; index < default_layer_names.size(); index++) {
		String layer_name = default_layer_names[index];
		int z_index = default_layer_names.size() - index;

		CanvasLayer *canvas_layer = memnew(CanvasLayer);
		canvas_layer->set_name(layer_name);
		canvas_layer->set_process_mode(Node::PROCESS_MODE_WHEN_PAUSED);
		canvas_layer->set_layer(z_index);
		add_child(canvas_layer);
		_canvas_layers[layer_name] = canvas_layer;
	}

	/*
	// This is what the implementation should look like when settings are
	available: Array canvas_layer_configs = S.snore_core_settings.canvas_layers;
	int layer_count = canvas_layer_configs.size();
	for (int index = 0; index < layer_count; index++) {
		Ref<CanvasLayerConfig> config = canvas_layer_configs[index];
		int z_index = layer_count - index;
		CanvasLayer *canvas_layer = memnew(CanvasLayer);
		canvas_layer->set_name(config->get_name());
		canvas_layer->set_process_mode(config->get_process_mode());
		canvas_layer->set_layer(z_index);
		add_child(canvas_layer);
		_canvas_layers[config->get_name()] = canvas_layer;
	}
	*/
}

void ScaffolderShell::add_to_canvas_layer(
		const String &p_layer_name,
		Node *p_node) {
	if (!_canvas_layers.has(p_layer_name)) {
		Log::error(
				"ScaffolderShell.add_to_canvas_layer: Invalid "
				"CanvasLayer name: %s",
				p_layer_name);
		return;
	}

	CanvasLayer *canvas_layer =
			Object::cast_to<CanvasLayer>(_canvas_layers[p_layer_name]);
	if (canvas_layer) {
		canvas_layer->add_child(p_node);
	}
}

void ScaffolderShell::remove_from_canvas_layer(
		const String &p_layer_name,
		Node *p_node) {
	if (!_canvas_layers.has(p_layer_name)) {
		Log::error(
				"ScaffolderShell.remove_from_canvas_layer: Invalid "
				"CanvasLayer name: %s",
				p_layer_name);
		return;
	}

	CanvasLayer *canvas_layer =
			Object::cast_to<CanvasLayer>(_canvas_layers[p_layer_name]);
	if (canvas_layer) {
		canvas_layer->remove_child(p_node);
	}
}

void ScaffolderShell::_bind_methods() {
	ClassDB::bind_method(D_METHOD("close_app"), &ScaffolderShell::close_app);
	ClassDB::bind_method(
			D_METHOD("add_to_canvas_layer", "layer_name", "node"),
			&ScaffolderShell::add_to_canvas_layer);
	ClassDB::bind_method(
			D_METHOD("remove_from_canvas_layer", "layer_name", "node"),
			&ScaffolderShell::remove_from_canvas_layer);
}

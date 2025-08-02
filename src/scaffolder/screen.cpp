#include "scaffolder/screen.h"

#include "scaffolder/scaffolder_settings.h"
#include "snore_core/logger.h"

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void ScaffolderScreen::_ready() {
	PanelContainer::_ready();
	set_process_mode(Node::PROCESS_MODE_ALWAYS);
	set_theme(ScaffolderSettings::get()->get_main_theme());
}

void ScaffolderScreen::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("get_canvas_layer"), &ScaffolderScreen::get_canvas_layer);
	ClassDB::bind_method(
			D_METHOD("set_canvas_layer", "canvas_layer"),
			&ScaffolderScreen::set_canvas_layer);

	ClassDB::bind_method(
			D_METHOD("get_pauses_game_when_open"),
			&ScaffolderScreen::get_pauses_game_when_open);
	ClassDB::bind_method(
			D_METHOD("set_pauses_game_when_open", "pauses_game_when_open"),
			&ScaffolderScreen::set_pauses_game_when_open);

	ClassDB::bind_method(
			D_METHOD("get_screen_state"), &ScaffolderScreen::get_screen_state);
	ClassDB::bind_method(
			D_METHOD("set_screen_state", "screen_state"),
			&ScaffolderScreen::set_screen_state);

	ADD_PROPERTY(
			PropertyInfo(Variant::STRING, "canvas_layer"), "set_canvas_layer",
			"get_canvas_layer");
	ADD_PROPERTY(
			PropertyInfo(Variant::BOOL, "pauses_game_when_open"),
			"set_pauses_game_when_open", "get_pauses_game_when_open");
	ADD_PROPERTY(
			PropertyInfo(
					Variant::INT, "screen_state", PROPERTY_HINT_ENUM,
					"CLOSED,OPEN,TOP"),
			"set_screen_state", "get_screen_state");

	BIND_ENUM_CONSTANT(CLOSED);
	BIND_ENUM_CONSTANT(OPEN);
	BIND_ENUM_CONSTANT(TOP);
}

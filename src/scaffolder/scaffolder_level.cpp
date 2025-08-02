#include "scaffolder/scaffolder_level.h"

#include "scaffolder/game_session.h"
#include "scaffolder/scaffolder_module.h"
#include "scaffolder/screen.h"
#include "scaffolder/screen_name.h"
#include "snore_core/snore_core_utils.h"
#include "snore_core/time/snore_core_time.h"

#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/scene_tree_timer.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void ScaffolderLevel::_ready() {
	Node2D::_ready();
	Scaffolder::get()->on_level_loaded(this);
}

void ScaffolderLevel::reset() {
	has_started = false;
	has_ended = false;
}

void ScaffolderLevel::start() {
	Log::print("Starting level: %s", SnoreCoreUtils::get_display_name(this));

	reset();
	Scaffolder::get()->get_session()->start();

	unpause();
	has_started = true;

	Scaffolder::get()->on_level_started(this);

	// FIXME: LEFT OFF HERE: Play SFX when audio module is available.
	// S.audio.play_sfx("level_start")
}

void ScaffolderLevel::pause() {
	// FIXME: LEFT OFF HERE: Handle screen management when screens module is
	// available.
	// if S.screens.is_top_screen(ScreenName::game()):
	//     S.screens.open("pause")

	get_tree()->set_pause(true);
}

void ScaffolderLevel::unpause() {
	// FIXME: LEFT OFF HERE: Handle screen management when screens module is
	// available.
	// if not S.screens.is_top_screen(ScreenName::game()):
	//     S.screens.close_screens_above(ScreenName::game())

	get_tree()->set_pause(false);
}

void ScaffolderLevel::game_over(bool p_success) {
	const String result = p_success ? "success" : "failure";
	const String display_name = SnoreCoreUtils::get_display_name(this);
	Log::print("Game over: %s on level %s", result, display_name);

	Scaffolder::get()->get_session()->end();

	has_ended = true;

	Scaffolder::get()->on_level_ended(this);

	SnoreCoreTime::get()->set_timeout(
			Callable(this, "show_game_over_screen"),
			ScaffolderSettings::get()->get_game_over_screen_delay_sec());
}

void ScaffolderLevel::show_game_over_screen() {
	// FIXME: LEFT OFF HERE: Handle screen management when screens module is
	// available.
	// S.screens.open(ScreenName::game_over())
	// S.screens.close(ScreenName::game())
}

void ScaffolderLevel::_bind_methods() {
	ClassDB::bind_method(D_METHOD("reset"), &ScaffolderLevel::reset);
	ClassDB::bind_method(D_METHOD("start"), &ScaffolderLevel::start);
	ClassDB::bind_method(D_METHOD("pause"), &ScaffolderLevel::pause);
	ClassDB::bind_method(D_METHOD("unpause"), &ScaffolderLevel::unpause);
	ClassDB::bind_method(
			D_METHOD("game_over", "p_success"), &ScaffolderLevel::game_over);

	ClassDB::bind_method(
			D_METHOD("get_has_started"), &ScaffolderLevel::get_has_started);
	ADD_PROPERTY(
			PropertyInfo(Variant::BOOL, "has_started"), "", "get_has_started");

	ClassDB::bind_method(
			D_METHOD("get_has_ended"), &ScaffolderLevel::get_has_ended);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "has_ended"), "", "get_has_ended");
}

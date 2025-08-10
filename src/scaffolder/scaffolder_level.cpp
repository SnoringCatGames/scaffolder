#include "scaffolder/scaffolder_level.h"

#include "scaffolder/audio_service.h"
#include "scaffolder/game_session.h"
#include "scaffolder/scaffolder_module.h"
#include "scaffolder/screen.h"
#include "scaffolder/screen_name.h"
#include "scaffolder/screen_service.h"
#include "scaffolder/sfx_name.h"
#include "snore_core/snore_core_utils.h"
#include "snore_core/time/time_service.h"

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

	AudioService::get()->play_sfx(SfxName::level_start());
}

void ScaffolderLevel::pause() {
	if (ScreenService::get()->is_top_screen(ScreenName::game())) {
		ScreenService::get()->open(ScreenName::pause());
	}

	get_tree()->set_pause(true);
}

void ScaffolderLevel::unpause() {
	if (!ScreenService::get()->is_top_screen(ScreenName::game())) {
		ScreenService::get()->close_screens_above(ScreenName::game());
	}

	get_tree()->set_pause(false);
}

void ScaffolderLevel::game_over(bool p_success) {
	const String result = p_success ? "success" : "failure";
	const String display_name = SnoreCoreUtils::get_display_name(this);
	Log::print("Game over: %s on level %s", result, display_name);

	Scaffolder::get()->get_session()->end();

	has_ended = true;

	Scaffolder::get()->on_level_ended(this);

	const StringName &sfx_name = p_success ? SfxName::game_over_success()
										   : SfxName::game_over_failure();
	AudioService::get()->play_sfx(sfx_name);

	TimeService::get()->set_timeout(
			Callable(this, "show_game_over_screen"),
			ScaffolderSettings::get()->get_game_over_screen_delay_sec());
}

void ScaffolderLevel::show_game_over_screen() {
	ScreenService::get()->open(ScreenName::game_over());
	ScreenService::get()->close(ScreenName::game());
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

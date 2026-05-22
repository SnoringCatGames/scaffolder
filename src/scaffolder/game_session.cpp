#include "scaffolder/game_session.h"

#include "snore_core/time/time_service.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GameSession::reset() {
	// Make each playthrough yield different random values.
	UtilityFunctions::randomize();
	start_time = 0.0;
	end_time = 0.0;
}

void GameSession::start() {
	reset();
	start_time = TimeService::play_time();
}

void GameSession::end() { end_time = TimeService::play_time(); }

float GameSession::get_play_time() const {
	if (start_time > 0) {
		if (end_time > 0) {
			return end_time - start_time;
		} else {
			// Guard against TimeService not being active (e.g. in
			// unit tests): play_time() returns 0 in that case, so
			// the naive `now - start_time` would be negative. Treat
			// "no TimeService" the same as "session just started".
			const float now = TimeService::play_time();
			return now > start_time ? now - start_time : 0.0;
		}
	} else {
		return 0.0;
	}
}

void GameSession::_bind_methods() {
	ClassDB::bind_method(D_METHOD("reset"), &GameSession::reset);

	ClassDB::bind_method(
			D_METHOD("get_start_time"), &GameSession::get_start_time);
	ClassDB::bind_method(
			D_METHOD("set_start_time", "start_time"),
			&GameSession::set_start_time);
	ADD_PROPERTY(
			PropertyInfo(Variant::FLOAT, "start_time"), "set_start_time",
			"get_start_time");

	ClassDB::bind_method(D_METHOD("get_end_time"), &GameSession::get_end_time);
	ClassDB::bind_method(
			D_METHOD("set_end_time", "end_time"), &GameSession::set_end_time);
	ADD_PROPERTY(
			PropertyInfo(Variant::FLOAT, "end_time"), "set_end_time",
			"get_end_time");

	ClassDB::bind_method(
			D_METHOD("get_play_time"), &GameSession::get_play_time);
	ADD_PROPERTY(
			PropertyInfo(
					Variant::FLOAT, "play_time", PROPERTY_HINT_NONE, "",
					PROPERTY_USAGE_EDITOR),
			"", "get_play_time");
}

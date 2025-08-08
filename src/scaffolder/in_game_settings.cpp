#include "scaffolder/in_game_settings.h"

#include "snore_core/internal/debug_utils.h"
#include "snore_core/internal/registration_utils.h"
#include "snore_core/time/time_service.h"

#include <godot_cpp/classes/resource_saver.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>

using namespace godot;

const StringName InGameSettings::user_settings_path =
		"user://user_settings.tres";
const StringName InGameSettings::default_settings_path =
		"res://addons/scaffolder2/src/config/default_settings.tres";

const StringName InGameSettings::sfx_volume_property_name = "sfx_volume";
const StringName InGameSettings::music_volume_property_name = "music_volume";
const StringName InGameSettings::show_logs_property_name = "show_logs";

void InGameSettings::set_up() {
	throttled_save = TimeService::get()->throttle(
			callable_mp(this, &InGameSettings::save_throttled), 0.3f, false);
}

void InGameSettings::reset() { throttled_save = {}; }

TypedArray<Dictionary> InGameSettings::get_settings_properties() {
	const TypedArray<Dictionary> property_list = get_property_list();
	TypedArray<Dictionary> filtered_properties;

	for (int i = 0; i < property_list.size(); i++) {
		Dictionary property = property_list[i];
		const int usage = property["usage"];

		// - PROPERTY_USAGE_SCRIPT_VARIABLE filters properties of this script.
		// - PROPERTY_USAGE_EDITOR filters @export properties.
		if ((usage & PROPERTY_USAGE_SCRIPT_VARIABLE) &&
			(usage & PROPERTY_USAGE_EDITOR)) {
			filtered_properties.push_back(property);
		}
	}

	return filtered_properties;
}

void InGameSettings::update_property(
		const StringName &p_name,
		const Variant &p_value) {
	Variant old_value = Object::get(p_name);

	Log::print(
			"Settings property changed: %s: %s => %s", p_name, old_value,
			p_value);

	set(p_name, p_value);
	throttled_save.call();
	emit_signal("property_changed", p_name, p_value, old_value);
}

void InGameSettings::save_throttled() {
	Log::print("Player settings saved");
	const Error result = ResourceSaver::get_singleton()->save(
			Ref<Resource>(this), user_settings_path);
	ENSURE(result == OK, "Failed to save user settings");
}

void InGameSettings::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("get_settings_properties"),
			&InGameSettings::get_settings_properties);
	ClassDB::bind_method(
			D_METHOD("update_property", "p_name", "p_value"),
			&InGameSettings::update_property);

	ClassDB::bind_method(
			D_METHOD("get_music_volume"), &InGameSettings::get_music_volume);
	ClassDB::bind_method(
			D_METHOD("set_music_volume", "p_value"),
			&InGameSettings::set_music_volume);
	ADD_PROPERTY(
			PropertyInfo(
					Variant::FLOAT, "music_volume", PROPERTY_HINT_RANGE,
					"0.0,1.0,0.05", PROPERTY_USAGE_EXPORTED_ITEM),
			"set_music_volume", "get_music_volume");

	ClassDB::bind_method(
			D_METHOD("get_sfx_volume"), &InGameSettings::get_sfx_volume);
	ClassDB::bind_method(
			D_METHOD("set_sfx_volume", "p_value"),
			&InGameSettings::set_sfx_volume);
	ADD_PROPERTY(
			PropertyInfo(
					Variant::FLOAT, "sfx_volume", PROPERTY_HINT_RANGE,
					"0.0,1.0,0.05", PROPERTY_USAGE_EXPORTED_ITEM),
			"set_sfx_volume", "get_sfx_volume");

	ClassDB::bind_method(
			D_METHOD("get_show_logs"), &InGameSettings::get_show_logs);
	ClassDB::bind_method(
			D_METHOD("set_show_logs", "p_value"),
			&InGameSettings::set_show_logs);
	ADD_PROPERTY(
			PropertyInfo(Variant::BOOL, "show_logs"), "set_show_logs",
			"get_show_logs");

	ADD_SIGNAL(MethodInfo(
			"property_changed", PropertyInfo(Variant::STRING_NAME, "name"),
			PropertyInfo(Variant::NIL, "new_value"),
			PropertyInfo(Variant::NIL, "old_value")));
}

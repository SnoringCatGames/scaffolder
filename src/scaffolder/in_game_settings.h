#ifndef IN_GAME_SETTINGS_H
#define IN_GAME_SETTINGS_H

#include "scaffolder/scaffolder_module.h"
#include "snore_core/internal/registration_utils.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/core/binder_common.hpp>

namespace godot {

class Callable;
class Dictionary;
class StringName;
template <class T> class TypedArray;
class Variant;

class InGameSettings : public SnoreCoreSubmodule {
	GDCLASS(InGameSettings, SnoreCoreSubmodule)
	SC_SUBMODULE_CLASS(InGameSettings, Scaffolder)

public:
	STATIC_STRING_NAME(user_settings_path, "user://user_settings.tres")
	STATIC_STRING_NAME(
			default_settings_path,
			"res://addons/scaffolder2/src/config/default_settings.tres")

	STATIC_STRING_NAME(sfx_volume_property_name, "sfx_volume")
	STATIC_STRING_NAME(music_volume_property_name, "music_volume")
	STATIC_STRING_NAME(show_logs_property_name, "show_logs")

	InGameSettings() = default;
	~InGameSettings() = default;

	TypedArray<Dictionary> get_settings_properties();

	void update_property(const StringName &p_name, const Variant &p_value);

	float get_music_volume() const { return music_volume; }
	void set_music_volume(float p_value) { music_volume = p_value; }

	float get_sfx_volume() const { return sfx_volume; }
	void set_sfx_volume(float p_value) { sfx_volume = p_value; }

	bool get_show_logs() const { return show_logs; }
	void set_show_logs(bool p_value) { show_logs = p_value; }

protected:
	static void _bind_methods();

private:
	void save_throttled();

	float music_volume = 0.5f;
	float sfx_volume = 0.5f;
	bool show_logs = false;

	Callable throttled_save;
};

} // namespace godot

#endif // IN_GAME_SETTINGS_H

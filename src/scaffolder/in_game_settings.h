#ifndef IN_GAME_SETTINGS_H
#define IN_GAME_SETTINGS_H

#include "scaffolder/scaffolder_module.h"
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
	static const StringName user_settings_path;
	static const StringName default_settings_path;

	static const StringName sfx_volume_property_name;
	static const StringName music_volume_property_name;
	static const StringName show_logs_property_name;

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

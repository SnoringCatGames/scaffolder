#ifndef SCAFFOLDER_SETTINGS_H
#define SCAFFOLDER_SETTINGS_H

#include "snore_core/snore_core_settings.h"

#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/theme.hpp>
#include <godot_cpp/core/binder_common.hpp>

namespace godot {

class StringName;

class ScaffolderSettings : public SnoreCoreSettings {
	GDCLASS(ScaffolderSettings, SnoreCoreSettings)
	SC_SETTINGS_CLASS_DECLARATION(ScaffolderSettings)

public:
	ScaffolderSettings() = default;
	~ScaffolderSettings() = default;

	bool get_god_mode() const { return god_mode; }
	void set_god_mode(bool p_value) { god_mode = p_value; }

	bool get_skip_main_menu_in_dev_mode() const {
		return skip_main_menu_in_dev_mode;
	}
	void set_skip_main_menu_in_dev_mode(bool p_value) {
		skip_main_menu_in_dev_mode = p_value;
	}

	bool get_full_screen() const { return full_screen; }
	void set_full_screen(bool p_value) { full_screen = p_value; }

	bool get_mute_music() const { return mute_music; }
	void set_mute_music(bool p_value) { mute_music = p_value; }

	bool get_pauses_on_focus_out() const { return pauses_on_focus_out; }
	void set_pauses_on_focus_out(bool p_value) {
		pauses_on_focus_out = p_value;
	}

	Key get_screenshot_hotkey() const { return screenshot_hotkey; }
	void set_screenshot_hotkey(Key p_value) { screenshot_hotkey = p_value; }

	Key get_toggle_hud_visibility_hotkey() const {
		return toggle_hud_visibility_hotkey;
	}
	void set_toggle_hud_visibility_hotkey(Key p_value) {
		toggle_hud_visibility_hotkey = p_value;
	}

	Key get_pause_hotkey() const { return pause_hotkey; }
	void set_pause_hotkey(Key p_value) { pause_hotkey = p_value; }

	Key get_quit_hotkey() const { return quit_hotkey; }
	void set_quit_hotkey(Key p_value) { quit_hotkey = p_value; }

	bool get_show_hud() const { return show_hud; }
	void set_show_hud(bool p_value) { show_hud = p_value; }

	Ref<Theme> get_main_theme() const { return main_theme; }
	void set_main_theme(const Ref<Theme> &p_theme) { main_theme = p_theme; }

	Ref<PackedScene> get_dev_mode_level() const { return dev_mode_level; }
	void set_dev_mode_level(const Ref<PackedScene> &p_scene) {
		dev_mode_level = p_scene;
	}

	Ref<PackedScene> get_main_level() const { return main_level; }
	void set_main_level(const Ref<PackedScene> &p_scene) {
		main_level = p_scene;
	}

	Ref<PackedScene> get_hud_scene() const { return hud_scene; }
	void set_hud_scene(const Ref<PackedScene> &p_scene) { hud_scene = p_scene; }

	Dictionary get_screens() const { return screens; }
	void set_screens(const Dictionary &p_screens) { screens = p_screens; }

	Dictionary get_sfxs() const { return sfxs; }
	void set_sfxs(const Dictionary &p_sfxs) { sfxs = p_sfxs; }

	double get_debug_time_scale() const { return debug_time_scale; }
	void set_debug_time_scale(double p_scale) { debug_time_scale = p_scale; }

	bool get_render_debug_annotations() const {
		return render_debug_annotations;
	}
	void set_render_debug_annotations(bool p_value) {
		render_debug_annotations = p_value;
	}

	Ref<PackedScene> get_super_hud_scene() const { return super_hud_scene; }
	void set_super_hud_scene(const Ref<PackedScene> &p_scene) {
		super_hud_scene = p_scene;
	}

	float get_game_over_screen_delay_sec() const {
		return game_over_screen_delay_sec;
	}
	void set_game_over_screen_delay_sec(float p_value) {
		game_over_screen_delay_sec = p_value;
	}

	StringName get_initial_screen() const;
	Ref<PackedScene> get_screen_scene(const StringName &p_name) const;
	bool has_screen_scene(const StringName &p_name) const;

protected:
	static void _bind_methods();

private:
	bool god_mode = false;
	bool skip_main_menu_in_dev_mode = false;
	bool full_screen = false;
	bool mute_music = false;
	bool pauses_on_focus_out = true;
	bool show_hud = true;

	Key screenshot_hotkey = KEY_P;
	Key toggle_hud_visibility_hotkey = KEY_O;
	Key pause_hotkey = KEY_ESCAPE;
	Key quit_hotkey = KEY_NONE;

	Ref<Theme> main_theme;
	Ref<PackedScene> dev_mode_level;
	Ref<PackedScene> main_level;
	Ref<PackedScene> hud_scene;

	Dictionary screens;
	Dictionary sfxs;

	double debug_time_scale = 1.0;
	bool render_debug_annotations = false;

	Ref<PackedScene> super_hud_scene;

	float game_over_screen_delay_sec = 2.0f;
};

} // namespace godot

#endif // SCAFFOLDER_SETTINGS_H

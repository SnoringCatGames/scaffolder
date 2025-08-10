#include "scaffolder/scaffolder_settings.h"

#include "scaffolder/scaffolder_module.h"
#include "scaffolder/screen.h"
#include "scaffolder/screen_name.h"
#include "snore_core/internal/registration_utils.h"
#include "snore_core/snore_core_main_settings.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string_name.hpp>

using namespace godot;

// TODO: Update the demo settings to use the default values from the old
//       manifest.gd.

SC_SETTINGS_CLASS_DEFINITION_ON_MODULE(ScaffolderSettings, Scaffolder)

StringName ScaffolderSettings::get_initial_screen() const {
	if (SnoreCoreMainSettings::get()->get_dev_mode() &&
		skip_main_menu_in_dev_mode) {
		return ScreenName::game();
	} else {
		return ScreenName::main_menu();
	}
}

Ref<PackedScene> ScaffolderSettings::get_screen_scene(
		const StringName &p_name) const {
	if (screens.has(p_name)) {
		return screens[p_name];
	}
	return Ref<PackedScene>();
}

bool ScaffolderSettings::has_screen_scene(const StringName &p_name) const {
	return screens.has(p_name);
}

void ScaffolderSettings::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("get_initial_screen"),
			&ScaffolderSettings::get_initial_screen);
	ClassDB::bind_method(
			D_METHOD("get_screen_scene", "p_name"),
			&ScaffolderSettings::get_screen_scene);
	ClassDB::bind_method(
			D_METHOD("has_screen_scene", "p_name"),
			&ScaffolderSettings::has_screen_scene);

	ClassDB::bind_method(
			D_METHOD("get_main_theme"), &ScaffolderSettings::get_main_theme);
	ClassDB::bind_method(
			D_METHOD("set_main_theme", "p_theme"),
			&ScaffolderSettings::set_main_theme);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::OBJECT, "main_theme", PROPERTY_HINT_RESOURCE_TYPE,
					"Theme"),
			"set_main_theme", "get_main_theme");

	ClassDB::bind_method(
			D_METHOD("get_dev_mode_level"),
			&ScaffolderSettings::get_dev_mode_level);
	ClassDB::bind_method(
			D_METHOD("set_dev_mode_level", "p_scene"),
			&ScaffolderSettings::set_dev_mode_level);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::OBJECT, "dev_mode_level",
					PROPERTY_HINT_RESOURCE_TYPE, "PackedScene"),
			"set_dev_mode_level", "get_dev_mode_level");

	ClassDB::bind_method(
			D_METHOD("get_main_level"), &ScaffolderSettings::get_main_level);
	ClassDB::bind_method(
			D_METHOD("set_main_level", "p_scene"),
			&ScaffolderSettings::set_main_level);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::OBJECT, "main_level", PROPERTY_HINT_RESOURCE_TYPE,
					"PackedScene"),
			"set_main_level", "get_main_level");

	ClassDB::bind_method(
			D_METHOD("get_hud_scene"), &ScaffolderSettings::get_hud_scene);
	ClassDB::bind_method(
			D_METHOD("set_hud_scene", "p_scene"),
			&ScaffolderSettings::set_hud_scene);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::OBJECT, "hud_scene", PROPERTY_HINT_RESOURCE_TYPE,
					"PackedScene"),
			"set_hud_scene", "get_hud_scene");

	ClassDB::bind_method(
			D_METHOD("get_screens"), &ScaffolderSettings::get_screens);
	ClassDB::bind_method(
			D_METHOD("set_screens", "p_screens"),
			&ScaffolderSettings::set_screens);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::DICTIONARY, "screens"),
			"set_screens", "get_screens");

	ClassDB::bind_method(D_METHOD("get_sfxs"), &ScaffolderSettings::get_sfxs);
	ClassDB::bind_method(
			D_METHOD("set_sfxs", "p_sfxs"), &ScaffolderSettings::set_sfxs);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::DICTIONARY, "sfxs"), "set_sfxs",
			"get_sfxs");

	ClassDB::bind_method(
			D_METHOD("get_debug_time_scale"),
			&ScaffolderSettings::get_debug_time_scale);
	ClassDB::bind_method(
			D_METHOD("set_debug_time_scale", "p_scale"),
			&ScaffolderSettings::set_debug_time_scale);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::FLOAT, "debug_time_scale", PROPERTY_HINT_RANGE,
					"0.5,5.0,0.1"),
			"set_debug_time_scale", "get_debug_time_scale");

	ADD_GROUP("Flags", "");
	ClassDB::bind_method(
			D_METHOD("get_god_mode"), &ScaffolderSettings::get_god_mode);
	ClassDB::bind_method(
			D_METHOD("set_god_mode", "p_value"),
			&ScaffolderSettings::set_god_mode);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "god_mode"), "set_god_mode",
			"get_god_mode");
	ClassDB::bind_method(
			D_METHOD("get_skip_main_menu_in_dev_mode"),
			&ScaffolderSettings::get_skip_main_menu_in_dev_mode);
	ClassDB::bind_method(
			D_METHOD("set_skip_main_menu_in_dev_mode", "p_value"),
			&ScaffolderSettings::set_skip_main_menu_in_dev_mode);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "skip_main_menu_in_dev_mode"),
			"set_skip_main_menu_in_dev_mode", "get_skip_main_menu_in_dev_mode");
	ClassDB::bind_method(
			D_METHOD("get_full_screen"), &ScaffolderSettings::get_full_screen);
	ClassDB::bind_method(
			D_METHOD("set_full_screen", "p_value"),
			&ScaffolderSettings::set_full_screen);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "full_screen"),
			"set_full_screen", "get_full_screen");
	ClassDB::bind_method(
			D_METHOD("get_mute_music"), &ScaffolderSettings::get_mute_music);
	ClassDB::bind_method(
			D_METHOD("set_mute_music", "p_value"),
			&ScaffolderSettings::set_mute_music);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "mute_music"),
			"set_mute_music", "get_mute_music");
	ClassDB::bind_method(
			D_METHOD("get_pauses_on_focus_out"),
			&ScaffolderSettings::get_pauses_on_focus_out);
	ClassDB::bind_method(
			D_METHOD("set_pauses_on_focus_out", "p_value"),
			&ScaffolderSettings::set_pauses_on_focus_out);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "pauses_on_focus_out"),
			"set_pauses_on_focus_out", "get_pauses_on_focus_out");
	ClassDB::bind_method(
			D_METHOD("get_show_hud"), &ScaffolderSettings::get_show_hud);
	ClassDB::bind_method(
			D_METHOD("set_show_hud", "p_value"),
			&ScaffolderSettings::set_show_hud);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "show_hud"), "set_show_hud",
			"get_show_hud");
	ClassDB::bind_method(
			D_METHOD("get_render_debug_annotations"),
			&ScaffolderSettings::get_render_debug_annotations);
	ClassDB::bind_method(
			D_METHOD("set_render_debug_annotations", "p_value"),
			&ScaffolderSettings::set_render_debug_annotations);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::BOOL, "render_debug_annotations"),
			"set_render_debug_annotations", "get_render_debug_annotations");
	// END GROUP "Flags"

	// TODO: Add PROPERTY_HINT_ENUM and hint strings for these hotkey enums.
	ADD_GROUP("Hotkeys", "");
	ClassDB::bind_method(
			D_METHOD("get_screenshot_hotkey"),
			&ScaffolderSettings::get_screenshot_hotkey);
	ClassDB::bind_method(
			D_METHOD("set_screenshot_hotkey", "p_value"),
			&ScaffolderSettings::set_screenshot_hotkey);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::INT, "screenshot_hotkey"),
			"set_screenshot_hotkey", "get_screenshot_hotkey");
	ClassDB::bind_method(
			D_METHOD("get_toggle_hud_visibility_hotkey"),
			&ScaffolderSettings::get_toggle_hud_visibility_hotkey);
	ClassDB::bind_method(
			D_METHOD("set_toggle_hud_visibility_hotkey", "p_value"),
			&ScaffolderSettings::set_toggle_hud_visibility_hotkey);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(
					Variant::INT, "toggle_hud_visibility_hotkey"),
			"set_toggle_hud_visibility_hotkey",
			"get_toggle_hud_visibility_hotkey");
	ClassDB::bind_method(
			D_METHOD("get_pause_hotkey"),
			&ScaffolderSettings::get_pause_hotkey);
	ClassDB::bind_method(
			D_METHOD("set_pause_hotkey", "p_value"),
			&ScaffolderSettings::set_pause_hotkey);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::INT, "pause_hotkey"),
			"set_pause_hotkey", "get_pause_hotkey");
	ClassDB::bind_method(
			D_METHOD("get_quit_hotkey"), &ScaffolderSettings::get_quit_hotkey);
	ClassDB::bind_method(
			D_METHOD("set_quit_hotkey", "p_value"),
			&ScaffolderSettings::set_quit_hotkey);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(Variant::INT, "quit_hotkey"),
			"set_quit_hotkey", "get_quit_hotkey");
	// END GROUP "Hotkeys"

	ADD_GROUP("Advanced", "");
	ClassDB::bind_method(
			D_METHOD("get_super_hud_scene"),
			&ScaffolderSettings::get_super_hud_scene);
	ClassDB::bind_method(
			D_METHOD("set_super_hud_scene", "p_scene"),
			&ScaffolderSettings::set_super_hud_scene);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO_WITH_HINT(
					Variant::OBJECT, "super_hud_scene",
					PROPERTY_HINT_RESOURCE_TYPE, "PackedScene"),
			"set_super_hud_scene", "get_super_hud_scene");
	ClassDB::bind_method(
			D_METHOD("get_game_over_screen_delay_sec"),
			&ScaffolderSettings::get_game_over_screen_delay_sec);
	ClassDB::bind_method(
			D_METHOD("set_game_over_screen_delay_sec", "p_delay_sec"),
			&ScaffolderSettings::set_game_over_screen_delay_sec);
	ADD_PROPERTY(
			EXPORTED_PROPERTY_INFO(
					Variant::FLOAT, "game_over_screen_delay_sec"),
			"set_game_over_screen_delay_sec", "get_game_over_screen_delay_sec");
}

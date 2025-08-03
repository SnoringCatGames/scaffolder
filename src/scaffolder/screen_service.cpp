#include "scaffolder/screen_service.h"

#include "scaffolder/scaffolder_level.h"
#include "scaffolder/scaffolder_shell.h"
#include "scaffolder/screen_name.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/log_service.h"
#include "snore_core/snore_core_utils.h"

#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/variant.hpp>

using namespace godot;

void ScreenService::set_up() {}

void ScreenService::reset() {}

void ScreenService::open(const StringName &p_screen_name) {
	if (SnoreCoreUtils::is_running_in_isolated_scene_mode()) {
		Log::warning(
				"Screens not opened in isolated-scene mode: %s", p_screen_name);
		return;
	}

	const ScaffolderSettings *settings = ScaffolderSettings::get();
	if (!ENSURE(settings->has_screen_scene(p_screen_name),
				vformat("Invalid screen_name: %s", p_screen_name))) {
		return;
	}

	const Ref<ActiveScreen> previous_screen = get_top_screen();

	if (previous_screen.is_valid() &&
		previous_screen->get_name() == p_screen_name) {
		Log::print("Screen already open: %s", p_screen_name);
		return;
	}

	if (get_active_screen_by_name(p_screen_name).is_valid()) {
		Log::print(
				"Moving preexisting screen to the top, rather than "
				"creating a new instance: %s",
				p_screen_name);
		move_screen_to_top(p_screen_name);
		return;
	}

	Log::print("Opening screen: %s", p_screen_name);

	// Prepare the new screen.
	const Ref<PackedScene> scene = settings->get_screen_scene(p_screen_name);
	ScaffolderScreen *screen =
			Object::cast_to<ScaffolderScreen>(scene->instantiate());
	if (!ENSURE(screen,
				vformat("Failed to instantiate screen: %s", p_screen_name))) {
		return;
	}

	Ref<ActiveScreen> stack_entry =
			set_up_ref<ActiveScreen>(p_screen_name, screen);

	// Update the screen-state of the old screen.
	if (previous_screen.is_valid()) {
		previous_screen->get_screen()->set_screen_state(ScaffolderScreen::OPEN);
	}

	// Open the new screen.
	ScaffolderShell::get()->add_to_layer(screen->get_canvas_layer(), screen);
	screen_stack.push_back(stack_entry);
	screen->set_screen_state(ScaffolderScreen::TOP);

	if (is_a_pausing_screen_above_level()) {
		// Pause the level when a screen is opened above it.
		Ref<ScaffolderLevel> level = Scaffolder::get()->get_level();
		if (level.is_valid()) {
			level->pause();
		}
	}
}

void ScreenService::close_screens_above(const StringName &p_screen_name) {
	const Ref<ActiveScreen> target_screen =
			get_active_screen_by_name(p_screen_name);
	if (!ENSURE(target_screen.is_valid(),
				vformat("close_screens_above called for a screen that isn't "
						"actually open: %s",
						p_screen_name))) {
		return;
	}

	Ref<ActiveScreen> top_screen = get_top_screen();
	while (top_screen.is_valid() && top_screen->get_name() != p_screen_name) {
		close(top_screen->get_name());
		top_screen = get_top_screen();
	}
}

void ScreenService::move_screen_to_top(const StringName &p_screen_name) {
	Ref<ActiveScreen> previous_screen = get_top_screen();
	if (!ENSURE(previous_screen.is_valid(), "No previous screen found")) {
		return;
	}
	previous_screen->get_screen()->set_screen_state(ScaffolderScreen::OPEN);

	Ref<ActiveScreen> next_screen = get_active_screen_by_name(p_screen_name);
	std::vector<Ref<ActiveScreen>>::iterator it =
			std::find(screen_stack.begin(), screen_stack.end(), next_screen);
	if (it != screen_stack.end()) {
		screen_stack.erase(it);
	}
	screen_stack.push_back(next_screen);

	next_screen->get_screen()->set_screen_state(ScaffolderScreen::TOP);
}

bool ScreenService::close(const Variant &p_screen_node_or_name) {
	const String display_text =
			SnoreCoreUtils::get_display_name(p_screen_node_or_name);
	Log::print("ScreenService.close( %s )", display_text);

	// Get the screen entry to close.
	Ref<ActiveScreen> screen_entry;
	if (p_screen_node_or_name.get_type() == Variant::STRING) {
		screen_entry = get_active_screen_by_name(p_screen_node_or_name);
	} else {
		const ScaffolderScreen *screen_node =
				Object::cast_to<ScaffolderScreen>(p_screen_node_or_name);
		screen_entry = get_active_screen_by_node(screen_node);
	}

	if (!screen_entry.is_valid()) {
		Log::print("Screen not open: %s", display_text);
		return false;
	}

	// Remove the old screen.
	const std::vector<Ref<ActiveScreen>>::iterator it =
			std::find(screen_stack.begin(), screen_stack.end(), screen_entry);
	if (it != screen_stack.end()) {
		screen_stack.erase(it);
	}
	screen_entry->get_screen()->queue_free();

	// Update the screen-state of the new top screen.
	Ref<ActiveScreen> top_screen = get_top_screen();
	if (top_screen.is_valid() &&
		top_screen->get_screen()->get_screen_state() != ScaffolderScreen::TOP) {
		top_screen->get_screen()->set_screen_state(ScaffolderScreen::TOP);
	}

	// Possibly unpause the level.
	if (!is_a_pausing_screen_above_level() &&
		screen_entry->get_name() != ScreenName::game()) {
		Ref<ScaffolderLevel> level = Scaffolder::get()->get_level();
		if (level.is_valid()) {
			level->unpause();
		}
	}

	return true;
}

Ref<ActiveScreen> ScreenService::get_top_screen() {
	if (screen_stack.empty()) {
		return Ref<ActiveScreen>();
	}
	return screen_stack.back();
}

bool ScreenService::is_top_screen(const StringName &p_screen_name) {
	Ref<ActiveScreen> top_screen = get_top_screen();
	return top_screen.is_valid() && top_screen->get_name() == p_screen_name;
}

Ref<ActiveScreen> ScreenService::get_active_screen_by_name(
		const StringName &p_name) {
	for (int i = 0; i < screen_stack.size(); i++) {
		Ref<ActiveScreen> entry = screen_stack[i];
		if (entry.is_valid() && entry->get_name() == p_name) {
			return entry;
		}
	}
	return Ref<ActiveScreen>();
}

Ref<ActiveScreen> ScreenService::get_active_screen_by_node(
		const ScaffolderScreen *p_screen) {
	for (int i = 0; i < screen_stack.size(); i++) {
		Ref<ActiveScreen> entry = screen_stack[i];
		if (entry.is_valid() && entry->get_screen() == p_screen) {
			return entry;
		}
	}
	return Ref<ActiveScreen>();
}

bool ScreenService::is_a_pausing_screen_above_level() {
	const Ref<ActiveScreen> game_screen =
			get_active_screen_by_name(ScreenName::game());

	if (!game_screen.is_valid()) {
		return false;
	}

	const std::vector<Ref<ActiveScreen>>::iterator it =
			std::find(screen_stack.begin(), screen_stack.end(), game_screen);
	const int game_screen_index = std::distance(screen_stack.begin(), it);
	int index = game_screen_index + 1;
	while (screen_stack.size() > index) {
		const Ref<ActiveScreen> entry = screen_stack[index];
		if (entry.is_valid() &&
			entry->get_screen()->get_pauses_game_when_open()) {
			return true;
		}
		index++;
	}

	return false;
}

void ScreenService::_bind_methods() {
	ClassDB::bind_method(D_METHOD("open", "screen_name"), &ScreenService::open);
	ClassDB::bind_method(
			D_METHOD("close_screens_above", "screen_name"),
			&ScreenService::close_screens_above);
	ClassDB::bind_method(
			D_METHOD("close", "screen_node_or_name"), &ScreenService::close);
	ClassDB::bind_method(
			D_METHOD("get_top_screen"), &ScreenService::get_top_screen);
	ClassDB::bind_method(
			D_METHOD("is_top_screen", "screen_name"),
			&ScreenService::is_top_screen);
}

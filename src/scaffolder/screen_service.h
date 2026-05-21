#ifndef SCREEN_SERVICE_H
#define SCREEN_SERVICE_H

#include "scaffolder/active_screen.h"
#include "scaffolder/scaffolder_module.h"
#include "scaffolder/screen.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/templates/hash_map.hpp>

#include <vector>

namespace godot {

class StringName;
class Variant;

class ScreenService : public SnoreCoreSubmodule {
	GDCLASS(ScreenService, SnoreCoreSubmodule)
	SC_SUBMODULE_CLASS(ScreenService, Scaffolder)

public:
	static const std::unordered_map<std::string, std::string> default_screens;

	ScreenService() = default;
	virtual ~ScreenService() = default;

	// Opens a screen and adds it to the top of the screen stack.
	void open(const StringName &p_screen_name);

	// Closes all screens above the specified screen in the stack.
	void close_screens_above(const StringName &p_screen_name);

	// Closes the specified screen.
	// - Returns true if the screen was found and closed.
	bool close(const Variant &p_screen_node_or_name);

	// Gets the top screen from the stack, or null if the stack is empty.
	Ref<ActiveScreen> get_top_screen();

	// Checks if the specified screen is currently the top screen.
	bool is_top_screen(const StringName &p_screen_name);

protected:
	static void _bind_methods();

private:
	std::vector<Ref<ActiveScreen>> screen_stack;

	HashMap<StringName, Ref<PackedScene>> registered_screens;

	void move_screen_to_top(const StringName &p_screen_name);

	Ref<ActiveScreen> get_active_screen_by_name(const StringName &p_name);

	Ref<ActiveScreen> get_active_screen_by_node(
			const ScaffolderScreen *p_screen);

	bool is_a_pausing_screen_above_level();
};

} //namespace godot

#endif // SCREEN_SERVICE_H

#ifndef ACTIVE_SCREEN_H
#define ACTIVE_SCREEN_H

#include "scaffolder/screen.h"

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/string.hpp>

namespace godot {

class ActiveScreen : public RefCounted {
	GDCLASS(ActiveScreen, RefCounted)

public:
	ActiveScreen() = default;
	virtual ~ActiveScreen() = default;

	void set_up(const StringName &p_name, ScaffolderScreen *p_screen) {
		name = p_name;
		screen = p_screen;
	}

	const StringName &get_name() const { return name; }
	void set_name(const StringName &p_name) { name = p_name; }

	ScaffolderScreen *get_screen() const { return screen; }
	void set_screen(ScaffolderScreen *p_screen) { screen = p_screen; }

protected:
	static void _bind_methods();

private:
	StringName name;
	ScaffolderScreen *screen = nullptr;
};

} //namespace godot

#endif // ACTIVE_SCREEN_H

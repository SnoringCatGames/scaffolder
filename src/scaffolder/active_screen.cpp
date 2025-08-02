#include "scaffolder/active_screen.h"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void ActiveScreen::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_name"), &ActiveScreen::get_name);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "", "get_name");

	ClassDB::bind_method(D_METHOD("get_screen"), &ActiveScreen::get_screen);
	ADD_PROPERTY(
			PropertyInfo(
					Variant::OBJECT, "screen", PROPERTY_HINT_RESOURCE_TYPE,
					"ScaffolderScreen"),
			"", "get_screen");
}

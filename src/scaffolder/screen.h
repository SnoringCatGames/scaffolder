#ifndef SCAFFOLDER_SCREEN_H
#define SCAFFOLDER_SCREEN_H

#include "snore_core/canvas_layer_config.h"
#include "snore_core/canvas_layer_name.h"

#include <godot_cpp/classes/panel_container.hpp>
#include <godot_cpp/variant/string_name.hpp>

namespace godot {

class ScaffolderScreen : public PanelContainer {
	GDCLASS(ScaffolderScreen, PanelContainer)

public:
	enum ScreenState {
		CLOSED,
		OPEN,
		TOP,
	};

	ScaffolderScreen() = default;
	virtual ~ScaffolderScreen() = default;

	virtual void _ready() override;

	const StringName &get_canvas_layer() const { return canvas_layer; }
	void set_canvas_layer(const StringName &p_value) { canvas_layer = p_value; }

	bool get_pauses_game_when_open() const { return pauses_game_when_open; }
	void set_pauses_game_when_open(bool p_value) {
		pauses_game_when_open = p_value;
	}

	ScreenState get_screen_state() const { return screen_state; }
	void set_screen_state(ScreenState p_value) { screen_state = p_value; }

protected:
	static void _bind_methods();

private:
	StringName canvas_layer = CanvasLayerName::screens;
	bool pauses_game_when_open = true;
	ScreenState screen_state = CLOSED;
};

} //namespace godot

VARIANT_ENUM_CAST(ScaffolderScreen::ScreenState);

#endif // SCAFFOLDER_SCREEN_H

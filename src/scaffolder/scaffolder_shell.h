#ifndef SCAFFOLDER_SHELL_H
#define SCAFFOLDER_SHELL_H

#include "scaffolder/scaffolder_module.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/container.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>

#include "snore_core/canvas_layer_config.h"

// FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------

// FIXME: LEFT OFF HERE: ---------------
// - The previous shell had a scene file associated with it.
// - And we probably want to make it easy to override most shell logic.
// - So maybe I should leave the shell logic in GDScript, and extract the
//   canvas-layer stuff into a separate C++ utility?

namespace godot {

class ScaffolderShell : public SnoreCoreSubmoduleWithNode {
	GDCLASS(ScaffolderShell, SnoreCoreSubmoduleWithNode)
	SC_SUBMODULE_WITH_NODE_CLASS(
			ScaffolderShell,
			Scaffolder,
			"ScaffolderShellProxy",
			Container)

public:
	static const constexpr char *node_name = "ScaffolderShellProxy";

	ScaffolderShell() = default;
	virtual ~ScaffolderShell() = default;

	void add_to_canvas_layer(const String &p_layer_name, Node *p_node);
	void remove_from_canvas_layer(const String &p_layer_name, Node *p_node);

protected:
	static void _bind_methods();

private:
	Dictionary _canvas_layers;

	void _create_canvas_layers();
};

} //namespace godot

#endif // SCAFFOLDER_SHELL_H

#ifndef CANVAS_LAYER_SERVICE_H
#define CANVAS_LAYER_SERVICE_H

#include "scaffolder/scaffolder_module.h"
#include "snore_core/canvas_layer_config.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/container.hpp>

namespace godot {

class CanvasLayerService : public SnoreCoreSubmoduleWithNode {
	GDCLASS(CanvasLayerService, SnoreCoreSubmoduleWithNode)
	SC_SUBMODULE_CLASS(CanvasLayerService, Scaffolder)

public:
	static const std::vector<CanvasLayerConfig> layer_configs;

	CanvasLayerService() = default;
	virtual ~CanvasLayerService() = default;

	void add_to_layer(const StringName &p_layer_name, Node *p_node);
	void remove_from_layer(const StringName &p_layer_name, Node *p_node);

protected:
	static void _bind_methods();

private:
	Container *root = nullptr;

	std::unordered_map<StringName, CanvasLayer *> layers;

	void create_canvas_layers();
};

} //namespace godot

#endif // CANVAS_LAYER_SERVICE_H

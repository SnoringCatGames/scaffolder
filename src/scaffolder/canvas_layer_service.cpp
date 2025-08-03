#include "scaffolder/canvas_layer_service.h"

#include "scaffolder/screen_handler.h"
#include "snore_core/canvas_layer_config.h"
#include "snore_core/canvas_layer_name.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/logger.h"
#include "snore_core/snore_core_utils.h"

#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

const std::vector<CanvasLayerConfig> CanvasLayerService::layer_configs = {
	CanvasLayerConfig(
			CanvasLayerName::utils,
			Node::ProcessMode::PROCESS_MODE_ALWAYS),
	CanvasLayerConfig(
			CanvasLayerName::top,
			Node::ProcessMode::PROCESS_MODE_ALWAYS),
	CanvasLayerConfig(
			CanvasLayerName::notifications,
			Node::ProcessMode::PROCESS_MODE_ALWAYS),
	CanvasLayerConfig(
			CanvasLayerName::super_hud,
			Node::ProcessMode::PROCESS_MODE_ALWAYS),
	CanvasLayerConfig(
			CanvasLayerName::screens,
			Node::ProcessMode::PROCESS_MODE_ALWAYS),
	CanvasLayerConfig(
			CanvasLayerName::top,
			Node::ProcessMode::PROCESS_MODE_PAUSABLE),
	CanvasLayerConfig(
			CanvasLayerName::annotations,
			Node::ProcessMode::PROCESS_MODE_PAUSABLE),
	CanvasLayerConfig(
			CanvasLayerName::game,
			Node::ProcessMode::PROCESS_MODE_PAUSABLE),
};

void CanvasLayerService::set_up() {
	root = memnew(Container);
	SnoreCore::get()->add_utility_node(root, "CanvasLayers");

	// Make the container fill the screen.
	root->set_anchors_and_offsets_preset(Control::PRESET_FULL_RECT);
	root->set_h_size_flags(Control::SIZE_EXPAND_FILL);
	root->set_v_size_flags(Control::SIZE_EXPAND_FILL);

	create_canvas_layers();

	// Create the HUDs.
	if (!SnoreCoreUtils::is_running_in_isolated_scene_mode() ||
		Object::cast_to<ScaffolderLevel>(
				SnoreCore::get()->get_scene_tree()->get_current_scene())) {
		Node *super_hud =
				ScaffolderSettings::get()->get_super_hud_scene()->instantiate();
		add_to_layer(CanvasLayerName::super_hud(), super_hud);
		Scaffolder::get()->set_super_hud(super_hud);

		Node *hud = ScaffolderSettings::get()->get_hud_scene()->instantiate();
		add_to_layer(CanvasLayerName::hud(), hud);
		Scaffolder::get()->set_hud(hud);
	}
}

void CanvasLayerService::reset() {
	if (is_instance_valid(root)) {
		root->queue_free();
		root = nullptr;
	}
}

void CanvasLayerService::create_canvas_layers() {
	SceneTree *tree = SnoreCore::get()->get_scene_tree();
	if (!tree) {
		return;
	}
	Window *root = tree->get_root();
	if (!root) {
		return;
	}

	for (int index = 0; index < layer_configs.size(); index++) {
		const CanvasLayerConfig &config = layer_configs[index];
		const int z_index = layer_configs.size() - index;

		CanvasLayer *layer = memnew(CanvasLayer);
		layer->set_name("Layer_" + config.get_name());
		layer->set_process_mode(config.get_process_mode());
		layer->set_layer(z_index);
		root->add_child(layer);
		// FIXME: Is emplace the right API?
		layers.emplace(config.get_name(), layer);
	}
}

void CanvasLayerService::add_to_layer(
		const StringName &p_layer_name,
		Node *p_node) {
	if (!ENSURE(layers.find(p_layer_name) != layers.end(),
				vformat("Invalid CanvasLayer: %s", p_layer_name))) {
		return;
	}

	layers[p_layer_name]->add_child(p_node);
}

void CanvasLayerService::remove_from_layer(
		const StringName &p_layer_name,
		Node *p_node) {
	if (!ENSURE(layers.find(p_layer_name) != layers.end(),
				vformat("Invalid CanvasLayer: %s", p_layer_name))) {
		return;
	}

	layers[p_layer_name]->remove_child(p_node);
}

void CanvasLayerService::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("add_to_layer", "layer_name", "node"),
			&CanvasLayerService::add_to_layer);
	ClassDB::bind_method(
			D_METHOD("remove_from_layer", "layer_name", "node"),
			&CanvasLayerService::remove_from_layer);
}

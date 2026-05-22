#include "scaffolder/scaffolder_module.h"

#include "scaffolder/active_screen.h"
#include "scaffolder/audio_service.h"
#include "scaffolder/game_session.h"
#include "scaffolder/in_game_settings.h"
#include "scaffolder/scaffolder_level.h"
#include "scaffolder/scaffolder_settings.h"
#include "scaffolder/scaffolder_shell.h"
#include "scaffolder/screen.h"
#include "scaffolder/screen_service.h"
#include "scaffolder/sfx_name.h"
#include "snore_core/canvas_layer_service.h"
#include "snore_core/internal/snore_core_module_utils.h"
#include "snore_core/snore_core_main_module.h"
#include "snore_core/snore_core_utils.h"

#include <godot_cpp/classes/canvas_item.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/core/class_db.hpp>

#ifdef SC_TESTS_ENABLED
#include "scaffolder/test_active_screen.h"
#include "scaffolder/test_audio_service.h"
#include "scaffolder/test_game_session.h"
#include "scaffolder/test_in_game_settings.h"
#include "scaffolder/test_scaffolder_level.h"
#include "scaffolder/test_scaffolder_module.h"
#include "scaffolder/test_scaffolder_settings.h"
#include "scaffolder/test_scaffolder_shell.h"
#include "scaffolder/test_screen.h"
#include "scaffolder/test_screen_service.h"
#endif // SC_TESTS_ENABLED

using namespace godot;

bool Scaffolder::are_types_registered = false;

void Scaffolder::register_gdextension_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	// Intra-DLL re-entry guard: surf_scaf's chained registration calls
	// Scaffolder's registrar; a downstream consumer that also calls
	// Scaffolder::register_gdextension_types directly would otherwise
	// re-enter.
	if (are_types_registered) {
		return;
	}
	are_types_registered = true;

	// Cross-extension guard: if another loaded GDExtension already
	// registered Scaffolder (e.g., a stray standalone
	// scaffolder.gdextension alongside the surf_scaf bundle), skip the
	// whole registration block instead of failing per-class with cryptic
	// ClassDB collision errors. See bootstrapper HANDOVER Phase 2.1
	// finding (a).
	if (ClassDB::class_exists("Scaffolder")) {
		WARN_PRINT(
				"Scaffolder GDExtension classes are already registered "
				"by another loaded extension; skipping duplicate "
				"registration. Only one extension (surf_scaf, the "
				"canonical bundle) should register Scaffolder classes.");
		return;
	}

	GDREGISTER_CLASS(Scaffolder);
	GDREGISTER_CLASS(ScaffolderSettings);
	GDREGISTER_CLASS(InGameSettings);
	GDREGISTER_CLASS(ActiveScreen);
	GDREGISTER_CLASS(GameSession);
	GDREGISTER_CLASS(AudioService);
	GDREGISTER_CLASS(ScaffolderLevel);
	GDREGISTER_CLASS(ScaffolderScreen);
	GDREGISTER_CLASS(ScreenService);
	GDREGISTER_CLASS(ScaffolderShell);

	REGISTER_SNORE_CORE_ROOT_MODULE(Scaffolder);
}

void Scaffolder::unregister_gdextension_types(
		ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	UNREGISTER_SNORE_CORE_ROOT_MODULE(Scaffolder);
}

std::vector<SnoreCoreSubmodule *> Scaffolder::instantiate_submodules() {
	return {
		memnew(InGameSettings),
		memnew(ScreenService),
		memnew(AudioService),
	};
}

void Scaffolder::set_up() {
	// TODO: Do any initialization that depends on runtime settings.

	const Ref<ScaffolderSettings> settings = ScaffolderSettings::get();

	// Create the shell.
	shell = memnew(ScaffolderShell);
	SnoreCore::get()->add_utility_node(shell, ScaffolderShell::name);

	ResourceLoader *loader = ResourceLoader::get_singleton();
	if (!ENSURE_SIMPLE(loader)) {
		return;
	}

	// Create the HUDs.
	if (!SnoreCoreUtils::is_running_in_isolated_scene_mode() ||
		Object::cast_to<ScaffolderLevel>(
				SnoreCore::get()->get_scene_tree()->get_current_scene())) {
		const Ref<PackedScene> custom_super_hud_scene =
				settings->get_super_hud_scene();
		const Ref<PackedScene> super_hud_scene =
				custom_super_hud_scene.is_valid()
				? custom_super_hud_scene
				: Ref<PackedScene>(
						  loader->load(default_super_hud_scene_path));

		CanvasItem *super_hud =
				Object::cast_to<CanvasItem>(super_hud_scene->instantiate());
		super_hud->set_visible(settings->get_show_hud());
		CanvasLayerService::get()->add_to_layer(
				CanvasLayerName::super_hud(), super_hud);
		Scaffolder::get()->set_super_hud(super_hud);

		const Ref<PackedScene> custom_hud_scene = settings->get_hud_scene();
		const Ref<PackedScene> hud_scene = custom_hud_scene.is_valid()
				? custom_hud_scene
				: Ref<PackedScene>(loader->load(default_hud_scene_path));

		CanvasItem *hud = Object::cast_to<CanvasItem>(hud_scene->instantiate());
		hud->set_visible(settings->get_show_hud());
		CanvasLayerService::get()->add_to_layer(CanvasLayerName::hud(), hud);
		Scaffolder::get()->set_hud(hud);
	}

	on_set_up_finished();
}

void Scaffolder::reset() {
	// TODO: Clear state.
	// TODO: Cancel any in-progress set_up operations.

	if (is_valid(shell)) {
		shell->queue_free();
	}
	shell = nullptr;
}

void Scaffolder::on_level_loaded(ScaffolderLevel *p_level) {
	level = p_level;
	emit_signal("level_loaded", p_level);
}

void Scaffolder::on_level_started(ScaffolderLevel *p_level) {
	emit_signal("level_started", p_level);
}

void Scaffolder::on_level_ended(ScaffolderLevel *p_level) {
	emit_signal("level_ended", p_level);
}

ScaffolderShell *Scaffolder::get_shell() const { return shell; }

void Scaffolder::set_shell(ScaffolderShell *p_shell) { shell = p_shell; }

ScaffolderLevel *Scaffolder::get_level() const { return level; }

void Scaffolder::set_level(ScaffolderLevel *p_level) { level = p_level; }

Ref<GameSession> Scaffolder::get_session() const { return session; }

void Scaffolder::set_session(Ref<GameSession> p_session) {
	session = p_session;
}

CanvasItem *Scaffolder::get_super_hud() const { return super_hud; }
void Scaffolder::set_super_hud(CanvasItem *p_super_hud) {
	super_hud = p_super_hud;
}

CanvasItem *Scaffolder::get_hud() const { return hud; }
void Scaffolder::set_hud(CanvasItem *p_hud) { hud = p_hud; }

void Scaffolder::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_settings"), &Scaffolder::get_settings);

	ClassDB::bind_method(D_METHOD("get_level"), &Scaffolder::get_level);
	ClassDB::bind_method(D_METHOD("set_level"), &Scaffolder::set_level);
	ADD_PROPERTY(
			PropertyInfo(Variant::OBJECT, "level"), "set_level", "get_level");

	ClassDB::bind_method(D_METHOD("get_session"), &Scaffolder::get_session);
	ClassDB::bind_method(D_METHOD("set_session"), &Scaffolder::set_session);
	ADD_PROPERTY(
			PropertyInfo(Variant::OBJECT, "session"), "set_session",
			"get_session");

	ClassDB::bind_method(D_METHOD("get_super_hud"), &Scaffolder::get_super_hud);
	ClassDB::bind_method(D_METHOD("set_super_hud"), &Scaffolder::set_super_hud);
	ADD_PROPERTY(
			PropertyInfo(Variant::OBJECT, "super_hud"), "set_super_hud",
			"get_super_hud");

	ClassDB::bind_method(D_METHOD("get_hud"), &Scaffolder::get_hud);
	ClassDB::bind_method(D_METHOD("set_hud"), &Scaffolder::set_hud);
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "hud"), "set_hud", "get_hud");

	ADD_SIGNAL(
			MethodInfo("level_loaded", PropertyInfo(Variant::OBJECT, "level")));
	ADD_SIGNAL(MethodInfo(
			"level_started", PropertyInfo(Variant::OBJECT, "level")));
	ADD_SIGNAL(
			MethodInfo("level_ended", PropertyInfo(Variant::OBJECT, "level")));
}

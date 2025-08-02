#include "scaffolder/scaffolder_module.h"

#include "scaffolder/active_screen.h"
#include "scaffolder/game_session.h"
#include "scaffolder/scaffolder_audio.h"
#include "scaffolder/scaffolder_level.h"
#include "scaffolder/scaffolder_settings.h"
#include "scaffolder/scaffolder_shell.h"
#include "scaffolder/screen.h"
#include "scaffolder/screen_handler.h"
#include "snore_core/internal/snore_core_module_utils.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>

#ifdef SC_TESTS_ENABLED
#include "scaffolder/test_active_screen.h"
#include "scaffolder/test_game_session.h"
#include "scaffolder/test_scaffolder_audio.h"
#include "scaffolder/test_scaffolder_level.h"
#include "scaffolder/test_scaffolder_module.h"
#include "scaffolder/test_scaffolder_settings.h"
#include "scaffolder/test_scaffolder_shell.h"
#include "scaffolder/test_screen.h"
#include "scaffolder/test_screen_handler.h"
#endif // SC_TESTS_ENABLED

using namespace godot;

bool Scaffolder::are_types_registered = false;

void Scaffolder::register_gdextension_types(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	// This method is idempotent, so we check here whether it has been called
	// already.
	if (are_types_registered) {
		return;
	}
	are_types_registered = true;

	GDREGISTER_CLASS(Scaffolder);
	GDREGISTER_CLASS(ScaffolderSettings);
	GDREGISTER_CLASS(ActiveScreen);
	GDREGISTER_CLASS(GameSession);
	GDREGISTER_CLASS(ScaffolderAudio);
	GDREGISTER_CLASS(ScaffolderLevel);
	GDREGISTER_CLASS(ScaffolderScreen);
	GDREGISTER_CLASS(ScreenHandler);
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
		memnew(ScreenHandler),
		memnew(ScaffolderAudio),
		memnew(ScaffolderShell),
	};
}

void Scaffolder::set_up() {
	// TODO: Do any initialization that depends on runtime settings settings.
	on_set_up_finished();
}

void Scaffolder::reset() {
	// TODO: Clear state.
	// TODO: Cancel any in-progress set_up operations.
}

void Scaffolder::on_level_loaded(Ref<ScaffolderLevel> p_level) {
	level = p_level;
	emit_signal("level_loaded", p_level);
}

void Scaffolder::on_level_started(Ref<ScaffolderLevel> p_level) {
	emit_signal("level_started", p_level);
}

void Scaffolder::on_level_ended(Ref<ScaffolderLevel> p_level) {
	emit_signal("level_ended", p_level);
}

Ref<ScaffolderLevel> Scaffolder::get_level() const { return level; }

void Scaffolder::set_level(Ref<ScaffolderLevel> p_level) { level = p_level; }

Ref<GameSession> Scaffolder::get_session() const { return session; }

void Scaffolder::set_session(Ref<GameSession> p_session) {
	session = p_session;
}

void Scaffolder::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_settings"), &Scaffolder::get_settings);

	ClassDB::bind_method(D_METHOD("get_level"), &Scaffolder::get_level);
	ClassDB::bind_method(D_METHOD("set_level"), &Scaffolder::set_level);
	ADD_PROPERTY(
			PropertyInfo(Variant::OBJECT, "level"), "set_level", "get_level");

	ADD_SIGNAL(
			MethodInfo("level_loaded"), PropertyInfo(Variant::OBJECT, "level"));
	ADD_SIGNAL(
			MethodInfo("level_started"),
			PropertyInfo(Variant::OBJECT, "level"));
	ADD_SIGNAL(
			MethodInfo("level_ended"), PropertyInfo(Variant::OBJECT, "level"));
}

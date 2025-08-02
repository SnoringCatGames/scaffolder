#ifndef SCAFFOLDER_MODULE_H
#define SCAFFOLDER_MODULE_H

#include "scaffolder/scaffolder_settings.h"
#include "snore_core/snore_core_root_module.h"

#include <godot_cpp/godot.hpp>

namespace godot {

class GameSession;
class ScaffolderLevel;

class Scaffolder : public SnoreCoreRootModule<ScaffolderSettings> {
	GDCLASS(Scaffolder, SnoreCoreRootModule)
	SC_ROOT_MODULE_CLASS(Scaffolder, ScaffolderSettings)

public:
	static void register_gdextension_types(ModuleInitializationLevel p_level);
	static void unregister_gdextension_types(ModuleInitializationLevel p_level);

	void on_level_loaded(Ref<ScaffolderLevel> p_level);
	void on_level_started(Ref<ScaffolderLevel> p_level);
	void on_level_ended(Ref<ScaffolderLevel> p_level);

	Ref<ScaffolderLevel> get_level() const;
	void set_level(Ref<ScaffolderLevel> p_level);

	Ref<GameSession> get_session() const;
	void set_session(Ref<GameSession> p_session);

protected:
	static void _bind_methods();

private:
	static bool are_types_registered;

	Ref<ScaffolderLevel> level;
	Ref<GameSession> session;
};

} //namespace godot

#endif // SCAFFOLDER_MODULE_H

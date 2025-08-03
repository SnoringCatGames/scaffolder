#ifndef SCAFFOLDER_MODULE_H
#define SCAFFOLDER_MODULE_H

#include "scaffolder/scaffolder_settings.h"
#include "snore_core/snore_core_root_module.h"

#include <godot_cpp/godot.hpp>

namespace godot {

class GameSession;
class Node;
class ScaffolderLevel;
class ScaffolderShell;

class Scaffolder : public SnoreCoreRootModule<ScaffolderSettings> {
	GDCLASS(Scaffolder, SnoreCoreRootModule)
	SC_ROOT_MODULE_CLASS(Scaffolder, ScaffolderSettings)

public:
	static void register_gdextension_types(ModuleInitializationLevel p_level);
	static void unregister_gdextension_types(ModuleInitializationLevel p_level);

	void on_level_loaded(Ref<ScaffolderLevel> p_level);
	void on_level_started(Ref<ScaffolderLevel> p_level);
	void on_level_ended(Ref<ScaffolderLevel> p_level);

	Ref<ScaffolderShell> get_shell() const;
	void set_shell(Ref<ScaffolderShell> p_shell);

	Ref<ScaffolderLevel> get_level() const;
	void set_level(Ref<ScaffolderLevel> p_level);

	Ref<GameSession> get_session() const;
	void set_session(Ref<GameSession> p_session);

	Ref<Node> get_super_hud() const;
	void set_super_hud(Ref<Node> p_super_hud);

	Ref<Node> get_hud() const;
	void set_hud(Ref<Node> p_hud);

protected:
	static void _bind_methods();

private:
	static bool are_types_registered;

	Ref<ScaffolderShell> shell;
	Ref<ScaffolderLevel> level;
	Ref<GameSession> session;
	Ref<Node> super_hud;
	Ref<Node> hud;
};

} //namespace godot

#endif // SCAFFOLDER_MODULE_H

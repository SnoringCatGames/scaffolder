#ifndef SCAFFOLDER_MODULE_H
#define SCAFFOLDER_MODULE_H

#include "scaffolder/game_session.h"
#include "scaffolder/scaffolder_settings.h"
#include "snore_core/snore_core_root_module.h"

#include <godot_cpp/godot.hpp>

namespace godot {

class CanvasItem;
class ScaffolderLevel;
class ScaffolderShell;

class Scaffolder : public SnoreCoreRootModule<ScaffolderSettings> {
	GDCLASS(Scaffolder, SnoreCoreRootModule)
	SC_ROOT_MODULE_CLASS(Scaffolder, ScaffolderSettings)

public:
	static const constexpr char *default_hud_scene_path =
			"res://addons/scaffolder/src/ui/hud/default_hud.tscn";
	static const constexpr char *default_super_hud_scene_path =
			"res://addons/scaffolder/src/ui/hud/default_super_hud.tscn";

	static void register_gdextension_types(ModuleInitializationLevel p_level);
	static void unregister_gdextension_types(ModuleInitializationLevel p_level);

	void on_level_loaded(ScaffolderLevel *p_level);
	void on_level_started(ScaffolderLevel *p_level);
	void on_level_ended(ScaffolderLevel *p_level);

	ScaffolderShell *get_shell() const;
	void set_shell(ScaffolderShell *p_shell);

	ScaffolderLevel *get_level() const;
	void set_level(ScaffolderLevel *p_level);

	Ref<GameSession> get_session() const;
	void set_session(Ref<GameSession> p_session);

	CanvasItem *get_super_hud() const;
	void set_super_hud(CanvasItem *p_super_hud);

	CanvasItem *get_hud() const;
	void set_hud(CanvasItem *p_hud);

protected:
	static void _bind_methods();

private:
	static bool are_types_registered;

	ScaffolderShell *shell;
	ScaffolderLevel *level;
	Ref<GameSession> session;
	CanvasItem *super_hud;
	CanvasItem *hud;
};

} //namespace godot

#endif // SCAFFOLDER_MODULE_H

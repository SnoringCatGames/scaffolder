#ifndef AUDIO_SERVICE_H
#define AUDIO_SERVICE_H

#include "scaffolder/scaffolder_module.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/classes/node.hpp>

namespace godot {

class AudioStreamPlayer;
class StringName;
class Variant;

// Audio manager for the Scaffolder framework.
// - Handles SFX and music volume control, manages audio stream players,
//   and provides audio bus management functionality.
class AudioService : public SnoreCoreSubmoduleWithNode {
	GDCLASS(AudioService, SnoreCoreSubmoduleWithNode)
	SC_SUBMODULE_WITH_NODE_CLASS(
			AudioService,
			Scaffolder,
			"AudioServiceProxy",
			Node)

public:
	static const StringName sfx_bus_name;
	static const StringName music_bus_name;

	AudioService() = default;
	~AudioService() = default;

	void set_music_volume(float p_volume_db);
	void set_sfx_volume(float p_volume_db);

	// -   Plays the SFX non-positionally.
	// -   SFXs are registered in the app settings.
	void play_sfx(const StringName &p_name);

protected:
	static void _bind_methods();

private:
	std::unordered_map<StringName, AudioStreamPlayer *> sfx_players;

	void on_property_changed(
			const StringName &p_name,
			const Variant &p_new_value,
			const Variant &p_old_value);
};

} // namespace godot

#endif // AUDIO_SERVICE_H

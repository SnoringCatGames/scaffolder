#ifndef SCAFFOLDER_AUDIO_H
#define SCAFFOLDER_AUDIO_H

#include "scaffolder/scaffolder_module.h"
#include "snore_core/snore_core_submodule.h"

#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/variant.hpp>

namespace godot {

// FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------

// Audio manager for the Scaffolder framework.
// - Handles SFX and music volume control, manages audio stream players,
// and provides audio bus management functionality.
class ScaffolderAudio : public SnoreCoreSubmoduleWithNode {
	GDCLASS(ScaffolderAudio, SnoreCoreSubmoduleWithNode)
	SC_SUBMODULE_WITH_NODE_CLASS(
			ScaffolderAudio,
			Scaffolder,
			"ScaffolderAudioProxy",
			Node)

public:
	static const constexpr char *SFX_BUS_NAME = "SFX";
	static const constexpr char *MUSIC_BUS_NAME = "Music";

	ScaffolderAudio() = default;
	~ScaffolderAudio() = default;

	void set_music_volume(float p_volume_db);

	void set_sfx_volume(float p_volume_db);

	void play_sfx(const StringName &p_name);

protected:
	static void _bind_methods();

private:
	Dictionary sfx_players;

	void _on_property_changed(
			const StringName &p_name,
			const Variant &p_new_value,
			const Variant &p_old_value);
};

} // namespace godot

#endif // SCAFFOLDER_AUDIO_H

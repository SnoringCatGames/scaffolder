#include "scaffolder_audio.h"

#include "scaffolder/scaffolder_module.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/logger.h"

#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

// FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------

void ScaffolderAudio::_ready() {
	Node::_ready();

	AudioServer *audio_server = AudioServer::get_singleton();

	// Verify that required audio buses exist.
	ENSURE(audio_server->get_bus_index(SFX_BUS_NAME) >= 0,
		   vformat("ScaffolderOld expects an audio bus of name %s.",
				   SFX_BUS_NAME));
	ENSURE(audio_server->get_bus_index(MUSIC_BUS_NAME) >= 0,
		   vformat("ScaffolderOld expects an audio bus of name %s.",
				   MUSIC_BUS_NAME));

	// Create SFX players for each registered sound effect.
	Scaffolder *scaffolder = Scaffolder::get();
	ScaffolderSettings *settings = scaffolder->get_settings();
	Dictionary sfxs = settings->get_sfxs();

	Array sfx_names = sfxs.keys();
	for (int i = 0; i < sfx_names.size(); ++i) {
		StringName name = sfx_names[i];
		AudioStreamPlayer *player = memnew(AudioStreamPlayer);
		player->set_stream(sfxs[name]);
		player->set_bus(SFX_BUS_NAME);
		add_child(player);
		sfx_players[name] = player;
	}

	// Handle music muting if configured.
	// Note: In the original GDScript, this checked `mute_music` which
	// doesn't exist in ScaffolderSettings This logic may need to be adjusted
	// based on actual settings implementation
	bool should_mute = settings->get_mute_music();
	if (should_mute) {
		int32_t index = audio_server->get_bus_index(MUSIC_BUS_NAME);
		if (!ENSURE(index >= 0, "Failed to get music bus index")) {
			return;
		}
		audio_server->set_bus_mute(index, true);
	}
}

void ScaffolderAudio::set_up() {
	Scaffolder *scaffolder = Scaffolder::get();
	// Note: In the original GDScript, this connects to
	// S.settings.property_changed This would need to be implemented when
	// settings system is ported
	// scaffolder->get_settings()->connect("property_changed", callable_mp(this,
	// &ScaffolderAudio::_on_property_changed));

	// Initialize volumes from current settings.
	PackedStringArray property_names;
	property_names.append("music_volume");
	property_names.append("sfx_volume");

	for (int i = 0; i < property_names.size(); ++i) {
		StringName property_name = property_names[i];
		// Note: This would need the settings system to be ported
		// Variant value = scaffolder->get_settings()->get(property_name);
		// _on_property_changed(property_name, value, value);
	}
}

void ScaffolderAudio::reset() {}

void ScaffolderAudio::_on_property_changed(
		const StringName &p_name,
		const Variant &p_new_value,
		const Variant &p_old_value) {
	if (p_name == "music_volume") {
		// p_new_value is [0,1].
		float linear_value = p_new_value;
		float db_value = UtilityFunctions::linear_to_db(linear_value);
		set_music_volume(db_value);
	} else if (p_name == "sfx_volume") {
		// p_new_value is [0,1].
		float linear_value = p_new_value;
		float db_value = UtilityFunctions::linear_to_db(linear_value);
		set_sfx_volume(db_value);
	}
	// Default case: Do nothing.
}

void ScaffolderAudio::set_music_volume(float p_volume_db) {
	AudioServer *audio_server = AudioServer::get_singleton();
	int32_t index = audio_server->get_bus_index(MUSIC_BUS_NAME);
	if (!ENSURE(index >= 0, "Failed to get music bus index")) {
		return;
	}
	audio_server->set_bus_volume_db(index, p_volume_db);
}

void ScaffolderAudio::set_sfx_volume(float p_volume_db) {
	AudioServer *audio_server = AudioServer::get_singleton();
	int32_t index = audio_server->get_bus_index(SFX_BUS_NAME);
	if (!ENSURE(index >= 0, "Failed to get SFX bus index")) {
		return;
	}
	audio_server->set_bus_volume_db(index, p_volume_db);
}

void ScaffolderAudio::play_sfx(const StringName &p_name) {
	if (!ENSURE(sfx_players.has(p_name),
				vformat("SFX player not found: %s", p_name))) {
		return;
	}

	// Assigning the AudioStream to null in the manifest will disable the SFX.
	Variant player_variant = sfx_players[p_name];
	if (player_variant.get_type() == Variant::OBJECT) {
		AudioStreamPlayer *player =
				Object::cast_to<AudioStreamPlayer>(player_variant);
		if (player != nullptr && Object::is_instance_valid(player)) {
			player->play();
		}
	}
}

void ScaffolderAudio::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_up"), &ScaffolderAudio::set_up);
	ClassDB::bind_method(
			D_METHOD("set_music_volume", "volume_db"),
			&ScaffolderAudio::set_music_volume);
	ClassDB::bind_method(
			D_METHOD("set_sfx_volume", "volume_db"),
			&ScaffolderAudio::set_sfx_volume);
	ClassDB::bind_method(
			D_METHOD("play_sfx", "name"), &ScaffolderAudio::play_sfx);
	ClassDB::bind_method(
			D_METHOD("_on_property_changed", "name", "new_value", "old_value"),
			&ScaffolderAudio::_on_property_changed);
}

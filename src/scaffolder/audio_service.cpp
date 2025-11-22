#include "audio_service.h"

#include "scaffolder/in_game_settings.h"
#include "scaffolder/scaffolder_module.h"
#include "snore_core/internal/debug_utils.h"
#include "snore_core/log_service.h"

#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/classes/audio_stream.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/variant.hpp>

using namespace godot;

const std::unordered_map<std::string, std::string>
		AudioService::default_sfxs = {
			{ "achievement", "res://assets/sfx/achievement.wav" },
			{ "cadence_lose", "res://assets/sfx/cadence_lose.wav" },
			{ "cadence_win", "res://assets/sfx/cadence_win.wav" },
			{ "jump", "res://assets/sfx/jump.wav" },
			{ "land", "res://assets/sfx/land.wav" },
			{ "menu_select", "res://assets/sfx/menu_select.wav" },
			{ "menu_select_fancy", "res://assets/sfx/menu_select_fancy.wav" },
			{ "single_cat_snore", "res://assets/sfx/single_cat_snore.wav" },
			{ "walk", "res://assets/sfx/walk.wav" },
		};

void AudioService::set_up() {
	AudioServer *audio_server = AudioServer::get_singleton();

	// Verify that required audio buses exist.
	ENSURE(audio_server->get_bus_index(sfx_bus_name()) >= 0,
		   vformat("Scaffolder expects an audio bus of name \"%s\".",
				   sfx_bus_name()));
	ENSURE(audio_server->get_bus_index(music_bus_name()) >= 0,
		   vformat("Scaffolder expects an audio bus of name \"%s\".",
				   music_bus_name()));

	ResourceLoader *loader = ResourceLoader::get_singleton();
	if (!ENSURE_SIMPLE(loader)) {
		return;
	}

	// Create SFX players for each registered sound effect.
	const Dictionary sfxs = ScaffolderSettings::get()->get_sfxs();
	const Array sfx_names = sfxs.keys();
	for (int i = 0; i < sfx_names.size(); ++i) {
		const StringName name = sfx_names[i];
		add_audio_stream_player(name, sfxs[name]);
	}

	// Add defaults for any missing SFXs.
	for (const std::pair<std::string, std::string> &sfx : default_sfxs) {
		const StringName name = StringName(sfx.first.c_str());
		if (sfx_players.find(name) != sfx_players.end()) {
			// This sfx was defined in the app settings.
			continue;
		}
		const Ref<AudioStream> stream =
				loader->load(String(sfx.second.c_str()));
		add_audio_stream_player(name, stream);
	}

	// Handle music muting if configured.
	if (ScaffolderSettings::get()->get_mute_music()) {
		const int32_t index = audio_server->get_bus_index(music_bus_name());
		if (!ENSURE(index >= 0, "Failed to get music bus index")) {
			return;
		}
		audio_server->set_bus_mute(index, true);
	}

	InGameSettings *settings = InGameSettings::get();
	settings->connect(
			"property_changed",
			callable_mp(this, &AudioService::on_property_changed));

	// Initialize volumes from current settings.
	const std::vector<StringName> property_names = {
		"music_volume",
		"sfx_volume",
	};
	for (int i = 0; i < property_names.size(); ++i) {
		const StringName &property_name = property_names[i];
		const Variant value = settings->Object::get(property_name);
		on_property_changed(property_name, value, value);
	}
}

void AudioService::add_audio_stream_player(
		const StringName p_name,
		Ref<AudioStream> p_stream) {
	AudioStreamPlayer *player = memnew(AudioStreamPlayer);
	player->set_stream(p_stream);
	player->set_bus(sfx_bus_name());
	node->add_child(player);
	sfx_players[p_name] = player;
}

void AudioService::reset() {}

void AudioService::on_property_changed(
		const StringName &p_name,
		const Variant &p_new_value,
		const Variant &p_old_value) {
	if (p_name == InGameSettings::music_volume_property_name()) {
		// p_new_value is [0,1].
		float linear_value = p_new_value;
		float db_value = UtilityFunctions::linear_to_db(linear_value);
		set_music_volume(db_value);
	} else if (p_name == InGameSettings::sfx_volume_property_name()) {
		// p_new_value is [0,1].
		float linear_value = p_new_value;
		float db_value = UtilityFunctions::linear_to_db(linear_value);
		set_sfx_volume(db_value);
	}
	// Default case: Do nothing.
}

void AudioService::set_music_volume(float p_volume_db) {
	AudioServer *audio_server = AudioServer::get_singleton();
	const int32_t index = audio_server->get_bus_index(music_bus_name());
	if (!ENSURE(index >= 0, "Failed to get music bus index")) {
		return;
	}
	audio_server->set_bus_volume_db(index, p_volume_db);
}

void AudioService::set_sfx_volume(float p_volume_db) {
	AudioServer *audio_server = AudioServer::get_singleton();
	const int32_t index = audio_server->get_bus_index(sfx_bus_name());
	if (!ENSURE(index >= 0, "Failed to get SFX bus index")) {
		return;
	}
	audio_server->set_bus_volume_db(index, p_volume_db);
}

void AudioService::play_sfx(const StringName &p_name) {
	if (!ENSURE(sfx_players.find(p_name) != sfx_players.end(),
				vformat("SFX player not found: %s", p_name))) {
		return;
	}

	// Assigning the AudioStream to null in the manifest will disable the SFX.
	Variant player_variant = sfx_players[p_name];
	if (player_variant.get_type() == Variant::OBJECT) {
		AudioStreamPlayer *player =
				Object::cast_to<AudioStreamPlayer>(player_variant);
		if (is_valid(player)) {
			player->play();
		}
	}
}

void AudioService::_bind_methods() {
	ClassDB::bind_method(
			D_METHOD("set_music_volume", "volume_db"),
			&AudioService::set_music_volume);
	ClassDB::bind_method(
			D_METHOD("set_sfx_volume", "volume_db"),
			&AudioService::set_sfx_volume);
	ClassDB::bind_method(D_METHOD("play_sfx", "name"), &AudioService::play_sfx);
}

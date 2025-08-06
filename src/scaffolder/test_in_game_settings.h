#ifndef TEST_IN_GAME_SETTINGS_H
#define TEST_IN_GAME_SETTINGS_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/in_game_settings.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class InGameSettingsTest : public SnoreCoreTest {
public:
	void BeforeEach() override {
		settings = memnew(InGameSettings);
		settings->set_up();
	}

	void AfterEach() override {
		if (settings) {
			settings->reset();
			memdelete(settings);
		}
	}

	InGameSettings *settings;
};

TEST_F(InGameSettingsTest, PropertySettersAndGetters) {
	// Test music volume.
	settings->set_music_volume(0.8f);
	EXPECT_FLOAT_EQ(settings->get_music_volume(), 0.8f);

	// Test sfx volume.
	settings->set_sfx_volume(0.3f);
	EXPECT_FLOAT_EQ(settings->get_sfx_volume(), 0.3f);

	// Test show logs.
	settings->set_show_logs(true);
	EXPECT_TRUE(settings->get_show_logs());
}

TEST_F(InGameSettingsTest, GetSettingsProperties) {
	// Test that get_settings_properties returns the expected properties.
	Array properties = settings->get_settings_properties();
	EXPECT_GT(properties.size(), 0);

	// Verify that the properties include our exported fields.
	bool found_music_volume = false;
	bool found_sfx_volume = false;
	bool found_show_logs = false;

	for (int i = 0; i < properties.size(); i++) {
		Dictionary property = properties[i];
		String name = property["name"];

		if (name == "music_volume") {
			found_music_volume = true;
		} else if (name == "sfx_volume") {
			found_sfx_volume = true;
		} else if (name == "show_logs") {
			found_show_logs = true;
		}
	}

	EXPECT_TRUE(found_music_volume);
	EXPECT_TRUE(found_sfx_volume);
	EXPECT_TRUE(found_show_logs);
}

} // namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_IN_GAME_SETTINGS_H

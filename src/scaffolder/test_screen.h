#ifndef TEST_SCREEN_H
#define TEST_SCREEN_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/screen.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class ScaffolderScreenTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { screen.instantiate(); }

	Ref<ScaffolderScreen> screen;
};

TEST_F(ScaffolderScreenTest, Constructor) {
	EXPECT_TRUE(screen.is_valid());
	EXPECT_EQ(screen->get_canvas_layer(), "screens");
	EXPECT_TRUE(screen->get_pauses_game_when_open());
	EXPECT_EQ(screen->get_screen_state(), ScaffolderScreen::CLOSED);
}

TEST_F(ScaffolderScreenTest, CanvasLayerProperty) {
	screen->set_canvas_layer("test_layer");
	EXPECT_EQ(screen->get_canvas_layer(), "test_layer");
}

TEST_F(ScaffolderScreenTest, PausesGameWhenOpenProperty) {
	screen->set_pauses_game_when_open(false);
	EXPECT_FALSE(screen->get_pauses_game_when_open());

	screen->set_pauses_game_when_open(true);
	EXPECT_TRUE(screen->get_pauses_game_when_open());
}

TEST_F(ScaffolderScreenTest, ScreenStateProperty) {
	screen->set_screen_state(ScaffolderScreen::OPEN);
	EXPECT_EQ(screen->get_screen_state(), ScaffolderScreen::OPEN);

	screen->set_screen_state(ScaffolderScreen::TOP);
	EXPECT_EQ(screen->get_screen_state(), ScaffolderScreen::TOP);

	screen->set_screen_state(ScaffolderScreen::CLOSED);
	EXPECT_EQ(screen->get_screen_state(), ScaffolderScreen::CLOSED);
}

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCREEN_H

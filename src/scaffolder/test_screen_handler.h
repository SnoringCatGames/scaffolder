#ifndef TEST_SCREEN_HANDLER_H
#define TEST_SCREEN_HANDLER_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/screen_handler.h"

#include "scaffolder/active_screen.h"
#include "scaffolder/screen.h"
#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class ScreenHandlerTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { screen_handler.instantiate(); }

	Ref<ScreenHandler> screen_handler;
};

TEST_F(ScreenHandlerTest, CloseNonExistentScreen) {
	bool result = screen_handler->close("nonexistent_screen");
	EXPECT_FALSE(result);
}

TEST_F(ScreenHandlerTest, CloseScreensAboveNonExistent) {
	// This should handle gracefully when target screen doesn't exist.
	// The method should log an error but not crash.
	screen_handler->close_screens_above("nonexistent_screen");
	// If we reach here without crashing, the test passes.
	EXPECT_TRUE(true);
}

// FIXME: Add tests with mocks.

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCREEN_HANDLER_H

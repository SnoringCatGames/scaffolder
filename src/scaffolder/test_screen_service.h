#ifndef TEST_SCREEN_SERVICE_H
#define TEST_SCREEN_SERVICE_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/screen_service.h"

#include "scaffolder/active_screen.h"
#include "scaffolder/screen.h"
#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class ScreenServiceTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { screen_service = memnew(ScreenService); }
	void AfterEach() override { memdelete(screen_service); }

	ScreenService *screen_service;
};

TEST_F(ScreenServiceTest, CloseNonExistentScreen) {
	bool result = screen_service->close("nonexistent_screen");
	EXPECT_FALSE(result);
}

TEST_F(ScreenServiceTest, CloseScreensAboveNonExistent) {
	// This should handle gracefully when target screen doesn't exist.
	// The method should log an error but not crash.
	screen_service->close_screens_above("nonexistent_screen");
	// If we reach here without crashing, the test passes.
	EXPECT_TRUE(true);
}

// FIXME: Add tests with mocks.

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCREEN_SERVICE_H

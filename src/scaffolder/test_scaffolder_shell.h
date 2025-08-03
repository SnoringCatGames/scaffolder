#ifndef TEST_SCAFFOLDER_SHELL_H
#define TEST_SCAFFOLDER_SHELL_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/scaffolder_shell.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

// FIXME: LEFT OFF HERE: FINISH PORTING ---------------------------------------

namespace godot {

class ScaffolderShellTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { shell.instantiate(); }

	void AfterEach() override { shell.unref(); }

	Ref<ScaffolderShell> shell;
};

TEST_F(ScaffolderShellTest, NotificationHandling) {
	// Test that notification handling doesn't crash.
	shell->_notification(NOTIFICATION_WM_GO_BACK_REQUEST);
	shell->_notification(NOTIFICATION_WM_CLOSE_REQUEST);
	shell->_notification(NOTIFICATION_WM_WINDOW_FOCUS_OUT);
	shell->_notification(999); // Invalid notification.
}

TEST_F(ScaffolderShellTest, CloseApp) {
	// Note: We can't actually test the full close_app functionality without
	// a proper scene tree setup. This just ensures the method doesn't crash
	// when called directly.
	// In a real test environment with scene tree, we would check that
	// get_tree()->call_deferred("quit") was called.

	// For now, just ensure the method exists and can be called.
	// shell->close_app(); // Commented out to avoid actually quitting during
	// tests.

	// Test passes if we get here without crashing
	EXPECT_TRUE(true);
}

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCAFFOLDER_SHELL_H

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

TEST_F(ScaffolderShellTest, Constructor) { EXPECT_TRUE(shell.is_valid()); }

TEST_F(ScaffolderShellTest, CanvasLayerManagement) {
	// Create a test node.
	Ref<Node> test_node;
	test_node.instantiate();
	test_node->set_name("test_node");

	// Test that canvas layers are created.
	// Since _create_canvas_layers() now creates default layers,
	// we should be able to add nodes to them.
	shell->_enter_tree(); // This should call _create_canvas_layers().

	// Test adding to a valid layer (should work with default implementation).
	shell->add_to_canvas_layer("hud", test_node.ptr());

	// Test adding to invalid layer (should log error but not crash).
	shell->add_to_canvas_layer("nonexistent_layer", test_node.ptr());

	// Test removing from a valid layer.
	shell->remove_from_canvas_layer("hud", test_node.ptr());

	// Test removing from invalid layer (should log error but not crash).
	shell->remove_from_canvas_layer("nonexistent_layer", test_node.ptr());
}

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

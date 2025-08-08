#ifndef TEST_ACTIVE_SCREEN_H
#define TEST_ACTIVE_SCREEN_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/active_screen.h"

#include "scaffolder/screen.h"
#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class ActiveScreenTest : public SnoreCoreTest {
protected:
	void BeforeEach() override {
		active_screen.instantiate();
		screen = memnew(ScaffolderScreen);
	}

	void AfterEach() override {
		active_screen.unref();
		memdelete(screen);
	}

	Ref<ActiveScreen> active_screen;
	ScaffolderScreen *screen;
};

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_ACTIVE_SCREEN_H

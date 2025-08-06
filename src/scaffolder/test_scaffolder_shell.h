#ifndef TEST_SCAFFOLDER_SHELL_H
#define TEST_SCAFFOLDER_SHELL_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/scaffolder_shell.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class ScaffolderShellTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { shell.instantiate(); }

	void AfterEach() override { shell.unref(); }

	Ref<ScaffolderShell> shell;
};

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCAFFOLDER_SHELL_H

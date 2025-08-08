#ifndef TEST_SCAFFOLDER_SHELL_H
#define TEST_SCAFFOLDER_SHELL_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/scaffolder_shell.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class ScaffolderShellTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { shell = memnew(ScaffolderShell); }

	void AfterEach() override { memdelete(shell); }

	ScaffolderShell *shell;
};

} //namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCAFFOLDER_SHELL_H

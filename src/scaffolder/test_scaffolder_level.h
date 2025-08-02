#ifndef TEST_SCAFFOLDER_LEVEL_H
#define TEST_SCAFFOLDER_LEVEL_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/scaffolder_level.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class ScaffolderLevelTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { p_level = memnew(ScaffolderLevel); }

	void AfterEach() override { memdelete(p_level); }

	ScaffolderLevel *p_level;
};

} // namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_SCAFFOLDER_LEVEL_H

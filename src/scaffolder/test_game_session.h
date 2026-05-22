#ifndef TEST_GAME_SESSION_H
#define TEST_GAME_SESSION_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/game_session.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class GameSessionTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { game_session = memnew(GameSession); }

	void AfterEach() override { memdelete(game_session); }

	GameSession *game_session;
};

TEST_F(GameSessionTest, PlayTimeCalculation) {
	// Test play time calculation with end time set.
	const float start_time = 100.0;
	const float end_time = 250.0;
	game_session->set_start_time(start_time);
	game_session->set_end_time(end_time);

	const float expected_play_time = end_time - start_time;
	EXPECT_EQ(game_session->get_play_time(), expected_play_time);
}

TEST_F(GameSessionTest, PlayTimeWithoutEndTime) {
	// Test play time calculation without end time (ongoing session).
	// Without a live TimeService (unit-test context),
	// get_play_time() returns 0.0 instead of going negative when the
	// elapsed wall-clock query has no source. The contract: play_time
	// stays non-negative even in this case.
	game_session->set_start_time(100.0);

	const float play_time = game_session->get_play_time();
	EXPECT_GE(play_time, 0.0);
}

TEST_F(GameSessionTest, Reset) {
	// Set some values.
	game_session->set_start_time(123.45);
	game_session->set_end_time(456.78);

	// Reset and verify values are cleared.
	game_session->reset();
	EXPECT_EQ(game_session->get_start_time(), 0.0);
	EXPECT_EQ(game_session->get_end_time(), 0.0);
	EXPECT_EQ(game_session->get_play_time(), 0.0);
}

TEST_F(GameSessionTest, PlayTimeWithZeroStartTime) {
	// Test play time when start time is 0 (not started).
	EXPECT_EQ(game_session->get_play_time(), 0.0);
}

} // namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_GAME_SESSION_H

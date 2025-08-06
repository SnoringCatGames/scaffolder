#ifndef TEST_AUDIO_SERVICE_H
#define TEST_AUDIO_SERVICE_H

#ifdef SC_TESTS_ENABLED

#include "scaffolder/audio_service.h"

#include "snore_core/internal/test_utils.h"

#include <gtest/gtest.h>

namespace godot {

class AudioServiceTest : public SnoreCoreTest {
protected:
	void BeforeEach() override { audio = memnew(AudioService); }

	void AfterEach() override { memdelete(audio); }

	AudioService *audio;
};

} // namespace godot

#endif // SC_TESTS_ENABLED

#endif // TEST_AUDIO_SERVICE_H

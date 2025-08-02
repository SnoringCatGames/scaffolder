#ifndef GAME_SESSION_H
#define GAME_SESSION_H

#include <godot_cpp/classes/ref_counted.hpp>

namespace godot {

class GameSession : public RefCounted {
	GDCLASS(GameSession, RefCounted)

public:
	GameSession() = default;
	virtual ~GameSession() = default;

	void reset();

	void start();
	void end();

	float get_start_time() const { return start_time; }
	void set_start_time(float p_start_time) { start_time = p_start_time; }

	float get_end_time() const { return end_time; }
	void set_end_time(float p_end_time) { end_time = p_end_time; }

	float get_play_time() const;

protected:
	static void _bind_methods();

private:
	float start_time = 0.0;
	float end_time = 0.0;
};

} //namespace godot

#endif // GAME_SESSION_H

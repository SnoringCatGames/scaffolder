#ifndef SCAFFOLDER_LEVEL_H
#define SCAFFOLDER_LEVEL_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/scene_tree_timer.hpp>

namespace godot {

class ScaffolderLevel : public Node2D {
	GDCLASS(ScaffolderLevel, Node2D)

public:
	ScaffolderLevel() = default;
	virtual ~ScaffolderLevel() = default;

	virtual void _ready() override;

	void reset();

	void start();

	void pause();
	void unpause();

	void game_over(bool p_success);

	bool get_has_started() const { return has_started; }
	bool get_has_ended() const { return has_ended; }

protected:
	static void _bind_methods();

private:
	bool has_started = false;
	bool has_ended = false;

	void show_game_over_screen();
};

} // namespace godot

#endif // SCAFFOLDER_LEVEL_H

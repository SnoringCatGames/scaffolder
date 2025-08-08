#ifndef SCAFFOLDER_SHELL_H
#define SCAFFOLDER_SHELL_H

#include <godot_cpp/classes/container.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input_event_key.hpp>

namespace godot {

class ScaffolderShell : public Container {
	GDCLASS(ScaffolderShell, Container)

public:
	static const constexpr char *name = "ScaffolderShell";

	static ScaffolderShell *get();

	ScaffolderShell() = default;
	virtual ~ScaffolderShell() = default;

	virtual void _ready() override;
	virtual void _unhandled_input(const Ref<InputEvent> &p_event) override;

protected:
	static void _bind_methods();

	void _notification(int p_notification);

private:
	void deferred_ready();

	void close_app();
};

} //namespace godot

#endif // SCAFFOLDER_SHELL_H

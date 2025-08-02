#ifndef SCREEN_NAME_H
#define SCREEN_NAME_H

#include <godot_cpp/variant/string_name.hpp>

#define SCREEN_NAME(m_name)                                                    \
	namespace Internal {                                                       \
	static const constexpr char *m_name##_screen_name = #m_name;               \
	} /*namespace Internal*/                                                   \
                                                                               \
	const StringName &m_name() {                                               \
		static const StringName string_name =                                  \
				StringName(Internal::m_name##_screen_name);                    \
		return string_name;                                                    \
	}

namespace godot {
namespace ScreenName {

SCREEN_NAME(credits)
SCREEN_NAME(game_over)
SCREEN_NAME(game)
SCREEN_NAME(main_menu)
SCREEN_NAME(pause)
SCREEN_NAME(settings)

} //namespace ScreenName
} //namespace godot

#endif // SCREEN_NAME_H

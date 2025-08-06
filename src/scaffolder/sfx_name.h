#ifndef SFX_NAME_H
#define SFX_NAME_H

#include <godot_cpp/variant/string_name.hpp>

#define SFX_NAME(m_name)                                                       \
	namespace Internal {                                                       \
	static const constexpr char *m_name##_sfx_name = #m_name;                  \
	} /*namespace Internal*/                                                   \
                                                                               \
	const StringName &m_name() {                                               \
		static const StringName string_name =                                  \
				StringName(Internal::m_name##_sfx_name);                       \
		return string_name;                                                    \
	}

namespace godot {
namespace SfxName {

// FIXME: Register these in ScaffolderSettings.

SFX_NAME(app_start)
SFX_NAME(level_start)
SFX_NAME(game_over_success)
SFX_NAME(game_over_failure)
SFX_NAME(pause)
SFX_NAME(unpause)
SFX_NAME(widget_click)

} //namespace SfxName
} //namespace godot

#endif // SFX_NAME_H

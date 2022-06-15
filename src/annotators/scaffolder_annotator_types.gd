class_name ScaffolderAnnotatorTypes


const RULER = "RULER"
const SURFACES = "SURFACES"
const GRID_INDICES = "GRID_INDICES"
const LEVEL = "LEVEL"
const CHARACTER = "CHARACTER"
const CHARACTER_POSITION = "CHARACTER_POSITION"
const RECENT_MOVEMENT = "RECENT_MOVEMENT"
const NAVIGATOR = "NAVIGATOR"
const PATH_PRESELECTION = "PATH_PRESELECTION"
const UNKNOWN = "UNKNOWN"


static func get_settings_key(type: String) -> String:
    return type + "_enabled"

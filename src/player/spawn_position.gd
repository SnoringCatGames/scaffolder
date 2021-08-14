tool
class_name SpawnPosition, \
"res://addons/scaffolder/assets/images/editor_icons/spawn_position.png"
extends Position2D


const PLAYER_OPACITY := 0.5

const ATTACHMENT_CONE_RADIUS := 8.0
const ATTACHMENT_CONE_LENGTH := 20.0
const ATTACHMENT_CONE_STROKE_WIDTH := 1.6
const ATTACHMENT_CONE_OPACITY := 0.4
const ATTACHMENT_CONE_FILL_COLOR := Color("ad00ad")
const ATTACHMENT_CONE_STROKE_COLOR := Color("ffffff")

const INCLUDE_EXCLUSIVELY_WIDTH := 64.0
const INCLUDE_EXCLUSIVELY_STROKE_WIDTH := 12.0
const INCLUDE_EXCLUSIVELY_COLOR := Color("00ff00")

const EXCLUDE_WIDTH := 64.0
const EXCLUDE_STROKE_WIDTH := 12.0
const EXCLUDE_COLOR := Color("ff0000")

var PLAYER_NAME_PROPERTY_CONFIG := {
    name = "player_name",
    type = TYPE_STRING,
    usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    hint = PROPERTY_HINT_ENUM,
    hint_string = "",
}

var SURFACE_ATTACHMENT_PROPERTY_CONFIG := {
    name = "surface_attachment",
    type = TYPE_STRING,
    usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    hint = PROPERTY_HINT_ENUM,
    hint_string = "FLOOR,LEFT_WALL,RIGHT_WALL,CEILING,NONE",
}

var INCLUDE_EXCLUSIVELY_PROPERTY_CONFIG := {
    name = "include_exclusively",
    type = TYPE_BOOL,
    usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
}

var EXCLUDE_PROPERTY_CONFIG := {
    name = "exclude",
    type = TYPE_BOOL,
    usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
}

## The name of the player to spawn at this position.
var player_name := "" setget _set_player_name

## The type of surface side that this player should start out attached to.
var surface_attachment := "FLOOR" setget _set_surface_attachment

## If true, then the player will not be created for any other spawn positions
## (unless they also have include_exclusively enabled).
var include_exclusively := false setget _set_include_exclusively

## If true, then the player will not be created for this spawn position.
var exclude := false setget _set_exclude

var surface_side := SurfaceSide.FLOOR

var _property_list_addendum = [
    PLAYER_NAME_PROPERTY_CONFIG,
    SURFACE_ATTACHMENT_PROPERTY_CONFIG,
    INCLUDE_EXCLUSIVELY_PROPERTY_CONFIG,
    EXCLUDE_PROPERTY_CONFIG,
]
var _player
var _configuration_warning := ""


func _init() -> void:
    _update_property_list_addendum()


func _ready() -> void:
    if is_instance_valid(Sc.level):
        # Walk up the scene tree in order to find the active level, and register
        # this spawn position with it.
        var ancestor := get_parent()
        while is_instance_valid(ancestor) and \
                ancestor != Sc.level:
            ancestor = ancestor.get_parent()
        if ancestor == Sc.level:
            ancestor.register_spawn_position(player_name, self)


# -   This makes the `player_name` property exported for editing in the
#     inspector panel.
# -   This also defines the `player_name` property as an enum of all the
#     player names that are registered in the app manifest.
func _update_property_list_addendum() -> void:
    var player_names: Array = Sc.players.player_scenes.keys()
    player_names.push_front("")
    PLAYER_NAME_PROPERTY_CONFIG.hint_string = Sc.utils.join(player_names, ",")


func _get_property_list() -> Array:
    return _property_list_addendum


func _draw() -> void:
    if !Engine.editor_hint:
        return
    
    if surface_side == SurfaceSide.NONE:
        return
    
    var fill_cone_end_point := \
            -SurfaceSide.get_normal(surface_side) * ATTACHMENT_CONE_LENGTH
    var stroke_cone_end_point := \
            -SurfaceSide.get_normal(surface_side) * \
            (ATTACHMENT_CONE_LENGTH + ATTACHMENT_CONE_STROKE_WIDTH * 2.4)
    
    self.self_modulate.a = ATTACHMENT_CONE_OPACITY
    Sc.draw.draw_ice_cream_cone(
            self,
            stroke_cone_end_point,
            Vector2.ZERO,
            ATTACHMENT_CONE_RADIUS + ATTACHMENT_CONE_STROKE_WIDTH,
            ATTACHMENT_CONE_STROKE_COLOR,
            true)
    Sc.draw.draw_ice_cream_cone(
            self,
            fill_cone_end_point,
            Vector2.ZERO,
            ATTACHMENT_CONE_RADIUS,
            ATTACHMENT_CONE_FILL_COLOR,
            true)
    
    if include_exclusively:
        Sc.draw.draw_checkmark(
                self,
                Vector2.ZERO,
                INCLUDE_EXCLUSIVELY_WIDTH,
                INCLUDE_EXCLUSIVELY_COLOR,
                INCLUDE_EXCLUSIVELY_STROKE_WIDTH)
    
    if exclude:
        Sc.draw.draw_x(
                self,
                Vector2.ZERO,
                EXCLUDE_WIDTH,
                EXCLUDE_WIDTH,
                EXCLUDE_COLOR,
                EXCLUDE_STROKE_WIDTH)


func _update_editor_configuration() -> void:
    surface_side = SurfaceSide.get_type(surface_attachment)
    
    if !Engine.editor_hint:
        return
    
    if player_name == "":
        _set_configuration_warning("Must choose a player_name.")
        return
    
    # TODO: Remove this hack, and decouple things properly.
    var Su: Node = \
            get_node("/root/Su") if \
            has_node("/root/Su") else \
            null
    if Su != null:
        var movement_params = \
                Su.movement.player_movement_params[player_name] if \
                Su.movement.player_movement_params.has(player_name) else \
                null
        
        if surface_side != SurfaceSide.NONE and \
                movement_params == null:
            _set_configuration_warning(
                    "%s has no movement_params, and cannot attach to surafces." % \
                    player_name)
            return
        
        if surface_side == SurfaceSide.FLOOR and \
                !movement_params.can_grab_floors:
            _set_configuration_warning(
                    "%s's movement_params.can_grab_floors is false." % \
                    player_name)
            return
        
        if (surface_side == SurfaceSide.LEFT_WALL or \
                surface_side == SurfaceSide.RIGHT_WALL) and \
                !movement_params.can_grab_walls:
            _set_configuration_warning(
                    "%s's movement_params.can_grab_walls is false." % \
                    player_name)
            return
        
        if surface_side == SurfaceSide.CEILING and \
                !movement_params.can_grab_ceilings:
            _set_configuration_warning(
                    "%s's movement_params.can_grab_ceilings is false." % \
                    player_name)
            return
    
    call_deferred("_add_player")
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()
    property_list_changed_notify()
    update()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _add_player() -> void:
    if is_instance_valid(_player):
        _player.queue_free()
    _player = Sc.utils.add_scene(
            self,
            Sc.players.player_scenes[player_name])
    _player.modulate.a = PLAYER_OPACITY
    _player.show_behind_parent = true
    
    if surface_side == SurfaceSide.LEFT_WALL or \
            surface_side == SurfaceSide.RIGHT_WALL:
        _player.animator.play("RestOnWall")
        if surface_side == SurfaceSide.LEFT_WALL:
            _player.animator.face_left()
        else:
            _player.animator.face_right()
    else:
        _player.animator.play("Rest")


func _set_player_name(value: String) -> void:
    player_name = value
    _update_editor_configuration()


func _set_surface_attachment(value: String) -> void:
    surface_attachment = value
    _update_editor_configuration()


func _set_include_exclusively(value: bool) -> void:
    include_exclusively = value
    if include_exclusively:
        exclude = false
    _update_editor_configuration()


func _set_exclude(value: bool) -> void:
    exclude = value
    if exclude:
        include_exclusively = false
    _update_editor_configuration()

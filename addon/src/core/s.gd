class_name ScaffolderOld
extends Node
## S (ScaffolderOld)
##
## -   This is an autoload that holds a bunch of modules for the Scaffolder
##     framework.
## -   These modules provide lots of common functionality that is reusable across
##     many different kinds of games.
##
## Set up:
## -   Register this as an Autoload named S.
## -   Change stuff in manifest.tres.


signal loaded

signal level_loaded
signal level_started
signal level_ended

var snore_core: SnoreCore
var snore_core_settings: SnoreCoreMainSettings

var scaffolder: Scaffolder
var scaffolder_settings: ScaffolderSettings

var settings: ScaffolderSettingsOld
var game_screen: ScaffolderGameScreen
var session: GameSession

var logs_display: LoggersDisplay
var player: Node


# NOTE: Call this as early as possible from your main class.
func set_up(manifest: ScaffolderSettings) -> void:
	S.snore_core = SnoreCore.get_module("SnoreCore")
	S.scaffolder = SnoreCore.get_module("Scaffolder")
	S.snore_core_settings = snore_core.get_settings()
	S.scaffolder_settings = scaffolder.get_settings()

	# Load the user's custom settings if they exist, otherwise, load the default settings.
	if ResourceLoader.exists(S.snore_core_settings.get_user_settings_path()):
		settings = load(S.snore_core_settings.get_user_settings_path())
		if is_instance_valid(settings):
			S.log.print("Loaded player's previous settings")
		else:
			S.log.warning("An error occurred loading the player's previous settings")
	if not is_instance_valid(settings):
		settings = load(ScaffolderSettingsOld.DEFAULT_SETTINGS_PATH)
		S.log.print("Loaded default settings")

	var set_up_modules := [
		"settings",
		"log",
		"utils",
		"time",
		"audio",
		"screens",
	]
	for entry in set_up_modules:
		_set_up_module(entry)

	# TODO: Instantiate a Script that was registered with Manifest.
	session = GameSession.new()

	_on_loaded()


func _instantiate_attach_and_record_module(property_name: String, script: Script) -> void:
	var instance: Node = script.new()
	set(property_name, instance)
	add_child(instance)
	instance.process_mode = Node.PROCESS_MODE_ALWAYS


func _set_up_module(property_name: String) -> void:
	var instance: Object = get(property_name)
	if instance.has_method("set_up"):
		instance.set_up()


func _on_loaded() -> void:
	if S.log.logs_early_bootstrap_events:
		S.log.print("S.loaded")
	loaded.emit()

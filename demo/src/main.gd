class_name DemoMain
extends Node


# FIXME: LEFT OFF HERE: Implement manifests. ------------------------------
@export var snore_core_settings: SnoreCoreMainSettings
@export var scaffolder_settings: ScaffolderSettings

@export var run_tests := true


func _ready() -> void:
    G.snore_core = SnoreCore.get_module("SnoreCore")
    G.scaffolder = SnoreCore.get_module("Scaffolder")

    G.snore_core.connect("all_modules_set_up_finished", _on_snore_core_set_up_finished)
    SnoreCore.set_up([snore_core_settings, scaffolder_settings])

    if run_tests:
        var tests_passed = SnoreCore.run_tests()


func _on_snore_core_set_up_finished() -> void:
    G.snore_core_settings = G.snore_core.get_settings()
    G.scaffolder_settings = G.scaffolder.get_settings()

    # FIXME: Port Scaffolder logic and get this running.
    #S.set_up(G.scaffolder_settings)


func _on_gd_example_position_changed(node: Object, new_pos: Vector2) -> void:
    print("The position of " + node.get_class() + " is now " + str(new_pos))

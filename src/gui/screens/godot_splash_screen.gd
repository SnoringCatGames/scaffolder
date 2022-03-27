tool
class_name GodotSplashScreen
extends SplashScreen
## NOTE: This is actually an extra splash screen. This is shown after the
##       built-in "boot splash" that Godot always renders. This is made to be a
##       pixel-perfect duplicate of Godot's built-in splash screen.


func _ready() -> void:
    background_color_override = Sc.palette.get_color("boot_splash_background")

# Getting set up

Probably the easiest way to get set up is to copy the [Squirrel Away example project](https://github.com/snoringcatgames/squirrel_away), and then adjust it to fit your needs.

-   `addons/scaffolder`
    -   Add the Scaffolder library to your `addons/` folder.
-   `Sc`
    -   All of the Scaffolder functionality is globally accessible through properties on the `Sc` AutoLoad.
    -   The `Sc` AutoLoad is automatically registered.
    -   "Sc" is short for "Scaffolder".
-   `app_manifest`
    -   Define configuration parameters for Scaffolder.
    -   There are a _lot_ of parameters you can adjust here.
    -   Probably the easiest way to get started with this is to copy/paste/edit the pre-existing app-configuration from the Squirrel Away example app.
-   `Sc.run(app_manifest)`
    -   Configure the Scaffolder framework by calling `Sc.run(app_manifest)` as early as possible in your application.

## Do not instantiate anything before Scaffolder

> NOTE: This is important for Scaffolder's automatic crash reporting system to work correctly. If you don't care about crash reporting, then, yolo, do whatever you want!

### About app crashes...

It is very common for an application to work fine on your dev machine, but then fail on someone else's device. And most often, this failure will occur during app initialization.

Pretty much the only way to debug these errors is to upload and look at the console logs. These logs hopefully contain some interesting error messages or, at the very least, help you to understand roughly when/where in the application runtime the error occurred.

Unfortunately, since these errors so often occur during app initialization, you must try to handle them _before_ the rest of your app is initialized. This means that you need to be _very_ careful with any AutoLoads you register and with anything you do in your "Main Scene", since any logic in these places will likely run, and could crash the app, before we have a chance to report any previous crashes.

### Guidelines for how you initialize app state 

Here are some guidelines to minimize app crashes before we can report any previous crashes:
-   Include as few AutoLoads as possible.
-   Do as little in your "Main Scene" as possible.
-   Do not call `.new()` on anything from any of your AutoLoads or your "Main Scene", until after you know `Sc` is ready.
    -   You can listen for the signal `Sc.initialized` to know when Scaffolder is ready.

## Overriding `Sc` defaults

If you want to override or extend any Scaffolder functionality, you should be able to configure a replacement for the corresponding object. But make sure that your replacement `extends` the underlying Scaffolder class!

Here's an example of overriding some Scaffolder functionality:
```
var my_app_manifest := {
    ...
    audio_class = MyCustomAudio,
}
Sc.run(my_app_manifest)

class MyCustomAudio extends Audio:
    ...
```

## `Sc` and `app_manifest` properties

[sc.gd](/src/global/sc.gd) contains a list of interesting app-level parameters you can adjust.

> TODO: Enumerate and describe each `Sc` property.

## Automatic Project Settings and Input Map overrides

> **Note**: Scaffolder will automatically define various Project Settings fields and many Input Map actions. You can see which fields and actions are defined in [scaffolder_project_settings.gd](/src/global/scaffolder_project_settings.gd).

## Expected console errors

-   "Invalid get index 'foo'" and "Invalid call. Nonexistent function 'foo'"
    -   These are an artifact of how Godot handles AutoLoads with in-editor `tool` scripts.
    -   Hopefully, these will have been fixed by the time you're reading this...
-   When closing your game, you may see the following errors printed in the console. These are due to an underlying bug in Godot's type system. Godot improperly handles circular type references, and this leads to false-positives in Godot's memory-leak detection system.
```
ERROR: ~List: Condition "_first != __null" is true.
   At: ./core/self_list.h:112
ERROR: ~List: Condition "_first != __null" is true.
   At: ./core/self_list.h:112
WARNING: cleanup: ObjectDB instances leaked at exit (run with --verbose for details).
     At: core/object.cpp:2132
ERROR: clear: Resources still in use at exit (run with --verbose for details).
   At: core/resource.cpp:450
ERROR: There are still MemoryPool allocs in use at exit!
   At: core/pool_vector.cpp:66
```

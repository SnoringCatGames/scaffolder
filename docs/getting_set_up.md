# Getting set up

Probably the easiest way to get set up is to copy the [example app](https://github.com/snoringcatgames/exampler), and then adjust it to fit your needs.

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

## Still not working?

I'm sorry!

I have a long list of fixes I'd love to implement to make my frameworks do less by default, depend on less, and be much easier to use for folks in general. Unfortunately, I don't have time to do much! Nor will I have time to help you get things working in your particular game.

So I at least try to describe here why things are likely so broken, and possible things you could look into if you have the time, the technical expertise, and the motivation to get this working on your own!

Also, it might be easiest to start by cloning whatever game repo is my latest, and making changes to it.

> NOTE: Any of my game repos other than my latest one will likely be broken because of recent framework changes! Since these docs will inevitably become out-of-date, the safest thing is to check my recent GitHub activity.

In general, another thing to try is enabling one autoload at a time, then re-opening Godot. Since the AutoLoads are only instatiated in-editor when the editor first opens, enabling one AutoLoad won't fix another dependent AutoLoad.

### Some context

-   I am essentially developing these frameworks by myself.
-   I've been making many small games with these frameworks.
-   I include each framework as submodules within a given game's repo. This lets me easily make changes to the frameworks while working on a game.

### Problem 1: Extensive use of `tool` scripts, types, and AutoLoads

-   I expose each of my frameworks through a separate Autoload.
-   Unfortunately, if framework B depends on framework A, and framework A is broken or not registered in project settings, then the Autoload for framework A isn't going to be able to instantiate. And this type of error cascades, so frameworks C and D will fail too.
-   Also, many of the scripts in my frameworks are annotated as `tool`, which means that they are run within the editor (as well as in the actual running game).
-   This combination means that a "framework failure" will show up as many, many dependency-not-found and null-pointer-exception errors in the console as soon as you try to open the editor.
-   This will lock the editor for quite some time, and will again lock it when you make new changes or open new scenes.
-   These broken dependency errors are made even more worse because I include types whenever possible, and these type dependencies also break.

### Problem 2: Unintended inter-framework dependencies

-   Because I always include all of my frameworks, it's really easy for me to unintentionally introduce a dependency from one to the other without knowing it.
-   So if you are trying to use only a subset of my frameworks, you might see some errors for things not existing.

Inter-framework dependencies also happen because my latest game's configuration state leaks into my frameworks' scene files, because of how I use `tool` scripts and programmatically update state node state according to global configuration state.

### Problem 3: Scaffolder does too much

-   Most of my frameworks, but especially Scaffolder, do too much. They're too opinionated.
-   This saves me time, since I tend to repeat a lot of the same patterns between games.
-   But this is a nightmare for _you_, since you've set-up your codebase and application UI in a different way than I have.
-   In its current state, you'll need to disable various parts of Scaffolder in order to prevent it from doing strange things to your app.
-   Probably disabling initial screen-nav transitions from within `framework_bootstrap.gd` should help with the biggest issues.

### Problem 4: Scattered and confusing configurations

-   Each framework has its own autoload class (e.g., `sc.gd` for Scaffolder).
-   Each framework has its own schema class (e.g., `scaffolder_schema.gd` for Scaffolder).
-   My frameworks are setup to expect that you'll define a separate schema class for your game, and define/override most state for all frameworks through this schema class (e.g., `squirrel_away_schema.gd`).
-   My frameworks expect that you'll also define a class that extends either SurfacerLevelConfig or ScaffolderLevelConfig, and that you'll configure additional level state here for each level.
-   My frameworks expect that you'll also subclass various other important classes like SurfacerLevel, SurfacerLevelSession, and SurfacerCharacter and use these to integrate your game logic with my frameworks.

### Problem 5: Godot's import system

-   Because of how Godot configures imports, things may become less broken after you open the editor another time.

# Scaffolder

<p align="center">
  <img src="assets/images/device_icons/icon_128.png"
       alt="The Scaffolder icon, showing construction scaffolding">
</p>

> _**[Example app](https://github.com/snoringcatgames/squirrel-away)**_

This is an opinionated framework that provides a bunch of general-purpose application scaffolding and utility functionality for Godot games.

## Getting set up

Probably the easiest way to get set up is to copy the [Squirrel Away example app](https://github.com/snoringcatgames/squirrel-away), and then adjust it to fit your needs.

### Project Settings

Some of these are just my personal preference, some are important for the framework to run correctly.

-   Application > Config:
    -   Name
    -   Icon
    -   Quit On Go Back: false
-   Application > Run:
    -   Main Scene
-   Application > Boot Splash:
    -   Image
    -   Bg Color: Must match `Gs.screen_background_color`
-   Logging > File Logging:
    -   Enable File Logging: true
-   Rendering > Quality:
    -   Use Pixel Snap: true
    -   Framebuffer Allocation: 2D Without Sampling
    -   Framebuffer Allocation.mobile: 2D Without Sampling
-   Rendering > Environment:
    -   Default Clear Color: Match `Gs.screen_background_color`
    -   Default Environment: I usually move this out from the top-level directory.
-   Display > Window:
    -   Size > Width/Height: Must match `Gs.default_game_area_size`.
    -   Handheld > Orientation: sensor
    -   Stretch > Mode: disabled
    -   Stretch > Aspect: expand
-   Input Devices > Pointing:
    -   Emulate Touch From Mouse: true
    -   Ios > Touch Delay: 0.005
-   Layer Names:
    -   Name these!

### `Gs` AutoLoad and app setup

All of the Scaffolder functionality is globally accessible through properties on the `Gs` AutoLoad.

-   Define `Gs` as an AutoLoad (in Project Settings).
    -   It should point to the path `res://addons/scaffolder/src/ScaffolderConfig.gd`.
    -   It should be the first AutoLoad in the list.
-   Configure the Scaffolder framework by calling `ScaffolderBootstrap.on_app_ready` at the start of your Main Scene.

> **NOTE:** `Gs` stands for "Scaffolder", in case that's helful to know!

#### DO NOT INSTANTIATE ANYTHING UNTIL AFTER Scaffolder IS READY

> NOTE: This is important for the automatic crash reporting system to work correctly. If you don't care about crash reporting, then yolo, do whatever you want!

##### About app crashes...

It is very common for an application to work fine on your dev machine, but then fail on someone else's device. And most often, this failure will occur during app initialization.

Pretty much the only way to debug these errors is to upload and look at the console logs. These logs hopefully contain some interesting error messages or, at the very least, help you to understand roughly when/where in the application runtime the error occurred.

Unfortunately, since these errors so often occur during app initialization, you must try to handle them _before_ the rest of your app is initialized. This means that you need to be _very_ careful with any AutoLoads you register and with anything you do in your "Main Scene", since any logic in these places will likely run, and could crash the app, before we have a chance to report any previous crashes.

##### Guidelines for how you initialize app state 

Here are some guidelines to minimize app crashes before we can report any previous crashes:
-   Include as few AutoLoads as possible.
-   Do as little in your "Main Scene" as possible.
-   Do not call `.new()` on anything from any of your AutoLoads or your "Main Scene", until after you know `SurfacerConfig` is ready. You can use `call_deferred()` for this.

#### Overriding `ScaffolderConfig` defaults

If you want to override or extend any Scaffolder functionality, you should be able to configure a replacement for the corresponding object. But make sure that your replacement `extends` the underlying Scaffolder class!

Here's an example of overriding some Scaffolder functionality:
```
var my_app_manifest := {
    ...
    utils = MyCustomUtils.new(),
}
ScaffolderBootstrap.new().on_app_ready(my_app_manifest, self)

class MyCustomUtils extends ScaffolderUtils:
    ...
```

#### `ScaffolderConfig` properties

> TODO: Enumerate and describe each `ScaffolderConfig` property.

## Features

### Viewport scaling

This framework handles viewport scaling directly. You will need to turn off Godot's built-in viewport scaling (`Display > Window > Stretch > Mode = disabled`).

This provides some powerful benefits over Godot's standard behaviors, but requires you to be careful with how you define your GUI layouts.

#### Handling camera zoom

This provides limited flexibility in how far the camera is zoomed. That is, you will be able to see more of the level on a larger screen, but not too much more of the level. Similarly, on a wider screen, you will be able to able to see more from side to side, but not too much more.

-   You can configure a minimum and maximum aspect ratio for the game region.
-   You can configure a default screen size and aspect ratio that the levels are designed around.
-   At runtime, if the current viewport aspect ratio is greater than the max or less than the min, bars will be shown along the sides or top and bottom of the game area.
-   At runtime, the camera zoom will be adjusted so that the same amount of level is showing, either vertically or horizontally, as would be visible with the configured default screen size. If the screen aspect ratio is different than the default, then a little more of the level is visible in the other direction.
-   Any annotations that are drawn in the separate annotations CanvasLayer are automatically transformed to match whatever the game-area's current zoom and position is.
-   Click positions can also be transformed to match the game area.

#### Handling GUI scale

-   At runtime, a `gui_scale` value is calculated according to how the current screen resolution compares to the expected default screen resolution, as described above.
-   Then all fonts—which are registered with the scaffold configuration—are resized according to this `gui_scale`.
-   Then the size, position, and scale of all GUI nodes are updated accordingly.

#### Constraints for how you define your GUI layouts

> TODO: List any other constraints/tips.

-   Avoid custom positions, except maybe for centering images. For example:
    -   Instead of encoding a margin/offset, use a VBoxContainer or HBoxContainer parent, and include an empty spacer sibling with size or min-size.
    -   This is especially important when your positioning is calculated to include bottom/right-side margins.
-   Centering images:
    -   To center an image, I often place a `TextureRect` inside of a `Control` inside of some time of auto-positioning container.
    -   I then set the image position in this way: `TextureRect.rect_position = -TextureRect.rect_size/2`.
    -   This wrapper pattern also works well when I need to scale the image.
-   In general, whenever possible, I find it helpful to use a VBoxContainer or HBoxContainer as a parent, and to have children use the shrink-center size flag for both horizontal and vertical directions along with a min-size.

### Analytics

This feature depends on the proprietary third-party **[Google Analytics](https://analytics.google.com/analytics/web/#/)** service.

-   Fortunately, Google Analytics is at least free to use.
-   To get started with Google Analytics, [read this doc](https://support.google.com/analytics/answer/1008015?hl=en).
-   To learn more about the "Measurement Protocol" API that this class uses to send event info, [read this doc](https://developers.google.com/analytics/devguides/collection/protocol/v1).
-   To learn more about the "Reporting API" you could use to run arbitrary queries on your recorded analytics, [read this doc](https://developers.google.com/analytics/devguides/reporting/core/v4).
    -   Alternatively, you could just use [Google's convenient web client](http://analytics.google.com/).

#### "Privacy Policy" and "Terms and Conditions" documents

If you intend to record any sort of user data (including app-usage analytics or crash logs), you should create a "Privacy Policy" document and a "Terms and Conditions" document. These are often legally required when recording any sort of app-usage data. Fortunately, there are a lot of tools out there to help you easily generate these documents. You could then easily host these as view-only [Google Docs](https://docs.google.com/).

Here are two such generator tools that might be useful, and at least have free-trial options:
-   [Termly's privacy policy generator](https://termly.io/products/privacy-policy-generator/?ftseo)
-   [Nishant's terms and conditions generator](https://app-privacy-policy-generator.nisrulz.com/)

> _**DISCLAIMER:** I'm not a lawyer, so don't interpret anything from this framework as legal advice, and make sure you understand which laws you need to obey._

### Automatic error/crash reporting

This feature currently depends on the proprietary third-party **[Google Cloud Storage](https://cloud.google.com/storage)** service. But you could easily override it to upload logs somewhere else.

### Screen layout and navigation

-   You can control transitions through `Gs.nav`.
-   It is easy to include custom screens and exclude default screens.
-   Here are some of the default screns included:
    -   Main menu
    -   Credits
    -   Settings
        -   Configurable to display checkboxes, dropdowns, or plain text for whatever settings you might want to support.
    -   Level select
    -   Game/level
    -   Pause
    -   Notification
        -   Configurable to display custom text and buttons as needed.
    -   Game over

### Lots of useful utility functions

It might just be easiest to scroll through some of the following files to see what sorts of functions are included:
-   [`Audio`](./src/utils/Audio.gd)
-   [`CameraShake`](./src/utils/CameraShake.gd)
-   [`DrawUtils`](./src/utils/DrawUtils.gd)
-   [`Geometry`](./src/utils/Geometry.gd)
-   [`Profiler`](./src/utils/Profiler.gd)
-   [`SaveState`](./src/data/SaveState.gd)
-   [`Time`](./src/utils/Time.gd)
-   [`Utils`](./src/utils/Utils.gd)

### A widget library

For example:
-   [`AccordionPanel`](./src/gui/AccordionPanel.gd)
-   [`LabeledControlList`](./src/gui/labeled_control_list/LabeledControlList.gd)
-   [`ShinyButton`](./src/gui/ShinyButton.gd)
-   [`NavBar`](./src/gui/NavBar.gd)

## Licenses

-   All code is published under the [MIT license](LICENSE).
-   All art assets (files under `assets/images/`, `assets/music/`, and `assets/sounds/`) are published under the [CC0 1.0 Universal license](https://creativecommons.org/publicdomain/zero/1.0/deed.en).
-   This project depends on various pieces of third-party code that are licensed separately. [Here is a list of these third-party licenses](./src/config/ScaffolderThirdPartyLicenses.gd).

<p align="center">
  <img src="assets/images/device_icons/icon_128.png"
       alt="The Scaffolder icon, showing construction scaffolding">
</p>

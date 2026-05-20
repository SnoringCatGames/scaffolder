# scaffolder

> **Status: rewrite in progress.** This branch (`master`) is intentionally
> minimal during active development; the real code lives on `dev`.

A general-purpose Godot game framework — screens/menus, app lifecycle,
settings, save data, time/timers, debug overlays. Originally written
for Godot 3 in GDScript; being rewritten for Godot 4 in C++ as a
GDExtension.

## Branches

| Branch | Content |
|---|---|
| `master` (this) | Minimal during the rewrite — just this README. |
| `dev` | Active Godot 4 + C++/GDExtension development. |
| `godot3` | Preserved Godot 3 GDScript version (pre-rewrite). |
| `asset-lib-v0.7.0` | Pinned reference for the Godot Asset Library entry. |

## Where to go next

- Current work in progress: `git checkout dev`
- Stable Godot 3 version: `git checkout godot3`
- Umbrella project: [bootstrapper](https://github.com/SnoringCatGames/bootstrapper)

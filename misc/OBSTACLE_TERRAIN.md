# Procedural obstacle visuals

`Levels.generate_obstacles()` chooses **which cells are blocked**. The
`ObstaclePainter` chooses **how those cells look**. It never expands the mask or
opens a path through it, and it preserves existing waypoint tiles. All scenery
uses the `Obstacle` flags already configured in `game.tscn`.

The new atlas is source **2** (the third source in the TileSet). Cells remain
64 by 64 pixels.

| Atlas coordinates | Purpose |
| --- | --- |
| `(0,1)` through `(2,3)` | Lake corners, edges, and center |
| `(0,4)` through `(2,6)` | Forest corners, edges, and center |
| `(3,1)` and `(4,1)` | Standalone rocks |
| `(3,2)` | Standalone tree |
| `(0,7)`, `(1,7)`, `(2,7)` | Random waypoint markers, including the starting point |

## How patches are chosen

1. Group obstacles that touch horizontally or vertically.
2. Pick a lake or forest theme once for each group.
3. Fit large rectangles inside the group, then fit smaller patches in the
   remaining space. Each patch is at least 2 by 2 tiles.
4. Use the top/left/right/bottom artwork along the patch boundary and repeat the
   center artwork inside it. A 2 by 2 patch uses only the four corner tiles.
5. Fill the remaining narrow strips, protrusions, and awkward joins with props.
   Forest groups favor trees (85%); lake groups favor rocks (85%).

This is deliberately an approximation of the irregular obstacle shapes. The
nine-tile bodies have no inward-facing corners or one-cell end caps, so they
can form closed rectangular patches. The props preserve the original irregular
outline around those patches. Several patches may sit next to one another,
each with its own complete border.

For continuous L-shaped lakes or forests, the next artwork addition would be
the four inner corners. Narrow necks, tips, and isolated body cells need further
variants if they should also be rendered as water or canopy instead of props.

## Tuning

Select `Layers` in `game.tscn`:

- **Forest Chance**: `0.5` gives each obstacle group a 50% chance of being a
  forest. `0` produces lake groups; `1` produces forest groups. Props still fill
  shapes that the body tiles cannot represent. This is a probability per group,
  not a guaranteed percentage of the map's area.
- **Generation Seed**: `-1` generates new obstacles and scenery each run. Set
  a nonnegative number to reproduce both while experimenting. Waypoint choices
  still vary independently.

Obstacle density and smoothing are still the arguments to
`Levels.generate_obstacles()` in `misc/pathfinder.gd`. Higher density generally
allows larger bodies; thin shapes need more props.

## Verification

Run with Godot 4.6:

```text
godot --headless --path . res://tests/obstacle_painter_smoke.tscn
```

This checks corners and edges, thin strips, holes, protrusions, negative map
coordinates, repeatable seeds, several full generated maps, atlas flags,
navigation blocking, reachable waypoints, and all three waypoint variants.

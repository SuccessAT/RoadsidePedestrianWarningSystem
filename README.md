# Roadside LiDAR Pedestrian Warning System (MATLAB-Only)

## Overview

A MATLAB-only simulation of a **fixed roadside LiDAR** that watches a
blind corner and activates a warning sign when a pedestrian enters a
defined conflict zone. The LiDAR is pole-mounted, not vehicle-mounted.

Built with MATLAB R2025b, Automated Driving Toolbox, Lidar Toolbox.
No CARLA, no Python.

## Current status: Dynamic Simulation milestone (ground truth)

The pipeline currently runs end-to-end using **ground-truth pedestrian
position** in place of LiDAR-based detection:

```
Pedestrian actor -> position -> ROI check -> debounced controller -> sign
```

LiDAR point-cloud generation and detection (crop / ground removal /
clustering) have **not** been built yet — the LiDAR pole, range, and
FOV cone are drawn for visual reference and geometry planning only,
and are not yet wired into the controller.

## How to run

```matlab
cd RoadsidePedestrianWarningSystem
main
```

A figure opens showing the road, building, LiDAR pole + FOV wedge,
detection zone, and an animated pedestrian icon with a motion trail.
The warning sign marker turns red when the pedestrian is inside the
detection zone (after a debounce delay) and grey when it clears.

## Project structure

```
RoadsidePedestrianWarningSystem/
├── main.m                     Entry point: builds scenario, runs the
│                               animation loop, drives the controller
├── config.m                   ALL parameters live here -- no magic
│                               numbers anywhere else in the codebase
│
├── scenario/
│   ├── createRoad.m           L-shaped road via drivingScenario
│   ├── createBuilding.m       Building bounding box (centroid-based)
│   └── createPedestrian.m     Pedestrian actor (position only --
│                               motion is NOT driven by a toolbox
│                               trajectory, see note below)
│
├── controller/
│   ├── isInDetectionZone.m    Ground-truth ROI membership check
│   └── warningController.m    Debounced ON/OFF state machine
│
├── visualization/
│   ├── drawMap.m               Figure/axes setup, calls all draws
│   ├── drawRoad.m
│   ├── drawLaneMarkings.m
│   ├── drawBuilding.m
│   ├── drawDetectionZone.m
│   ├── drawLidar.m             LiDAR marker + FOV wedge
│   ├── drawWarningSign.m
│   ├── updateWarningSign.m     Runtime color flip (grey/red)
│   └── drawPedestrianIcon.m    hgtransform-based person glyph
│
├── lidar/          (empty -- next milestone)
├── processing/      (empty -- next milestone)
├── evaluation/      (empty -- future milestone)
└── data/            (empty)
```

## Key design decisions

- **`building.position` is a centroid**, not a corner. All footprint
  math derives `x:[cx-L/2, cx+L/2]`, `y:[cy-W/2, cy+W/2]` from this.
  This was changed after an early version placed the pedestrian path
  inside the building footprint (position was ambiguous as a corner).
- **Detection zone sits on the visible side of the building**
  (`x >= 38`), so "inside the zone" cleanly means "pedestrian has
  rounded the blind corner," not "pedestrian is inside a wall."
- **Pedestrian motion is manually interpolated**, not driven by
  `trajectory()` or `smoothTrajectory()`. Both toolbox functions fit a
  spline through waypoints and round off corners, even with only two
  waypoints. `main.m` instead computes position each frame via
  straight-line interpolation (`positionAlongPath`, a local function
  at the bottom of `main.m`), which gives exact, un-smoothed vertices
  when a sharp turn is wanted.
- **LiDAR cone parameters are derived from the detection zone
  geometry**, not guessed. `heading`/`fov`/`range` were computed from
  the angle and distance of each zone corner relative to the LiDAR
  position, so the cone fully covers the zone with margin. If the
  zone or LiDAR position changes, this angular coverage should be
  re-checked (see "Adjusting the FOV" below).

## Current parameter values (`config.m`)

| Parameter | Value | Notes |
|---|---|---|
| `simulation.sampleTime` | 0.03 s | ~33 updates/sec |
| `simulation.stopTime` | 20 s | |
| `road.width` | 7 m | |
| `building.position` (centroid) | [30, 17] | footprint x:[22,38] y:[10,24] |
| `lidar.position` | [34, 4, 4] | pole-mounted |
| `lidar.range` | 35 m | |
| `lidar.fov` | 140° | |
| `lidar.heading` | 30° | bisects the detection zone |
| `sign.position` | [35, 2, 3] | |
| `detectionZone.x` | [38, 48] | |
| `detectionZone.y` | [2, 28] | |
| `detectionZone.triggerDelay` | 0.5 s | debounce before ON |
| `detectionZone.clearDelay` | 1.0 s | debounce before OFF |
| `pedestrian.waypoints` | [15 2 0; 44 2 0; 44 30 0] | sharp 90° turn at (44,2) |
| `pedestrian.speed` | 1.4 m/s | average walking speed |

### Adjusting the FOV

If you move the LiDAR or the detection zone, re-check coverage by
computing, for each zone corner `(x,y)`:

```matlab
dx = x - lidar.position(1);
dy = y - lidar.position(2);
angle = atan2d(dy, dx);          % must fall within [heading-fov/2, heading+fov/2]
dist  = hypot(dx, dy);           % must be <= lidar.range
```

All four corners must satisfy both conditions for full coverage.

## Known limitations / not yet implemented

- No LiDAR point cloud generation (`lidar/` is empty).
- No ROI crop, ground removal, or clustering (`processing/` is empty).
- Controller reacts to ground-truth position, not detected position.
- No precision/recall/latency evaluation yet (`evaluation/` is empty).
- LiDAR FOV wedge is a flat 2D projection, not a true 3D coverage
  volume.
- `road.m`/lane rendering are centerline placeholders, not full road
  polygons with lane edges.

## Next milestones

1. **LiDAR**: configure a simulated roadside LiDAR sensor, generate
   point clouds against the scenario (including building occlusion).
2. **Processing**: crop to ROI, remove ground plane, cluster objects,
   classify/detect the pedestrian cluster.
3. **Controller**: replace `isInDetectionZone(ped.Position, cfg)` with
   the LiDAR-based detection result. No other controller logic should
   need to change.
4. **Evaluation**: precision, recall, false positive rate, detection
   latency, detection distance, compared against the ground-truth
   controller already built.

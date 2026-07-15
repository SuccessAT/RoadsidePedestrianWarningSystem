# Roadside LiDAR Pedestrian Warning System — Progress Notes

Living handoff document. Goal: someone picking this up cold should be able to
understand not just *what* the code does, but *why* every non-obvious number
and design choice is what it is, and exactly where the remaining risk sits.

---

## 1. What this project is

A MATLAB simulation of a **fixed roadside LiDAR** watching a blind street
corner. When a pedestrian rounds the corner (hidden from an approaching
driver by a building) and enters a defined conflict zone, the LiDAR detects
them and a roadside warning sign switches on, with debounce delays so it
doesn't flicker. Built on Automated Driving Toolbox + Lidar Toolbox (MATLAB
R2025b). No CARLA, no Python, no RoadRunner.

---

## 2. Two parallel entry points — know which one you're editing

| | `main.m` | `main3D.m` |
|---|---|---|
| Detection | **Ground truth** — pedestrian position checked directly against the ROI box (`isInDetectionZone.m`) | **Real LiDAR** — actual point cloud generated, cropped, clustered (`pcsegdist`) |
| Visualization | Hand-drawn 2D top-down (`drawMap.m` + friends) | Real 3D meshes via `plot(scenario,'Meshes','on')` |
| Actors | Pedestrian only (icon + trail) | Pedestrian (human mesh), vehicle (car mesh), building (custom mesh), LiDAR pole |
| Status | Complete, stable, not touched in recent sessions | Active development — this is where all recent work has gone |

**They share `config.m`, `createRoad.m`, `createBuilding.m`, and
`createPedestrian.m`.** Recent edits to `createPedestrian.m` (real mesh,
manual position driving) apply to both, but `main.m`'s 2D visualization
files (`drawMap.m`, `drawPedestrianIcon.m`, etc.) have **not** been
re-verified against the pedestrian's current waypoints/geometry since the
last major config rewrite. If you run `main.m` right now, don't be surprised
if the pedestrian icon walks somewhere that no longer matches the visually
narrower/tighter road — that file tree was last coherent under the *old*
config numbers, before the corner/building/zone geometry got reworked for
`main3D.m`.

**This document focuses on `main3D.m`**, since that's where all current
effort is.

---

## 3. Current file map

```
RoadsidePedestrianWarningSystem/
├── main.m                    2D ground-truth demo (stable, not recently touched)
├── main3D.m                  3D LiDAR demo (active development)
├── config.m                  ALL parameters -- single source of truth
│
├── scenario/
│   ├── createRoad.m           L-shaped road via drivingScenario
│   ├── createBuilding.m       Bounding-box math only (centroid -> x/y extents)
│   ├── createBuildingActor.m  Building as a real actor w/ custom mesh (main3D only)
│   ├── createEgoSensorMount.m Stationary "vehicle" actor = the LiDAR pole (main3D only)
│   ├── createVehicle.m        Approaching car, real mesh, trajectory() (main3D only)
│   └── createPedestrian.m     Pedestrian actor -- shared by both mains
│
├── controller/
│   ├── isInDetectionZone.m    Ground-truth ROI check (main.m path)
│   └── warningController.m    Debounced ON/OFF state machine -- shared
│
├── lidar/
│   ├── createLidarSensor.m    Configures lidarPointCloudGenerator (main3D only)
│   └── simulateLidarFrame.m   Steps the sensor each frame (main3D only)
│
├── processing/
│   ├── cropToFOV.m            Azimuth/range crop, sensor frame (main3D only)
│   ├── toWorldFrame.m         Sensor-frame -> world-frame transform (main3D only)
│   └── detectPedestrian.m     ROI crop + pcsegdist clustering -> detected flag (main3D only)
│
├── visualization/
│   ├── drawMap.m, drawRoad.m, drawLaneMarkings.m, drawBuilding.m,
│   │   drawDetectionZone.m, drawLidar.m, drawWarningSign.m,
│   │   updateWarningSign.m, drawPedestrianIcon.m   -- all main.m (2D) only
│   ├── draw3DScene.m           Real mesh render + overlays (main3D only)
│   └── update3DScene.m         Per-frame overlay update (main3D only)
│
├── controller/, evaluation/, data/  -- evaluation/ and data/ still empty (future milestone)
```

---

## 4. Milestone history (chronological, condensed)

1. **Static planning doc → working 2D ground-truth sim.** Road, building,
   detection zone, debounced warning controller, pedestrian as an animated
   dot with a trail. This is `main.m` today.
2. **Geometry bug caught early:** `building.position` was ambiguous (corner
   vs. centroid). Fixed by defining it as **centroid** everywhere, and
   re-routing the pedestrian path so it didn't walk through the building.
3. **Sharp-corner requirement:** discovered that both `trajectory()` and
   `smoothTrajectory()` spline through waypoints and round off corners —
   neither can produce an exact vertex. Solution: **stopped using either**;
   the pedestrian's position is now computed manually every frame by
   `positionAlongPath()` (a local function inside `main3D.m`), which does
   true piecewise-linear interpolation between waypoints. This is why the
   pedestrian has no `trajectory()` call in `createPedestrian.m` — that's
   intentional, not an oversight.
4. **Upgrade to real LiDAR (`main3D.m` born).** Multiple rounds of API
   trial-and-error against `lidarPointCloudGenerator` — documented in
   detail in §6 below, because the property names/call signature that
   actually work are *not* what most cached documentation/examples imply,
   and re-guessing them is exactly the mistake to avoid repeating.
5. **Realism pass:** real human mesh (`driving.scenario.pedestrianMesh`),
   real car mesh (`driving.scenario.carMesh`) on a new vehicle actor, a
   constructed building mesh (box + rooftop unit via `extendedObjectMesh`),
   and switched rendering from hand-drawn patches to the toolbox's own
   `plot(scenario,'Meshes','on')`.
6. **Geometry overhaul (most recent):** user reported three problems from a
   screenshot — (a) the road corner was a huge sweeping curve instead of a
   tight street-corner bend, (b) the pedestrian never entered the detection
   zone, (c) the LiDAR didn't actually cover the zone geometrically. All
   three were traced to the same root cause: road/building/LiDAR/zone/
   pedestrian/vehicle numbers had drifted out of sync across many
   incremental edits. Fixed by **re-deriving the entire layout as one
   coherent system** (see §7) rather than patching pieces independently.
7. **LiDAR sensor API, final correction:** the working call signature is
   `lidarSensor(tgts, rdmesh, time)` (three positional args: target poses,
   nearby road mesh, sim time) — **not** `(time, egoPose, poses)` and not
   `(time, poses)`. Sensor position is set via `SensorLocation` (2-D
   `[x y]`, relative to the ego actor) + `Height` (scalar) — **not**
   `MountingLocation`/`MountingAngles`, which don't exist on this class in
   this MATLAB version. Downward tilt is achieved by setting `Pitch` on the
   **ego actor itself** (`createEgoSensorMount.m`), not on the sensor
   object. See §6 for the full trail of wrong guesses, kept deliberately so
   they aren't retried.

---

## 5. Current geometry, as one coherent system

Everything below is derived together — if you change one number, re-check
the others using the same angle/distance math, or coverage breaks again
(this has already happened twice).

**Road** (`cfg.road.centers`): L-shaped, corner compressed into a ~12m span
(x:28→40, y:0→8) instead of spanning the full 40m, giving a tighter,
street-corner-like bend. `road()` always fits a smooth spline — MATLAB
offers no literal zero-radius corner (and a real car couldn't drive one
anyway) — but this reads as a curb-radius turn, not a highway sweep.

**Building** (`cfg.building`): centroid `[26 14]`, 16×16×8m →
footprint x:[18,34], y:[6,22]. Sits in the inner corner, creating the
blind spot.

**LiDAR pole** (`cfg.lidar`): position derived parametrically as an offset
from the building's own corner (`bldCornerX`/`bldCornerY` computed inline
in `config.m`), landing at `[22, -5, 6]` — south side of Road A, moderate
standoff distance (not right on top of the zone). heading 48°, FOV 60°,
range 44m, pitch −13°.

**Detection zone**: x:[34,46], y:[8,26], z:[0,3] — past the corner, on
Road B.

**Verified coverage math** (angle/distance from LiDAR to each zone corner):

| Corner | Angle | Distance | Elevation needed (downward) |
|---|---|---|---|
| (34,8) | 47.3° | 17.7m | 18.7° |
| (46,8) | 28.4° | 27.3m | 8.7° |
| (34,26) | 68.8° | 33.3m | — |
| (46,26) | 52.3° | 39.2m | — |

- Azimuth: heading 48° ± 30° (fov/2) → covers 18°–78°. All four corners
  (28.4°–68.8°) fall inside with margin.
- Range: max corner distance 39.2m < 44m range, with margin.
- Elevation: pitch −13° ± elevationLimits [-8,8]° → beam covers 5°–21°
  downward. Needed range is 8.7°–18.7° — inside, with margin both ends.

**Pedestrian** (`cfg.pedestrian.waypoints`): sharp 90° turn at `(44,4)`.
Walks south along Road B's far sidewalk (x=44, always east of the
building — opposite side from the vehicle), sweeping through the
detection zone for ~18m of that descent, then turns west along Road A's
north sidewalk (y=4, always south of the building), moving away from the
corner and never re-entering. Verified against the building footprint:
segment 1 (x=44 constant) is always east of the building's x-max (34), so
it can never intersect the building regardless of y. Segment 2 (y=4
constant) is always south of the building's y-min (6), so it can never
intersect the building regardless of x.

**Vehicle** (`cfg.vehicle.waypoints`): Road A south lane, stops at x=26,
before the corner cluster starts (x=28) — doesn't need to navigate the
turn itself. Opposite side of the building from the pedestrian's sidewalk.

---

## 6. LiDAR sensor API — the trail of wrong guesses (read before touching `lidar/`)

This class's real interface does **not** match the most commonly-cached
examples online, and was wrong three separate times before landing on
something that actually ran. Recorded here specifically so no one
(human or AI) re-tries the same dead ends.

1. ❌ `'UpdateRate'` as a constructor property — **not accessible** on this
   class/version. Removed.
2. ❌ Calling the sensor as `lidarSensor(time, poses)` (2 args) — errored
   with "expected 3, got 2".
3. ❌ Calling it as `lidarSensor(time, egoPoseStruct, poses)` (hand-built
   ego pose + hand-built poses struct) — got past the arg-count check but
   failed struct validation on the poses argument no matter how carefully
   the struct was constructed field-by-field.
4. ❌ Hand-building the target-poses struct at all — abandoned in favor of
   the officially documented `actorPoses(scenario)` — still didn't fully
   resolve the issue because the call signature itself was wrong.
5. ✅ **Working signature**, confirmed against the actual documented
   workflow:
   ```matlab
   tgts   = targetPoses(egoVehicle);
   rdmesh = roadMesh(egoVehicle);
   [ptCloud, isValidTime] = lidarSensor(tgts, rdmesh, scenario.SimulationTime);
   ```
   This requires a **real ego actor** in the scenario (not a hand-built
   pose struct) — hence `createEgoSensorMount.m` creates an actual
   stationary `vehicle()` object to represent the pole.
6. ❌ `'MountingLocation'` / `'MountingAngles'` as constructor
   properties — **not accessible** on this class/version either (this
   error came *after* fix #5, i.e., the call signature was right but the
   positioning properties were wrong).
7. ✅ **Working position properties**, confirmed directly from MathWorks
   docs for this exact class: `'SensorLocation'` (2-D `[x y]`, relative to
   the ego actor's own frame) + `'Height'` (separate scalar). No combined
   3-D mounting vector exists for this object.
8. **Pitch/tilt** — since the sensor object itself has no confirmed
   angle-mounting property, downward tilt is applied to the **ego actor's
   own `Pitch` property** instead (a standard, well-documented pose
   property on `actor()`/`vehicle()`, unlike anything on the sensor
   object). Because of this, `toWorldFrame.m` had to be upgraded from a
   yaw-only rotation to a full yaw+pitch rotation, since the point cloud
   is now returned relative to a genuinely tilted ego body frame, not a
   level one.

**Known unverified assumption, flagged for testing:** `Pitch` is assumed
to follow the conventional positive = nose-up sign. `cfg.lidar.pitch` is
set to `-13` (nose down, looking at the zone). **If the point cloud ends
up pointing away from the zone instead of into it**, the fix is a one-line
sign flip: change `cfg.lidar.pitch = -13` to `+13` in `config.m`. Nothing
else needs to change if this is wrong — the azimuth/range geometry is
independently verified and doesn't depend on the pitch sign.

**Stale comment to clean up:** `config.m` line 51 still says "mounted via
MountingAngles" in a trailing comment — that's now inaccurate since pitch
moved to the ego actor's `Pitch` property (see point 8 above). Harmless,
but worth fixing next time that file is touched.

---

## 7. Known limitations / not yet done

- **`main.m`'s 2D visualization tree is stale** relative to the current
  geometry (§2) — not broken, just not re-verified against the latest
  corner/building/zone numbers.
- **No real building import.** Automated Driving Toolbox has no OSM/GIS
  building import in scripted MATLAB workflows — that exists only in
  RoadRunner Scene Builder, a separate application. The current building
  is a constructed proxy mesh (box + rooftop unit via `extendedObjectMesh`
  + `join()`), not an imported real structure. If a supervisor specifically
  wants imported real-world building geometry, that requires RoadRunner,
  not this MATLAB script.
- **`evaluation/` and `data/` are still empty.** No precision/recall/false
  positive rate/detection latency/detection distance metrics exist yet.
- **LiDAR FOV wedge visualization** (from the earlier 2D `drawLidar.m`) is
  a flat 2D projection, not a true 3D coverage volume — and isn't used at
  all in `main3D.m`'s renderer, which shows the live point cloud directly
  instead (arguably better — it shows *actual* coverage, not a
  theoretical wedge).
- **No noise model.** `HasNoise` is `false` throughout — real LiDAR
  returns would have range/angle noise; useful to enable once detection
  logic is trusted, to stress-test `detectPedestrian.m`'s clustering
  threshold (`pcsegdist(...,0.5)`, minimum 5 points).
- **Warning controller logic itself hasn't changed** since the ground-truth
  milestone — `warningController.m` and its debounce timers
  (`triggerDelay`=0.5s, `clearDelay`=1.0s) are shared, untouched, and
  already validated against the ground-truth path back in milestone 1.

---

## 8. Suggested next steps

1. Run `main3D.m`, confirm the point cloud actually appears inside the red
   detection zone box during the pedestrian's crossing, and confirm the
   warning sign flips red. If the point cloud looks like it's aimed the
   wrong way vertically, apply the one-line pitch sign flip from §6.
2. Once confirmed working, re-sync `main.m`'s 2D visualization files
   against the current config (§2) — or explicitly retire `main.m` in
   favor of `main3D.m` if the 2D ground-truth view is no longer needed.
3. Start on `evaluation/`: precision, recall, false positive rate,
   detection latency, detection distance — comparing `detectPedestrian.m`'s
   real-LiDAR-based trigger against `isInDetectionZone.m`'s ground-truth
   trigger on the same pedestrian path.
4. Consider enabling `HasNoise` and re-testing the clustering threshold in
   `detectPedestrian.m` once the clean-signal case is confirmed solid.

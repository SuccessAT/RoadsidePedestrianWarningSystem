function cfg = config()
%CONFIG Central configuration for the Roadside Pedestrian Warning System.
% Every script reads from this struct. No magic numbers elsewhere.
%
% Geometry note: road(), building, LiDAR, detection zone, pedestrian and
% vehicle paths are ALL solved together as one coherent layout -- moving
% one number here without re-checking the others (angle/distance/
% elevation math below) will likely break coverage again.

%% Simulation
cfg.simulation.sampleTime = 0.03;   % s (~33 updates/sec)
cfg.simulation.stopTime   = 25;     % s

%% Road (L-shaped)
% Corner is compressed into a ~12m span (x:28-40, y:0-8) instead of
% spanning the full 40m, giving a much tighter, more street-corner-like
% bend. road() always fits a smooth spline -- a literal zero-radius
% corner isn't physically drivable and isn't offered by this function --
% but this is a realistic curb-radius turn, not a highway sweep.
cfg.road.width   = 7;
cfg.road.centers = [
     0   0
    28   0
    34   0
    38   3
    40   8
    40  40
];

%% Building (position = CENTROID [x y])
cfg.building.position = [26 14];
cfg.building.length   = 16;   % x-extent
cfg.building.width    = 16;   % y-extent
cfg.building.height   = 8;
% Footprint: x:[18 34], y:[6 22] -- sits in the inner corner, creating
% the blind spot for a vehicle on Road A turning onto Road B.

%% LiDAR (roadside pole, fixed, moderate standoff -- not right on top of
% the target zone, so a modest downward tilt can cover it cleanly)
bldCornerX = cfg.building.position(1) + cfg.building.length/2;   % 34
bldCornerY = cfg.building.position(2) - cfg.building.width/2;    % 6

cfg.lidar.offsetFromBuildingCorner = [-12 -11 6];   % [dx dy poleHeight]
cfg.lidar.position = [bldCornerX + cfg.lidar.offsetFromBuildingCorner(1), ...
                       bldCornerY + cfg.lidar.offsetFromBuildingCorner(2), ...
                       cfg.lidar.offsetFromBuildingCorner(3)];   % -> [22 -5 6]

cfg.lidar.heading = 48;    % degrees, bisects the detection zone azimuth
cfg.lidar.fov     = 60;    % degrees -- covers 18-78 deg (zone: 28.4-68.8)
cfg.lidar.range   = 44;    % m -- covers farthest corner (39.2m) with margin
cfg.lidar.pitch   = -13;   % degrees, downward tilt (mounted via MountingAngles)

cfg.lidar.azimuthResolution   = 0.5;      % degrees
cfg.lidar.elevationLimits     = [-8 8];   % degrees, combined with pitch
cfg.lidar.elevationResolution = 1.25;     % degrees
% Beam covers 5-21 deg downward (pitch +/- limits); zone needs 8.7-18.7 deg.

%% Warning sign (visible to the approaching driver before the corner)
cfg.sign.position = [24 -3 3];

%% Detection zone (ROI) -- past the corner, on Road B
cfg.detectionZone.x = [34 46];
cfg.detectionZone.y = [8  26];
cfg.detectionZone.z = [0  3];

cfg.detectionZone.triggerDelay = 0.5;   % s inside zone before warning ON
cfg.detectionZone.clearDelay   = 1.0;   % s absent before warning OFF

%% Pedestrian
% Sharp 90-degree turn at (44,4): walks south along the FAR sidewalk of
% Road B (x=44, always east of the building -- opposite side from the
% vehicle), sweeping through the detection zone for ~18m of that
% descent, then turns west along Road A's north sidewalk (y=4, always
% south of the building) -- away from the corner, never re-entering.
% Position is driven manually each frame in main3D.m (positionAlongPath),
% NOT via trajectory()/smoothTrajectory(), which round off the corner.
cfg.pedestrian.waypoints = [
    44  34   0
    44   4   0
    10   4   0
];
cfg.pedestrian.speed  = 1.4;
cfg.pedestrian.length = 0.24;
cfg.pedestrian.width  = 0.45;
cfg.pedestrian.height = 1.7;

%% Approaching vehicle (Road A, south lane -- opposite side of the
% building from the pedestrian's sidewalk). Stops before the corner
% cluster (x=28) so it doesn't need to navigate the turn itself.
cfg.vehicle.waypoints = [
     0  -1.75  0
    26  -1.75  0
];
cfg.vehicle.speed = 8;   % m/s (~29 km/h)

end

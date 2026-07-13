function cfg = config()
%CONFIG Central configuration for the Roadside Pedestrian Warning System.
% Every script reads from this struct. No magic numbers elsewhere.

%% Simulation
cfg.simulation.sampleTime = 0.03;   % s (~33 updates/sec for smoother animation)
cfg.simulation.stopTime   = 150;     % s

%% Road (L-shaped, defined by drivingScenario road centerline)
cfg.road.width   = 7;
cfg.road.centers = [
     0   0
    40   0
    40  40
];

%% Building
% position = CENTROID [x y]  <-- explicitly defined to remove ambiguity
% length   = extent along X
% width    = extent along Y
cfg.building.position = [30 17];
cfg.building.length   = 16;
cfg.building.width    = 14;
cfg.building.height   = 8;
% Resulting footprint: x:[22 38], y:[10 24]
% This sits on the inner corner and creates the LiDAR blind spot.

%% LiDAR (roadside, fixed, NOT vehicle-mounted)
cfg.lidar.position = [34 4 4];   % [x y z], pole-mounted
cfg.lidar.range    = 35;
cfg.lidar.fov      = 140;        % degrees
cfg.lidar.heading  = 30;         % degrees, bisects the detection zone corners

%% Warning sign
cfg.sign.position = [35 2 3];

%% Detection zone (ROI)
% Placed on the VISIBLE side of the building (x > 38), so "inside zone"
% cleanly means "pedestrian has rounded the blind corner and is now
% approaching the crossing" -- not "pedestrian is inside a wall".
cfg.detectionZone.x = [38 42];
cfg.detectionZone.y = [2  28];
cfg.detectionZone.z = [0  3];

cfg.detectionZone.triggerDelay = 0.5;   % s inside zone before warning ON
cfg.detectionZone.clearDelay   = 1.0;   % s absent before warning OFF

%% Pedestrian (ground-truth actor for this milestone -- no LiDAR yet)
% Multi-waypoint path, routed to stay clear of the building footprint.
% Designed to sweep the pedestrian INTO and OUT of the LiDAR FOV cone:
%   (15,6) -> (30,6)  : approaching along the south sidewalk, outside FOV
%                        (angle ~150-175 deg, cone only covers -40..100)
%   (40,6)             : rounds the corner, enters the FOV (~18 deg, 6.3m)
%   (44,20)             : still inside FOV, sweeping through (~58 deg, 19m)
%   (48,40)             : exits FOV via range limit (~39m > 35m range)
cfg.pedestrian.waypoints = [
    15   2   0
    42   2   0
    42  30   0
];
cfg.pedestrian.speed = 0.5;   % m/s, average walking speed

end

function main3D()
clc; close all;

addpath('scenario', 'visualization', 'controller', 'lidar', 'processing');

cfg = config();

scenario   = createRoad(cfg);
bld        = createBuilding(cfg);
egoVehicle = createEgoSensorMount(scenario, cfg);
createBuildingActor(scenario, cfg);
ped        = createPedestrian(scenario, cfg);

lidarSensor = createLidarSensor(cfg, scenario, egoVehicle);
h = draw3DScene(cfg, bld);

state = [];

while advance(scenario)
    t   = scenario.SimulationTime;
    pos = positionAlongPath(cfg.pedestrian.waypoints, cfg.pedestrian.speed, t);
    ped.Position = pos;

    ptCloudSensor = simulateLidarFrame(lidarSensor, egoVehicle, t);
    ptCloudFOV    = cropToFOV(ptCloudSensor, cfg);
    ptCloudWorld  = toWorldFrame(ptCloudFOV, egoVehicle);

    occupied = detectPedestrian(ptCloudWorld, cfg);
    [warningOn, state] = warningController(state, occupied, cfg.simulation.sampleTime, cfg);

    update3DScene(h, pos, ptCloudWorld, warningOn);
    title(h.ax, sprintf('t = %.2f s | Warning: %s | Points: %d', ...
        t, ternaryStr(warningOn), ptCloudWorld.Count));

    drawnow limitrate;
end

end

function s = ternaryStr(tf)
if tf
    s = 'ON';
else
    s = 'OFF';
end
end

function pos = positionAlongPath(waypoints, speed, t)
segLengths = vecnorm(diff(waypoints(:,1:2)), 2, 2);
cumLen     = [0; cumsum(segLengths)];
distTravelled = min(speed * t, cumLen(end));

segIdx = find(cumLen <= distTravelled, 1, 'last');
segIdx = min(segIdx, size(waypoints,1) - 1);

segLen = segLengths(segIdx);
if segLen == 0
    frac = 0;
else
    frac = (distTravelled - cumLen(segIdx)) / segLen;
end

p1 = waypoints(segIdx, :);
p2 = waypoints(segIdx + 1, :);
pos = p1 + frac * (p2 - p1);
end

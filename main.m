function main()
%MAIN Roadside Pedestrian Warning System -- Dynamic Simulation milestone.
% Pedestrian actor + walking path + animation loop + ground-truth
% warning controller. No LiDAR processing yet -- this validates the
% controller logic before perception is added.

clc; close all;

addpath('scenario', 'visualization', 'controller');

cfg = config();

scenario = createRoad(cfg);
bld      = createBuilding(cfg);
ped      = createPedestrian(scenario, cfg);

h = drawMap(cfg, bld);

state = [];   % warningController state, initialized on first call

while advance(scenario)
    t   = scenario.SimulationTime;
    pos = positionAlongPath(cfg.pedestrian.waypoints, cfg.pedestrian.speed, t);
    ped.Position = pos;   % manually drive the actor -- exact straight segments

    occupied = isInDetectionZone(pos, cfg);
    [warningOn, state] = warningController(state, occupied, cfg.simulation.sampleTime, cfg);

    set(h.ped, 'Matrix', makehgtform('translate', [pos(1) pos(2) 0]));
    addpoints(h.trail, pos(1), pos(2));
    updateWarningSign(h.sign, warningOn);

    title(h.ax, sprintf('Roadside Pedestrian Warning -- t = %.2f s | Warning: %s', ...
        t, ternaryStr(warningOn, 'ON', 'OFF')));

    drawnow limitrate;
end

end

function pos = positionAlongPath(waypoints, speed, t)
%POSITIONALONGPATH True piecewise-linear position at elapsed time t.
% Walks along the straight segments between waypoints at constant speed;
% holds at the final waypoint once the path is complete.

segLengths = vecnorm(diff(waypoints(:,1:2)), 2, 2);   % (N-1)x1
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

function s = ternaryStr(tf, a, b)
if tf
    s = a;
else
    s = b;
end
end
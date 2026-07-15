function veh = createVehicle(scenario, cfg)
%CREATEVEHICLE Real car mesh, driving toward the blind corner.
% Straight path -- trajectory()'s spline-through-corners behavior is a
% non-issue here since there's no corner to round.

veh = vehicle(scenario, 'ClassID', 1, ...
    'Mesh', driving.scenario.carMesh, ...
    'Position', cfg.vehicle.waypoints(1,:), ...
    'Name', 'ApproachingVehicle');

trajectory(veh, cfg.vehicle.waypoints, cfg.vehicle.speed);
end

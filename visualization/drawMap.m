function h = drawMap(cfg, bld)
%DRAWMAP Create the figure/axes and draw all static + dynamic elements.
% Returns handles needed for the animation loop in main.m.

h.fig = figure('Color', 'w', 'Name', 'Roadside Pedestrian Warning System');
h.ax = axes(h.fig);
hold(h.ax, 'on');
axis(h.ax, 'equal');
xlim(h.ax, [-5 55]);
ylim(h.ax, [-5 45]);
xlabel(h.ax, 'X (m)');
ylabel(h.ax, 'Y (m)');
title(h.ax, 'Roadside LiDAR Pedestrian Warning -- Ground Truth Demo');
grid(h.ax, 'on');

drawRoad(h.ax, cfg);
drawLaneMarkings(h.ax, cfg);
drawBuilding(h.ax, bld);
drawDetectionZone(h.ax, cfg);
h.lidar = drawLidar(h.ax, cfg);
h.sign  = drawWarningSign(h.ax, cfg);

% Motion trail: fixed-length window gives a "recent path" fading effect
h.trail = animatedline(h.ax, 'Color', [0.3 0.6 0.9], 'LineWidth', 2, ...
    'MaximumNumPoints', 60);

% Pedestrian icon (hgtransform -- moved via translation, not redrawn)
h.ped = drawPedestrianIcon(h.ax, cfg.pedestrian.waypoints(1,:));

legend(h.ax, {'', '', '', 'Detection Zone', 'LiDAR', 'LiDAR FOV', 'Warning Sign'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal', 'Box', 'off');

end

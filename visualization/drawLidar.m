function h = drawLidar(ax, cfg)
%DRAWLIDAR Draw the roadside LiDAR position and its field-of-view wedge.

p = cfg.lidar.position;

h = plot(ax, p(1), p(2), '^', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0 0.6 0.2], 'MarkerEdgeColor', 'k');
text(ax, p(1) + 0.5, p(2) + 0.5, 'LiDAR');

heading = cfg.lidar.heading;
fov     = cfg.lidar.fov;
r       = cfg.lidar.range;

angles = linspace(heading - fov/2, heading + fov/2, 30);
xw = p(1) + [0, r * cosd(angles), 0];
yw = p(2) + [0, r * sind(angles), 0];

patch(ax, xw, yw, [0 0.6 0.2], 'FaceAlpha', 0.06, ...
    'EdgeColor', [0 0.6 0.2], 'LineStyle', ':');

end

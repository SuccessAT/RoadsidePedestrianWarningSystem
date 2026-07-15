function h = draw3DScene(scenario, cfg)
%DRAW3DSCENE Render the real scenario meshes, then overlay everything
% the toolbox doesn't draw natively: LiDAR pole, warning sign, detection
% zone, and the live point cloud.

h.fig = figure('Color', 'w', 'Name', 'Roadside LiDAR -- Realistic 3D View');
plot(scenario, 'Meshes', 'on');   % renders real building/vehicle/pedestrian meshes
h.ax = gca;
hold(h.ax, 'on');
view(h.ax, 45, 30);
zlim(h.ax, [0 12]);

% LiDAR pole
p = cfg.lidar.position;
plot3(h.ax, [p(1) p(1)], [p(2) p(2)], [0 p(3)], 'k-', 'LineWidth', 3);
plot3(h.ax, p(1), p(2), p(3), '^', 'MarkerSize', 12, ...
    'MarkerFaceColor', [0 0.6 0.2], 'MarkerEdgeColor', 'k');

% Warning sign
sp = cfg.sign.position;
h.sign = plot3(h.ax, sp(1), sp(2), sp(3), 's', 'MarkerSize', 18, ...
    'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerEdgeColor', 'k', 'LineWidth', 2);

% Detection zone (translucent box)
drawCuboid(h.ax, cfg.detectionZone.x, cfg.detectionZone.y, cfg.detectionZone.z, ...
    [1 0 0], 0.08);

% Live LiDAR point cloud overlay
h.pc = scatter3(h.ax, nan, nan, nan, 8, [1 0 0], 'filled');

end

function drawCuboid(ax, xr, yr, zr, faceColor, faceAlpha)
[X, Y, Z] = ndgrid(xr, yr, zr);
V = [X(:) Y(:) Z(:)];
F = [1 2 4 3; 5 6 8 7; 1 2 6 5; 3 4 8 7; 1 3 7 5; 2 4 8 6];
patch(ax, 'Vertices', V, 'Faces', F, 'FaceColor', faceColor, ...
    'FaceAlpha', faceAlpha, 'EdgeColor', faceColor, 'LineStyle', '--');
end

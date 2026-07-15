function h = draw3DScene(cfg, bld)
h.fig = figure('Color', 'w', 'Name', 'Roadside LiDAR -- 3D View');
h.ax = axes(h.fig);
hold(h.ax, 'on'); axis(h.ax, 'equal'); view(h.ax, 45, 30);
xlim(h.ax, [-5 55]); ylim(h.ax, [-5 45]); zlim(h.ax, [0 12]);
xlabel(h.ax, 'X (m)'); ylabel(h.ax, 'Y (m)'); zlabel(h.ax, 'Z (m)');
grid(h.ax, 'on');
camlight(h.ax); lighting(h.ax, 'gouraud');

% Ground strip along the first road segment (visual only)
patch(h.ax, [0 50 50 0], ...
    [-cfg.road.width/2 -cfg.road.width/2 cfg.road.width/2 cfg.road.width/2], ...
    [0 0 0 0], [0.3 0.3 0.3], 'EdgeColor', 'none');

% Building cuboid
drawCuboid(h.ax, bld.x, bld.y, [0 bld.height], [0.6 0.6 0.6]);

% LiDAR pole + head
p = cfg.lidar.position;
plot3(h.ax, [p(1) p(1)], [p(2) p(2)], [0 p(3)], 'k-', 'LineWidth', 2);
plot3(h.ax, p(1), p(2), p(3), '^', 'MarkerSize', 10, 'MarkerFaceColor', [0 0.6 0.2]);

% Warning sign
sp = cfg.sign.position;
h.sign = plot3(h.ax, sp(1), sp(2), sp(3), 's', 'MarkerSize', 16, ...
    'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

% Pedestrian marker
startPos = cfg.pedestrian.waypoints(1,:);
h.ped = plot3(h.ax, startPos(1), startPos(2), 0.9, 'o', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0 0.4 0.8], 'MarkerEdgeColor', 'k');

% Live LiDAR point cloud
h.pc = scatter3(h.ax, nan, nan, nan, 6, [1 0 0], 'filled');

end

function drawCuboid(ax, xr, yr, zr, faceColor)
[X, Y, Z] = ndgrid(xr, yr, zr);
V = [X(:) Y(:) Z(:)];
F = [1 2 4 3; 5 6 8 7; 1 2 6 5; 3 4 8 7; 1 3 7 5; 2 4 8 6];
patch(ax, 'Vertices', V, 'Faces', F, 'FaceColor', faceColor, ...
    'FaceAlpha', 0.85, 'EdgeColor', 'k');
end

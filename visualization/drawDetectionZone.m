function drawDetectionZone(ax, cfg)
%DRAWDETECTIONZONE Draw the ROI as a semi-transparent rectangle.

x0 = cfg.detectionZone.x(1); w = diff(cfg.detectionZone.x);
y0 = cfg.detectionZone.y(1); h = diff(cfg.detectionZone.y);

rectangle(ax, 'Position', [x0 y0 w h], ...
    'FaceColor', [1 0 0 0.08], 'EdgeColor', [1 0 0], ...
    'LineStyle', '--', 'LineWidth', 1);

end

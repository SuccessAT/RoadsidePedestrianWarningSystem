function drawRoad(ax, cfg)
%DRAWROAD Draw the road as a thick centerline (placeholder for full polygon).

c = cfg.road.centers;
plot(ax, c(:,1), c(:,2), 'Color', [0.25 0.25 0.25], 'LineWidth', cfg.road.width * 3);

end

function drawLaneMarkings(ax, cfg)
%DRAWLANEMARKINGS Yellow dashed centerline (placeholder for lane edges).

c = cfg.road.centers;
plot(ax, c(:,1), c(:,2), 'y--', 'LineWidth', 1.2);

end

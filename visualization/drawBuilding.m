function drawBuilding(ax, bld)
%DRAWBUILDING Draw the building footprint as a filled rectangle.

w = bld.x(2) - bld.x(1);
h = bld.y(2) - bld.y(1);

rectangle(ax, 'Position', [bld.x(1), bld.y(1), w, h], ...
    'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'k', 'LineWidth', 1.2);

end

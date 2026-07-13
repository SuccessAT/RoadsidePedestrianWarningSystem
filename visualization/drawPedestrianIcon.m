function hg = drawPedestrianIcon(ax, pos)
%DRAWPEDESTRIANICON Draw a simple head+body pedestrian glyph.
% Returns an hgtransform handle; move the pedestrian each frame with:
%   set(hg, 'Matrix', makehgtform('translate', [x y 0]));
% instead of redrawing the patches, which is much cheaper per frame.

hg = hgtransform('Parent', ax);

% Head (small circle), local coordinates centered on the feet at [0 0]
theta = linspace(0, 2*pi, 20);
headR = 0.25;
headX = headR * cos(theta);
headY = headR * sin(theta) + 0.55;
patch('Parent', hg, 'XData', headX, 'YData', headY, ...
    'FaceColor', [1 0.85 0.7], 'EdgeColor', 'k', 'LineWidth', 0.5);

% Body (rounded-looking rectangle)
bodyX = [-0.18  0.18  0.18 -0.18];
bodyY = [ 0     0     0.5   0.5];
patch('Parent', hg, 'XData', bodyX, 'YData', bodyY, ...
    'FaceColor', [0 0.4 0.8], 'EdgeColor', 'k', 'LineWidth', 0.5);

set(hg, 'Matrix', makehgtform('translate', [pos(1) pos(2) 0]));

end

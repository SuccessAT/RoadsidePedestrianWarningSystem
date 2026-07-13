function h = drawWarningSign(ax, cfg)
%DRAWWARNINGSIGN Draw the warning sign marker, initially OFF (grey).

p = cfg.sign.position;

h = plot(ax, p(1), p(2), 's', 'MarkerSize', 14, ...
    'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
text(ax, p(1) + 0.5, p(2), 'WARNING SIGN');

end

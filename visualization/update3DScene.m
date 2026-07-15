function update3DScene(h, pedPos, ptCloudWorld, warningOn)
set(h.ped, 'XData', pedPos(1), 'YData', pedPos(2), 'ZData', 0.9);

if ptCloudWorld.Count > 0
    xyz = ptCloudWorld.Location;
    set(h.pc, 'XData', xyz(:,1), 'YData', xyz(:,2), 'ZData', xyz(:,3));
else
    set(h.pc, 'XData', nan, 'YData', nan, 'ZData', nan);
end

if warningOn
    set(h.sign, 'MarkerFaceColor', [1 0 0]);
else
    set(h.sign, 'MarkerFaceColor', [0.7 0.7 0.7]);
end
end

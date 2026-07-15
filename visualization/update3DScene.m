function update3DScene(h, ptCloudWorld, warningOn)
%UPDATE3DSCENE Per-frame update of the overlay elements only.
% Pedestrian/vehicle meshes update themselves via the native scenario
% plot as their Position/Yaw change -- no manual redraw needed here.

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

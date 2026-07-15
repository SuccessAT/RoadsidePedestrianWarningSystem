function ptCloudOut = cropToFOV(ptCloud, cfg)
xyz = ptCloud.Location;
if isempty(xyz)
    ptCloudOut = ptCloud;
    return;
end

az  = atan2d(xyz(:,2), xyz(:,1));   % sensor-frame azimuth, 0 = heading direction
rng = hypot(xyz(:,1), xyz(:,2));

keep = abs(az) <= cfg.lidar.fov/2 & rng <= cfg.lidar.range;
ptCloudOut = select(ptCloud, keep);
end

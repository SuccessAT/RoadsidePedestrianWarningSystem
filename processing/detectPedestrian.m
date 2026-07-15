function detected = detectPedestrian(ptCloudWorld, cfg)
detected = false;
if ptCloudWorld.Count == 0
    return;
end

xyz = ptCloudWorld.Location;
inZone = xyz(:,1) >= cfg.detectionZone.x(1) & xyz(:,1) <= cfg.detectionZone.x(2) & ...
         xyz(:,2) >= cfg.detectionZone.y(1) & xyz(:,2) <= cfg.detectionZone.y(2) & ...
         xyz(:,3) >= cfg.detectionZone.z(1) & xyz(:,3) <= cfg.detectionZone.z(2);

zonePts = xyz(inZone, :);
if size(zonePts,1) < 5
    return;
end

ptCloudZone = pointCloud(zonePts);
[labels, numClusters] = pcsegdist(ptCloudZone, 0.5);

for k = 1:numClusters
    if nnz(labels == k) >= 5
        detected = true;
        return;
    end
end
end

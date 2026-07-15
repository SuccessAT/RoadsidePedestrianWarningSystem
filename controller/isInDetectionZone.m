function inside = isInDetectionZone(pos, cfg)
%ISINDETECTIONZONE True if pos = [x y z] lies inside the ROI box in cfg.
% This milestone uses ground-truth position. Later this will be replaced
% by a LiDAR-based detector operating on the same ROI box.

x = pos(1); y = pos(2); z = pos(3);

inside = x >= cfg.detectionZone.x(1) && x <= cfg.detectionZone.x(2) && ...
         y >= cfg.detectionZone.y(1) && y <= cfg.detectionZone.y(2) && ...
         z >= cfg.detectionZone.z(1) && z <= cfg.detectionZone.z(2);

end

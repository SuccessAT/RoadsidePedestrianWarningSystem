function bld = createBuilding(cfg)
%CREATEBUILDING Compute the building's axis-aligned bounding box from cfg.
% cfg.building.position is the CENTROID [x y].

cx = cfg.building.position(1);
cy = cfg.building.position(2);
L  = cfg.building.length;   % x-extent
W  = cfg.building.width;    % y-extent

bld.x      = [cx - L/2, cx + L/2];
bld.y      = [cy - W/2, cy + W/2];
bld.height = cfg.building.height;

end

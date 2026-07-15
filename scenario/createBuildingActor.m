function bldActor = createBuildingActor(scenario, cfg)
bld = createBuilding(cfg);
cx = mean(bld.x); cy = mean(bld.y);
L  = diff(bld.x);  W = diff(bld.y);

bldActor = actor(scenario, 'ClassID', 1, ...
    'Position', [cx cy 0], ...
    'Length', L, 'Width', W, 'Height', bld.height, ...
    'Name', 'Building');
end

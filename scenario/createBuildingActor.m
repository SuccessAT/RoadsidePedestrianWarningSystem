function bldActor = createBuildingActor(scenario, cfg)
%CREATEBUILDINGACTOR Building as a real actor with a custom mesh.
% NOTE: this is a constructed proxy mesh (box + rooftop unit), not an
% imported real-world building. Automated Driving Toolbox scripting has
% no OSM/GIS building import -- that exists only in RoadRunner Scene
% Builder, outside this MATLAB workflow.

bld = createBuilding(cfg);
cx = mean(bld.x); cy = mean(bld.y);
L  = diff(bld.x);  W = diff(bld.y);  H = bld.height;

mainBody = extendedObjectMesh('cuboid');
mainBody = scaleToFit(mainBody, struct( ...
    'Length', L, 'Width', W, 'Height', H, ...
    'OriginOffset', [0 0 -H/2]));   % shift so base sits at actor ground level

roofUnit = extendedObjectMesh('cuboid');
roofUnit = scaleToFit(roofUnit, struct( ...
    'Length', L*0.4, 'Width', W*0.4, 'Height', H*0.15, ...
    'OriginOffset', [0 0 -H*0.15/2]));
roofUnit = translate(roofUnit, [0 0 H]);   % sits on the roof

buildingMesh = join(mainBody, roofUnit);

bldActor = actor(scenario, 'ClassID', 5, ...
    'Position', [cx cy 0], ...
    'Length', L, 'Width', W, 'Height', H, ...
    'Mesh', buildingMesh, ...
    'Name', 'Building');
end

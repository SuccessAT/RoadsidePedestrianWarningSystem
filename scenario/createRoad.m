function scenario = createRoad(cfg)
%CREATEROAD Build the L-shaped drivingScenario road from cfg.

scenario = drivingScenario( ...
    'SampleTime', cfg.simulation.sampleTime, ...
    'StopTime',   cfg.simulation.stopTime);

road(scenario, cfg.road.centers, cfg.road.width);

end

function ptCloud = simulateLidarFrame(lidarSensor, egoVehicle, time)
tgts   = targetPoses(egoVehicle);
rdmesh = roadMesh(egoVehicle);

[ptCloudOut, isValidTime] = lidarSensor(tgts, rdmesh, time);
if isValidTime
    ptCloud = ptCloudOut;
else
    ptCloud = pointCloud(zeros(0,3));
end
end

function ptCloudWorld = toWorldFrame(ptCloudSensorFrame, egoVehicle)
xyzSensor = ptCloudSensorFrame.Location;
if isempty(xyzSensor)
    ptCloudWorld = pointCloud(zeros(0,3));
    return;
end

yawRad = deg2rad(egoVehicle.Yaw);
R = [cos(yawRad) -sin(yawRad) 0; sin(yawRad) cos(yawRad) 0; 0 0 1];
xyzWorld = (R * xyzSensor')' + egoVehicle.Position;

ptCloudWorld = pointCloud(xyzWorld);
end

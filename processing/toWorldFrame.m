function ptCloudWorld = toWorldFrame(ptCloudSensorFrame, egoVehicle)
xyzSensor = ptCloudSensorFrame.Location;
if isempty(xyzSensor)
    ptCloudWorld = pointCloud(zeros(0,3));
    return;
end

yawRad   = deg2rad(egoVehicle.Yaw);
pitchRad = deg2rad(egoVehicle.Pitch);

Rz = [cos(yawRad) -sin(yawRad) 0; sin(yawRad) cos(yawRad) 0; 0 0 1];
Ry = [cos(pitchRad) 0 sin(pitchRad); 0 1 0; -sin(pitchRad) 0 cos(pitchRad)];

xyzWorld = (Rz * Ry * xyzSensor')' + egoVehicle.Position;

ptCloudWorld = pointCloud(xyzWorld);
end

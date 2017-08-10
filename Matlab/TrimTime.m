function aedat = TrimTime(aedat, startTime, endTime, reZero)

%{
default is not to rezero
Times come in as seconds
%}

dbstop if error

startTime = uint64(startTime * 1e6);
endTime = uint64(endTime * 1e6);

if ~isfield(aedat, 'data')
    disp('No data found')
    return
end

%% Special

if isfield(aedat.data, 'special')
    keepLogical = aedat.data.special.timeStamp >= startTime & aedat.data.special.timeStamp <= endTime;
    aedat.data.special.timeStamp = aedat.data.special.timeStamp(keepLogical);
    aedat.data.special.address   = aedat.data.special.address  (keepLogical);
end

%% Polarity

if isfield(aedat.data, 'polarity')
    keepLogical = aedat.data.polarity.timeStamp >= startTime & aedat.data.polarity.timeStamp <= endTime;
    aedat.data.polarity.timeStamp = aedat.data.polarity.timeStamp (keepLogical);
    aedat.data.polarity.x           = aedat.data.polarity.x       (keepLogical);
    aedat.data.polarity.y           = aedat.data.polarity.y       (keepLogical);
    aedat.data.polarity.polarity    = aedat.data.polarity.polarity(keepLogical);
end

%% Frames

if isfield(aedat.data, 'frame')
    keepLogical = aedat.data.frame.timeStampStart >= startTime & aedat.data.frame.timeStampStart <= endTime;
    aedat.data.frame.timeStampStart = aedat.data.frame.timeStampStart(keepLogical);
    aedat.data.frame.timeStampEnd   = aedat.data.frame.timeStampEnd  (keepLogical);
    aedat.data.frame.samples        = aedat.data.frame.samples       (keepLogical);
    aedat.data.frame.xLength        = aedat.data.frame.xLength       (keepLogical);
    aedat.data.frame.yLength        = aedat.data.frame.yLength       (keepLogical);
    aedat.data.frame.xPosition      = aedat.data.frame.xPosition     (keepLogical);
    aedat.data.frame.yPosition      = aedat.data.frame.yPosition     (keepLogical);
end

%% IMU6, SAMPLE, EAR TODO

%% Point1D

if isfield(aedat.data, 'point1D')
    keepLogical = aedat.data.point1D.timeStamp >= startTime ...
                & aedat.data.point1D.timeStamp <= endTime;
    aedat.data.point1D.timeStamp = aedat.data.point1D.timeStamp(keepLogical);
    aedat.data.point1D.type      = aedat.data.point1D.type     (keepLogical);
    aedat.data.point1D.x         = aedat.data.point1D.x        (keepLogical);
end

%% Point2D

if isfield(aedat.data, 'point2D')
    keepLogical = aedat.data.point2D.timeStamp >= startTime ...
                & aedat.data.point2D.timeStamp <= endTime;
    aedat.data.point2D.timeStamp = aedat.data.point2D.timeStamp(keepLogical);
    aedat.data.point2D.type      = aedat.data.point2D.type     (keepLogical);
    aedat.data.point2D.x         = aedat.data.point2D.x        (keepLogical);
    aedat.data.point2D.y         = aedat.data.point2D.y        (keepLogical);
end

%% Point3D

if isfield(aedat.data, 'point3D')
    keepLogical = aedat.data.point3D.timeStamp >= startTime ...
                & aedat.data.point3D.timeStamp <= endTime;
    aedat.data.point3D.timeStamp = aedat.data.point3D.timeStamp(keepLogical);
    aedat.data.point3D.type      = aedat.data.point3D.type     (keepLogical);
    aedat.data.point3D.x         = aedat.data.point3D.x        (keepLogical);
    aedat.data.point3D.y         = aedat.data.point3D.y        (keepLogical);
    aedat.data.point3D.z         = aedat.data.point3D.z        (keepLogical);
end


%% Rezero

if exist('reZero', 'var') && reZero
    aedat = ZeroTime(aedat);
end

%% Tidy up

aedat = NumEventsByType(aedat);
aedat = FindFirstAndLastTimeStamps(aedat);

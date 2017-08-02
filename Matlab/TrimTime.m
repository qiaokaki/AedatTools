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

%% Point3D

if isfield(aedat.data, 'point3D')
    keepLogical = aedat.data.point3D.timeStamp >= startTime ...
                & aedat.data.point3D.timeStamp <= endTime;
    aedat.data.point3D.timeStamp = aedat.data.point3D.timeStamp(keepLogical);
    aedat.data.point3D.value1    = aedat.data.point3D.value1   (keepLogical);
    aedat.data.point3D.value2    = aedat.data.point3D.value2   (keepLogical);
    aedat.data.point3D.value3    = aedat.data.point3D.value3   (keepLogical);
end

% To do: handle other event types

%% Rezero

if exist('reZero', 'var') && reZero
    aedat = ZeroTime(aedat);
end

%% Tidy up

aedat = NumEventsByType(aedat);
aedat = FindFirstAndLastTimeStamps(aedat);

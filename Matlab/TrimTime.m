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

%% Imu6

if isfield(aedat.data, 'imu6')
    keepLogical = aedat.data.imu6.timeStamp >= startTime & aedat.data.imu6.timeStamp <= endTime;
        aedat.data.imu6.timeStamp = aedat.data.imu6.timeStamp (keepLogical);
    aedat.data.imu6.accelX       = aedat.data.imu6.accelX (keepLogical);
    aedat.data.imu6.accelY       = aedat.data.imu6.accelY (keepLogical);
    aedat.data.imu6.accelZ       = aedat.data.imu6.accelZ (keepLogical);
    aedat.data.imu6.gyroX        = aedat.data.imu6.gyroX (keepLogical);
    aedat.data.imu6.gyroY        = aedat.data.imu6.gyroY (keepLogical);
    aedat.data.imu6.gyroZ        = aedat.data.imu6.gyroZ (keepLogical);
    aedat.data.imu6.temperature  = aedat.data.imu6.temperature (keepLogical);
end

% To do: handle other event types

%% Rezero

if exist('reZero', 'var') && reZero
    aedat = ZeroTime(aedat);
end

%% Tidy up

aedat = NumEventsByType(aedat);
aedat = FindFirstAndLastTimeStamps(aedat);

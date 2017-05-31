function aedat = TrimTime(aedat, startTime, endTime, reZero)

%{
%}

dbstop if error

startTime = uint64(startTime * 1e6);
endTime = uint64(endTime * 1e6);

% Special

if ~isfield(aedat, 'data')
    disp('No data found')
    return
end
if isfield(aedat.data, 'special')
    keepLogical = aedat.data.special.timeStamp >= startTime & aedat.data.special.timeStamp <= endTime;
    if exist('reZero', 'var') && reZero
        aedat.data.special.timeStamp = aedat.data.special.timeStamp (keepLogical) - startTime;
    else
        aedat.data.special.timeStamp = aedat.data.special.timeStamp (keepLogical);
    end
    aedat.data.special.address       = aedat.data.special.address  (keepLogical);
    if isfield(aedat.data.special, 'valid')
        aedat.data.special.valid    = aedat.data.special.valid (keepLogical);
    end
end
% Polarity

if isfield(aedat.data, 'polarity')
    keepLogical = aedat.data.polarity.timeStamp >= startTime & aedat.data.polarity.timeStamp <= endTime;
    if exist('reZero', 'var') && reZero
        aedat.data.polarity.timeStamp = aedat.data.polarity.timeStamp (keepLogical) - startTime;
    else
        aedat.data.polarity.timeStamp = aedat.data.polarity.timeStamp (keepLogical);
    end
    aedat.data.polarity.x           = aedat.data.polarity.x         (keepLogical);
    aedat.data.polarity.y           = aedat.data.polarity.y         (keepLogical);
    aedat.data.polarity.polarity    = aedat.data.polarity.polarity  (keepLogical);
    aedat.data.polarity.numEvents   = nnz(keepLogical);
    if isfield(aedat.data.polarity, 'valid')
        aedat.data.polarity.valid    = aedat.data.polarity.valid (keepLogical);
    end
end

% Frames

% This assumes that timestamps have been simplified to aedat2 standard, if
% they came from aedat3 file
if isfield(aedat.data, 'frame')
    keepLogical = aedat.data.frame.timeStampStart >= startTime & aedat.data.frame.timeStampStart <= endTime;
    if exist('reZero', 'var') && reZero
        aedat.data.frame.timeStampStart = aedat.data.frame.timeStampStart   (keepLogical) - startTime;
        aedat.data.frame.timeStampEnd   = aedat.data.frame.timeStampEnd     (keepLogical) - startTime;
    else
        aedat.data.frame.timeStampStart = aedat.data.frame.timeStampStart   (keepLogical);
        aedat.data.frame.timeStampEnd   = aedat.data.frame.timeStampEnd     (keepLogical);
    end
    aedat.data.frame.samples           = aedat.data.frame.samples         (keepLogical);
    aedat.data.frame.xLength           = aedat.data.frame.xLength         (keepLogical);
    aedat.data.frame.yLength           = aedat.data.frame.yLength         (keepLogical);
    aedat.data.frame.xPosition         = aedat.data.frame.xPosition       (keepLogical);
    aedat.data.frame.yPosition         = aedat.data.frame.yPosition       (keepLogical);
    aedat.data.frame.numEvents         = nnz(keepLogical);
    if isfield(aedat.data.frame, 'valid')
        aedat.data.frame.valid    = aedat.data.frame.valid (keepLogical);
    end
end
% Imu6

if isfield(aedat.data, 'imu6')
    keepLogical = aedat.data.imu6.timeStamp >= startTime & aedat.data.imu6.timeStamp <= endTime;
    if exist('reZero', 'var') && reZero
        aedat.data.imu6.timeStamp = aedat.data.imu6.timeStamp (keepLogical) - startTime;
    else
        aedat.data.imu6.timeStamp = aedat.data.imu6.timeStamp (keepLogical);
    end
    aedat.data.imu6.accelX       = aedat.data.imu6.accelX (keepLogical);
    aedat.data.imu6.accelY       = aedat.data.imu6.accelY (keepLogical);
    aedat.data.imu6.accelZ       = aedat.data.imu6.accelZ (keepLogical);
    aedat.data.imu6.gyroX        = aedat.data.imu6.gyroX (keepLogical);
    aedat.data.imu6.gyroY        = aedat.data.imu6.gyroY (keepLogical);
    aedat.data.imu6.gyroZ        = aedat.data.imu6.gyroZ (keepLogical);
    aedat.data.imu6.temperature  = aedat.data.imu6.temperature (keepLogical);
    aedat.data.imu6.numEvents    = nnz(keepLogical);
    if isfield(aedat.data.imu6, 'valid')
        aedat.data.imu6.valid    = aedat.data.imu6.valid (keepLogical);
    end
end


% To do: handle other event types

% To do - correct first and last timestamp in info, also numPackets, ...
% startTime, endTime, startPacket, endPacket, startEvent, endEvent

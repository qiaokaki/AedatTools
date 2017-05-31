function aedat = RemoveInvalidEvents(aedat)

%{
This function removes any events which are flagged as invalid, and then
removes the 'valid' fields 
%}

% NOT WRITTEN YET - FIRST BLOCK (SPECIAL) IS AN EXAMPLE  ....

dbstop if error

if ~isfield(aedat, 'data')
    return
end
% Special

if isfield(aedat.data, 'special') && isfield(aedat.data.special, 'valid')
    aedat.data.special.timeStamp    = aedat.data.special.timeStamp(aedat.data.special.valid);
    aedat.data.special.address      = aedat.data.special.address (aedat.data.special.valid);
    aedat.data.special = rmfieldaedat.data.special.valid (aedat.data.special.valid);
end

% Polarity

if isfield(aedat.data, 'special') && isfield(aedat.data.special, 'valid')
    aedat.data.polarity.timeStamp   = aedat.data.polarity.timeStamp (keepLogical);
    aedat.data.polarity.x           = aedat.data.polarity.x         (keepLogical);
    aedat.data.polarity.y           = aedat.data.polarity.y         (keepLogical);
    aedat.data.polarity.polarity    = aedat.data.polarity.polarity  (keepLogical);
    aedat.data.polarity.numEvents   = nnz(keepLogical);
end
% Frames

if isfield(aedat.data, 'special') && isfield(aedat.data.special, 'valid')
    aedat.data.frame.timeStampStart    = aedat.data.frame.timeStampStart  (keepLogical);
    aedat.data.frame.timeStampEnd      = aedat.data.frame.timeStampEnd    (keepLogical);
    aedat.data.frame.samples           = aedat.data.frame.samples         (keepLogical);
    aedat.data.frame.xLength           = aedat.data.frame.xLength         (keepLogical);
    aedat.data.frame.yLength           = aedat.data.frame.yLength         (keepLogical);
    aedat.data.frame.xPosition         = aedat.data.frame.xPosition       (keepLogical);
    aedat.data.frame.yPosition         = aedat.data.frame.yPosition       (keepLogical);
    aedat.data.frame.numEvents         = nnz(keepLogical);
end
% Imu6

if isfield(aedat.data, 'special') && isfield(aedat.data.special, 'valid')
    aedat.data.imu6.timeStamp    = aedat.data.imu6.timeStamp (keepLogical);
    aedat.data.imu6.accelX       = aedat.data.imu6.accelX (keepLogical);
    aedat.data.imu6.accelY       = aedat.data.imu6.accelY (keepLogical);
    aedat.data.imu6.accelZ       = aedat.data.imu6.accelZ (keepLogical);
    aedat.data.imu6.gyroX        = aedat.data.imu6.gyroX (keepLogical);
    aedat.data.imu6.gyroY        = aedat.data.imu6.gyroY (keepLogical);
    aedat.data.imu6.gyroZ        = aedat.data.imu6.gyroZ (keepLogical);
    aedat.data.imu6.temperature  = aedat.data.imu6.temperature (keepLogical);
    aedat.data.imu6.numEvents    = nnz(keepLogical);
end
% To do: handle other event types

% To do - correct first and last timestamp in info, also numPackets, ...
% startTime, endTime, startPacket, endPacket, startEvent, endEvent

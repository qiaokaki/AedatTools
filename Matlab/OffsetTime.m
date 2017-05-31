function aedat = OffsetTime(aedat, offset)

%{
%}

dbstop if error


if ~isfield(aedat, 'data')
    disp('No data found')
    return
end

% Assume offset param is given in secs (AedatTools standard)
offset = int64(offset * 1e6);
% Special
if isfield(aedat.data, 'special')
    aedat.data.special.timeStamp = uint64(int64(aedat.data.special.timeStamp) + offset);
end
% Polarity
if isfield(aedat.data, 'polarity')
    aedat.data.polarity.timeStamp = uint64(int64(aedat.data.polarity.timeStamp) + offset);
end

% Frames
% This assumes that timestamps have been simplified to aedat2 standard, if
% they came from aedat3 file
if isfield(aedat.data, 'frame')
    aedat.data.frame.timeStampStart = uint64(int64(aedat.data.frame.timeStampStart)   + offset);
    aedat.data.frame.timeStampEnd   = uint64(int64(aedat.data.frame.timeStampEnd)     + offset);
end
% Imu6

if isfield(aedat.data, 'imu6')
    aedat.data.imu6.timeStamp = uint64(int64(aedat.data.imu6.timeStamp) + offset);
end


% To do: handle other event types

% To do - correct first and last timestamp in info, also numPackets, ...
% startTime, endTime, startPacket, endPacket, startEvent, endEvent

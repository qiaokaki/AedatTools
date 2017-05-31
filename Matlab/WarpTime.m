function aedat = WarpTime(aedat, factor)

%{
Actually it just stretches or squeezes time by multiplying all timestamps
by a factor. Is there a collective term for stretching and squeezing? let
me know...
It doesn't affect any of the info in aedat.info - packetTimeStamps are not
affected. 
%}

dbstop if error

if ~isfield(aedat, 'data')
    disp('No data found')
    return
end

% Special
if isfield(aedat.data, 'special')
	aedat.data.special.timeStamp = uint64(double(aedat.data.special.timeStamp * factor));
end

% Polarity
if isfield(aedat.data, 'polarity')
	aedat.data.polarity.timeStamp = uint64(double(aedat.data.polarity.timeStamp * factor));
end

% Frames
% This assumes that timestamps have been simplified to aedat2 standard, if
% they came from aedat3 file
if isfield(aedat.data, 'frame')
	aedat.data.frame.timeStampStart = uint64(double(aedat.data.frame.timeStampStart * factor));
	aedat.data.frame.timeStampEnd = uint64(double(aedat.data.frame.timeStampEnd * factor));
end

% Imu6
if isfield(aedat.data, 'imu6')
	aedat.data.imu6.timeStamp = uint64(double(aedat.data.imu6.timeStamp * factor));
end

% To do: handle other event types

% To do - correct first and last timestamp in info, also numPackets, ...
% startTime, endTime, startPacket, endPacket, startEvent, endEvent
% OR maybe not ...

function aedat = ZeroTime(aedat)

%{
shifts all timestamps so that the first timestamp is zero
This affects both data.<dataType>.timeStamp and info.packetTimeStamps;
info.first/lastTimeStamp are also updated
%}

dbstop if error

aedat = FindFirstAndLastTimeStamps(aedat);

if isfield(aedat.info, 'firstTimeStamp')
    lowestTimeStamp = aedat.info.firstTimeStamp;
else % Allow the comparison with the packettimestamp timestamps to take place. 
    lowestTimeStamp = uint64(inf);    
end

if isfield(aedat.info, 'packetTimeStamps') ...
        && min(aedat.info.packetTimeStamps) < lowestTimeStamp
    lowestTimeStamp = min(aedat.info.packetTimeStamps);
end

% Now we have the lowest timestamp, whether it came from data or from packet timestamps

if isfield(aedat.info, 'packetTimeStamps') ...
    aedat.info.packetTimeStamps = aedat.info.packetTimeStamps - lowestTimeStamp;
end
    
    
if isfield(aedat, 'data')

    % Special
    if isfield(aedat.data, 'special')
        aedat.data.special.timeStamp = aedat.data.special.timeStamp - lowestTimeStamp;
    end

    % Polarity
    if isfield(aedat.data, 'polarity')
        aedat.data.polarity.timeStamp = aedat.data.polarity.timeStamp - lowestTimeStamp;
    end

    % Frames
    % This assumes that timestamps have been simplified to aedat2 standard, if
    % they came from aedat3 file
    if isfield(aedat.data, 'frame')
        aedat.data.frame.timeStampStart = aedat.data.frame.timeStampStart - lowestTimeStamp;
        aedat.data.frame.timeStampEnd = aedat.data.frame.timeStampEnd - lowestTimeStamp;
    end

    % Imu6
    if isfield(aedat.data, 'imu6')
        aedat.data.imu6.timeStamp = aedat.data.imu6.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'sample')
        aedat.data.sample.timeStamp = aedat.data.sample.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'ear')
        aedat.data.ear.timeStamp = aedat.data.ear.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'point1D')
        aedat.data.point1D.timeStamp = aedat.data.point1D.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'point2D')
        aedat.data.point2D.timeStamp = aedat.data.point2D.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'point3D')
        aedat.data.point3D.timeStamp = aedat.data.point3D.timeStamp - lowestTimeStamp;
    end

    if isfield(aedat.data, 'point4D')
        aedat.data.point4D.timeStamp = aedat.data.point4D.timeStamp - lowestTimeStamp;
    end

    aedat = FindFirstAndLastTimeStamps(aedat);
end
function [startPacket, endPacket] = FindPacketsByTimeAfterTimeStampReset(aedat, startTime, endTime)

%{
If timestamp reset events occur, timestamps become non-monotonic.
For an aedat3 import where the packet indices have already been created, 
Search for the packet range which corresponds to a chosen time range,
excluding any packets before the last timestamp reset.

%}

dbstop if error

if ~isfield(aedat, 'info')
    disp('No data found.')
    return
end
if ~isfield(aedat.info, 'packetTimeStamps')
    disp('No packet indices found.')
    return
end
ts = int64(aedat.info.packetTimeStamps);
lastTsReset = find(ts(2 : end) - ts(1 : end - 1) < 0, 1, 'last');
if ~isempty(lastTsReset)
    disp('Timestamp reset found')
    firstPacket = lastTsReset + 1;
else
    disp('Timestamp reset not found')
    firstPacket = 1;
end
startPacket = find(ts(firstPacket : end) >= startTime * 1e6, 1, 'first');
if isempty(startPacket)
    disp('No packets found in time range (after any timestamp resets)')
    startPacket = 0;
    endPacket = 0;
    return
end
startPacket = startPacket + firstPacket - 1;
endPacket = find(ts <= endTime * 1e6, 1, 'last');

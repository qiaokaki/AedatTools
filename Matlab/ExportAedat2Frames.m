function ExportAedat2Frames(aedat)

%{
This function exports data to a .aedat file. 
The .aedat file format is documented here:

http://inilabs.com/support/software/fileformat/
%}

dbstop if error

if ~exist('aedat', 'var')
	error('Missing input')
end

% Create the file
if ~isfield(aedat.exportParams, 'filePath')
    error('Missing file path and name')
end

f = fopen(aedat.exportParams.filePath, 'w', 'b');

% Simple - events only - assume DAVIS

% CRLF \r\n is needed to not break header parsing in jAER
fprintf(f,'#!AER-DAT2.0\r\n');
fprintf(f,'# This is a raw AE data file created by an export function in the AedatTools library\r\n');
fprintf(f,'# Data format is int32 address, int32 timestamp (8 bytes total), repeated for each event\r\n');
fprintf(f,'# Timestamps tick is 1 us\r\n');
% Put the source in - use an override if it has been given
if isfield(aedat.exportParams, 'source')
    fprintf(f,['# AEChip: ' aedat.exportParams.source '\r\n']);
else 
    fprintf(f,['# AEChip: ' aedat.info.source '\r\n']);
end
fprintf(f,'# End of ASCII Header\r\n');

% DAVIS
% In the 32-bit address:
% bit 32 (1-based) being 1 indicates an APS sample
% bit 11 (1-based) being 1 indicates a special event 
% bits 11 and 32 (1-based) both being zero signals a polarity event

yShiftBits = 22;
xShiftBits = 12;
% frameShiftBits = 0;
frameFlagShiftBits = 31;

frameData = aedat.data.frame;

numFrames = frameData.numEvents;
deviceAddressSpace = ImportAedatDeviceAddressSpace(aedat.info.source);
xDim = deviceAddressSpace(1);
yDim = deviceAddressSpace(2);
numPixels = xDim * yDim;

% Allocate horizontal vectors to hold output data.
% Why are the vectors that big? The factor of 2 is because 
% we insert dummy 'reset' frames prior to each frame. 
samples = uint32(zeros(1, 2 * numFrames * numPixels)); 
timeStamps = uint32(zeros(1, 2 * numFrames * numPixels)); 

% The output vector is twice as big again because samples and timeStamps 
% will be interspersed in the 'output' vector.
output = uint32(zeros(1, 2 * 2 * numFrames * numPixels)); 
y = repmat(uint32(0 : yDim - 1), 1, xDim * numFrames * 2);
x = repmat(uint32(0 : xDim - 1), yDim, numFrames * 2);
x = x(:);
x = x';
for frameIndex = 1 : numFrames
    samples((frameIndex * 2 - 1) * numPixels + 1 : frameIndex * 2 * numPixels) ...
        = frameData.samples{frameIndex}(:) ; 
    timeStamps((frameIndex - 1) * 2 * numPixels + 1 : frameIndex * 2 * numPixels) ...
        = frameData.timeStampStart(frameIndex); 
end
frameFlag = uint32(ones(1, numFrames * 2 * numPixels) * 2 ^ frameFlagShiftBits);
y = y * uint32(2 ^ yShiftBits);
x = x * uint32(2 ^ xShiftBits);
% samples should now be in the range 0-1023 (10-bit). 
% subtract samples from 1023. This has the effect of leaving all the reset
% frame samples at 1023 - the highest value, gainst which the signal frames
% will later be subtracted. 
samples = 1023 - samples;

output(1:2:end) = frameFlag + y + x + samples;
output(2:2:end) = timeStamps; % set even elements to timestamps

% write addresses and timestamps
count=fwrite(f, output, 'uint32', 0, 'b')/2; % write 4 byte data
fclose(f);
fprintf('wrote %d events to %s\n', count, aedat.exportParams.filePath);



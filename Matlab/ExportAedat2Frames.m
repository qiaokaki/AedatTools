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
output = uint32(zeros(1, 2 * numFrames * numPixels)); % allocate horizontal vector to hold output data
samples = uint32(zeros(1, numFrames * numPixels)); % allocate horizontal vector to hold output data
timeStamps = uint32(zeros(1, numFrames * numPixels)); % allocate horizontal vector to hold output data
y = repmat(uint32(0 : yDim - 1), 1, xDim * numFrames);
x = repmat(uint32(0 : xDim - 1), yDim, numFrames);
x = x(:);
x = x';
for frameIndex = 1 : numFrames
    samples((frameIndex - 1) * numPixels + 1 : frameIndex * numPixels) ...
        = frameData.samples{frameIndex}(:) ; 
    timeStamps((frameIndex - 1) * numPixels + 1 : frameIndex * numPixels) ...
        = frameData.timeStampExposureStart(frameIndex); % This gives zeros delay from exposure start to read out - unrealistic
end
frameFlag = uint32(ones(1, numFrames * numPixels) * 2 ^ frameFlagShiftBits);
y = y * uint32(2 ^ yShiftBits);
x = x * uint32(2 ^ xShiftBits);
output(1:2:end) = frameFlag + y + x + samples;
output(2:2:end) = timeStamps; % set even elements to timestamps

% write addresses and timestamps
count=fwrite(f, output, 'uint32', 0, 'b')/2; % write 4 byte data
fclose(f);
fprintf('wrote %d events to %s\n', count, aedat.exportParams.filePath);



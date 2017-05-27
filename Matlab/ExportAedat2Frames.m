function ExportAedat2Frames(input)

%{
This function exports data to a .aedat file. 
The .aedat file format is documented here:

http://inilabs.com/support/software/fileformat/
%}

dbstop if error

if ~exist('input', 'var')
	error('Missing input')
end

% Create the file
if ~isfield(input.info, 'filePath')
    error('Missing file path and name')
end

f = fopen(input.info.filePath, 'w', 'b');

% Simple - events only - assume DAVIS

% CRLF \r\n is needed to not break header parsing in jAER
fprintf(f,'#!AER-DAT2.0\r\n');
fprintf(f,'# This is a raw AE data file created by saveaerdat.m\r\n');
fprintf(f,'# Data format is int32 address, int32 timestamp (8 bytes total), repeated for each event\r\n');
fprintf(f,'# Timestamps tick is 1 us\r\n');

% Put the source in NEEDS DOING PROPERLY
fprintf(f,'# AEChip: DAVIS240C\r\n');

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

numFrames = input.data.frame.numEvents;
yDim = 180;
xDim = 240;
numPixels = xDim * yDim;
% HARDCODED CONSTANTS!
output = uint32(zeros(1, 2 * numFrames * numPixels)); % allocate horizontal vector to hold output data
samples = uint32(zeros(1, numFrames * numPixels)); % allocate horizontal vector to hold output data
timeStamps = uint32(zeros(1, numFrames * numPixels)); % allocate horizontal vector to hold output data
y = repmat(uint32(0 : yDim - 1), 1, xDim * numFrames);
x = repmat(uint32(0 : xDim - 1), yDim, numFrames);
x = x(:);
x = x';
for frameIndex = 1 : numFrames
    samples((frameIndex - 1) * numPixels + 1 : frameIndex * numPixels) ...
        = input.data.frame.samples{frameIndex}(:) ; 
    timeStamps((frameIndex - 1) * numPixels + 1 : frameIndex * numPixels) ...
        = input.data.frame.timeStampExposureStart(frameIndex); % This gives zeros delay from exposure start to read out - unrealistic
end
frameFlag = uint32(ones(1, numFrames * numPixels) * 2 ^ frameFlagShiftBits);
y = y * uint32(2 ^ yShiftBits);
x = x * uint32(2 ^ xShiftBits);
output(1:2:end) = frameFlag + y + x + samples;
output(2:2:end) = timeStamps; % set even elements to timestamps

% write addresses and timestamps
count=fwrite(f,output,'uint32', 0, 'b')/2; % write 4 byte data
fclose(f);
fprintf('wrote %d events to %s\n',count,input.info.filePath);



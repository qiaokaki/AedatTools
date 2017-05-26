function ExportAedat2Imu6(input)

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
startDataPointer = ftell(f);

% DAVIS

% Write timestamps
fseek(f, startDataPointer + 4, 'bof');
fwrite(f, int32(input.data.imu6.timeStamp(:)), 'uint32', 4, 'b'); % write 4 byte data

fseek(f, startDataPointer, 'bof');
fwrite(f, double(input.data.imu6.accelX), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 8, 'bof');
fwrite(f, double(input.data.imu6.accelY), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 16, 'bof');
fwrite(f, double(input.data.imu6.accelZ), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 24, 'bof');
fwrite(f, double(input.data.imu6.gyroX), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 32, 'bof');
fwrite(f, double(input.data.imu6.gyroY), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 40, 'bof');
fwrite(f, double(input.data.imu6.gyroZ), 'double', 8 * 7 - 4, 'b');

fseek(f, startDataPointer + 48, 'bof');
fwrite(f, double(input.data.imu6.temperature), 'double', 8 * 7 - 4, 'b');

fclose(f);
%fprintf('wrote %d events to %s\n',count,input.info.filePath);



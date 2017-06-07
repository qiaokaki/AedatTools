% Example script for how to invoke the importAedat function

clearvars
dbstop if error

% make sure Matlab can see the AedatTools library
addpath('C:\AedatTools\Matlab') 

% Create a structure with which to pass in the input parameters.
aedat = struct;

% Put the filename, including full path, in the 'file' field.

aedat.importParams.filePath = 'C:\project\example3.aedat'; % Windows
aedat.importParams.filePath = '/home/project/example3.aedat'; % Linux

% Alternatively, make sure the file is already on the matlab path.
addpath('C:\project')
aedat.importParams.filePath = 'example3.aedat'; 

% Add any restrictions on what to read out. 
% This example limits readout to the first 1M events (aedat fileFormat 1 or 2 only):
aedat.importParams.endEvent = 1e6;

% This example ignores the first 1M events (aedat fileFormat 1 or 2 only):
aedat.importParams.startEvent = 1e6;

% This example limits readout to a time window between 48.0 and 48.1 s:
aedat.importParams.startTime = 48;
aedat.importParams.endTime = 48.1;

% This example only reads out from packets 1000 to 2000 (aedat3.x only)
aedat.importParams.startPacket = 1000;
aedat.importParams.endPacket = 2000;

% This example samples only every 100th packet (aedat3.x only), in order to quickly assess a large file
aedat.importParams.modPacket = 100;

%These examples limit the read out to certain types of event only
aedat.importParams.dataTypes = {'polarity', 'special'};
aedat.importParams.dataTypes = {'special'};
aedat.importParams.dataTypes = {'frame'};

% With the following flag, you don't get data, but just the header info, 
% plus packet indices info for Aedat3.x
% Thereafter, (aedat3.x only) you can run the import routine again for a
% selected time or packet range and it will use the indices to jump
% straight to the right place in the file. This can be a quicker way of
% exploring large files. There is no such facility for aedat1-2 files. 
aedat.importParams.noData = true;

% Working with a file where the source hasn't been declared - do this explicitly:
input.source = 'Davis240c';

% Invoke the function
output = ImportAedat(input);


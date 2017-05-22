% Example script for how to invoke the importAedat function

clearvars
dbstop if error

% make sure Matlab can see the AedatTools library
addpath('C:\AedatTools\Matlab') 

% Create a structure with which to pass in the input parameters.
input = struct;

% Put the filename, including full path, in the 'file' field.

input.filePath = 'C:\project\example3.aedat'; % Windows
input.filePath = '/home/project/example3.aedat'; % Linux

% Alternatively, make sure the file is already on the matlab path.
addpath('C:\project')
input.filePath = 'example3.aedat'; 

% Add any restrictions on what to read out. 
% This example limits readout to the first 1M events (aedat fileFormat 1 or 2 only):
input.endEvent = 1e6;

% This example ignores the first 1M events (aedat fileFormat 1 or 2 only):
input.startEvent = 1e6;

% This example limits readout to a time window between 48.0 and 48.1 s:
input.startTime = 48;
input.endTime = 48.1;

% This example only reads out from packets 1000 to 2000 (aedat3.x only)
input.startPacket = 1000;
input.endPacket = 2000;

% This example samples only every 100th packet (aedat3.x only), in order to quickly assess a large file
input.modPacket = 100;

%These examples limit the read out to certain types of event only
input.dataTypes = {'polarity', 'special'};
input.dataTypes = {'special'};
input.dataTypes = {'frame'};

% Setting the dataTypes empty tells the function to not import any data;
% You get the header info, plus packet indices info for Aedat3.x

% Exclude non-valid events from the output (aedat3.x only)
input.validOnly = true;

% Working with a file where the source hasn't been declared - do this explicitly:
input.source = 'Davis240b';

% Invoke the function
output = ImportAedat(input);


%{
ImportAedat supports importation of a large file chunk by chunk. One way of
using this is to pick out small parts of a file at a time and work with
them. 

Another type of batch mode is importing from and working with a series of
files. 

This script contains examples of both types of operation
%}

%% Import and plot from selected sections of a file

clearvars
close all
dbstop if error

% Create a structure with which to pass in the input parameters.
aedat = struct;
aedat.importParams.filePath = 'N:\Project\example3.aedat';

packetRanges = [	1		1000; ...
					5000	6000; ...
					10000	11000];

for packetRange = 1 : size(packetRanges, 1)
	aedat.importParams.startPacket	= packetRanges(packetRange, 1);
	aedat.importParams.endPacket		= packetRanges(packetRange, 2);
	aedat = ImportAedat(aedat);
	PlotAedat(aedat)
end

%% Import and plot from a series of files

clearvars
close all
dbstop if error

% Create a structure with which to pass in the input parameters.
aedat = struct;

% This example only reads out the first 1000 packets
aedat.importParams.endPacket = 1000;


filePaths = {	'N:\Project\example1.aedat'; ...
				'N:\Project\example2.aedat'; ...
				'N:\Project\example3.aedat'};

numFiles = length(filePaths);
			
for file = 1 : numFiles
	aedat.importParams.filePath = filePaths{file};
	aedat = ImportAedat(aedat);
	PlotAedat(aedat)
end

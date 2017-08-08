function aedat = ImportSec(aedat)
%{
This function works similarly to ImportAedat, but takes instead data from 
SEC DVS Gen2. These .bin files have no header info, therefore they are not 
compatible with ImportAedat.

Expects the aedat.importParams.filePath parameter to contain a .bin file.
If, however the suffix is not .bin, it assumes that it has been passed a
folder path and takes the most recent file in the folder. 
%}

dbstop if error

importParams = aedat.importParams;

% Open the file
if ~strcmp(importParams.filePath(end -3 : end), '.bin') 
% TO DO
    % Open the newest file
    directoryListing = dir('*.mat');
    [~, dx] = sort([directoryListing.datenum]);
    lf = d(dx==1).name;
	aedat.importParams.filePath = [path fileName];
end

fileHandle = fopen(importParams.filePath, 'r');

if fileHandle == -1
    error('file not found')
end

% Go to the EOF to find out how long it is
fseek(fileHandle, 0, 'eof');

% Find the number of packets. 
numPacketsInFile = ftell(fileHandle) / 4;

% Check the startEvent and endEvent parameters - if present, this shall 
% actually refer to packets.
if isfield(importParams, 'startPacket')
    startPacket = importParams.startPacket;
elseif isfield(importParams, 'startEvent')
    startPacket = importParams.startEvent;
else
    startPacket = 1;
end
if startPacket > numPacketsInFile
	error([	'The file contains ' num2str(numPacketsInFile) ...
			'; the startEvent/startPacket parameter is ' num2str(startPacket)]);
end
if isfield(importParams, 'endPacket')	
    endPacket = importParams.endPacket;
elseif isfield(importParams, 'endEvent')	
    endPacket = importParams.endEvent;
else
    endPacket = numPacketsInFile;
end
	
if endPacket > numPacketsInFile
	disp([	'The file contains ' num2str(numPacketsInFile) ...
			'; the endEvent/endPacket parameter is ' num2str(endPacket) ...
			'; reducing the endPacket parameter accordingly.']);
        endPacket = numPacketsInFile;
end
if startPacket >= endPacket 
	error([	'The startEvent/Packet parameter is ' num2str(startEvent) ...
		', but the endEvent/Packet parameter is ' num2str(endEvent) ]);
end

numPacketsToRead = endPacket - startPacket + 1;

% Read data
disp('Reading data ...')
fseek(fileHandle, 0, 'bof'); 
allPackets = uint32(fread(fileHandle, numPacketsToRead, 'uint32', 0, 'b'));

% Let's just do this iteratively for now; not sure how to matricise this
% Set up data arrays

majorTimeStampMask = bin2dec('0000 0000 0011 1111 1111 1111 1111 1111');
minorTimeStampMask = bin2dec('0000 0000 0000 1111 1111 1100 0000 0000');
columnAddressMask = bin2dec('0000 0000 0000 0000 0000 0011 1111 1111');

numEventsProcessed = 0;
currentLengthOfEventVectors = 1024;
majorTimeStamp = 0;
timeStampOffSet = 0;
polarityTimeStamp	= uint32(zeros(eventNumber, 1));
polarityX			= uint16(zeros(eventNumber, 1));
polarityY			= uint16(zeros(eventNumber, 1));
polarityPolarity	= false(eventNumber, 1);
for packetIndex = 1 : numEventsToRead
    currentPacket = allPackets(packetIndex);
    packetCode = bitshift(currentPacket, -24);
    if packetCode == 102 % 0x66
        % Timestamp packet
        currentTimeStamp = bitand(currentPacket, majorTimeStampMask);
        if majorTimeStamp == 0
            timeStampOffset = currentTimeStamp - 1;
        end
        majorTimeStamp = bitshift(currentTimeStamp - timeStampOffset, 10);
    elseif packetCode == 153 % 0x99
        % Column address packet
        minorTimeStamp = bitshift(bitand(currentPacket, majorTimeStampMask), -10);
        columnAddress = bitand(currentPacket, columnAddressMask);
    elseif packetCode == 204 % 0xCC
        % Events packet
        majorRowAddress = bitshift(bitand(currentPacket, majorRowAddressMask), 3);
        minorRowAndPolOneShot = bitand(currentPacket, majorRowAddressMask), 3)
        characterArray = dec2bin(m)
        % Tack on column of 0's to the left edge
        characterArray = [repmat('0', length(m), 1), characterArray]
        logicalArray = logical(characterArray - '0')
        
        numEventsProcessed = numEventsProcessed + 1;
        while eventNumber > currentLengthOfEventVectors - 15 % A packet can contribute
            polarityTimeStamp	= [polarityTimeStamp;	uint64(zeros(currentLength, 1))];
            polarityX			= [polarityX;			uint16(zeros(currentLength, 1))];
            polarityY			= [polarityY;			uint16(zeros(currentLength, 1))];
            polarityPolarity	= [polarityPolarity;	false(currentLength, 1)];
        currentLength = length(polarityValid);
    else
        error('packet formation error')
    end
%}

%{ 

Half-baked approach to matricising computation

msb = bitget(allPackets, 32);
secondMsb = bitget(allPackets, 31);

eventsLogical = msb & secondMsb;
columnLogical = msb & ~secondMsb;
timeStampLogical = ~msb & secondMsb;

timeStamps = zeros(numPackets, 1, 'uint32');
timeStamps(timeStampLogical) = bitshift(allPackets(timeStampLogical), 10);
timeStamps = FloodFillColumnDownwards(timeStamps);

%}

events = 
    
    
% Trim events outside time window
% This is an inefficent implementation, which allows for
% non-monotonic timestamps. 

if isfield(importParams, 'startTime')
    disp('Trimming to start time ...')
	tempIndex = allTs >= startTime * 1e6;
	allAddr = allAddr(tempIndex);
	allTs	= allTs(tempIndex);
end

if isfield(importParams, 'endTime')
    disp('Trimming to end time ...')    
	tempIndex = allTs <= endTime * 1e6;
	allAddr = allAddr(tempIndex);
	allTs	= allTs(tempIndex);
end

% Interpret the addresses
%{ 
- Split between DVS/DAVIS and DAS.
	For DAS1:
		- Special events - external injected events has never been
		implemented for DAS
		- Split between Address events and ADC samples
		- Intepret address events
		- Interpret ADC samples
	For DVS128:
		- Special events - external injected events are on bit 15 = 1;
		there is a more general label for special events which is bit 31 =
		1, but this has ambiguous interpretations; it is also overloaded
		for the stereo pair encoding - ignore this. 
		- Intepret address events
	For DAVIS:
		- Special events
			- Interpret IMU events from special events
		- Interpret DVS events according to chip class
		- Interpret APS events according to chip class
%}

% Declare function for finding specific event types in eventTypes cell array
cellFind = @(string)(@(cellContents)(strcmp(string, cellContents)));

% Create structure to put all the data in 
data = struct;


%% DVS128
    
elseif strcmp(info.source, 'Dvs128')
	% DVS128
	specialMask = hex2dec ('8000');
	specialLogical = bitand(allAddr, specialMask);
	polarityLogical = ~specialLogical;
	if (~isfield(importParams, 'dataTypes') || any(cellfun(cellFind('special'), importParams.dataTypes))) && any(specialLogical)
		% Special events
		data.special.timeStamp = allTs(specialLogical);
		% No need to create address field, since there is only one type of special event
	end
	if (~isfield(importParams, 'dataTypes') || any(cellfun(cellFind('polarity'), importParams.dataTypes))) && any(polarityLogical)
		% Polarity events
		data.polarity.timeStamp = allTs(polarityLogical); % Use the negation of the special mask for polarity events
		% Y addresses
		yMask = hex2dec('7F00');
		yShiftBits = 8;
		data.polarity.y = uint16(bitshift(bitand(allAddr(polarityLogical), yMask), -yShiftBits));
		% X addresses
		xMask = hex2dec('fE');
		xShiftBits = 1;
		data.polarity.x = uint16(bitshift(bitand(allAddr(polarityLogical), xMask), -xShiftBits));
		% Polarity bit
		polBit = 1;
		data.polarity.polarity = bitget(allAddr(polarityLogical), polBit) == 1;
    end	
    
end

%% Pack data

% aedat.importParams is already there and should be unchanged

info.numEventsInFile = 
aedat.info = info;
aedat.data = data;

%% Find first and last time stamps        

aedat = FindFirstAndLastTimeStamps(aedat);

%% Add NumEvents field for each data type

aedat = NumEventsByType(aedat);




disp('Import finished')




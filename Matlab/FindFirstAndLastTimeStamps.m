function aedat = FindFirstAndLastTimeStamps(aedat)
%{
This is a sub-function of importAedat. 
For eachj field in aedat.data, it finds the first and last timestamp. 
The min and max of these respectively are put into aedat.info
%}

dbstop if error

% Clip arrays to correct size and add them to the output structure.
% Also find first and last timeStamps

if ~isfield(aedat, 'data')
    disp('No data found from which to extract time stamps')
    return
end

firstTimeStamp = inf;
lastTimeStamp = 0;

if isfield(aedat.data, 'special')
	if aedat.data.special.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.special.timeStamp(1);
	end
	if aedat.data.special.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.special.timeStamp(end);
	end	
end

if polarityNumEvents > 0
    aedat.data.polarity = polarity;
	if aedat.data.polarity.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.polarity.timeStamp(1);
	end
	if aedat.data.polarity.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.polarity.timeStamp(end);
	end	
end

if frameNumEvents > 0
	if aedat.data.frame.timeStampExposureStart(1) < firstTimeStamp
		firstTimeStamp = aedat.data.frame.timeStampExposureStart(1);
	end
	if aedat.data.frame.timeStampExposureEnd(end) > lastTimeStamp
		lastTimeStamp = aedat.data.frame.timeStampExposureEnd(end);
	end	
end

if imu6NumEvents > 0
	if aedat.data.imu6.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.imu6.timeStamp(1);
	end
	if aedat.data.imu6.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.imu6.timeStamp(end);
	end	
end

if sampleNumEvents > 0
	if aedat.data.sample.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.sample.timeStamp(1);
	end
	if aedat.data.sample.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.sample.timeStamp(end);
	end	
end

if earNumEvents > 0
	if aedat.data.ear.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.ear.timeStamp(1);
	end
	if aedat.data.ear.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.ear.timeStamp(end);
	end	
end

if point1DNumEvents > 0
	if aedat.data.point1D.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.point1D.timeStamp(1);
	end
	if aedat.data.point1D.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.point1D.timeStamp(end);
	end	
end

if point2DNumEvents > 0
	if aedat.data.point2D.timeStamp(1) < firstTimeStamp
		firstTimeStamp = aedat.data.point2D.timeStamp(1);
	end
	if aedat.data.point2D.timeStamp(end) > lastTimeStamp
		lastTimeStamp = aedat.data.point2D.timeStamp(end);
	end	
end

aedat.info.firstTimeStamp = firstTimeStamp;
aedat.info.lastTimeStamp = lastTimeStamp;


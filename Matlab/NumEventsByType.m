function aedat = NumEventsByType(aedat)

%{
For each data type in aedat.data, fill in the numEvents field
%}

dbstop if error


if isfield(aedat.data, 'special')
	aedat.data.special.numEvents = length(aedat.data.special.timeStamp);
end
if isfield(aedat.data, 'polarity')
	aedat.data.polarity.numEvents = length(aedat.data.polarity.timeStamp);
end
if isfield(aedat.data, 'frame')
	aedat.data.frame.numEvents = length(aedat.data.frame.samples); % Don't use timeStamp fields because of the possible ambiguity
end
if isfield(aedat.data, 'imu6')
	aedat.data.imu6.numEvents = length(aedat.data.imu6.timeStamp);
end
if isfield(aedat.data, 'sample')
	aedat.data.sample.numEvents = length(aedat.data.sample.timeStamp);
end
if isfield(aedat.data, 'ear')
	aedat.data.ear.numEvents = length(aedat.data.ear.timeStamp);
end
if isfield(aedat.data, 'point1D')
	aedat.data.point1D.numEvents = length(aedat.data.point1D.timeStamp);
end
if isfield(aedat.data, 'point2D')
	aedat.data.point2D.numEvents = length(aedat.data.point2D.timeStamp);
end

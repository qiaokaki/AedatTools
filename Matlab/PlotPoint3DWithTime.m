function PlotPoint3DWithTime(aedat, minTime, maxTime, useCurrentAxes)

%{

Takes 'aedat' - a data structure containing an imported .aedat file, 
as created by ImportAedat, and creates a plot of point3D events,
where: 
 - X and Y are the first two values; 
 - Z is the timestamp; 
 - the color gives the 3rd value
%}

% Unpack

timeStamp = aedat.data.point3D.timeStamp;
x = aedat.data.point3D.value1;
y = aedat.data.point3D.value2;
type = aedat.data.point3D.value3;


if ~exist('minTime', 'var') || (exist('minTime', 'var') && minTime == 0)
    minTime = min(timeStamp);
else
    minTime = minTime * 1e6;
end
if ~exist('maxTime', 'var') || (exist('maxTime', 'var') && maxTime == 0)
    maxTime = max(timeStamp);
else
    maxTime = maxTime * 1e6;
end

% To do: time selection here ...

if ~exist('useCurrentAxes', 'var') || ~useCurrentAxes 
    figure
end


hold all

uniqueTypes = unique(type);

for typeIndex = uniqueTypes'
    selectedByTypeLogical = type == typeIndex;
    plot3(x(selectedByTypeLogical), y(selectedByTypeLogical), timeStamp(selectedByTypeLogical), '.-');    
end



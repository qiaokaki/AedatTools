function PlotPoint1D(aedat)

%{

Takes 'aedat' - a data structure containing an imported .aedat file, 
as created by ImportAedat, and creates a plot of point1D events. 
%}

timeStamps = double(aedat.data.point2D.timeStamp)' / 1000000;
value1 = (aedat.data.point2D.value1)';

figure
set(gcf,'numbertitle','off','name','Point1D')
%timeStamp vs value 1
plot(timeStamps, value1, '-o')
xlabel('Time (s)')
ylabel('Value 1')
	
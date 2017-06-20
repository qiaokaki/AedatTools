function PlotPoint3DLikePolarity(aedat, numPlots, distributeBy, minTime, maxTime, proportionOfPixels, transpose, flipVertical, flipHorizontal)

%{

Works like polarity, except that value1 = x; value2 = y; value3 = the type
(polarity) of the event, a unique color is chosen for each type, and
there's no concept of contrast.
%}

% The proportion of an array-full of events which is shown on a plot
if ~exist('proportionOfPixels', 'var')
	proportionOfPixels = 0.1;
end

if ~exist('numPlots', 'var')
	numPlots = 12;
end

if ~exist('distributeBy', 'var')
	distributeBy = 'time';
end

% Unpack

timeStamp = aedat.data.point3D.timeStamp;
x = aedat.data.point3D.value1;
y = aedat.data.point3D.value2;
z = aedat.data.point3D.value3;

% Distribute plots in a raster with a 3:4 ratio
numPlotsX = round(sqrt(numPlots / 3 * 4));
numPlotsY = ceil(numPlots / numPlotsX);

numEvents = length(timeStamp);
if strcmpi(distributeBy, 'time')
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
	totalTime = maxTime - minTime;
	timeStep = totalTime / numPlots;
	timePoints = minTime + timeStep * 0.5 : timeStep : maxTime;
else % distribute by event number
	eventsPerStep = numEvents / numPlots;
	timePoints = timeStamp(ceil(eventsPerStep * 0.5 : eventsPerStep : numEvents));
end

if exist ('transpose', 'var') && transpose
    y = y + x;
    x = x - y;
    y = y - x;
end

minY = double(min(y));
maxY = double(max(y));
minX = double(min(x));
maxX = double(max(x));
numPixelsInArray = (maxY - minY) * (maxX - minX);
numPixelsToSelectEachWay = ceil(numPixelsInArray * proportionOfPixels / 2);

if numPlots > 1
    figure
end
for plotCount = 1 : numPlots
    if numPlots > 1
    	subplot(numPlotsY, numPlotsX, plotCount);
    end
	hold all
	% Find eventIndex nearest to timePoint
	eventIndex = find(timeStamp >= timePoints(plotCount), 1, 'first');
	firstIndex = max(1, eventIndex - numPixelsToSelectEachWay);
	lastIndex = min(numEvents, eventIndex + numPixelsToSelectEachWay);
	selectedLogical = [false(firstIndex - 1, 1); ...
					true(lastIndex - firstIndex + 1, 1); ...
					false(numEvents - lastIndex, 1)];
	zSelected = z(selectedLogical);
    zUniqueValues = unique(zSelected);
    
    for uniqueValue = zUniqueValues'
        selectedByTypeLogical = selectedLogical & z == uniqueValue;
    	plot(x(selectedByTypeLogical), y(selectedByTypeLogical), '.');    
    end
                
	axis equal tight
	if ~exist('flipVertical', 'var') || flipVertical
		set(gca, 'YDir', 'reverse')
	end
    if exist('flipHorizontal', 'var') && flipHorizontal
		set(gca, 'XDir', 'reverse')
    end
	title([num2str(double(timeStamp(eventIndex)) / 1000000) ' s'])
end


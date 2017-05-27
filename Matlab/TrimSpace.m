function aedat = TrimSpace(aedat, newX, newY)

%{
This function take a structure which has been imported and trims the events
(polarity only for now ...) down to the params newX and newY. parameters
give the array size and one-based, but the address space is zero based. 
%}

dbstop if error

if isfield(aedat, 'data') && isfield(aedat.data, 'polarity')
    keepXLogical = aedat.data.polarity.x < newX;
    keepYLogical = aedat.data.polarity.y < newY;
    keepLogical = keepXLogical & keepYLogical;
    aedat.data.polarity.x = aedat.data.polarity.x(keepLogical);
    aedat.data.polarity.y = aedat.data.polarity.y(keepLogical);
    aedat.data.polarity.polarity = aedat.data.polarity.polarity(keepLogical);
    aedat.data.polarity.timeStamp = aedat.data.polarity.timeStamp(keepLogical);
    % Need to handle 'reset'
    aedat.data.polarity.numEvents = length(aedat.data.polarity.polarity);
end
    
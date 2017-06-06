function PlotPacketTimeStamps(aedat, newFigure)

%{
Takes 'aedat' - a data structure containing an imported .aedat file, 
as created by ImportAedat. 
When imported from aedat3, there is an info field packetTimeStamps. Plot
this.
%}

if ~isfield(aedat, 'info') || ~isfield(aeadt.info, 'packetTimeStamps')
    disp('No packet timestamps found')
    return
end

% newFigure - default is to create a new figure in which to plot - supress
% this with the newFigure flag
if ~exist(newFigure, 'var') || newFigure
    figure
end
plot(aedat.info.packetTimeStamps, '.-')
xlabel('Packet number')
ylabel('Time (us)')


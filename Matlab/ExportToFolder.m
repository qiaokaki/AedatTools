function ExportToFolder(input)

%{
This function exports to a folder following Henri's scripts for
intermediate export to ROSBAG
%}

dbstop if error

if ~exist('input', 'var')
	error('Missing input')
end

if ~isfield(input, 'exportFolderPath')
    exportFolderPath = '';
else
    exportFolderPath = [input.exportFolderPath '\']; % Windows
end

%% Write events to text file

if isfield(input.data, 'polarity')

    events = input.data.polarity;
    fid=fopen([exportFolderPath 'events.txt'], 'w');
    % To Do: export a custom range
    for i=1:events.numEvents
        if mod(i,100000) == 0
            fprintf('%d / %d \n', i, events.numEvents)
        end
        if ~isfield(events, 'valid') || events.valid(i)
            fprintf(fid, '%d %d %d %d \n', events.timeStamp(i), events.x(i), events.y(i), events.polarity(i));
        end
    end
    fclose(fid);
end

%% Copy the images to a folder

if isfield(input.data, 'frame')
    frames = input.data.frame;
    
    imagesFolderPath = [exportFolderPath 'images\']; % Windows
    mkdir(imagesFolderPath);
    fid=fopen([imagesFolderPath 'images.txt', 'w']); 

    for i = 1 : frames.numEvents
        if ~isfield(events, 'valid') || events.valid(i)
            if isfield(frames, 'timeStampExposureEnd') 
                fprintf(fid, '%d %d \n', i, frames.timeStampExposureEnd(i));
            else
                fprintf(fid, '%d %d \n', i, frames.timeStampEnd(i));
            end
            % Save the image
            str = sprintf([imagesFolderPath '%02d.png'], i);
            imwrite(uint8(frames.samples{i}/256), str);
            disp(str)
        end
    end

    fclose(fid);
end


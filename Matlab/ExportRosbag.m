function ExportRosbag(input)

%{
This function exports to Rosbag format following RPG-DVS-ROS conventions
%}

dbstop if error

if ~exist('input', 'var')
	error('Missing input')
end

% Create the file
if ~isfield(input.info, 'filePath')
    error('Missing file path and name')
end

f = fopen(input.info.filePath, 'w', 'b');

%% Write events to text file

events = cam1.data.polarity;

fid=fopen('events.txt','w');

%for i=1:events.numEvents
for i = 1: 4509695
    
    if mod(i,100000) == 0
        fprintf('%d / %d \n', i, events.numEvents)
    end
    
    if events.valid(i) == 1
        fprintf(fid, '%d %d %d %d \n', events.timeStamp(i), events.x(i), events.y(i), events.polarity(i));
    end
end

fclose(fid);

%% Write odometry to text file

fid=fopen('output/odometry.txt','w');

for i=1:odometer.numEvents
    if odometer.valid(i) == 1
        fprintf(fid, '%d %f \n', odometer.timeStamp(i), odometer.distanceTravelled(i));
    end
end

fclose(fid);

%% Copy the images to a folder

frames = cam1.data.frame;

mkdir('outputCam1');
mkdir('outputCam1/images');
fid=fopen('outputCam1/images.txt','w');

for i=1:frames.numEvents
    if frames.valid(i) == 1
        fprintf(fid, '%d %d \n', i, frames.timeStampExposureEnd(i));
        
        % Save the image
        str = sprintf('outputCam1/images/%02d.png',i);
        imwrite(uint8(frames.samples{i}/256), str);
        disp(str)
    end
end

fclose(fid);

frames = cam2.data.frame;

mkdir('outputCam2');
mkdir('outputCam2/images');
fid=fopen('outputCam2/images.txt','w');

for i=1:frames.numEvents
    if frames.valid(i) == 1
        fprintf(fid, '%d %d \n', i, frames.timeStampExposureEnd(i));
        
        % Save the image
        str = sprintf('outputCam2/images/%02d.png',i);
        imwrite(uint8(frames.samples{i}/256), str);
        disp(str);
    end
end

fclose(fid);


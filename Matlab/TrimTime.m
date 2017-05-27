function output = TrimData(input, startTime, endTime)

%{
%}

dbstop if error

startTime = startTime * 1e6;
endTime = endTime * 1e6;

% Frames

keepLogical = input.data.frame.timeStampStart >= startTime & input.data.frame.timeStampStart <= endTime;

input.data.frame.timeStampStart    = input.data.frame.timeStampStart  (keepLogical);
input.data.frame.timeStampEnd      = input.data.frame.timeStampEnd    (keepLogical);
input.data.frame.samples           = input.data.frame.samples         (keepLogical);
input.data.frame.xLength           = input.data.frame.xLength         (keepLogical);
input.data.frame.yLength           = input.data.frame.yLength         (keepLogical);
input.data.frame.xPosition         = input.data.frame.xPosition       (keepLogical);
input.data.frame.yPosition         = input.data.frame.yPosition       (keepLogical);
input.data.frame.numEvents         = nnz(keepLogical);

% Polarity

keepLogical = input.data.polarity.timeStamp >= startTime & input.data.polarity.timeStamp <= endTime;

input.data.polarity.timeStamp   = input.data.polarity.timeStamp (keepLogical);
input.data.polarity.x           = input.data.polarity.x         (keepLogical);
input.data.polarity.y           = input.data.polarity.y         (keepLogical);
input.data.polarity.polarity    = input.data.polarity.polarity  (keepLogical);
input.data.polarity.numEvents   = nnz(keepLogical);

% Imu6

keepLogical = input.data.imu6.timeStamp >= startTime & input.data.imu6.timeStamp <= endTime;

input.data.imu6.timeStamp    = input.data.imu6.timeStamp (keepLogical);
input.data.imu6.accelX       = input.data.imu6.accelX (keepLogical);
input.data.imu6.accelY       = input.data.imu6.accelY (keepLogical);
input.data.imu6.accelZ       = input.data.imu6.accelZ (keepLogical);
input.data.imu6.gyroX        = input.data.imu6.gyroX (keepLogical);
input.data.imu6.gyroY        = input.data.imu6.gyroY (keepLogical);
input.data.imu6.gyroZ        = input.data.imu6.gyroZ (keepLogical);
input.data.imu6.temperature  = input.data.imu6.temperature (keepLogical);
input.data.imu6.numEvents    = nnz(keepLogical);

% To do - correct first and last timestamp in info

output = input;
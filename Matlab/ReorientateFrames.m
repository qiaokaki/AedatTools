function aedat = ReorientateFrames(aedat, transpose, flipX, flipY)

%{
For the frame data, if present, apply transpose, flipX and flipY operations
in that order according o the boolean inputs.
%}

dbstop if error
if transpose
    aedat.data.frame.samples    = aedat.data.frame.samples';
    temp                        = aedat.data.frame.xLength;
    aedat.data.frame.xLength    = aedat.data.frame.yLength;
    aedat.data.frame.yLength    = temp;
    temp                        = aedat.data.frame.xPosition;
    aedat.data.frame.xPosition  = aedat.data.frame.yPosition;
    aedat.data.frame.yPosition  = temp;
end

if flipX
    aedat.data.frame.samples    = aedat.data.frame.samples(:, end: -1 : 1);
    % aedat.data.frame.xPosition  = Needs to be subtracted from full sensor
    % size - later
end

if flipY
    aedat.data.frame.samples    = aedat.data.frame.samples(end: -1 : 1, :);
    % aedat.data.frame.yPosition  = Needs to be subtracted from full sensor
    % size - later
end

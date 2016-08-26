% Here we set the size of the arms of our fixation cross
ODimPix = DataStruct.PTB.wRect(end)*DataStruct.Parameters.O.ScreenRatio;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
allCoords = [-ODimPix -ODimPix ODimPix ODimPix];

% Set the line width for our fixation cross
lineWidthPix = ODimPix*DataStruct.Parameters.O.lineWidthRatio;

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
penWidth = lineWidthPix;
penHeight = [];
penMode = [];
Screen('FrameOval', DataStruct.PTB.wPtr ,...
    DataStruct.Parameters.O.Color,...
    CenterRectOnPoint(allCoords,DataStruct.PTB.CenterH,DataStruct.PTB.CenterV),...
    penWidth,...
    penHeight,...
    penMode);
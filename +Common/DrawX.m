% Here we set the size of the arms of our fixation cross
XDimPix = DataStruct.PTB.wRect(end)*DataStruct.Parameters.X.ScreenRatio;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-XDimPix XDimPix XDimPix -XDimPix];
yCoords = [-XDimPix XDimPix -XDimPix XDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = XDimPix*DataStruct.Parameters.X.lineWidthRatio;

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', DataStruct.PTB.wPtr, allCoords,...
    lineWidthPix,...
    DataStruct.Parameters.X.Color,...
    [DataStruct.PTB.CenterH DataStruct.PTB.CenterV]);

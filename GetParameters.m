function [ Parameters ] = GetParameters( DataStruct )
% GETPARAMETERS Prepare common parameters
%
% Response buttuns (fORRP 932) :
% USB
% HHSC - 1x2 - CYL
% HID NAR BYGRT


%% Paths

% Parameters.Path.wav = ['wav' filesep];
Parameters.Path.negative = [fileparts(pwd) filesep 'img' filesep 'negative']; % fileparts(pwd) == path of the upper directory
Parameters.Path.neutral  = [fileparts(pwd) filesep 'img' filesep 'neutral' ];
Parameters.Path.positive = [fileparts(pwd) filesep 'img' filesep 'positive'];


%% Set parameters

%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 0.120; % m
Parameters.Video.ScreenWidthM    = 0.040; % m
Parameters.Video.ScreenHeightM   = 0.030; % m

Parameters.Video.ScreenBackgroundColor = [255 255 255]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.Size  = 40;
Parameters.Text.Font  = 'Courier New';
Parameters.Text.Color = [0 0 0]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%%%%%%%%%%%%
%   Fixation cross   %
%%%%%%%%%%%%%%%%%%%%%%
Parameters.FixationCross.ScreenRatio    = 1/30;      % ratio : FixCrossDimPx       = ScreenWidePix*ration
Parameters.FixationCross.lineWidthRatio = 1/10;      % ratio : FixCrossLineWidthPx = FixCrossDimPx*ration
Parameters.FixationCross.BaseColor      = [0   0 0]; % [R G B] ( from 0 to 255 )
Parameters.FixationCross.WrongColor     = [255 0 0]; % [R G B] ( from 0 to 255 )


%%%%%%%%%
%   X   %
%%%%%%%%%
Parameters.X.ScreenRatio    = 1/20;    % ratio : FixCrossDimPx       = ScreenWide*ration
Parameters.X.lineWidthRatio = 1/10;    % ratio : FixCrossLineWidthPx = FixCrossDimPx*ration
Parameters.X.Color          = [0 0 0]; % [R G B] ( from 0 to 255 )

%%%%%%%%%
%   O   %
%%%%%%%%%
Parameters.O.ScreenRatio    = 1/20;    % ratio : FixCrossDimPx       = ScreenWide*ration
Parameters.O.lineWidthRatio = 1/10;    % ratio : FixCrossLineWidthPx = FixCrossDimPx*ration
Parameters.O.Color          = [0 0 0]; % [R G B] ( from 0 to 255 )


%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100/2; % Hz
% 
% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Record_freq             = SamplingRate;
% Parameters.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');

Parameters.Keybinds.Right_Blue_b_ASCII   = KbName('b');
% Parameters.Keybinds.Left_Yellow_y_ASCII  = KbName('y');

% Parameters.Keybinds.LeftArrow            = KbName('LeftArrow');
% Parameters.Keybinds.RightArrow           = KbName('RightArrow');


%% Echo in command window

disp('--------------------------');
disp(['--- ' mfilename ' done ---']);
disp('--------------------------');
disp(' ');


end
function [ EP , nGo , nNoGo , Paradigm , Instructions , Timings , firstGO ] = Planning( DataStruct , Stimuli )
% This function can be executed without input parameters for display


%% Paradigm

% Execution of the function without parameter : for display
if nargout < 1
    
    DataStruct.Task  = 'MRI';
    DataStruct.OperationMode = 'Acquistion';
    
    osef = struct;
    for o = 1:50
        osef.(sprintf('img%d',o)) = o;
    end
    Stimuli.neutral  = osef;
    Stimuli.positive = osef;
    Stimuli.negative = osef;
    
end % if


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         USEFUL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nGo   = 30; % number of go
nNoGo = 15; % number of nogo

% Number of shuffled list we will play
switch DataStruct.Task
    case 'Training'
        
        nList = 1;
        needRandomization = 1;
        
        % All possible blocks here :
        fixList = {
            %Go        NoGo      nGo nNoGo
            'neutral' 'negative' nGo nNoGo
            'neutral' 'positive' nGo nNoGo
            };
        randList = {
            'circle'  'cross'    nGo nNoGo 'cross'   'circle'   nGo nNoGo % bloc1 (from 1 to 4) or bloc2 (from 5 to 8)
            };
        
    case 'MRI'
        
        nList = 1;
        needRandomization = 1;
        
        % All possible blocks here :
        fixList = {
            %Go        NoGo      nGo nNoGo
            'neutral' 'negative' nGo nNoGo
            'neutral' 'positive' nGo nNoGo
            'neutral' 'null'     nGo nNoGo
            };
        randList = {
            'circle'  'cross'    nGo nNoGo 'cross'   'circle'   nGo nNoGo % bloc1 (from 1 to 4) or bloc2 (from 5 to 8)
            'cross'   'null'     nGo nNoGo 'circle'  'null'     nGo nNoGo % bloc1 (from 1 to 4) or bloc2 (from 5 to 8)
            };
        
        %         % PILOTE 3 du 30_aug_2016
        %         % All possible blocks here :
        %         fixList = {
        %             %Go        NoGo      nGo nNoGo
        %             'negative' 'positive' nGo nNoGo
        %             'positive' 'negative' nGo nNoGo
        %             'positive' 'null'     nGo nNoGo
        %             'negative' 'null'     nGo nNoGo
        %
        %             };
        %         randList = {
        %             };
        
    case 'EEG'
        
        nList = 7;
        needRandomization = 1;
        
        % All possible blocks here :
        fixList = {
            %Go        NoGo      nGo nNoGo
            'neutral' 'negative' nGo nNoGo
            'neutral' 'positive' nGo nNoGo
            };
        randList = {
            'circle'  'cross'    nGo nNoGo 'cross'   'circle'   nGo nNoGo % bloc1 (from 1 to 4) or bloc2 (from 5 to 8)
            };
        
    case 'CalibrationXO'
        
        nList = 1;
        needRandomization = 0;
        
        % All possible blocks here :
        fixList = {
            %Go        NoGo      nGo nNoGo maxRT
            'circle'  'cross'    nGo nNoGo 0.350
            'cross'   'circle'   nGo nNoGo 0.300
            'circle'  'cross'    nGo nNoGo 0.250
            'cross'   'circle'   nGo nNoGo 0.200
            };
        
        randList = {
            };
        
    case 'CalibrationFaces'
        
        nList = 1;
        needRandomization = 0;
        
        % All possible blocks here :
        fixList = {
            %Go        NoGo      nGo nNoGo maxRT
            'neutral' 'positive' nGo nNoGo 0.400
            'neutral' 'negative' nGo nNoGo 0.400
            'neutral' 'positive' nGo nNoGo 0.350
            'neutral' 'negative' nGo nNoGo 0.350
            'neutral' 'positive' nGo nNoGo 0.300
            'neutral' 'negative' nGo nNoGo 0.300
            'neutral' 'positive' nGo nNoGo 0.250
            'neutral' 'negative' nGo nNoGo 0.250
            };
        
        randList = {
            };
        
end % switch


%% Fill the Paradigm with shuffled lists

Paradigm = {}; % initilize
for l = 1 : nList
    
    tmpList = fixList;
    
    for r = 1 : size(randList,1) % for each line of the randList
        switch round(rand) % pickup Left side or Right side randomly
            case 0
                tmpList = [ tmpList ; randList(r,1:4) ]; % Block on the Left side
            case 1
                tmpList = [ tmpList ; randList(r,5:8) ]; % Block on the Right side
        end % switch
    end % if
    
    if needRandomization
        conditionOrder = Shuffle(1:size(tmpList,1)); % shuffle the order
        shuffledList   = tmpList(conditionOrder,:);  % Creat a list with this randomized order
    else
        shuffledList = tmpList;
    end
    
    if ~isempty(Paradigm) % Don't add the 30s cross for the first
        switch DataStruct.Task
            case 'EEG'
                Paradigm = [Paradigm ; {[] [] [] []}];%#ok<*AGROW>
        end % switch
    end % if
    
    Paradigm = [Paradigm ; shuffledList]; % Append the shuffled list to the paradigm
    
end % for


%% Instructions
% It is very easy to read the code, but has no real meaning as a MATLAB
% code. Here I used a structure just because we can access it dynamiclay
% via strings. The 'keys' (strings) are the different contexts.

%            Go      NoGo        Instructions
Instructions.neutral.negative  = 'Go=neutral \nNoGo=negative';
Instructions.neutral.positive  = 'Go=neutral \nNoGo=positive';
Instructions.neutral.null      = 'Go=neutral';
Instructions.circle .cross     = 'Go=circle \nNoGo=cross';
Instructions.cross  .circle    = 'Go=cross \nNoGo=circle';
Instructions.cross  .null      = 'Go=cross';
Instructions.circle .null      = 'Go=circle';

Instructions.negative.positive = 'Go=negative \nNoGo=positive';
Instructions.positive.negative = 'Go=positive \nNoGo=negative';
Instructions.positive.null     = 'Go=positive';
Instructions.negative.null     = 'Go=negative';


%% Timings

% All Timings are in secondes
Timings.Stimulus      = 0.300;
Timings.WhiteScreen_1 = 0.250;
Timings.Cross         = [0.300 0.400]; % interval for the jitter
Timings.WhiteScreen_2 = 0.200;

Timings.Instructions  = 5.500;
Timings.FixationCross = 5.000;
Timings.WhiteScreen_0 = 0.500;

firstGO = 3; % number of forced Go at the beguining


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       End of : USEFUL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Acceleration
% Reduce the number of stimuli if acceleration

switch DataStruct.OperationMode
    
    case 'Acquisition'
        
        
    case 'FastDebug'
        
        nGo = 1;
        Paradigm(:,3) = num2cell(ones(size(Paradigm,1),1)*nGo);
        
        nNoGo = 1;
        Paradigm(:,4) = num2cell(ones(size(Paradigm,1),1)*nNoGo);
        
        firstGO = 0;
        Timings.Instructions  = Timings.Instructions/10;
        Timings.FixationCross = Timings.FixationCross/10;
        
        
    case 'RealisticDebug'
        
        
end % switch


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' , 'goContext' , 'nogoContext' , 'go/nogo' , 'content_type' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] [] [] [] });

% --- Stim ----------------------------------------------------------------


for p = 1 : size(Paradigm,1)
    
    if isempty(Paradigm{p,1})
        
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timings.FixationCross*6 []                                     goContext nogoContext -1 '+' });
        
    else
        
        goContext = Paradigm{p,1};
        nogoContext = Paradigm{p,2};
        
        EP.AddPlanning({ 'Instructions'  NextOnset(EP) Timings.Instructions    Instructions.(goContext).(nogoContext) goContext nogoContext -1              Instructions.(goContext).(nogoContext) });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timings.FixationCross   []                                     goContext nogoContext -1              '+'                                    });
        EP.AddPlanning({ 'WhiteScreen_0' NextOnset(EP) Timings.WhiteScreen_0   []                                     goContext nogoContext -1              'ws'                                   });
        
        % Generate the Go/NoGo sequence
        Sequence = PsedoRand2Conditions( nGo-firstGO , nNoGo , 1 );
        RandVect = [zeros(1,firstGO) Sequence];
        
        if ~( strcmp(goContext,'circle') || strcmp(goContext,'cross') )
            
            % Selecte the Go image from the pull
            goImg                   = struct;
            goImg.list              = fieldnames( Stimuli.(goContext) ); % *.bmp file names
            goImg.list_size         = length( goImg.list );              % how many files
            goImg.list_idx_shuffled = Shuffle( 1:goImg.list_size );      % shuffle all the files
            goImg.sequence_idx      = goImg.list_idx_shuffled( 1:nGo );  % take out some random files (index)
            goImg.sequence          = goImg.list( goImg.sequence_idx );  % take out some random files (names)
            
            if ~strcmp(nogoContext,'null')
                
                % Selecte the NoGo image from the pull
                nogoImg                   = struct;
                nogoImg.list              = fieldnames( Stimuli.(nogoContext) );  % *.bmp file names
                nogoImg.list_size         = length( nogoImg.list );               % how many files
                nogoImg.list_idx_shuffled = Shuffle( 1:nogoImg.list_size );       % shuffle all the files
                nogoImg.sequence_idx      = nogoImg.list_idx_shuffled( 1:nNoGo ); % take out some random files (index)
                nogoImg.sequence          = nogoImg.list( nogoImg.sequence_idx ); % take out some random files (names)
                
            end % if
            
        end % if
        
        if strcmp(nogoContext,'null')
            % Control blocks only have Go conditions
            RandVect = zeros(1, nGo + nNoGo );
        end % if
        
        
        goCount   = 0; % counter
        nogoCount = 0; % counter
        
        for trial = 1:length(RandVect)
            
            switch RandVect(trial)
                
                case 0 % Go
                    
                    if exist('goImg','var') && goCount >= length(goImg.sequence)
                        goCount = 1;
                    else
                        goCount = goCount + 1;
                    end % if
                    
                    switch goContext
                        case 'cross'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus 'x'                                           goContext nogoContext RandVect(trial) 'x'                     });
                        case 'circle'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus 'o'                                           goContext nogoContext RandVect(trial) 'o'                     });
                        case 'null'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus []                                            goContext nogoContext RandVect(trial) []                      });
                        otherwise
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus Stimuli.(goContext).(goImg.sequence{goCount}) goContext nogoContext RandVect(trial) goImg.sequence{goCount} });
                    end % switch
                    
                case 1 % NoGo
                    
                    if exist('nogoImg','var') && nogoCount >= length(nogoImg.sequence)
                        nogoCount = 1;
                    else
                        nogoCount = nogoCount + 1;
                    end % if
                    
                    switch nogoContext
                        case 'cross'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus 'x'                                                 goContext nogoContext RandVect(trial) 'x'                         });
                        case 'circle'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus 'o'                                                 goContext nogoContext RandVect(trial) 'o'                         });
                        case 'null'
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus []                                                  goContext nogoContext RandVect(trial) []                          });
                        otherwise
                            EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timings.Stimulus Stimuli.(nogoContext).(nogoImg.sequence{nogoCount}) goContext nogoContext RandVect(trial) nogoImg.sequence{nogoCount} });
                    end % switch
                    
            end % switch
            
            EP.AddPlanning({ 'WhiteScreen_1' NextOnset(EP) Timings.WhiteScreen_1                                         [] goContext nogoContext RandVect(trial) 'ws' });
            EP.AddPlanning({ 'Cross'         NextOnset(EP) (Timings.Cross(1) + (Timings.Cross(2)-Timings.Cross(1))*rand) [] goContext nogoContext RandVect(trial) '+'  });
            EP.AddPlanning({ 'WhiteScreen_2' NextOnset(EP) Timings.WhiteScreen_2                                         [] goContext nogoContext RandVect(trial) 'ws' });
            
        end % for
        
    end % if
    
end % for


% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] [] [] [] });


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    disp(Paradigm)
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end % if

end % function

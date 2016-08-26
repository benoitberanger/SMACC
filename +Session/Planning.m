function [ EP , Stimuli ] = Planning( DataStruct , Stimuli )
% This function can be executed without input parameters for display


%% Paradigm

% Execution of the function without parameter : for display
if nargout < 1
    
    DataStruct.Environement  = 'MRI';
%     DataStruct.OperationMode = 'Acquistion';
    DataStruct.OperationMode = 'FastDebug';
    
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

switch DataStruct.Environement
    
    case 'Training'
        
    case 'MRI'
        
        nGo   = 30; % number of go
        nNoGo = 15; % number of nogo
        
        Paradigm = {
            %  Go        NoGo    nGo nNoGo
            'neutral' 'negative' nGo nNoGo
            'neutral' 'positive' nGo nNoGo
            'circle'  'cross'    nGo nNoGo
            'cross'   'circle'   nGo nNoGo
            'neutral' 'null'     nGo nNoGo
            
            };
        
    case 'EEG'
        
end % switch


%% Instructions
% Here I used a structure just because we can access it dynamiclay via
% strings. Here this 'keys' (strings) are the different contexts. Thus it
% is very easy to read the code, but has no real meaning as a MATLAB code.

%           Go      NoGo        Instructions
Instruction.neutral.negative = 'Go=neutral NoGo=negative';
Instruction.neutral.positive = 'Go=neutral NoGo=positive';
Instruction.neutral.null     = 'Go=neutral NoGo=null';
Instruction.circle .cross    = 'Go=circle NoGo=cross';
Instruction.cross  .circle   = 'Go=cross NoGo=circle';


%% Timings

% All Timings are in secondes
Timing.Stimulus      = 0.300;
Timing.WhiteScreen_1 = 0.250;
Timing.Cross         = [0.300 0.400]; % interval for the jitter
Timing.WhiteScreen_2 = 0.200;

Timing.Instructions  = 5.500;
Timing.FixationCross = 5.000;


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
        Timing.Instructions  = Timing.Instructions/10;
        Timing.FixationCross = Timing.FixationCross/10;

        
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
    
    goContext = Paradigm{p,1};
    nogoContext = Paradigm{p,2};
    
    EP.AddPlanning({ 'Instructions'  NextOnset(EP) Timing.Instructions  Instruction.(goContext).(nogoContext) goContext nogoContext [] Instruction.(goContext).(nogoContext) });
    EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross []                                    goContext nogoContext [] '+'                                   });
    
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
    
    
    goCount   = 0; % counter
    nogoCount = 0; % counter
    
    for trial = 1:length(RandVect)
        
        switch RandVect(trial)
            
            case 0 % Go
                
                goCount = goCount + 1;
                
                switch goContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x'                                           goContext nogoContext RandVect(trial) 'x'                     });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o'                                           goContext nogoContext RandVect(trial) 'o'                     });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus []                                            goContext nogoContext RandVect(trial) []                      });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(goContext).(goImg.sequence{goCount}) goContext nogoContext RandVect(trial) goImg.sequence{goCount} });
                end % switch
                
            case 1 % NoGo
                
                nogoCount = nogoCount + 1;
                
                switch nogoContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x'                                                 goContext nogoContext RandVect(trial) 'x'                         });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o'                                                 goContext nogoContext RandVect(trial) 'o'                         });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus []                                                  goContext nogoContext RandVect(trial) []                          });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(nogoContext).(nogoImg.sequence{nogoCount}) goContext nogoContext RandVect(trial) nogoImg.sequence{nogoCount} });
                end % switch
                
        end % switch
        
        EP.AddPlanning({ 'WhiteScreen_1' NextOnset(EP) Timing.WhiteScreen_1                                       [] goContext nogoContext RandVect(trial) 'ws' });
        EP.AddPlanning({ 'Cross'         NextOnset(EP) (Timing.Cross(1) + (Timing.Cross(2)-Timing.Cross(1))*rand) [] goContext nogoContext RandVect(trial) '+' });
        EP.AddPlanning({ 'WhiteScreen_2' NextOnset(EP) Timing.WhiteScreen_2                                       [] goContext nogoContext RandVect(trial) 'ws' });
        
    end % for
    
end % for


% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] [] [] [] [] });


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end % if

end % function

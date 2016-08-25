function [ EP , Stimuli , Speed ] = Planning( DataStruct , Stimuli )
% This function can be executed without input parameters for display

%% Paradigme

if nargout < 1
    
    DataStruct.Environement  = 'MRI';
    DataStruct.OperationMode = 'Acquistion';
    
    osef = struct;
    for o = 1:50
        osef.(sprintf('img%d',o)) = o;
    end
    Stimuli.neutral  = osef;
    Stimuli.positive = osef;
    Stimuli.negative = osef;
    
end

switch DataStruct.Environement
    
    case 'Training'
        Paradigme = {};
    case 'MRI'
        
        nGo   = 30; % number of go
        nNoGo = 15; % number of nogo
        
        Paradigme = {
            %  Go        NoGo    nGo nNoGo
            'neutral' 'negative' nGo nNoGo
            'neutral' 'positive' nGo nNoGo
            'circle'  'cross'    nGo nNoGo
            'cross'   'circle'   nGo nNoGo
            'neutral' 'null'     nGo nNoGo
            
            };
        
end

switch DataStruct.OperationMode
    
    case 'Acquisition'
        Speed = 1;
        
    case 'FastDebug'
        Speed = 10;
        
        Paradigme(:,3) = cellfun(@(x) {round(x/Speed)},Paradigme(:,3));
        nGo = round(nGo/Speed);
        
        Paradigme(:,4) = cellfun(@(x) {round(x/Speed)},Paradigme(:,4));
        nNoGo = round(nNoGo/Speed);
        
    case 'RealisticDebug'
        Speed = 1;
        
end


%% Instructions

%           Go      NoGo        Instructions
Instruction.neutral.negative = 'neutral.negative';
Instruction.neutral.positive = 'neutral.positive';
Instruction.neutral.null     = 'neutral.null';
Instruction.circle .cross    = 'circle.cross';
Instruction.cross  .circle   = 'cross.circle';


%% Timings

Timing.Stimulus      = 0.300; % s
Timing.WhiteScreen_1 = 0.250; % s
Timing.Cross         = [0.300 0.400]; % s
Timing.WhiteScreen_2 = 0.200; % s

Timing.Instructions  = 5.500; % s
Timing.FixationCross = 5.000; % s

firstGO = 3;


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' , 'goContext' , 'nogoContext' , 'go/nogo' , 'content_type' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] [] [] [] [] });

% --- Stim ----------------------------------------------------------------


for p = 1 : size(Paradigme,1)
    
    goContext = Paradigme{p,1};
    nogoContext = Paradigme{p,2};
    
    EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.(goContext).(nogoContext) goContext nogoContext [] Instruction.(goContext).(nogoContext) });
    EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] goContext nogoContext [] '+'});
    
    % Generate the Go/NoGo sequence
    [ Sequence ] = PsedoRand2Conditions( nGo-firstGO , nNoGo , 1 );
    RandVect = [zeros(1,firstGO) Sequence];
    
    if ~( strcmp(goContext,'circle') || strcmp(goContext,'cross') )
        
        
        % Selecte the Go image from the pull
        goImg = struct;
        goImg.list = fieldnames( Stimuli.(goContext) ); % *.bmp file names
        goImg.list_size = length( goImg.list ); % how many files
        goImg.list_idx_shuffled = Shuffle( 1:goImg.list_size ); % shuffle all the files
        goImg.sequence_idx = goImg.list_idx_shuffled( 1:nGo ); % take out some random files (index)
        goImg.sequence = goImg.list( goImg.sequence_idx ); % take out some random files (names)
        
        if ~strcmp(nogoContext,'null')
            
            % Selecte the NoGo image from the pull
            nogoImg = struct;
            nogoImg.list = fieldnames( Stimuli.(nogoContext) ); % *.bmp file names
            nogoImg.list_size = length( nogoImg.list ); % how many files
            nogoImg.list_idx_shuffled = Shuffle( 1:nogoImg.list_size ); % shuffle all the files
            nogoImg.sequence_idx = nogoImg.list_idx_shuffled( 1:nNoGo ); % take out some random files (index)
            nogoImg.sequence = nogoImg.list( nogoImg.sequence_idx ); % take out some random files (names)
            
        end
        
    end
    
    
    goCount   = 0; % counter
    nogoCount = 0; % counter
    
    for trial = 1:length(RandVect)
        
        switch RandVect(trial)
            
            case 0 % Go
                
                goCount = goCount + 1;
                
                switch goContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x' goContext nogoContext RandVect(trial) 'x' });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o' goContext nogoContext RandVect(trial) 'o' });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus []  goContext nogoContext RandVect(trial) [] });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(goContext).(goImg.sequence{goCount}) goContext nogoContext RandVect(trial) goImg.sequence{goCount} });
                end
                
            case 1 % NoGo
                
                nogoCount = nogoCount + 1;
                
                switch nogoContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x' goContext nogoContext RandVect(trial) 'x' });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o' goContext nogoContext RandVect(trial) 'o' });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus []  goContext nogoContext RandVect(trial) [] });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(nogoContext).(nogoImg.sequence{nogoCount}) goContext nogoContext RandVect(trial) nogoImg.sequence{nogoCount} });
                end
                
        end
        
        EP.AddPlanning({ 'WhiteScreen_1' NextOnset(EP) Timing.WhiteScreen_1 [] goContext nogoContext RandVect(trial) 'ws' });
        EP.AddPlanning({ 'Cross' NextOnset(EP) (Timing.Cross(1) + (Timing.Cross(2)-Timing.Cross(1))*rand) [] goContext nogoContext RandVect(trial) '+' });
        EP.AddPlanning({ 'WhiteScreen_2' NextOnset(EP) Timing.WhiteScreen_2 [] goContext nogoContext RandVect(trial) 'ws' });
        
    end
    
end


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
    
end

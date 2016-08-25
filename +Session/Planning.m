function [ EP , Stimuli , Speed ] = Planning( DataStruct , Stimuli )

%% Paradigme

if nargout < 1
    
    DataStruct.Environement  = 'MRI';
    DataStruct.OperationMode = 'Acquistion';
    osef = struct;
    for o = 1:50
        osef.(sprintf('img%d',o)) = 0;
    end
    Stimuli.neutral = osef;
    Stimuli.positive = osef;
    Stimuli.negative = osef;
    
end

switch DataStruct.Environement
    
    case 'Training'
        Paradigme = {};
    case 'MRI'
        
        nGo = 30;
        nNoGo = 15;
        
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

%           Go      NoGo         Instructions
Instruction.neutral.negative = {''};
Instruction.neutral.positive = {''};
Instruction.neutral.null     = {''};
Instruction.circle .cross    = {''};
Instruction.cross  .circle   = {''};


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
header = { 'event_name' , 'onset(s)' , 'duration(s)' , 'content' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddPlanning({ 'StartTime' 0  0 [] });

% --- Stim ----------------------------------------------------------------


for p = 1 : size(Paradigme,1)
    
    goContext = Paradigme{p,1};
    nogoContext = Paradigme{p,2};
    
    EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.(goContext).(nogoContext) });
    EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
    
    % Generate the Go/NoGo sequence
    [ Sequence ] = PsedoRand2Conditions( nGo-firstGO , nNoGo );
    RandVect = [zeros(1,firstGO) Sequence];
    
    if ~( strcmp(goContext,'circle') || strcmp(goContext,'cross') )
        
        
        % Selecte the Go image from the pull
        GoImg = struct;
        GoImg.list = fieldnames( Stimuli.(goContext) ); % *.bmp file names
        GoImg.list_size = length( GoImg.list ); % how many files
        GoImg.list_idx_shuffled = Shuffle( 1:GoImg.list_size ); % shuffle all the files
        GoImg.sequence_idx = GoImg.list_idx_shuffled( 1:nGo ); % take out some random files (index)
        GoImg.sequence = GoImg.list( GoImg.sequence_idx ); % take out some random files (names)
        
        if ~strcmp(nogoContext,'null')
            
            % Selecte the NoGo image from the pull
            NoGoImg = struct;
            NoGoImg.list = fieldnames( Stimuli.(nogoContext) ); % *.bmp file names
            NoGoImg.list_size = length( NoGoImg.list ); % how many files
            NoGoImg.list_idx_shuffled = Shuffle( 1:NoGoImg.list_size ); % shuffle all the files
            NoGoImg.sequence_idx = NoGoImg.list_idx_shuffled( 1:nNoGo ); % take out some random files (index)
            NoGoImg.sequence = NoGoImg.list( NoGoImg.sequence_idx ); % take out some random files (names)
            
        end
        
    end
    
    
    goCount = 0;
    nogoCount = 0;
    for trial = 1:length(RandVect)
        
        switch RandVect(trial)
            
            case 0
                
                goCount = goCount + 1;
                
                switch goContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x' });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o' });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus [] });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(goContext).(GoImg.sequence{goCount}) });
                end
                
            case 1
                
                nogoCount = nogoCount + 1;
                
                switch nogoContext
                    case 'cross'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'x' });
                    case 'circle'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus 'o' });
                    case 'null'
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus [] });
                    otherwise
                        EP.AddPlanning({ 'Stimulus' NextOnset(EP) Timing.Stimulus Stimuli.(nogoContext).(NoGoImg.sequence{nogoCount}) });
                end
                
        end
        
        EP.AddPlanning({ 'WhiteScreen_1' NextOnset(EP) Timing.WhiteScreen_1 'x' });
        EP.AddPlanning({ 'Cross' NextOnset(EP) (Timing.Cross(1) + (Timing.Cross(2)-Timing.Cross(1))*rand) 'x' });
        EP.AddPlanning({ 'WhiteScreen_2' NextOnset(EP) Timing.WhiteScreen_2 'x' });
        
    end
    
end


% --- Stop ----------------------------------------------------------------

EP.AddPlanning({ 'StopTime' NextOnset(EP) 0 [] });


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end

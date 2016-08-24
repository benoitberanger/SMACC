function [ EP , Stimuli , Speed ] = Planning( DataStruct , Stimuli )

%% Paradigme

if nargout < 1
    
    DataStruct.Environement = 'MRI';
    DataStruct.OperationMode = 'Acquistion';
    
end

switch DataStruct.Environement
    
    case 'Training'
        Paradigme = {};
    case 'MRI'
        
        NbOfTrials = 30;
        
        Paradigme = {
            %  Go        NoGo    NbOfTrials
            'neutral' 'negative' NbOfTrials
            'neutral' 'positive' NbOfTrials
            'circle'  'cross'    NbOfTrials
            'cross'   'circle'   NbOfTrials
            'neutral' []         NbOfTrials
            
            };
        
end

switch DataStruct.OperationMode
    
    case 'Acquisition'
        Speed = 1;
        
    case 'FastDebug'
        Speed = 10;
        Paradigme(:,3) = cellfun(@(x) {round(x/Speed)},Paradigme(:,3));
        NbOfTrials = round(NbOfTrials/Speed); %#ok<*NASGU>
        
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
    
    if     strcmp(Paradigme{p,1}, 'neutral' ) && strcmp(Paradigme{p,2}, 'negative' )
        
        EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.neutral.negative });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
        
        RandVect = Shuffle([1:NbOfTrials]);
        
    elseif strcmp(Paradigme{p,1}, 'neutral' ) && strcmp(Paradigme{p,2}, 'positive' )
        
        EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.neutral.positive });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
        
    elseif strcmp(Paradigme{p,1}, 'neutral' ) && isempty(Paradigme{p,2}            )
        
        EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.neutral.null     });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
        
    elseif strcmp(Paradigme{p,1}, 'circle'  ) && strcmp(Paradigme{p,2}, 'cross'    )
        
        EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.circle.cross     });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
        
    elseif strcmp(Paradigme{p,1}, 'cross'   ) && strcmp(Paradigme{p,2}, 'circle'   )
        
        EP.AddPlanning({ 'Instructions' NextOnset(EP) Timing.Instructions Instruction.cross.circle     });
        EP.AddPlanning({ 'FixationCross' NextOnset(EP) Timing.FixationCross [] });
        
    else
        error('unrecognized paradigme')
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

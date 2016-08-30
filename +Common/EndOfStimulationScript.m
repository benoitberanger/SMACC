%% End of stimulation

% EventRecorder
% if size(EP.Data,2)>3
%     EP.Data(:,4:end) = [];
% end
ER.ClearEmptyEvents;
ER.ComputeDurations;
ER.BuildGraph;
TaskData.ER = ER;

% KbLogger
KL.GetQueue;
KL.Stop;
switch DataStruct.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        TR = 2.400; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) ; % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes , StartTime );
    case 'RealisticDebug'
        TR = 2.400; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ); % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes , StartTime );
    otherwise
end
KL.ScaleTime;
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here I use the KbLogger to add precise buttons inputs

click_spot.R = regexp(KL.KbEvents(:,1),KbName(DataStruct.Parameters.Keybinds.Right_Blue_b_ASCII));
click_spot.R = ~cellfun(@isempty,click_spot.R);
click_spot.R = find(click_spot.R);

% clic_spot.L = regexp(KL.KbEvents(:,1),KbName(DataStruct.Parameters.Keybinds.Left_Yellow_y_ASCII));
% clic_spot.L = ~cellfun(@isempty,clic_spot.L);
% clic_spot.L = find(clic_spot.L);

count = 0 ;
% Sides = {'R' ; 'L'};
Sides = {'R'};
for side = 1:length(Sides)
    
    count = count + 1 ;
    
    if ~isempty(KL.KbEvents{click_spot.(Sides{side}),2})
        click_idx = cell2mat(KL.KbEvents{click_spot.(Sides{side}),2}(:,2)) == 1;
        click_idx = find(click_idx);
        % the last click can be be unfinished : button down + end of stim = no button up
        if size(KL.KbEvents{click_spot.(Sides{side}),2},2) == 2
            KL.KbEvents{click_spot.(Sides{side}),2}{click_idx(end),3} =  ER.Data{end,2} - KL.KbEvents{click_spot.(Sides{side}),2}{click_idx(end),1};
        end% if
        click_onsets    = cell2mat(KL.KbEvents{click_spot.(Sides{side}),2}(click_idx,1));
        click_durations = cell2mat(KL.KbEvents{click_spot.(Sides{side}),2}(click_idx,3));
    else
        click_onsets = [];
    end % if
    
end % for

if ~isempty(click_onsets)
    for c = 1 : length(click_onsets)
        RR.AddEvent({ 'CLICK' click_onsets(c) click_durations(c)});
    end % for
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Response Recorder
RR.ClearEmptyEvents;
% RR.MakeBlocks;
RR.BuildGraph;
TaskData.RR = RR;


% Save some values
TaskData.StartTime = StartTime;
TaskData.StopTime  = StopTime;


% RT table
empty_idx = cellfun( @isempty , Table(:,1) );
Table( empty_idx , : ) = [];

% In cas I've messed with the code, let's check the coherence.
for t = 1 : size(Table,1)
    state = sum( cell2mat( Table(t,7:9) ) ) == Table{t,6};
    if ~state
        warning('Table:ColumnsNotCoherent','Table(%d,:) not coherent',t)
    end % if
end % for

TaskData.Table_hdr = Table_hdr;
TaskData.Table     = Table;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','RR',RR)
assignin('base','KL',KL)

assignin('base','Table',Table)

assignin('base','TaskData',TaskData)


%% Close all movies / textures / audio devices

% Close all textures
Screen('Close');


%% Close parallel port

switch DataStruct.ParPort
    
    case 'On'
        
        try
            CloseParPort;
        catch err % just try to colse it, but we don't want an error
            disp(err)
        end
        
    case 'Off'
        
end


%% Diagnotic

switch DataStruct.OperationMode
    case 'Acquisition'
        
    case 'FastDebug'
        plotDelay
        RR.Plot
        
    case 'RealisticDebug'
        plotDelay
        RR.Plot
        
end

disp(Table)



function [ names , onsets , durations ] = SPMnod( DataStruct )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

try
    
    % Shortcut
    BuildedEvents = DataStruct.TaskData.RR.Data;
    
    
    %% Preparation
    
    % 'names' for SPM
    switch DataStruct.Task
        
        case 'EyelinkCalibration'
            names = {'EyelinkCalibration'};
            
        case 'Session'
            
            names = {
                'Go'
                'Cross.too_late'
                'NoGo'
                'Cross.wrong_click'
                'CLICK'
                };
            
    end
    
    % 'onsets' & 'durations' for SPM
    onsets    = cell(size(names));
    durations = cell(size(names));
    
    
    %% Onsets building
    
    for n = 1:length(names)
        idx = strcmp(BuildedEvents(:,1),names{n});
        onsets{n} = cell2mat(BuildedEvents(idx,2));
    end % for
    
    
    %% Durations building
    
    for n = 1:length(names)
        idx = strcmp(BuildedEvents(:,1),names{n});
        durations{n} = cell2mat(BuildedEvents(idx,3));
    end % for
    
    
    %% Block reconstruction
    
    EventData = DataStruct.TaskData.ER.Data;
    
    Instructions_idx = strcmp(EventData(:,1),'Instructions');
    FixationCross_idx = strcmp(EventData(:,1),'FixationCross');
    
    InstrFixCross_idx = Instructions_idx + FixationCross_idx;
    D = diff(InstrFixCross_idx);
    
    blockstart_idx = find( D == -1 );
    
    EventData(blockstart_idx,end+1) = {1}; % diagnostic
    
    block = zeros(length(blockstart_idx),2);
    for b = 1 : length(blockstart_idx)
        
        block(b,1) = EventData{blockstart_idx(b),2};
        
        if b ~= length(blockstart_idx)
            
            block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):blockstart_idx(b+1)-2,3) ) );
            
        else
            switch  EventData{end-1,1}
                case 'Instructions'
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end-3,3) ) );
                    
                case 'FixationCross'
                     block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end-4,3) ) );
                    
                otherwise
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end,3) ) );

            end % switch
            
        end % if
        
    end % for
    
    
    
catch err
    
    sca
    rethrow(err)
    
end

end

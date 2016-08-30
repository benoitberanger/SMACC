function [ names , onsets , durations ] = SPMnod( DataStruct )
%SPMNOD Build 'names', 'onsets', 'durations' for SPM

try
    
    % Shortcut
    EventData = DataStruct.TaskData.RR.Data;
    
    
    %% Preparation
    
    % 'names' for SPM
    switch DataStruct.Task
        
        case 'EyelinkCalibration'
            names = {'EyelinkCalibration'};
            
        case 'Session'
            
            names = unique_stable(EventData(:,1));
            
            StartTime_idx = strcmp(names,'StartTime');
            names(StartTime_idx) = [];
            StopTime_idx = strcmp(names,'StopTime');
            names(StopTime_idx) = [];
            
    end
    
    % 'onsets' & 'durations' for SPM
    onsets    = cell(size(names));
    durations = cell(size(names));
    
    
    %% Onsets building
    
    for n = 1:length(names)
        idx = strcmp(EventData(:,1),names{n});
        onsets{n} = cell2mat(EventData(idx,2));
    end % for
    
    
    %% Durations building
    
    for n = 1:length(names)
        idx = strcmp(EventData(:,1),names{n});
        durations{n} = cell2mat(EventData(idx,3));
    end % for
    
    
catch err
    
    sca
    rethrow(err)
    
end

end

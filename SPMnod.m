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
            
        otherwise
            
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
    
    Instructions_idx  = strcmp(EventData(:,1),'Instructions' );
    FixationCross_idx = strcmp(EventData(:,1),'FixationCross');
    WhiteScreen_0_idx = strcmp(EventData(:,1),'WhiteScreen_0');
    
    %     InstrFixCrossWS0_idx = Instructions_idx + FixationCross_idx;
    InstrFixCrossWS0_idx = Instructions_idx + FixationCross_idx + WhiteScreen_0_idx;
    D = diff(InstrFixCrossWS0_idx);
    
    blockstart_idx = find( D == -1 ) + 1;
    
    EventData(blockstart_idx,end+1) = {1}; % diagnostic
    
    block = zeros(length(blockstart_idx),2);
    for b = 1 : length(blockstart_idx)
        
        block(b,1) = EventData{blockstart_idx(b),2};
        
        if b ~= length(blockstart_idx)
            
            block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):blockstart_idx(b+1)-4,3) ) );
            
        else
            switch  EventData{end-1,1}
                case 'Instructions'
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end-2,3) ) );
                    
                case 'FixationCross'
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end-3,3) ) );
                    
                case 'WhiteScreen_0'
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end-4,3) ) );
                    
                otherwise
                    block(b,2) = sum( cell2mat( EventData(blockstart_idx(b):end,3) ) );
                    
            end % switch
            
        end % if
        
    end % for
    
    N = length(names);
    
    % Build a condition name:
    allBlocks = cell( size(DataStruct.TaskData.Paradigm,1) , 1 );
    for ab = 1:size(DataStruct.TaskData.Paradigm,1)
        allBlocks{ab} = [DataStruct.TaskData.Paradigm{ab,1} '.' DataStruct.TaskData.Paradigm{ab,2}];
    end % for
    
    
    % allBlocks = regexprep(allBlocks,'^.$','rest');
    allBlocks(strcmp(allBlocks,'.'),:) = [];
    
    [blockNames,~,indC] = unique_stable( allBlocks );
    names = [names ; blockNames]; % append conditions names
    onsets{length(names)} = []; % pre-allocation
    durations{length(names)} = []; % pre-allocation
    
    for c = 1 : size(block,1)
        
        onsets{N + indC(c)} = [onsets{N + indC(c)} ; block(c,1)];
        durations{N + indC(c)} = [durations{N + indC(c)} ; block(c,2)];
        
    end % for
    
    
catch err
    
    sca
    rethrow(err)
    
end

end

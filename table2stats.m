function [ Stats, newTable, newTable_hdr ] = table2stats( DataStruct, display )

if nargin<2
    display = 1;
end

Table = DataStruct.TaskData.Table; % shortcut

Stats = struct;


%% Build condition name

% Retro-compatibility
if size(Table,2) ~= 10
    Table(:,10)= num2cell(ones(size(Table,1),1)*0.850);
end

allBlocks = cell( size(Table,1) , 1 );
for ab = 1:size(Table,1)
    allBlocks{ab} = [Table{ab,3} '_' Table{ab,4} '_' sprintf('%d',round(cell2mat(Table(ab,10))*1000))];
end % for


%% Regoup each condition

[blockNames,~,indC] = unique_stable( allBlocks );

for c = 1:length(blockNames)
    
    current_table               = Table(c==indC,:);
    Stats.(blockNames{c}).Table = current_table;
    
    Go           = cell2mat(current_table(:,2)) == 0;
    NoGo         = cell2mat(current_table(:,2)) == 1;
    Clicked      = cell2mat(current_table(:,6)) == 1;
    OkClick      = cell2mat(current_table(:,7)) == 1;
    TooLateClick = cell2mat(current_table(:,8)) == 1;
    NoGoClick    = cell2mat(current_table(:,9)) == 1;
    
    Stats.(blockNames{c}).OkGo.idx      = Go & Clicked & OkClick;
    Stats.(blockNames{c}).OkGo.RT       = cell2mat(current_table(Stats.(blockNames{c}).OkGo.idx,5));
    Stats.(blockNames{c}).OkGo.count    = length(Stats.(blockNames{c}).OkGo.RT);
    Stats.(blockNames{c}).OkGo.mean     = mean(Stats.(blockNames{c}).OkGo.RT);
    
    Stats.(blockNames{c}).ErrorNG.idx   = NoGo & Clicked & NoGoClick;
    Stats.(blockNames{c}).ErrorNG.RT    = cell2mat(current_table(Stats.(blockNames{c}).ErrorNG.idx,5));
    Stats.(blockNames{c}).ErrorNG.count = length(Stats.(blockNames{c}).ErrorNG.RT);
    Stats.(blockNames{c}).ErrorNG.mean  = mean(Stats.(blockNames{c}).ErrorNG.RT);
    
    Stats.(blockNames{c}).TooLate.idx   = Go & Clicked & TooLateClick;
    Stats.(blockNames{c}).TooLate.RT    = cell2mat(current_table(Stats.(blockNames{c}).TooLate.idx,5));
    Stats.(blockNames{c}).TooLate.count = length(Stats.(blockNames{c}).TooLate.RT);
    Stats.(blockNames{c}).TooLate.mean  = mean(Stats.(blockNames{c}).TooLate.RT);
    
    Stats.(blockNames{c}).Miss.idx      = Go & ~Clicked;
    Stats.(blockNames{c}).Miss.count    = sum(Go & ~Clicked);
    
end % for


%% Combine stats

fields = {'OkGo', 'ErrorNG', 'TooLate', 'Miss'};

newTable_hdr = {'block', 'OkGo:count', 'OkGo:mean', 'ErrorNG:count', 'ErrorNG:mean', 'TooLate:count', 'TooLate:mean', 'Miss:count', 'maxRT'};
newTable = cell(0);

for c = 1:length(blockNames)
    
    newTable{c,1} = blockNames{c}(1:end-4);
    
    
    for f = 1:length(fields)
        
        if strcmp(fields{f},'Miss')
            newTable{c,2*f} = Stats.(blockNames{c}).(fields{f}).count;
        else
            newTable{c,2*f} = Stats.(blockNames{c}).(fields{f}).count;
            newTable{c,2*f+1} = Stats.(blockNames{c}).(fields{f}).mean;
        end % if
        
    end % for
    
    newTable{c,9} =str2double(blockNames{c}(end-2:end))/1000;

end % for


%% Display

if display
    fprintf('\n')
    fprintf('\n')
    dsp = [ newTable_hdr ; newTable];
    disp(dsp)
    fprintf('\n')
end

end % function

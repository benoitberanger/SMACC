function [ Stats ] = table2stats( Table )
%%
Stats = struct;

% Build condition name

allBlocks = cell( size(Table,1) , 1 );
for ab = 1:size(Table,1)
    allBlocks{ab} = [Table{ab,3} '_' Table{ab,4}];
end % for


% Regoup each condition

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


end % function


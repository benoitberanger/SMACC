function [] = SubjectStats(hObject,eventdata)

clc

% ../
upperDir = fullfile( fileparts( pwd ) );

% ../data/
dataDir = fullfile( upperDir , 'data' );

% ../data/ exists ?
if ~isdir( dataDir )
    error( 'MATLAB:DataDirExists' , ' \n ---> data directory not found in the upper dir : %s <--- \n ' , upperDir )
end

SubjectID = get(hObject,'String');

% ../data/(SubjectID)
SubjectIDDir = fullfile( dataDir , SubjectID );

% ../data/(SubjectID) exists ?
if ~isdir( SubjectIDDir )
    error( 'MATLAB:SubjectIDDirExists' ,  ' \n ---> SubjectID directory not found in : %s <--- \n ' , dataDir )
end

% Content order : older to newer
dirContent = struct2cell( dir(SubjectIDDir) );
[~,IX] = sort( cell2mat( dirContent(end,:) ) );
dirContentSorted = dirContent(:,IX);

% Display dir
fprintf('\n\n SubjectID data dir : %s \n', SubjectIDDir)

% Display content
fullTable = cell(0,8);
for f = 1 : size(dirContentSorted,2)
    if regexp(dirContentSorted{1,f},[ SubjectID '_.*\d+.mat$'])
        fprintf('  %s \n', dirContentSorted{1,f})
        S = load([ SubjectIDDir filesep dirContentSorted{1,f} ]);
        [ ~ , newTable, newTable_hdr ] = table2stats(S.DataStruct.TaskData.Table,0);
        fullTable = [fullTable ; newTable]; %#ok<*AGROW>
    end % if
end % for

disp([ newTable_hdr ; fullTable])

listConditions = {
    'neutral_positive'
    'neutral_negative'
    'neutral_null'
    'circle_cross'
    'cross_circle'
    'circle_null'
    'cross_null'
    };

sortedTable = cell(0,8);

for s = 1 : length(listConditions)
    idx = strcmp(fullTable(:,1),listConditions{s});
    sortedTable = [sortedTable ; fullTable(idx,:)];
    if any(idx)
        sortedTable = [sortedTable ; ['mean'  num2cell(nanmean(cell2mat(fullTable(idx,2:end)),1))]];
    end % if
end % for

fprintf('\n')
disp([ newTable_hdr ; sortedTable])

end % function

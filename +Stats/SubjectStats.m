function SubjectStats(hObject,eventdata)

% ../
upperDir = fullfile( fileparts( pwd ) );

% ../data/
dataDir = fullfile( upperDir , 'data' );

% ../data/ exists ?
if ~isdir( dataDir )
    error( 'MATLAB:DataDirExists' , ' \n ---> data directory not found in the upper dir : %s <--- \n ' , upperDir )
end

SubjectID = get(hObject,'String');

if isempty(SubjectID)
    error( 'MATLAB:EmptySubjectID' ,  ' \n ---> Empty SubjectID <--- \n ' )
end

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


%% Display in order of occurrence

fullTable = cell(0,9);
for f = 1 : size(dirContentSorted,2)
    if ( ~isempty(regexp(dirContentSorted{1,f},[ SubjectID '_MRI.*_\d+.mat$'])) || ~isempty(regexp(dirContentSorted{1,f},[ SubjectID '_.*MRI_\d+.mat$'])) ) %#ok<RGXP1>
        fprintf('  %s \n', dirContentSorted{1,f})
        S = load([ SubjectIDDir filesep dirContentSorted{1,f} ]);
        [ ~ , newTable, newTable_hdr ] = Stats.table2stats(S.DataStruct,0);
        fullTable = [fullTable ; newTable]; %#ok<*AGROW>
    end % if
end % for

if isempty(fullTable)
    error('no MRI file found in : %s', dataDir)
end % if

disp([ newTable_hdr ; fullTable])


%% Display regrouped by conditions

listConditions = {
    'neutral_positive'
    'neutral_negative'
    'neutral_null'
    'circle_cross'
    'cross_circle'
    'circle_null'
    'cross_null'
    };
allMeans = nan(size(listConditions,1),8);
sortedTable = cell(0,9);

for s = 1 : length(listConditions)
    idx = strcmp(fullTable(:,1),listConditions{s});
    sortedTable = [sortedTable ; fullTable(idx,:)];
    if any(idx)
        localmean = cell2mat(fullTable(idx,2:end));
        localmean(isnan(localmean)) = 0;
        localmean = mean(localmean,1);
        sortedTable = [sortedTable ; ['mean' num2cell(localmean) ]];
        allMeans(s,:) = localmean;
    end % if
end % for

fprintf('\n')
disp([ newTable_hdr ; sortedTable])


%% Plot

% Count
figure( ...
    'Name'        , 'count'                   , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.01, 0.01, 0.98, 0.88]      ...
    )
bar(allMeans(:,[1 3 5 7]))
set(gca,'XTickLabel',listConditions)
legend(newTable_hdr(1+[1 3 5 7]))
grid on

% Mean
figure( ...
    'Name'        , 'mean'                   , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.01, 0.01, 0.98, 0.88]      ...
    )
bar(allMeans(:,[2 4 6]))
set(gca,'XTickLabel',listConditions)
legend(newTable_hdr(1+[2 4 6]))
grid on

end % function

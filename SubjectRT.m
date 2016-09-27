function SubjectRT(hObject,eventdata)

DesiredError = 6;

%%

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
fileNames = dirContent(1,:)';


%% Calibration XO

% Check files names in the directory
Faces_files_idx = regexp(fileNames,'CalibrationXO_.*_\d+.mat$');
Faces_files_idx = find(~cellfun(@isempty,Faces_files_idx));

% O nly 1 file, or error
if length(Faces_files_idx) < 1
    error('no CalibrationXO file found in : %s', dataDir)
elseif length(Faces_files_idx) > 1
    error('several CalibrationXO files found : only 1 is needed')
end

% Extraction of the Table
XOstruct = load([dataDir filesep SubjectID filesep fileNames{Faces_files_idx}]);
[ ~ , xoTable, ~ ] = table2stats(XOstruct.DataStruct,1);

% figure : open
figure( ...
    'Name'        , 'XO'                   , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.01, 0.01, 0.98, 0.88]      ...
    )
hold all

% real error
xXO = cell2mat(xoTable(:,9));
yXO = cell2mat(xoTable(:,4));
plot( xXO , yXO , '-O' , 'DisplayName','Error(RT)')

% fit
[pXO] = polyfit(xXO,yXO,1);
yfitXO = polyval(pXO,xXO);
plot(xXO,yfitXO, 'DisplayName','fit')

% best RT
invfitXO = @(y) (y-pXO(2))/pXO(1);
stem(invfitXO(DesiredError),DesiredError, 'DisplayName','optimal')

% figure : improvements
xlabel('RT (s)')
ylabel('error count')
legend('toggle')
grid on
ScaleAxisLimits

% Print
fprintf('\n')
fprintf('XO : RT(%d errors) = %1.3f (s) \n',DesiredError,invfitXO(DesiredError))


%% Calibration Faces : Positive

% Check files names in the directory
Faces_files_idx = regexp(fileNames,'CalibrationFaces_.*_\d+.mat$');
Faces_files_idx = find(~cellfun(@isempty,Faces_files_idx));

% O nly 1 file, or error
if length(Faces_files_idx) < 1
    error('no CalibrationFaces file found in : %s', dataDir)
elseif length(Faces_files_idx) > 1
    error('several CalibrationFaces files found : only 1 is needed')
end

% Extraction of the Table
Fstruct = load([dataDir filesep SubjectID filesep fileNames{Faces_files_idx}]);
[ ~ , FacesTable, ~ ] = table2stats(Fstruct.DataStruct,1);

% figure : open
figure( ...
    'Name'        , 'Positive'                   , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.01, 0.01, 0.98, 0.88]      ...
    )
hold all

% real error
xPositive = cell2mat(FacesTable(strcmp(FacesTable(:,1),'neutral_positive'),9));
yPositive = cell2mat(FacesTable(strcmp(FacesTable(:,1),'neutral_positive'),4));
plot( xPositive , yPositive , '-O' , 'DisplayName','Error(RT)')

% fit
[pPositive] = polyfit(xPositive,yPositive,1);
yfitPositive = polyval(pPositive,xPositive);
plot(xPositive,yfitPositive, 'DisplayName','fit')

% best RT
invfitPositive = @(y) (y-pPositive(2))/pPositive(1);
stem(invfitPositive(DesiredError),DesiredError, 'DisplayName','optimal')

% figure : improvements
xlabel('RT (s)')
ylabel('error count')
legend('toggle')
grid on
ScaleAxisLimits

% Print
fprintf('\n')
fprintf('Positive : RT(%d errors) = %1.3f (s) \n',DesiredError,invfitPositive(DesiredError))


%% Calibration Faces : Negative

% Check files names in the directory
Faces_files_idx = regexp(fileNames,'CalibrationFaces_.*_\d+.mat$');
Faces_files_idx = find(~cellfun(@isempty,Faces_files_idx));

% O nly 1 file, or error
if length(Faces_files_idx) < 1
    error('no CalibrationFaces file found in : %s', dataDir)
elseif length(Faces_files_idx) > 1
    error('several CalibrationFaces files found : only 1 is needed')
end

% Extraction of the Table
Fstruct = load([dataDir filesep SubjectID filesep fileNames{Faces_files_idx}]);
[ ~ , FacesTable, ~ ] = table2stats(Fstruct.DataStruct,1);

% figure : open
figure( ...
    'Name'        , 'Negative'                   , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.01, 0.01, 0.98, 0.88]      ...
    )
hold all

% real error
xNegative = cell2mat(FacesTable(strcmp(FacesTable(:,1),'neutral_negative'),9));
yNegative = cell2mat(FacesTable(strcmp(FacesTable(:,1),'neutral_negative'),4));
plot( xNegative , yNegative , '-O' , 'DisplayName','Error(RT)')

% fit
[pNegative] = polyfit(xNegative,yNegative,1);
yfitNegative = polyval(pNegative,xNegative);
plot(xNegative,yfitNegative, 'DisplayName','fit')

% best RT
invfitNegative = @(y) (y-pNegative(2))/pNegative(1);
stem(invfitNegative(DesiredError),DesiredError, 'DisplayName','optimal')

% figure : improvements
xlabel('RT (s)')
ylabel('error count')
legend('toggle')
grid on
ScaleAxisLimits

% Print
fprintf('\n')
fprintf('Negative : RT(%d errors) = %1.3f (s) \n',DesiredError,invfitNegative(DesiredError))


end % function

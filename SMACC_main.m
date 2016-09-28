function SMACC_main(hObject, ~)
% This function should not be called directely, only through the GUI : SMACC_GUI

if nargin == 0
    
    SMACC_GUI;
    
    fprintf('\n')
    fprintf('Use %s to start the GUI.','SMACC_GUI.m');
    fprintf('\n')
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data

clc
sca

% Initialize the main structure
DataStruct               = struct;
DataStruct.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
DataStruct.TimeStampFile = datestr(now, 30); % to sort automatically by time of creation


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    case 'pushbutton_MRI'
        Task                     = 'MRI';
        SessionNumber            = str2double( get(handles.edit_SessionNumber,'String') );
        DataStruct.SessionNumber = SessionNumber;
        
    case 'pushbutton_EEG'
        Task                     = 'EEG';
        SessionNumber            = str2double( get(handles.edit_SessionNumber,'String') );
        DataStruct.SessionNumber = SessionNumber;
        
    case 'pushbutton_Training'
        Task                     = 'Training';
        SessionNumber            = str2double( get(handles.edit_SessionNumber,'String') );
        DataStruct.SessionNumber = SessionNumber;
        
    case 'pushbutton_CalibrationXO'
        Task                     = 'CalibrationXO';
        SessionNumber            = str2double( get(handles.edit_SessionNumber,'String') );
        DataStruct.SessionNumber = SessionNumber;
        
    case 'pushbutton_CalibrationFaces'
        Task                     = 'CalibrationFaces';
        SessionNumber            = str2double( get(handles.edit_SessionNumber,'String') );
        DataStruct.SessionNumber = SessionNumber;
        
    otherwise
        error('SMACC:TaskSelection','Error in Task selection')
end

DataStruct.Task = Task;


%% Environement selection

% switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
%     case 'radiobutton_MRI'
%         Environement = 'MRI';
%     case 'radiobutton_Training'
%         Environement = 'Training';
%     case 'radiobutton_EEG'
%         Environement = 'EEG';
%     otherwise
%         warning('SMACC:ModeSelection','Error in Environement selection')
% end
%
% DataStruct.Environement = Environement;


%% Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('SMACC:SaveSelection','Error in SaveMode selection')
end

DataStruct.SaveMode = SaveMode;


%% Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('SMACC:ModeSelection','Error in Mode selection')
end

DataStruct.OperationMode = OperationMode;


%% Record video ?

% switch get(get(handles.uipanel_RecordVideo,'SelectedObject'),'Tag')
%     case 'radiobutton_RecordOn'
%         RecordVideo          = 'On';
%         VideoName            = [ get(handles.edit_RecordName,'String') '.mov'];
%         DataStruct.VideoName = VideoName;
%     case 'radiobutton_RecordOff'
RecordVideo          = 'Off';
%     otherwise
%         warning('SMACC:RecordVideo','Error in Record Video')
% end

DataStruct.RecordVideo = RecordVideo;


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('SMACC:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];
DataPathNoRun = sprintf('%s_%s_S%d_', SubjectID, Task, SessionNumber);

% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent),1);
for f = 1 : length(dirContent)
    split = regexp(dirContent(f).name,DataPathNoRun,'split');
    if length(split) == 2 && str2double(split{2}(1)) % yes there is a file
        previousRun(f) = str2double(split{2}(1)); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end

RunNumber = num2str(LastRunNumber + 1);

DataFile = sprintf('%s%s_%s_%s_S%d_%s', DataPath, DataStruct.TimeStampFile, SubjectID, Task, SessionNumber, RunNumber );

DataStruct.SubjectID = SubjectID;
DataStruct.RunNumber = RunNumber;
DataStruct.DataPath  = DataPath;
DataStruct.DataFile  = DataFile;


%% Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('SMACC:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('SMACC:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% Fetch the RT

RTlist = {'XO' 'Positive' 'Negative'};

for l = 1:length(RTlist)
    DataStruct.RT.(RTlist{l}) = str2double( get(handles.(['edit_' RTlist{l}]),'String') );
    if strcmp(Task,'MRI') || strcmp(Task,'EEG')
        if isnan(DataStruct.RT.(RTlist{l}))
            error('SMACC:RTempty','%s RT is required',RTlist{l})
        end
    end
end

if strcmp(Task,'Training')
    sumRT = sum(isnan(struct2array(DataStruct.RT)));
    if ~( sumRT == 0 || sumRT == 3 )
        error('SMACC:RTemptyTraining','For training, no RT or all RT')
    end
end


%% Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
        
    case 0
        ParPort = 'Off';
end

handles.ParPort    = ParPort;
DataStruct.ParPort = ParPort;


%% Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('SMACC:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(DataStruct.SaveMode,'NoSave')
            error('SMACC:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        % File name for the eyelink : 8 char maximum
        %         switch Task
        %             case 'EyelinkCalibration'
        %                 task = 'EC';
        %             case 'Session'
        %                 task = ['S' get(handles.edit_IlluBlock,'String')];
        %             otherwise
        %                 error('SMACC:Task','Task ?')
        %         end
        %         EyelinkFile = [ SubjectID task sprintf('%.2d',str2double(RunNumber)) ];
        
        DataStruct.EyelinkFile = EyelinkFile;
        
    otherwise
        
        warning('SMACC:EyelinkMode','Error in Eyelink mode')
        
end

DataStruct.EyelinkMode = EyelinkMode;


%% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% Get stimulation parameters

DataStruct.Parameters = GetParameters( DataStruct );

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
DataStruct.Parameters.Video.ScreenMode = str2double( AvalableDisplays(SelectedDisplay) );


%% Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('SMACC:WindowedScreen','Error in WindowedScreen')
        
end

DataStruct.WindowedMode = WindowedMode;


%% Open PTB window & sound

DataStruct.PTB = StartPTB( DataStruct );


%% Task run

switch Task
    case 'EyelinkCalibration'
        Eyelink.Calibration( DataStruct.PTB.wPtr );
        TaskData.ER.Data = {};
        TaskData.IsEyelinkRreadyToRecord = 1;
    otherwise
        TaskData = GoNogo.Task( DataStruct ); % all 'Task' converge to one pipeline
end

DataStruct.TaskData = TaskData;


%% Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastDataStruct'],'DataStruct');


%% Close PTB

% Just to be sure that if there is a problem with PTB, we do not loose all
% the data drue to a crash.
try
    
    Screen('CloseAll'); % Close PTB window
    ShowCursor;
    Priority( DataStruct.PTB.oldLevel );
    
catch err
    
end


%% SPM data organization

[ names , onsets , durations ] = SPMnod( DataStruct ); %#ok<*NASGU,*ASGLU>


%% Reaction time & stats

[ DataStruct.Stats, DataStruct.newTable, DataStruct.newTable_hdr ] = Stats.table2stats(DataStruct);


%% Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile, 'DataStruct', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
    % BrainVoyager data organization
    % spm2bv( names , onsets , durations , DataStruct.DataFile )
    
end


%% Send DataStruct and SPM nod to workspace

assignin('base', 'DataStruct', DataStruct);
assignin('base', 'names', names);
assignin('base', 'onsets', onsets);
assignin('base', 'durations', durations);


%% End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(DataStruct.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( DataStruct.EyelinkFile , DataStruct.DataPath )
    
    if ~strcmp(DataStruct.Task,'EyelinkCalibration')
        
        % Rename the file
        movefile([DataStruct.DataPath filesep EyelinkFile '.edf'], [DataStruct.DataFile '.edf'])
        
    end
    
end


%% Diagnotic

switch DataStruct.OperationMode
    case 'Acquisition'
        
    case 'FastDebug'
        plotDelay
        plotSPMnod
        
    case 'RealisticDebug'
        plotDelay
        plotSPMnod
        
end


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on')
set(handles.text_LastFileName,'Visible','on')
set(handles.text_LastFileName,'String',DataFile(length(DataPath)+1:end))

WaitSecs(0.100);
fprintf('\n')
fprintf('------------------------- \n')
fprintf('Ready for another session \n')
fprintf('------------------------- \n')


end % function

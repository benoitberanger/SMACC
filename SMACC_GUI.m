function varargout = SMACC_GUI
% Run this function start a GUI that will handle the whole stimulation
% process and parameters

% global handles

%% Open a singleton figure

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if isempty(figPtr) % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Normalized'             , ...
        'Position'        , [0.05, 0.05, 0.50, 0.90] , ...
        'Tag'             , mfilename                );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles = guihandles(figHandle);
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.05; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.vect  = ...
        [1 2 1.5 1 1.5 2]; % relative proportions of each panel, from bottom to top
    
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.adjustedTotal = panelProp.vectTotal + 1;
    panelProp.unitWidth     = 1/panelProp.adjustedTotal;
    panelProp.interWidth    = panelProp.unitWidth/panelProp.vectLength;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + 1*countP*panelProp.interWidth;
    
    
    %% Panel : Subject & Run
    
    p_sr.x = panelProp.xposP;
    p_sr.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sr.y = panelProp.yposP(panelProp.countP);
    p_sr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SubjectRun = uipanel(handles.(mfilename),...
        'Title','Subject & Run',...
        'Units', 'Normalized',...
        'Position',[p_sr.x p_sr.y p_sr.w p_sr.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sr.nbO       = 3; % Number of objects
    p_sr.Ow        = 1/(p_sr.nbO + 1); % Object width
    p_sr.countO    = 0; % Object counter
    p_sr.xposO     = @(countO) p_sr.Ow/(p_sr.nbO+1)*countO + (countO-1)*p_sr.Ow;
    p_sr.yposOmain = 0.1;
    p_sr.hOmain    = 0.6;
    p_sr.yposOhdr  = 0.7;
    p_sr.hOhdr     = 0.2;
    
    
    % ---------------------------------------------------------------------
    % Edit : Subject ID
    
    p_sr.countO = p_sr.countO + 1;
    e_sid.x = p_sr.xposO(p_sr.countO);
    e_sid.y = p_sr.yposOmain ;
    e_sid.w = p_sr.Ow;
    e_sid.h = p_sr.hOmain;
    handles.edit_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_sid.x e_sid.y e_sid.w e_sid.h],...
        'BackgroundColor',editBGcolor,...
        'String','');
    
    
    % ---------------------------------------------------------------------
    % Text : Subject ID
    
    t_sid.x = p_sr.xposO(p_sr.countO);
    t_sid.y = p_sr.yposOhdr ;
    t_sid.w = p_sr.Ow;
    t_sid.h = p_sr.hOhdr;
    handles.text_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sid.x t_sid.y t_sid.w t_sid.h],...
        'String','Subject ID',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Check SubjectID data
    
    p_sr.countO = p_sr.countO + 1;
    b_csidd.x = p_sr.xposO(p_sr.countO);
    b_csidd.y = p_sr.yposOmain+p_sr.hOmain/2;
    b_csidd.w = p_sr.Ow;
    b_csidd.h = p_sr.hOmain/2;
    handles.pushbutton_Check_SubjectID_data = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_csidd.x b_csidd.y b_csidd.w b_csidd.h],...
        'String','Check SubjectID data',...
        'BackgroundColor',buttonBGcolor,...
        'TooltipString','Display in Command Window the content of data/(SubjectID)',...
        'Callback',@(hObject,eventdata)GUI.Pushbutton_Check_SubjectID_data_Callback(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Stats
    
    b_stats.x = p_sr.xposO(p_sr.countO);
    b_stats.y = p_sr.yposOmain;
    b_stats.w = p_sr.Ow;
    b_stats.h = p_sr.hOmain/2;
    handles.pushbutton_SubjectStats = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_stats.x b_stats.y b_stats.w b_stats.h],...
        'String','Subject stats',...
        'BackgroundColor',buttonBGcolor,...
        'Callback',@(hObject,eventdata)Stats.SubjectStats(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : RT
    
    b_rt.x = p_sr.xposO(p_sr.countO);
    b_rt.y = p_sr.yposOhdr;
    b_rt.w = p_sr.Ow;
    b_rt.h = p_sr.hOmain/2;
    handles.pushbutton_RT = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_rt.x b_rt.y b_rt.w b_rt.h],...
        'String','Subject RT',...
        'BackgroundColor',buttonBGcolor,...
        'Callback',@(hObject,eventdata)Stats.SubjectRT(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name annoucer
    
    p_sr.countO = p_sr.countO + 1;
    t_lfna.x = p_sr.xposO(p_sr.countO);
    t_lfna.y = p_sr.yposOhdr ;
    t_lfna.w = p_sr.Ow;
    t_lfna.h = p_sr.hOhdr;
    handles.text_LastFileNameAnnouncer = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfna.x t_lfna.y t_lfna.w t_lfna.h],...
        'String','Last file name',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name
    
    t_lfn.x = p_sr.xposO(p_sr.countO);
    t_lfn.y = p_sr.yposOmain ;
    t_lfn.w = p_sr.Ow;
    t_lfn.h = p_sr.hOmain;
    handles.text_LastFileName = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfn.x t_lfn.y t_lfn.w t_lfn.h],...
        'String','',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    %% Panel : RT
    
    p_rt.x = panelProp.xposP;
    p_rt.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_rt.y = panelProp.yposP(panelProp.countP);
    p_rt.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_RT = uibuttongroup(handles.(mfilename),...
        'Title','RT',...
        'Units', 'Normalized',...
        'Position',[p_rt.x p_rt.y p_rt.w p_rt.h],...
        'BackgroundColor',figureBGcolor);
    
    p_rt.nbO    = 3; % Number of objects
    p_rt.Ow     = 1/(p_rt.nbO + 1); % Object width
    p_rt.countO = 0; % Object counter
    p_rt.xposO  = @(countO) p_rt.Ow/(p_rt.nbO+1)*countO + (countO-1)*p_rt.Ow;
    
    p_rt.yposOmain = 0.1;
    p_rt.hOmain    = 0.7;
    p_rt.yposOhdr  = 0.8;
    p_rt.hOhdr     = 0.2;
    
    
    % ---------------------------------------------------------------------
    % Edit : XO
    
    p_rt.countO = p_rt.countO + 1;
    e_xo.x = p_rt.xposO(p_rt.countO);
    e_xo.y = p_rt.yposOmain ;
    e_xo.w = p_rt.Ow;
    e_xo.h = p_rt.hOmain;
    handles.edit_XO = uicontrol(handles.uipanel_RT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_xo.x e_xo.y e_xo.w e_xo.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Tag','RT XO',...
        'Callback',@edit_RT_Callback);
    
    
    % ---------------------------------------------------------------------
    % Text : XO
    
    t_xo.x = p_rt.xposO(p_rt.countO);
    t_xo.y = p_rt.yposOhdr ;
    t_xo.w = p_rt.Ow;
    t_xo.h = p_rt.hOhdr;
    handles.text_XO = uicontrol(handles.uipanel_RT,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_xo.x t_xo.y t_xo.w t_xo.h],...
        'String','XO',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Edit : Positive
    
    p_rt.countO = p_rt.countO + 1;
    e_pos.x = p_rt.xposO(p_rt.countO);
    e_pos.y = p_rt.yposOmain ;
    e_pos.w = p_rt.Ow;
    e_pos.h = p_rt.hOmain;
    handles.edit_Positive = uicontrol(handles.uipanel_RT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_pos.x e_pos.y e_pos.w e_pos.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Tag','RT +++',...
        'Callback',@edit_RT_Callback);
    
    
    % ---------------------------------------------------------------------
    % Text : Positive
    
    t_pos.x = p_rt.xposO(p_rt.countO);
    t_pos.y = p_rt.yposOhdr ;
    t_pos.w = p_rt.Ow;
    t_pos.h = p_rt.hOhdr;
    handles.text_Positive = uicontrol(handles.uipanel_RT,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_pos.x t_pos.y t_pos.w t_pos.h],...
        'String','+++',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Edit : Negative
    
    p_rt.countO = p_rt.countO + 1;
    e_neg.x = p_rt.xposO(p_rt.countO);
    e_neg.y = p_rt.yposOmain ;
    e_neg.w = p_rt.Ow;
    e_neg.h = p_rt.hOmain;
    handles.edit_Negative = uicontrol(handles.uipanel_RT,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_neg.x e_neg.y e_neg.w e_neg.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Tag','RT ---',...
        'Callback',@edit_RT_Callback);
    
    
    % ---------------------------------------------------------------------
    % Text : Negative
    
    t_neg.x = p_rt.xposO(p_rt.countO);
    t_neg.y = p_rt.yposOhdr ;
    t_neg.w = p_rt.Ow;
    t_neg.h = p_rt.hOhdr;
    handles.text_Negative = uicontrol(handles.uipanel_RT,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_neg.x t_neg.y t_neg.w t_neg.h],...
        'String','---',...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Save mode
    
    p_sm.x = panelProp.xposP;
    p_sm.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sm.y = panelProp.yposP(panelProp.countP);
    p_sm.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SaveMode = uibuttongroup(handles.(mfilename),...
        'Title','Save mode',...
        'Units', 'Normalized',...
        'Position',[p_sm.x p_sm.y p_sm.w p_sm.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sm.nbO    = 2; % Number of objects
    p_sm.Ow     = 1/(p_sm.nbO + 1); % Object width
    p_sm.countO = 0; % Object counter
    p_sm.xposO  = @(countO) p_sm.Ow/(p_sm.nbO+1)*countO + (countO-1)*p_sm.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Save Data
    
    p_sm.countO = p_sm.countO + 1;
    r_sd.x   = p_sm.xposO(p_sm.countO);
    r_sd.y   = 0.1 ;
    r_sd.w   = p_sm.Ow;
    r_sd.h   = 0.8;
    r_sd.tag = 'radiobutton_SaveData';
    handles.(r_sd.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_sd.x r_sd.y r_sd.w r_sd.h],...
        'String','Save data',...
        'TooltipString','Save data to : /data/SubjectID/SubjectID_Task_RunNumber',...
        'HorizontalAlignment','Center',...
        'Tag',r_sd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : No save
    
    p_sm.countO = p_sm.countO + 1;
    r_ns.x   = p_sm.xposO(p_sm.countO);
    r_ns.y   = 0.1 ;
    r_ns.w   = p_sm.Ow;
    r_ns.h   = 0.8;
    r_ns.tag = 'radiobutton_NoSave';
    handles.(r_ns.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_ns.x r_ns.y r_ns.w r_ns.h],...
        'String','No save',...
        'TooltipString','In Acquisition mode, Save mode must be engaged',...
        'HorizontalAlignment','Center',...
        'Tag',r_ns.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Environement
    
    %     p_env.x = panelProp.xposP;
    %     p_env.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_env.y = panelProp.yposP(panelProp.countP);
    %     p_env.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_Environement = uibuttongroup(handles.(mfilename),...
    %         'Title','Environement',...
    %         'Units', 'Normalized',...
    %         'Position',[p_env.x p_env.y p_env.w p_env.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_env.nbO    = 3; % Number of objects
    %     p_env.Ow     = 1/(p_env.nbO + 1); % Object width
    %     p_env.countO = 0; % Object counter
    %     p_env.xposO  = @(countO) p_env.Ow/(p_env.nbO+1)*countO + (countO-1)*p_env.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Training
    %
    %     p_env.countO = p_env.countO + 1;
    %     r_tain.x   = p_env.xposO(p_env.countO);
    %     r_tain.y   = 0.1 ;
    %     r_tain.w   = p_env.Ow;
    %     r_tain.h   = 0.8;
    %     r_tain.tag = 'radiobutton_Training';
    %     handles.(r_tain.tag) = uicontrol(handles.uipanel_Environement,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_tain.x r_tain.y r_tain.w r_tain.h],...
    %         'String','Training',...
    %         'TooltipString','Training',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',(r_tain.tag),...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : EEG
    %
    %     p_env.countO = p_env.countO + 1;
    %     r_eeg.x   = p_env.xposO(p_env.countO);
    %     r_eeg.y   = 0.1 ;
    %     r_eeg.w   = p_env.Ow;
    %     r_eeg.h   = 0.8;
    %     r_eeg.tag = 'radiobutton_EEG';
    %     handles.(r_eeg.tag) = uicontrol(handles.uipanel_Environement,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_eeg.x r_eeg.y r_eeg.w r_eeg.h],...
    %         'String','EEG',...
    %         'TooltipString','EEG task',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',(r_eeg.tag),...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : MRI
    %
    %     p_env.countO = p_env.countO + 1;
    %     r_mri.x   = p_env.xposO(p_env.countO);
    %     r_mri.y   = 0.1 ;
    %     r_mri.w   = p_env.Ow;
    %     r_mri.h   = 0.8;
    %     r_mri.tag = 'radiobutton_MRI';
    %     handles.(r_mri.tag) = uicontrol(handles.uipanel_Environement,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_mri.x r_mri.y r_mri.w r_mri.h],...
    %         'String','MRI',...
    %         'TooltipString','fMRI task',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',(r_mri.tag),...
    %         'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Eyelink mode
    
    el_shift = 0.30;
    
    p_el.x = panelProp.xposP + el_shift;
    p_el.w = panelProp.wP - el_shift ;
    
    panelProp.countP = panelProp.countP - 1;
    p_el.y = panelProp.yposP(panelProp.countP);
    p_el.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_EyelinkMode = uibuttongroup(handles.(mfilename),...
        'Title','Eyelink mode',...
        'Units', 'Normalized',...
        'Position',[p_el.x p_el.y p_el.w p_el.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Windowed screen
    
    c_ws.x = panelProp.xposP;
    c_ws.w = el_shift - panelProp.xposP;
    
    c_ws.y = panelProp.yposP(panelProp.countP)-0.01 ;
    c_ws.h = p_el.h * 0.3;
    
    handles.checkbox_WindowedScreen = uicontrol(handles.(mfilename),...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_ws.x c_ws.y c_ws.w c_ws.h],...
        'String','Windowed screen',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Listbox : Screens
    
    l_sc.x = panelProp.xposP;
    l_sc.w = el_shift - panelProp.xposP;
    
    l_sc.y = c_ws.y + c_ws.h ;
    l_sc.h = p_el.h * 0.6;
    
    handles.listbox_Screens = uicontrol(handles.(mfilename),...
        'Style','listbox',...
        'Units', 'Normalized',...
        'Position',[l_sc.x l_sc.y l_sc.w l_sc.h],...
        'String',{'a' 'b' 'c'},...
        'TooltipString','Select the display mode   PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.',...
        'HorizontalAlignment','Center',...
        'CreateFcn',@GUI.Listbox_Screens_CreateFcn);
    
    
    % ---------------------------------------------------------------------
    % Text : ScreenMode
    
    t_sm.x = panelProp.xposP;
    t_sm.w = el_shift - panelProp.xposP;
    
    t_sm.y = l_sc.y + l_sc.h ;
    t_sm.h = p_el.h * 0.15;
    
    handles.text_ScreenMode = uicontrol(handles.(mfilename),...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sm.x t_sm.y t_sm.w t_sm.h],...
        'String','Screen mode selection',...
        'TooltipString','Output of Screen(''Screens'')   Use ''Screen Screens?'' in Command window for help',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_up.nbO    = 6; % Number of objects
    p_el_up.Ow     = 1/(p_el_up.nbO + 1); % Object width
    p_el_up.countO = 0; % Object counter
    p_el_up.xposO  = @(countO) p_el_up.Ow/(p_el_up.nbO+1)*countO + (countO-1)*p_el_up.Ow;
    p_el_up.y      = 0.6;
    p_el_up.h      = 0.3;
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink ON
    
    p_el_up.countO = p_el_up.countO + 1;
    r_elon.x   = p_el_up.xposO(p_el_up.countO);
    r_elon.y   = p_el_up.y ;
    r_elon.w   = p_el_up.Ow;
    r_elon.h   = p_el_up.h;
    r_elon.tag = 'radiobutton_EyelinkOn';
    handles.(r_elon.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_elon.x r_elon.y r_elon.w r_elon.h],...
        'String','On',...
        'HorizontalAlignment','Center',...
        'Tag',r_elon.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink OFF
    
    p_el_up.countO = p_el_up.countO + 1;
    r_eloff.x   = p_el_up.xposO(p_el_up.countO);
    r_eloff.y   = p_el_up.y ;
    r_eloff.w   = p_el_up.Ow;
    r_eloff.h   = p_el_up.h;
    r_eloff.tag = 'radiobutton_EyelinkOff';
    handles.(r_eloff.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_eloff.x r_eloff.y r_eloff.w r_eloff.h],...
        'String','Off',...
        'HorizontalAlignment','Center',...
        'Tag',r_eloff.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Parallel port
    
    p_el_up.countO = p_el_up.countO + 1;
    c_pp.x = p_el_up.xposO(p_el_up.countO);
    c_pp.y = p_el_up.y ;
    c_pp.w = p_el_up.Ow*2;
    c_pp.h = p_el_up.h;
    handles.checkbox_ParPort = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
        'String','Parallel port',...
        'HorizontalAlignment','Center',...
        'TooltipString','Send messages via parallel port : useful for Eyelink',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Callback',@GUI.Checkbox_ParPort_Callback,...
        'CreateFcn',@GUI.Checkbox_ParPort_Callback);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_dw.nbO    = 3; % Number of objects
    p_el_dw.Ow     = 1/(p_el_dw.nbO + 1); % Object width
    p_el_dw.countO = 0; % Object counter
    p_el_dw.xposO  = @(countO) p_el_dw.Ow/(p_el_dw.nbO+1)*countO + (countO-1)*p_el_dw.Ow;
    p_el_dw.y      = 0.1;
    p_el_dw.h      = 0.4 ;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_init.x = p_el_dw.xposO(p_el_dw.countO);
    b_init.y = p_el_dw.y ;
    b_init.w = p_el_dw.Ow;
    b_init.h = p_el_dw.h;
    handles.pushbutton_Initialize = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_init.x b_init.y b_init.w b_init.h],...
        'String','Initialize',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.Initialize');
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink IsConnected
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_isco.x = p_el_dw.xposO(p_el_dw.countO);
    b_isco.y = p_el_dw.y ;
    b_isco.w = p_el_dw.Ow;
    b_isco.h = p_el_dw.h;
    handles.pushbutton_IsConnected = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_isco.x b_isco.y b_isco.w b_isco.h],...
        'String','IsConnected',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.IsConnected');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Calibration
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_cal.x   = p_el_dw.xposO(p_el_dw.countO);
    b_cal.y   = p_el_dw.y ;
    b_cal.w   = p_el_dw.Ow;
    b_cal.h   = p_el_dw.h;
    b_cal.tag = 'pushbutton_EyelinkCalibration';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Calibration',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_cal.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink force shutdown
    
    b_fsd.x = c_pp.x + c_pp.h;
    b_fsd.y = p_el_up.y ;
    b_fsd.w = p_el_dw.Ow*1.25;
    b_fsd.h = p_el_dw.h;
    handles.pushbutton_ForceShutDown = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_fsd.x b_fsd.y b_fsd.w b_fsd.h],...
        'String','ForceShutDown',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.ForceShutDown');
    
    
    %% Panel : Task
    
    p_tk.x = panelProp.xposP;
    p_tk.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_tk.y = panelProp.yposP(panelProp.countP);
    p_tk.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Task = uibuttongroup(handles.(mfilename),...
        'Title','Task',...
        'Units', 'Normalized',...
        'Position',[p_tk.x p_tk.y p_tk.w p_tk.h],...
        'BackgroundColor',figureBGcolor);
    
    p_tk.H.nbO    = 3; % Number of objects
    p_tk.H.Ow     = 1/(p_tk.H.nbO + 1); % Object width
    p_tk.H.countO = 0; % Object counter
    p_tk.H.xposO  = @(countO) p_tk.H.Ow/(p_tk.H.nbO+1)*countO + (countO-1)*p_tk.H.Ow;
    
    p_tk.V.nbO    = 2; % Number of objects
    p_tk.V.Ow     = 1/(p_tk.V.nbO + 1); % Object width
    p_tk.V.countO = 0; % Object counter
    p_tk.V.xposO  = @(countO) p_tk.V.Ow/(p_tk.V.nbO+1)*countO + (countO-1)*p_tk.V.Ow;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : MRI
    
    p_tk.H.countO = p_tk.H.countO + 1;
    p_tk.V.countO = p_tk.V.countO + 1;
    b_mri.x = p_tk.H.xposO(p_tk.H.countO);
    b_mri.y = p_tk.V.xposO(p_tk.V.countO);
    b_mri.w = p_tk.H.Ow;
    b_mri.h = p_tk.V.Ow;
    b_mri.tag = 'pushbutton_MRI';
    handles.(b_mri.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_mri.x b_mri.y b_mri.w b_mri.h],...
        'String','MRI',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_mri.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : EEG
    
    p_tk.H.countO = p_tk.H.countO + 1;
    b_eeg.x = p_tk.H.xposO(p_tk.H.countO);
    b_eeg.y = p_tk.V.xposO(p_tk.V.countO);
    b_eeg.w = p_tk.H.Ow;
    b_eeg.h = p_tk.V.Ow;
    b_eeg.tag = 'pushbutton_EEG';
    handles.(b_eeg.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_eeg.x b_eeg.y b_eeg.w b_eeg.h],...
        'String','EEG',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_eeg.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Edit : SessionNumber
    
    p_tk.H.countO = p_tk.H.countO + 1;
    e_sess.x = p_tk.H.xposO(p_tk.H.countO);
    e_sess.y = p_tk.V.xposO(p_tk.V.countO);
    e_sess.w = p_tk.H.Ow;
    e_sess.h = p_tk.V.Ow;
    e_sess.tag = 'edit_SessionNumber';
    handles.(e_sess.tag) = uicontrol(handles.uipanel_Task,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_sess.x e_sess.y e_sess.w e_sess.h],...
        'String','1',...
        'Tag',e_sess.tag,...
        'BackgroundColor',editBGcolor,...
        'Callback',@edit_SessionNumber_Callback);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Training
    
    p_tk.H.countO = 0;
    p_tk.H.countO = p_tk.H.countO + 1;
    p_tk.V.countO = p_tk.V.countO + 1;
    b_train.x = p_tk.H.xposO(p_tk.H.countO);
    b_train.y = p_tk.V.xposO(p_tk.V.countO);
    b_train.w = p_tk.H.Ow;
    b_train.h = p_tk.V.Ow;
    b_train.tag = 'pushbutton_Training';
    handles.(b_train.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_train.x b_train.y b_train.w b_train.h],...
        'String','Training',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_train.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Calibration Cross Circle
    
    p_tk.H.countO = p_tk.H.countO + 1;
    b_calCC.x = p_tk.H.xposO(p_tk.H.countO);
    b_calCC.y = p_tk.V.xposO(p_tk.V.countO);
    b_calCC.w = p_tk.H.Ow;
    b_calCC.h = p_tk.V.Ow;
    b_calCC.tag = 'pushbutton_CalibrationXO';
    handles.(b_calCC.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_calCC.x b_calCC.y b_calCC.w b_calCC.h],...
        'String','Calibration XO',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_calCC.tag,...
        'Callback',@SMACC_main);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Calibration Faces
    
    p_tk.H.countO = p_tk.H.countO + 1;
    b_calFpos.x = p_tk.H.xposO(p_tk.H.countO);
    b_calFpos.y = p_tk.V.xposO(p_tk.V.countO);
    b_calFpos.w = p_tk.H.Ow;
    b_calFpos.h = p_tk.V.Ow;
    b_calFpos.tag = 'pushbutton_CalibrationFaces';
    handles.(b_calFpos.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_calFpos.x b_calFpos.y b_calFpos.w b_calFpos.h],...
        'String','Calibration Faces',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_calFpos.tag,...
        'Callback',@SMACC_main);
    
    
    %% Panel : Record video
    
    %     p_rv.x = panelProp.xposP;
    %     p_rv.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_rv.y = panelProp.yposP(panelProp.countP);
    %     p_rv.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_RecordVideo = uibuttongroup(handles.(mfilename),...
    %         'Title','Record mode',...
    %         'Units', 'Normalized',...
    %         'Position',[p_rv.x p_rv.y p_rv.w p_rv.h],...
    %         'BackgroundColor',figureBGcolor,...
    %         'SelectionChangeFcn',@uipanel_RecordVideo_SelectionChangeFcn,...
    %         'Visible','Off');
    %
    %     p_rv.nbO    = 3; % Number of objects
    %     p_rv.Ow     = 1/(p_rv.nbO + 1); % Object width
    %     p_rv.countO = 0; % Object counter
    %     p_rv.xposO  = @(countO) p_rv.Ow/(p_rv.nbO+1)*countO + (countO-1)*p_rv.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Record video OFF
    %
    %     p_rv.countO = p_rv.countO + 1;
    %     r_rvoff.x   = p_rv.xposO(p_rv.countO);
    %     r_rvoff.y   = 0.1 ;
    %     r_rvoff.w   = p_rv.Ow;
    %     r_rvoff.h   = 0.8;
    %     r_rvoff.tag = 'radiobutton_RecordOff';
    %     handles.(r_rvoff.tag) = uicontrol(handles.uipanel_RecordVideo,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_rvoff.x r_rvoff.y r_rvoff.w r_rvoff.h],...
    %         'String','Off',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_rvoff.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Record video ON
    %
    %     p_rv.countO = p_rv.countO + 1;
    %     r_rvon.x   = p_rv.xposO(p_rv.countO);
    %     r_rvon.y   = 0.1 ;
    %     r_rvon.w   = p_rv.Ow;
    %     r_rvon.h   = 0.8;
    %     r_rvon.tag = 'radiobutton_RecordOn';
    %     handles.(r_rvon.tag) = uicontrol(handles.uipanel_RecordVideo,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_rvon.x r_rvon.y r_rvon.w r_rvon.h],...
    %         'String','On',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_rvon.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Text : File name
    %
    %     t_fn.x = p_rv.xposO(p_rv.countO) + p_rv.Ow/2;
    %     t_fn.y = 0.2 ;
    %     t_fn.w = p_rv.Ow;
    %     t_fn.h = 0.4;
    %     handles.text_RecordName = uicontrol(handles.uipanel_RecordVideo,...
    %         'Style','text',...
    %         'Units', 'Normalized',...
    %         'Position',[t_fn.x t_fn.y t_fn.w t_fn.h],...
    %         'String','File name : ',...
    %         'HorizontalAlignment','Center',...
    %         'Visible','Off',...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Edit : File name
    %
    %     p_rv.countO = p_rv.countO + 1;
    %     e_fn.x = p_rv.xposO(p_rv.countO);
    %     e_fn.y = 0.1 ;
    %     e_fn.w = p_rv.Ow;
    %     e_fn.h = 0.8;
    %     handles.edit_RecordName = uicontrol(handles.uipanel_RecordVideo,...
    %         'Style','edit',...
    %         'Units', 'Normalized',...
    %         'Position',[e_fn.x e_fn.y e_fn.w e_fn.h],...
    %         'String','',...
    %         'Visible','Off',...
    %         'BackgroundColor',editBGcolor,...
    %         'HorizontalAlignment','Center');
    
    
    %% Panel : Operation mode
    
    p_op.x = panelProp.xposP;
    p_op.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_op.y = panelProp.yposP(panelProp.countP);
    p_op.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_OperationMode = uibuttongroup(handles.(mfilename),...
        'Title','Operation mode',...
        'Units', 'Normalized',...
        'Position',[p_op.x p_op.y p_op.w p_op.h],...
        'BackgroundColor',figureBGcolor);
    
    p_op.nbO    = 3; % Number of objects
    p_op.Ow     = 1/(p_op.nbO + 1); % Object width
    p_op.countO = 0; % Object counter
    p_op.xposO  = @(countO) p_op.Ow/(p_op.nbO+1)*countO + (countO-1)*p_op.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Acquisition
    
    p_op.countO = p_op.countO + 1;
    r_aq.x = p_op.xposO(p_op.countO);
    r_aq.y = 0.1 ;
    r_aq.w = p_op.Ow;
    r_aq.h = 0.8;
    r_aq.tag = 'radiobutton_Acquisition';
    handles.(r_aq.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_aq.x r_aq.y r_aq.w r_aq.h],...
        'String','Acquisition',...
        'TooltipString','Should be used for all the environements',...
        'HorizontalAlignment','Center',...
        'Tag',r_aq.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : FastDebug
    
    p_op.countO = p_op.countO + 1;
    r_fd.x   = p_op.xposO(p_op.countO);
    r_fd.y   = 0.1 ;
    r_fd.w   = p_op.Ow;
    r_fd.h   = 0.8;
    r_fd.tag = 'radiobutton_FastDebug';
    handles.radiobutton_FastDebug = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_fd.x r_fd.y r_fd.w r_fd.h],...
        'String','FastDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_fd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : RealisticDebug
    
    p_op.countO = p_op.countO + 1;
    r_rd.x   = p_op.xposO(p_op.countO);
    r_rd.y   = 0.1 ;
    r_rd.w   = p_op.Ow;
    r_rd.h   = 0.8;
    r_rd.tag = 'radiobutton_RealisticDebug';
    handles.(r_rd.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_rd.x r_rd.y r_rd.w r_rd.h],...
        'String','RealisticDebug',...
        'TooltipString','Only to work on the scripts',...
        'HorizontalAlignment','Center',...
        'Tag',r_rd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    % assignin('base','handles',handles)
    % disp(handles)
    
    figPtr = figHandle;
    
    
    %% Default values
    
    % Eyelink Off
    set(handles.uipanel_EyelinkMode,'SelectedObject',handles.radiobutton_EyelinkOff);
    oldsel = get(handles.uipanel_EyelinkMode,'SelectedObject');
    newsel = handles.radiobutton_EyelinkOff;
    fakevent = struct('EventName', 'SelectionChanged', 'OldValue', oldsel, 'NewValue', newsel);
    uipanel_EyelinkMode_SelectionChangeFcn(figHandle,fakevent)
    
    
    %% Button response recall
    
    fprintf('\n')
    fprintf('Response buttuns (fORRP 932) : \n')
    fprintf('USB \n')
    fprintf('HHSC - 1x2 - CYL \n')
    fprintf('HID NAR BYGRT \n')
    fprintf('\n')
    fprintf('==> BLUE button in the RIGHT hand <==\n')
    fprintf('\n')
    
else % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %     close(figPtr);
    %     SMACC_GUI;
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% % -------------------------------------------------------------------------
% function uipanel_RecordVideo_SelectionChangeFcn(hObject, eventdata)
% handles = guidata(hObject);
%
% switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
%     case 'radiobutton_RecordOn'
%         set(handles.text_RecordName,'Visible','On')
%         set(handles.edit_RecordName,'Visible','On')
%     case 'radiobutton_RecordOff'
%         set(handles.text_RecordName,'Visible','off')
%         set(handles.edit_RecordName,'Visible','off')
% end
%
% end % function


% -------------------------------------------------------------------------
function edit_SessionNumber_Callback(hObject, ~)

block = str2double(get(hObject,'String'));

if block ~= round(block) || block < 1
    set(hObject,'String','1');
    error('Session number must be positive integer')
end

end % function


% -------------------------------------------------------------------------
function edit_RT_Callback(hObject, ~)

RT = str2double(get(hObject,'String'));

if ~(RT <= 1 && RT > 0)
    set(hObject,'String','');
    error('%s must be between 0 and 1',get(hObject,'Tag'))
end

end % function


% -------------------------------------------------------------------------
function uipanel_EyelinkMode_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_EyelinkOff'
        set(handles.pushbutton_EyelinkCalibration,'Visible','off')
        set(handles.pushbutton_IsConnected       ,'Visible','off')
        set(handles.pushbutton_ForceShutDown     ,'Visible','off')
        set(handles.pushbutton_Initialize        ,'Visible','off')
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
        set(handles.pushbutton_IsConnected       ,'Visible','on')
        set(handles.pushbutton_ForceShutDown     ,'Visible','on')
        set(handles.pushbutton_Initialize        ,'Visible','on')
end

end % function

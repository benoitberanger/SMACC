function [ TaskData ] = Task( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Load and prepare all stimuli
    
    GoNogo.LoadStimuli;
    TaskData.Stimuli = Stimuli;
    
    %% Tunning of the task
    
    [ EP , nGo , nNoGo , Paradigm , Instructions , Timings , firstGO ] = GoNogo.Planning( DataStruct , Stimuli ); %#ok<*ASGLU>
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP           = EP;
    TaskData.nGo          = nGo;
    TaskData.nNoGo        = nNoGo;
    TaskData.Paradigm     = Paradigm;
    TaskData.Instructions = Instructions;
    TaskData.Timings      = Timings;
    TaskData.firstGO      = firstGO;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Record movie
    
    Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
    %% RT inputs
    
    switch DataStruct.Task
        case 'MRI'
            RTinputs    = 1;
            RT_XO       = DataStruct.RT.XO;
            RT_Positive = DataStruct.RT.Positive;
            RT_Negative = DataStruct.RT.Negative;
            
        case 'EEG'
            RTinputs    = 1;
            RT_XO       = DataStruct.RT.XO;
            RT_Positive = DataStruct.RT.Positive;
            RT_Negative = DataStruct.RT.Negative;
            
        case 'Training'
            
            sumRT = sum(isnan(struct2array(DataStruct.RT)));
            
            if sumRT == 0
                RTinputs    = 1;
                RT_XO       = DataStruct.RT.XO;
                RT_Positive = DataStruct.RT.Positive;
                RT_Negative = DataStruct.RT.Negative;
                
            elseif sumRT == 3
                RTinputs = 0;
                
            else
                error('SMACC:RTemptyTraining','For training, no RT or all RT')
            end
            
        otherwise
            RTinputs = 0;
    end
    
    
    %% Go
    
    event_onset = 0;
    Exit_flag = 0;
    wrong_click = 0;
    too_late_click = 0;
    too_late = 0;
    has_clicked = 0;
    last_stimulus_onset = [];
    secs = 0;
    once = 0;
    stimulus_counter = 0;
    good_click = 0;
    block_counter = 0;
    
    FixationCrossColor = DataStruct.Parameters.FixationCross.BaseColor;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            otherwise
                
                switch EP.Data{evt,1}
                    
                    case 'Instructions'
                        DrawFormattedText(DataStruct.PTB.wPtr, EP.Data{evt,4},...
                            'center','center',DataStruct.Parameters.Text.Color);
                        pp = msg.Instructions;
                        block_counter = block_counter +1 ;
                        
                        switch RTinputs
                            
                            case 0
                                
                                if size(Paradigm,2) == 5
                                    maxRT = Paradigm{block_counter,5};
                                else
                                    maxRT = Timings.Stimulus  + Timings.WhiteScreen_1 + Timings.Cross(1);
                                end
                                
                            case 1
                                
                                if strcmp(Paradigm{block_counter,2}, 'positive' )
                                    maxRT = RT_Positive;
                                elseif strcmp(Paradigm{block_counter,2}, 'negative' )
                                    maxRT = RT_Negative;
                                elseif strcmp(Paradigm{block_counter,2}, 'cross' ) || strcmp(Paradigm{block_counter,2}, 'circle' )
                                    maxRT = RT_XO;
                                elseif strcmp(Paradigm{block_counter,2}, 'null' )
                                    maxRT = Inf; % no red cross
                                end
                                
                        end
                        
                        Common.CommandWindowDisplay;
                        
                    case 'FixationCross'
                        Common.DrawFixation;
                        pp = msg.FixationCross;
                        
                    case 'Stimulus'
                        
                        wrong_click = 0;
                        once = 0;
                        too_late = 0;
                        has_clicked = 0;
                        too_late_click = 0;
                        good_click = 0;
                        finalRT = [];
                        
                        FixationCrossColor = DataStruct.Parameters.FixationCross.BaseColor;
                        
                        if isempty(EP.Data{evt,4})
                            
                        elseif isnumeric(EP.Data{evt,4})
                            Screen('DrawTexture',DataStruct.PTB.wPtr,EP.Data{evt,4})
                            
                        elseif ischar(EP.Data{evt,4}) && strcmp(EP.Data{evt,4},'x')
                            Common.DrawX;
                            
                        elseif ischar(EP.Data{evt,4}) && strcmp(EP.Data{evt,4},'o')
                            Common.DrawO;
                            
                        end % if
                        
                        switch EP.Data{evt,7}
                            case 0
                                col = 5;
                            case 1
                                col = 6;
                        end % switch
                        
                        pp = msg.Stimulus.(EP.Data{evt,col});
                        
                    case 'WhiteScreen_1'
                        % do nothing
                        pp = msg.WhiteScreen_1;
                        
                    case 'Cross'
                        Common.DrawFixation;
                        pp = msg.BaseCross;
                        
                    case 'WhiteScreen_2'
                        % do nothing
                        pp = msg.WhiteScreen_2;
                        
                end % switch
                
                % Flip
                event_onset = Screen('Flip',DataStruct.PTB.wPtr, StartTime + EP.Data{evt,2} - DataStruct.PTB.slack * 1 );
                Common.SendParPortMessage;
                
                % Save onset
                ER.AddEvent({ EP.Data{evt,1} event_onset-StartTime })
                
                % Reference for RT
                if strcmp(EP.Data{evt,1},'Stimulus')
                    
                    last_stimulus_onset = event_onset;
                    
                    switch EP.Data{evt,7}
                        case 0
                            RR.AddEvent({'Go' event_onset-StartTime EP.Data{evt+4,2}-EP.Data{evt,2}});
                            
                        case 1
                            RR.AddEvent({'NoGo' event_onset-StartTime EP.Data{evt+4,2}-EP.Data{evt,2}});
                    end
                    
                end % if
                
                while secs < StartTime + EP.Data{evt+1,2} - 0.002
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % in R2016a, BREAK in loop in a script (wrapper) is not
                    % allowed
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % ESCAPE key pressed ?
                    % Common.Interrupt;
                    
                    % Escape ?
                    [ ~ , secs , keyCode ] = KbCheck;
                    
                    if keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
                        
                        % Flag
                        Exit_flag = 1;
                        
                        % Stop time
                        StopTime = GetSecs;
                        
                        % Record StopTime
                        ER.AddStopTime( 'StopTime' , StopTime - StartTime );
                        RR.AddEvent( { 'StopTime' , StopTime - StartTime , 0 } );
                        
                        ShowCursor;
                        Priority( DataStruct.PTB.oldLevel );
                        
                        break
                        
                    end
                    
                    
                    RT = secs - last_stimulus_onset;
                    
                    if keyCode(DataStruct.Parameters.Keymap.SubjectButton) && ~has_clicked
                        has_clicked = 1;
                        good_click = 1;
                        pp = msg.Click.ok;
                        finalRT = RT;
                        
                        if EP.Data{evt,7} == 0 && RT > maxRT % Go and too late
                            too_late_click = 1;
                            good_click = 0;
                            pp = msg.Click.too_late;
                            
                        elseif EP.Data{evt,7} == 1 % NoGo
                            wrong_click = 1;
                            good_click = 0;
                            pp = msg.Click.nogo;
                            
                        end % if
                        
                        Common.SendParPortMessage;
                        
                    end % if
                    
                    if EP.Data{evt,7} == 0 && RT > maxRT && ~has_clicked % Go and too late
                        too_late = 1;
                        finalRT = [];
                    end % if
                    
                    if strcmp(EP.Data{evt,1},'Cross') && ( wrong_click || too_late )&& ~once
                        FixationCrossColor = DataStruct.Parameters.FixationCross.WrongColor;
                        Common.DrawFixation; % fixation cross changes color
                        event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                        if wrong_click
                            pp  = msg.WrongCross.nogo;
                            txt = 'Cross.wrong_click';
                        elseif too_late
                            pp  = msg.WrongCross.too_late;
                            txt = 'Cross.too_late';
                        end
                        Common.SendParPortMessage;
                        RR.AddEvent({ txt event_onset-StartTime EP.Data{evt+1,2}-(event_onset-StartTime)});
                        once = 1;
                        
                    end % if
                    
                end % while
                
                FixationCrossColor = DataStruct.Parameters.FixationCross.BaseColor;
                
        end % switch
        
        if strcmp(EP.Data{evt,1},'WhiteScreen_2')
            
            stimulus_counter = stimulus_counter +1 ;
            Table(stimulus_counter,:) = {...
                last_stimulus_onset-StartTime...
                EP.Data{evt,7}...
                EP.Data{evt,5}...
                EP.Data{evt,6}...
                finalRT...
                has_clicked...
                good_click...
                too_late_click...
                wrong_click...
                maxRT}; %#ok<AGROW>
            
            fprintf('%1.3f %d %s %s %1.3f %d %d %d %d %1.3f \n',Table{stimulus_counter,:})
            
        end % if
        
        if Exit_flag
            break %#ok<*UNRCH>
        end % if
        
        
    end % for
    
    
    %% End of stimulation
    
    
    Common.EndOfStimulationScript;
    
    Common.Movie.FinalizeMovie;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end % try catch

end % function

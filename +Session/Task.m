function [ TaskData ] = Task( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Load and prepare all stimuli
    
    Session.LoadStimuli;
    
    
    %% Tunning of the task
    
    [ EP , nGo , nNoGo , Paradigm , Instructions , Timings , firstGO ] = Session.Planning( DataStruct , Stimuli ); %#ok<*ASGLU>
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Record movie
    
    Common.Movie.CreateMovie;
    
    
    %% Start recording eye motions
    
    Common.StartRecordingEyelink;
    
    
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
    
    maxRT = Timings.Stimulus  + Timings.WhiteScreen_1 + Timings.Cross(1);
    
    FixationCrossColor = DataStruct.Parameters.FixationCross.BaseColor;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
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
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    RT = secs - last_stimulus_onset;
                    
                    if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_b_ASCII) && ~has_clicked
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
                wrong_click}; %#ok<AGROW>
            
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

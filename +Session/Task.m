function [ TaskData ] = Task( DataStruct )

try
    %% Load and prepare all stimuli
    
    Session.LoadStimuli;
    
    
    %% Tunning of the task
    
    [ EP , Stimuli ] = Session.Planning( DataStruct , Stimuli ); %#ok<*ASGLU,NODEF>
    
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
    
    %     wrapat = 1;
    %     vSpacing = 1;
    %     DrawFormattedText(DataStruct.PTB.wPtr,...
    %         EP.Data{evt,4},...
    %         'center',...
    %         'center',...
    %         [0 0 0],...
    %         wrapat,...
    %         [],[],...
    %         vSpacing,...
    %         [],...
    %         []);
                            
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
            otherwise
                
                frame_counter = 0;
                
                while event_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1
                    
                    frame_counter = frame_counter + 1;
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    switch EP.Data{evt,1}
                        
                        case 'Instructions'
                            DrawFormattedText(DataStruct.PTB.wPtr, EP.Data{evt,4},'center','center',[0 0 0])
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                            
                        case 'FixationCross'
                            Common.DrawFixation;
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                            
                        case 'Stimulus'
                            if isempty(EP.Data{evt,4})
                                
                            elseif isnumeric(EP.Data{evt,4})
                                Screen('DrawTexture',DataStruct.PTB.wPtr,EP.Data{evt,4})
                                
                            elseif ischar(EP.Data{evt,4}) && strcmp(EP.Data{evt,4},'x')
                                DrawFormattedText(DataStruct.PTB.wPtr, 'x','center','center',[0 0 0]);
                                
                            elseif ischar(EP.Data{evt,4}) && strcmp(EP.Data{evt,4},'o')
                                DrawFormattedText(DataStruct.PTB.wPtr, 'o','center','center',[0 0 0]);
                                
                            end % if
                            
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                        
                        case 'WhiteScreen_1'
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                        
                        case 'Cross'
                            Common.DrawFixation;
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                        
                        case 'WhiteScreen_2'
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                            
                        otherwise
                            event_onset = GetSecs;
                            % error('Unrecognzed condition : %s',EP.Data{evt,1})
                            
                    end % switch
                    
                    Common.Movie.AddFrameToMovie;
                    
                    if frame_counter == 1
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} event_onset-StartTime })
                    end % if
                    
                end % while
                
        end % switch
        
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

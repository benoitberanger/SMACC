function [ TaskData ] = Task( DataStruct )

try
    %% Load and prepare all stimuli
    
    Session.LoadStimuli;
    
    
    %% Tunning of the task
    
    [ EP , Stimuli , Speed ] = Session.Planning( DataStruct , Stimuli ); %#ok<*ASGLU,NODEF>
    
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
                        
                        case 'cross'
                            Common.DrawFixation;
                            event_onset = Screen('Flip',DataStruct.PTB.wPtr);
                            
                        otherwise
                            event_onset = GetSecs;
                            % error('Unrecognzed condition : %s',EP.Data{evt,1})
                            
                    end
                    
                    Common.Movie.AddFrameToMovie;
                    
                    if frame_counter == 1
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} event_onset-StartTime })
                    end
                    
                end % while
                
                
        end % switch
        
        if Exit_flag
            break %#ok<*UNRCH>
        end
        
        
    end % for
    
    
    %% End of stimulation
    
    
    Common.EndOfStimulationScript;
    
    Common.Movie.FinalizeMovie;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end

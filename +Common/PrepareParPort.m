switch DataStruct.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end

% Prepare messages

% bit weight 0 to 3
msg.Stimulus.neutral    = 1;
msg.Stimulus.positive   = 2;
msg.Stimulus.negative   = 3;
msg.Stimulus.cross      = 4;
msg.Stimulus.circle     = 5;
msg.WhiteScreen_1       = 6;
msg.BaseCross           = 7;
msg.WhiteScreen_2       = 8;

msg.WrongCross.too_late = 9;
msg.WrongCross.nogo     = 10;

msg.Instructions        = 11;
msg.FixationCross       = 12;

% bit weight 5, 6 and 7
msg.Click.ok            = 32;  % bin2dec(' 0 0 1 0 0 0 0 0 ')
msg.Click.too_late      = 64;  % bin2dec(' 0 1 0 0 0 0 0 0 ')
msg.Click.nogo          = 128; % bin2dec(' 1 0 0 0 0 0 0 0 ')


% Pulse duration
msg.duration              = 0.005; % seconds

TaskData.ParPortMessages  = msg;

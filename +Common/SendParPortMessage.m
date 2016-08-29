if strcmp( DataStruct.ParPort , 'On' )
    
    % Send Trigger
    WriteParPort( pp );
    WaitSecs( msg.duration );
    WriteParPort( 0 );
    
    % disp(pp)
    % disp(dec2bin(pp,8))
    
end

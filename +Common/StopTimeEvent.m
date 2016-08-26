% Fixation duration handeling
StopTime = WaitSecs('UntilTime', StartTime + ER.Data{ER.EventCount,2} + EP.Data{evt-1,3} );

% Record StopTime
ER.AddStopTime( 'StopTime' , StopTime - StartTime );
RR.AddEvent( { 'StopTime' , StopTime - StartTime , 0 } );

% ShowCursor;
% Priority( DataStruct.PTB.oldLevel );

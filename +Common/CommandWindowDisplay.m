% Command window display
fprintf( '\n' )
fprintf( 'Go = %s, Nogo = %s, maxRT = %1.3f (s)  \n' , EP.Data{evt,5}, EP.Data{evt,6},maxRT )
fprintf( ' Onset     = %.3g (s) \n' , EP.Data{evt,2} )
fprintf( ' Duration  = %.3g (s) \n' , EP.Data{evt,3} )
fprintf( ' Remaining = %.3g (s) \n' , EP.Data{end,2} - EP.Data{evt,2} )

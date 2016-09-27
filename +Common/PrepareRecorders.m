%% Prepare event record

% Create
ER = EventRecorder( { 'event_name' , 'onset(s)' } , size(EP.Data,1) );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' , 'duration(s)' } , 50000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddEvent( { 'StartTime' , 0 , 0 } );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

allKeys = struct2array(DataStruct.Parameters.Keybinds);

KL = KbLogger( allKeys , KbName(allKeys) );

% Start recording events
KL.Start;


%% Prepare a cell to store reaction time

Table_hdr = {'stimulus onset (s)' , 'Go=0/NoGo=1' , 'goContext' , 'nogoContext' , 'reaction time (s)' , 'has clicked' , 'good click' , 'too late click' , 'nogo click' , 'maxRT (s)' };

Table = cell(size(Paradigm,1)*(nGo+nNoGo),length(Table_hdr));

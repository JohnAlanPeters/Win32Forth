anew oglevts.f  \ April 26th, 2013

needs MultiTaskingClass.f

\ A timer does not wait. An event does. That is the advantage.
: event-set     ( hEvent - )  Call SetEvent   0= abort" Event not set" ;
: event-reset   ( hEvent - )  Call ResetEvent 0= abort" Event not reset" ;


: event-wait    ( hEvent - )            \ wait while event or object is NOT set
   INFINITE  swap  Call WaitForSingleObject drop  ;

\ Events-to-wait-for can wait till ALL or ONE event is set.
\ The handles of the events are in an array of pHandles.

\ if bWaitAll is false events-to-wait-for will wait till one event or object is set
\ if bWaitAll is true  events-to-wait-for will wait till all events or objects are set
\ pHandles is a pointer to an array with events or object handles
\ nCount is the number of handles in the array

: events-to-wait-for  ( bWaitAll pHandles nCount - #waitobject )
   dup MAXIMUM_WAIT_OBJECTS > abort" Too many objects"
   >r INFINITE -rot r> Call WaitForMultipleObjects ;

\ Note: In W98 it does not matter if bWaitAll is true or false

: event-set?    ( hEvent - true/false )    \ set/not_set
   0  swap  Call WaitForSingleObject 0=  ;

: make-event-set       ( z"name" - hEvent ) \ In Win32
    false              \ init state      ( seems ignored ? )
    true               \ manuel reset ( seems ignored ? )
    NULL               \ lpSecurityAttrib
    Call CreateEvent   \ handle event, the event seems allways NOT set
    dup event-set ;

: make-event-reset     ( z"name" - hEvent ) \ In Win32
    false              \ init state      ( seems ignored ? )
    true               \ manuel reset ( seems ignored ? )
    NULL               \ lpSecurityAttrib
    Call CreateEvent   \ handle event, the event seems allways NOT set
    dup event-reset ;

    wTasks EventTasks                 \ Make the object myTasks.

0 value h_ev_timeout_slow-action_done
0 value h_ev_slow-action
0 value h_ev_sound
0 value h_ev_Message

0 value slow-action?

WaitableTimer RefreshTimer       \ Create a timer


: ms-1-period ( max-periods/second - ms-1-period )  1000 swap / 1 max ;
: time-1-period ( max-periods/second - ) ( f: Time1Period ) 1e s>f f/ ;

66 time-1-period fvalue ns-time-out-done

: wait/restart-timer-slow-action
   h_ev_timeout_slow-action_done event-wait
   h_ev_timeout_slow-action_done event-reset
 ;

60 ms-1-period value ms-slow-action
0 value NestingDisplay?

: slow-action  ( - )
   false to slow-action?
        begin   h_ev_slow-action event-wait    \ stop or run
                ms-slow-action Call Sleep drop
                h_ev_timeout_slow-action_done event-set
                true to slow-action?
        again
 ;


0 value sound-file
true value sounds_on/off

INTERNAL WinLibrary WINMM.DLL EXTERNAL

: sounds  ( z"sound-file" -  )
   sounds_on/off
     if   SND_FILENAME SND_ASYNC or NULL rot call PlaySound  then drop  ;

: sound-action  ( - )  \ Prevents waiting while making a sound
        begin   h_ev_sound event-wait    \ wait or run
                h_ev_sound event-reset
                sound-file sounds
        again
 ;

defer .fps

: fps-action  ( - )  \ Shows Fps in the title of the window
        begin   1000 Call Sleep .fps
        again
 ;


: start-sound ( z"adres" - )   to sound-file h_ev_sound event-set ;

: reset-all-events ( - )
  h_ev_slow-action  event-reset
  h_ev_sound        event-reset
 ;

: set-all-events ( - )
  h_ev_slow-action  event-set
  h_ev_sound        event-set
 ;

: status-all-events ( - timeout_done slow-action sound )
  h_ev_slow-action  event-set?
  h_ev_sound        event-set?
 ;

: restore-event ( flag event - )
   swap
     if   event-set
     else event-reset
     then
 ;

: restore-all-events ( timeout_done slow-action - )
   h_ev_slow-action  restore-event
   h_ev_sound        restore-event
 ;

: set-priority  ( priority_class - )
    call GetCurrentProcess swap call SetPriorityClass drop  ;

: set-ogl-events
    HIGH_PRIORITY_CLASS set-priority
    0 make-event-reset to h_ev_slow-action
    0 make-event-reset to h_ev_sound
    0 make-event-reset to h_ev_Message
    0 make-event-reset to h_ev_timeout_slow-action_done
 ;


: start-ogl-threads
   Start: EventTasks              \ Need at least simultaneous tasks ( 2 spear )
   6 SetThreadcount: EventTasks \ Need at least 6 simultaneous tasks ( 2 spear )
   ['] slow-action   Submit: EventTasks
   ['] sound-action  Submit: EventTasks
   ['] fps-action    Submit: EventTasks

 ;
\s

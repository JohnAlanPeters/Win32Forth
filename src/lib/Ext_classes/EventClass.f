anew -EventClass.f

\ *D doc\classes\
\ *! EventClass
\ *T EventClass -- To manage unnamed event object.

\ *S Abstract

\ *P Event objects \n
\ ** The class EventObject is the root for various event objects like\n
\ ** a mutex, semaphore, or WaitableTimer.\n
\ ** Also useable to wait for a thread or process.\n
\ ** An array of events needs an other class.


\ *S Glossary

0x7fffffff constant max-sleep    \ This is not endless 46 days is the maximum

: .wait ( wait-value - )
\ *G Shows the wait state.
  case
    WAIT_ABANDONED of  ."  The mutex object that was not released the mutex is set to nonsignaled." endof
    WAIT_OBJECT_0  of  ."  The state of the specified object is signaled."  endof
    WAIT_TIMEOUT   of  ."  The time-out interval elapsed, and the object's state is nonsignaled."  endof
    WAIT_ABANDONED of  ."  The function WaitForSingleObject failed."         endof
  endcase
 ;

:Class EventObject    <Super Object
\ *G Create an eventobject.
    int Hndl      \ handle of an event object.


:M GetHandle: ( - hEvent )
\ *G Returns the handle of the event object.
    Hndl ;M

:M SetHandle: ( hEvent -  )
\ *G Sets the handle of the event object.
     to Hndl ;M

:M Wait:    ( - )
\ Returns when the specified object is in the signaled state.
   INFINITE  Hndl  Call WaitForSingleObject drop  ;M

:M WaitForSingleObject:    ( time-out-in-ms - wait )
\ Returns when the specified object is in the signaled state (set)
\ or when the time-out interval elapses.
\ Meaning of the returned value:
\ WAIT_ABANDONED The specified object is a mutex object that was not released by the thread
\                that owned the mutex object before the owning thread terminated.
\                Ownership of the mutex object is granted to the calling thread, and the mutex is set to nonsignaled.
\ WAIT_OBJECT_0  The state of the specified object is signaled.
\ WAIT_TIMEOUT   The time-out interval elapsed, and the object's state is nonsignaled.
\ WAIT_FAILED    The function failed.
     Hndl Call WaitForSingleObject
  ;M

:M ClassInit:  ( -- )
\ *G Initializes the object.
    ClassInit: Super
;M

:M Close: ( -- )
\ *G Clean up the handle.
  Hndl close-file drop ;M

;Class

:Class Event    <Super EventObject
\ *G To create events from eventObject

:M Create:     ( - )   \ In Win32
    0                  \ No name
    false              \ Initial state ( seems ignored ? )
    false              \ Manuel reset  ( seems ignored ? )
    NULL               \ lpSecurityAttrib
    Call CreateEvent   \ Create the handle event, the event seems allways NOT set
    to Hndl            \ save the handle
  ;M

:M Set:     ( - )
\ *G Sets the specified event object to the signaled state.
    Hndl Call SetEvent   0= abort" Event not set"  ;M

:M Reset:   ( - )
\ *G Sets the specified event object to the nonsignaled state
    Hndl Call ResetEvent 0= abort" Event not reset"  ;M

:M Pulse:   ( - )
\ *G Sets the specified event object to the signaled state and then resets
\ ** it to the nonsignaled state after releasing the appropriate number
\ ** of waiting threads. The advise is not to use it.
    Hndl Call PulseEvent ?win-error ;M


:M ClassInit:  ( -- )
\ *G Initializes the object.
    ClassInit: Super
    Create: Self
  ;M

;Class

\s
\ *S Example
\ *+

Event MyEvent       \ Create an event

: signal? ( - WaitValue ) \ signal? is not useable in critical operations.
    0 WaitForSingleObject: MyEvent dup
    WAIT_OBJECT_0 =
        if  Set: MyEvent  \ restoring event after WaitForSingleObject ends with WAIT_OBJECT_0
        then
 ;

: .signal ( - )
     cr  signal? .wait ."  --  "
;

: TestEvent
  cls
   cr      ." Event test:"   .signal ." Initial state"
   cr ." Wait for 1 seconds. "   1000 WaitForSingleObject: MyEvent .wait   \ Wait 1 seconds

\  Set: MyEvent cr  ." Event has now been set"   \ Disable this line to wait for 7 seconds
   .signal ." **** Before WaitForSingleObject: **** " cr
   cr ." Wait only when the event is nonsignaled." cr cr

\ The following line will wait when the event is NOT set
   7000 WaitForSingleObject: MyEvent .wait ." **** After WaitForSingleObject: **** "
   Pulse: MyEvent  .signal ." After first pulse"
   Pulse: MyEvent  .signal ." After second pulse"
 ;

TestEvent
\ *-
\ *Z

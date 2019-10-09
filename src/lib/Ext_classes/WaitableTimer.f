anew -WaitableTimer.f   \ April 26th, 2013 by Jos v.d.Ven Version

needs Ext_classes\EventClass.f

\ *D doc\classes\
\ *! WaitableTimerClass
\ *T WaitableTimerClass -- For high resolution waitable timers.

\ *S Abstract

\ *P A waitable timer gives a very stable result for small wait times. \n

\ *S Glossary

:Class WaitableTimer    <Super EventObject
\ *G Create a waitable timer object.
    2 cells bytes *pDueTime

:M CreateTimer: ( -  )
\ *G Create a waitable timer.
    0 true 0 call CreateWaitableTimer to Hndl
 ;M

10000000e fconstant #fsecond \ Time for one second

:M StartTimer:  ( F: fseconds - )
\ *G To start the Waitable timer.
\ ** StartTimer: needs a floating point number on the stack to specify the time to wait.
\ ** The timer has a resolution of 10,000 times better than the resulution of sleep.
    #fsecond f*  \ Convert to 100 nanoseconds
    fnegate      \ For a relative time
    f>d swap *pDueTime 2!  false 0 0 0 *pDueTime Hndl
    call SetWaitableTimer drop
 ;M

:M CancelWaitableTimer: ( - )
\ *G Sets the waitable timer to the inactive state
    Hndl call CancelWaitableTimer ?win-error
  ;M

:M ClassInit:  ( -- )
\ *G Initializes the object.
    ClassInit: Super
    CreateTimer: Self
  ;M

;Class


\s
\ *S Example
\ *+

WaitableTimer MyTimer       \ Create a timer

: testTimer ( - )
    0.5e StartTimer: MyTimer \ Set to a half second.
    \ CancelWaitableTimer: MyTimer \ Then it will not signal anymore
    Wait: MyTimer            \ Start waiting using the wait of the inherted EventObject
    beep
 ;

cr .( WaitableTimer.f ) cr
testTimer .( ok)

\ *-
\ *Z

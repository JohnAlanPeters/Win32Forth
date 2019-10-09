\ $Id: MultiHello.f,v 1.10 2013/12/17 19:25:22 georgeahubert Exp $
\ Based on WINHELLO.F            Simple Windows Hello World              by Tom Zimmer

anew -multihello.f

needs task.f
needs Resources.f

true value turnkey? \ set to TRUE if you want to create a turnkey application

variable #windows

defer startwindow
: StartTwoWindows       ( -- )
        startwindow startwindow ;

0 value ScreenWidth
0 value ScreenHeight

\ ---------------------------------------------------------------
\ timer-window class
\ ---------------------------------------------------------------

:class timer-window  <super window
\ *G timer-window class.
\ ** This class can be used for windows that should handle
\ ** timer events. Only one timer for the window can be used with
\ ** this class.

int timer

:m ClassInit:   ( -- )
\ *G Init the class
                ClassInit: super
                0 to timer
                ;m

:m KillTimer:   ( -- )
\ *G Destroy the timer for this window.
                timer ?dup
                if   hWnd Call KillTimer ?win-error \ destroy the timer
                     0 to timer
                then ;m

:M CreateTimer: ( ms -- )
\ *G Create the timer for this window.
                KillTimer: self \ not needed, but it doesn't hurt...
                NULL swap hWnd hWnd Call SetTimer to timer
                ;m

:M On_Done:     ( -- )
\ *G Things to do before program termination
                KillTimer: self  \ destroy the timer, we are done
                On_Done: super
                ;M

:M On_Timer:    ( -- )
\ *G Thing's to do when the window recives a timer event. Default does nothing.
                ;m

:M WM_TIMER     ( -- )                  \ handle the WM_TIMER events
                On_Timer: [ self ] ;M

;class

\ ---------------------------------------------------------------
\
\ ---------------------------------------------------------------
:Class thread-window     <Super timer-window

int myblock     \ taskblock of thread running the window

:m ClassInit:   ( -- )
                ClassInit: super
                0 to myblock
                ;m

:M Start:       ( addr -- )
\ *G Start this window. \n
\ ** Since every window with this super-class run's in it's
\ ** own thread we need a message loop for every window.
\ ** This message loop is part of this member function.
\ ** So we return from this function after the window is
\ ** closed.
                Start: Super
		to myblock \ save addr of taskblock

                \ Since every window in this demo runs in it's own thread
                \ we need a message loop for every window !
                MessageLoop

                \ here we get after the window is closed !
                ;M

:M On_Done:     ( -- )          \ things to do before program termination
                0 call PostQuitMessage drop
                myblock task>handle @ call CloseHandle 0= throw \ close taskhandle
                myblock free throw \ free taskblock

                On_Done: super             \ then do things superclass needs

                self dispose
                ;M
;Class


\ ---------------------------------------------------------------
\
\ ---------------------------------------------------------------
:Class DemoThreadWindow     <Super Thread-Window

int counter     \ a local variable for a counter

ButtonControl NewWindow
ButtonControl TwoWindows

:M ClassInit:   ( -- ) \ Added to handle dialog messages gah Friday, May 30 2008
                ClassInit: Super +DialogList ;M

:M ~:           ( -- ) \ Added to handle dialog messages gah Friday, May 30 2008
                -DialogList ~: Super ;M

:M StartSize:   ( -- w h )      \ the screen origin of our window
                170 120 ;M

:M StartPos:    ( -- x y )      \ the width and height of our window
                ScreenWidth  170 - Random
                ScreenHeight 150 - Random
                ;M

:M WindowTitle: ( -- Zstring )          \ window caption
                z" Hello World" ;M

:M On_Paint:    { \ temp$ -- }  \ all window refreshing is done by On_Paint:

                \ get the Client area of the window and fill it black
                winRect GetClientRect: self
                black winRect FillRect: dc

                \ set the backgroundcolor for text to black
                black SetBkColor: dc
                \ and set the Textcolor to green
                green SetTextColor: dc

                MAXSTRING LocalAlloc: temp$
                s" Repainted "        temp$  place
                counter (.)           temp$ +place
                s"  times"            temp$ +place
                20 ( x ) 50 ( y )     temp$  count TextOut: dc
                20 ( x ) 20 ( y )  s" Hello World" TextOut: dc
                width 2/ 60 - height 30 - 120 20 Move: NewWindow
                width 2/ 60 - height 50 - 120 20 Move: TwoWindows
                ;M

: InitTimer	( -- ) \ init timer for this window to a 200 ms rate
		200 CreateTimer: super ;

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super             \ do anything superclass needs
                0 to counter               \ then initialize counter is zero
		InitTimer                  \ init the timer for this window

                self Start: NewWindow
                self Start: TwoWindows
                width 2/ 60 - height 30 - 120 20 Move: NewWindow
                width 2/ 60 - height 50 - 120 20 Move: TwoWindows
                ['] StartWindow     SetFunc: NewWindow
                s" Open window"     SetText: NewWindow
                ['] StartTwoWindows SetFunc: TwoWindows
                s" Open 2 windows"  SetText: TwoWindows
                4 Random 2 over 1 and 6 * + swap 2 and 2* 2* + base !
                ;M

:M On_Timer:    ( h m w l -- res ) \ handle the WM_TIMER events
                1 +to counter              \ bump the counter
                Paint: self                \ refresh the window
                0 ;M

:M On_Done:     ( -- )          \ things to do before program termination
                On_Done: super             \ then do things superclass needs

                turnkey? #windows call InterlockedDecrement 0= and
                if bye then \ terminate application if last window in turnkey
                ;M
;Class


: (StartWindow) ( -- )
                #windows call InterlockedIncrement drop
                New> DemoThreadWindow start: [ ] ;

 1 proc CloseHandle

:noname         ( -- )
                ['] (StartWindow) 5 cells allocate throw tuck tuck
                (task-block) drop run-task 0= throw ; is StartWindow

: Main          ( -- ) \ start running the demo program
                0 #windows !
                SM_CXSCREEN call GetSystemMetrics to ScreenWidth
                SM_CYSCREEN call GetSystemMetrics to ScreenHeight
                RANDOM-INIT

                StartWindow
                ;

turnkey? [if]

        \ Create the exe-file
        &forthdir count &appdir place
        ' Main turnkey MultiHello.exe

        \ add the Application icon to the EXE file
        s" src\res\Win32For.ico" s" MultiHello.exe" Prepend<home>\ AddAppIcon

        1 pause-seconds bye
[else]
        Main
[then]

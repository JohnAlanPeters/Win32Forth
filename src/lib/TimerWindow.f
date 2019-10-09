\ $Id: TimerWindow.f,v 1.1 2008/04/30 15:51:09 dbu_de Exp $

\ *D doc\classes\
\ *! TimerWindow
\ *T Timer-Window -- Timer-Window class.
\ *S Glossary

require window.f

cr .( Loading Timer-Window class...)

only forth also definitions

in-application

\ ---------------------------------------------------------------
\ timer-window class
\ ---------------------------------------------------------------

:class timer-window  <super window
\ *G Timer-Window class.
\ ** This class can be used for windows that should handle timer events.
\ ** Only one timer per window can be used with this class.

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
\ *G End of timer-window class.

\ *Z

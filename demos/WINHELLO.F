\ WINHELLO.F            Simple Windows Hello World              by Tom Zimmer
\
\ See also HELLO.F for a similar example that doesn't use objects

only forth also definitions

needs Resources.f

true value turnkey?

\ ---------------------------------------------------------------
\ Define the main window object
\ ---------------------------------------------------------------

:Object HelloWindow     <Super Window

int counter                     \ a local variable for a counter

:M StartSize:   ( -- w h )      \ the screen origin of our window
                170 90 ;M

:M StartPos:    ( -- x y )      \ the width and height of our window
                200 100 ;M

:M WindowTitle: ( -- Zstring )  \ window caption
                z" Hello World" ;M

:M On_EraseBackground: ( hwnd msg wparam lparam -- res )
                \ let the On_Paint: Method redraw the background
                4drop 0 ;M

:M On_Paint:    { \ temp$ -- }  \ all window refreshing is done by On_Paint:

                \ draw background only if needed
                ps_fErase
                if   ps_left ps_top ps_right ps_bottom
                     black FillArea: dc
                then

                \ check if our drawing area is visible or not
                0 0 170 90 SetRect: winRect
                winRect GetHandle: dc call RectVisible
                if   \ let's draw...
                     black   SetBkColor: dc
                     ltgreen SetTextColor: dc

                     20 ( x ) 20 ( y )  s" Hello World" TextOut: dc

                     red SetTextColor: dc

                     MAXSTRING LocalAlloc: temp$
                     s" Repainted "        temp$  place
                     counter (.)           temp$ +place
                     s"  times"            temp$ +place
                     20 ( x ) 50 ( y )     temp$  count TextOut: dc
                then ;M

:M Paint:       ( -- )
                \ Note: The Paint: method of the window class invalidates the
                \ complete client rectangle. Since we only draw in a smal part
                \ of the window only the the part of the window in whitch we
                \ are going to draw is marked as invalid.
                0 0 170 90 SetRect: winRect
                1 winRect hWnd Call InvalidateRect ?win-error
                ;M

:M WM_TIMER     ( h m w l -- res ) \ handle the WM_TIMER events
                1 +to counter  \ bump the counter
                Paint: self    \ refresh the window
                0 ;M

:M On_Init:     ( -- )          \ things to do at the start of window creation
                On_Init: super             \ do anything superclass needs
                0 to counter               \ then initialize counter is zero
                0 200 1 hWnd Call SetTimer ?win-error \ init timer to a 200 ms rate
                ;M

:M On_Done:     ( -- )          \ things to do before program termination
                1 hWnd Call KillTimer ?win-error \ destroy the timer, we are done
                On_Done: super             \ then do things superclass needs

                \ in a turnkey application we have to make shure
                \ that the message loop is left now!
                turnkey? if 0 call PostQuitMessage drop then
                ;M
;Object

\ ---------------------------------------------------------------
\ Top Level program starts here
\ ---------------------------------------------------------------

: Main          ( -- )
                \ Open the main window
                Start: HelloWindow
                ;

turnkey? [if]

        \ Create the exe-file
        &forthdir count &appdir place
        ' Main turnkey WinHello.exe

        \ add the Application icon to the EXE file
        s" src\res\Win32For.ico" s" WinHello.exe" Prepend<home>\ AddAppIcon

        1 pause-seconds bye
[else]
        Main
[then]

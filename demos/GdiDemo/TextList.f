\ TextList.F    Example of Object Oriented Text Strings
\ Written by David R. Pochin
\ Changed to use the GDI class library by Dirk Busch

\ Examples of text foreground, background and mode options.

anew -TextList.f

needs gdi/gdi.f

\ Define an Object that is a super object of the Class "Window".
:OBJECT Stringdemo <SUPER WINDOW

gdiWindowDC   tDC
ButtonControl Button_1   \ Declare a button

:M WindowTitle: ( -- title )         \ Title for the window.
        z" Text String Objects. Win32Forth " ;M

:M StartSize:   ( -- width height )  \ Set width and height of window
        500 270 ;M

:M StartPos:    ( -- x y )           \ Set the screen origin.
        200 100  ;M

:M DrawRect:    ( y2 x2 y1 x1 -- )   \ See method GetHandle: in dc.f
        4reverse Rectangle: tDC ;M

:M Close:       ( -- )               \ Do anything the class needs.
        Destroy: tDC
        Close: super
        ;M

:M On_Init:     ( -- )
        \ Add a button.
        IDOK               SetID: Button_1
        self               Start: Button_1
        190 220 70 25       Move: Button_1
        s" CLOSE"        SetText: Button_1
                        GetStyle: Button_1 BS_DEFPUSHBUTTON OR
                        SetStyle: Button_1
        ;M

:M On_Paint:  ( -- )          \ screen redraw procedure
        GetHandle: self GetDC: tDC
        if
                \ Output the first text string.
                \ Example of the Forth word s" and see the method TextOut: in dc.f
                \ Note TextOut: requires the length of the string.
                90 20 s" COUNTED STRING. DEFAULT SETTINGS"  TextOut: tDC

                \ Set TextColor and BkColor.
                \ See the methods in dc.f which call Windows functions.
                Color: LTBLUE SetTextColor: tDC
                Color: LTRED SetBackgroundColor: tDC

                \ Set up two rectangles to see Mode Effects.
                \ Again see the methods in dc.f
                Brush: LTYELLOW SelectObject: tDC
                205 220 50 100 DrawRect: self
                Brush: LTGREEN SelectObject: tDC drop
                205 340 50 220 DrawRect: self

                \ Output the second text string.
                \ Used the z" word this time, note the string count required '53'
                \ As expected TextOut: is a method in dc.f
                20 60 z" LTBLUE Foreground and LTRED Background. BkMode OPAQUE" 53 TextOut: tDC

                \ Change background mode.
                TRANSPARENT SetBackgroundMode: tDC
                15 90 s" LTBLUE Foreground and LTRED Background. BkMode TRANSPARENT" TextOut: tDC

                \ Change Text Color to White
                Color: LTGREEN SetTextColor: tDC drop
                10 120 s" LTRED Background and LTGREEN Foreground. BkMode TRANSPARENT" TextOut: tDC

                \ Reset background mode to Opaque.
                OPAQUE SetBackgroundMode: tDC drop
                10 150 s" LTRED Background and LTGREEN Foreground. BkMode OPAQUE" TextOut: tDC

                \ Back to Defaults.
                SetBackgroundMode: tDC drop
                SelectObject: tDC drop \ bursh
                SetBackgroundColor: tDC drop
                SetTextColor: tDC drop
                120 180 s" Back to DEFAULT conditions." TextOut: tDC

                \ clean up
                Release: tDC
        then
        ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over LOWORD    \ fetch the identity of the Ok button which is in wParam
        case           \ case .. of .. endof .. endcase is a Forth defined
                       \ switch construction
             IDOK of   \ IDOK is the identity of Button_1
                    Close: self
                  endof
        endcase
        0 ;M

;OBJECT         \ Complete the definition of the new object.

: DEMO          ( -- )
        Start: Stringdemo ;
demo

\ END OF LISTING.



\ TextAlign.F
\ Written by David R. Pochin
\ Changed to use the GDI class library by Dirk Busch

anew -TextAlign

needs gdi/gdi.f

:Object TextAlign  <Super Window

gdiFont     tFont
gdiWindowDC tDC

ButtonControl Button_1   \ a button

:M WindowTitle: ( -- title )
        z" Text Alignment" ;M

:M StartSize:   ( -- w h )      \ the width and height of our window
        230 200 ;M

:M StartPos:    ( -- x y )      \ the screen origin of our window
        100 100 ;M

:M SetLines:    ( -- )
         80  10 MoveTo: tDC
         80 110 LineTo: tDC
         10 140 MoveTo: tDC
        210 140 LineTo: tDC
        ;M

:M PrintText:   ( -- )

        \ select out Font into the DC
        tFont SelectObject: tDC

        \ draw some Text
        TA_LEFT SetTextAlign: tDC
        80 20 s" LEFT" TextOut: tDC

        TA_CENTER SetTextAlign: tDC drop
        80 50 s" CENTRE" TextOut: tDC

        TA_RIGHT SetTextAlign: tDC drop
        80 80  s" RIGHT" TextOut: tDC

        TA_TOP SetTextAlign: tDC drop
        30 140  s" TOP" TextOut: tDC

        TA_BOTTOM SetTextAlign: tDC drop
        70 140  s" BOTTOM" TextOut: tDC

        TA_BASELINE SetTextAlign: tDC drop
        155 140  s" BASE" TextOut: tDC

        SetTextAlign: tDC drop \ reset Text alignment
        SelectObject: tDC drop \ reset Font
        ;M

:M On_Paint:    ( -- )
        GetHandle: self GetDC: tDC
        if   SetLines: self
             PrintText: self
             Release: tDC
        then ;M

:M On_Init:     ( -- )  \ things to do at the start of window creation
        On_Init: super  \ do anything superclass needs

        \ init the pushbutton to close the application
        IDOK               SetID: Button_1
        self               Start: Button_1
        80 160 60 25        Move: Button_1
        s" CLOSE"        SetText: Button_1
        BS_DEFPUSHBUTTON  +Style: Button_1

        \ create a font
        s" Arial" SetFaceName: tFont
        10 SetHeight: tFont
        Create: tFont drop
        ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        OVER LOWORD ( Id )
        CASE    IDOK OF Close: self ENDOF
        ENDCASE
        0 ;M

:M Close:       ( -- )  \ Do anything the class needs.
        Destroy: tFont
        Destroy: tDC

        Close: SUPER
        ;M

;Object

: DEMO  ( -- )  \ start running the demo program
        Start: TextAlign ;

\ Runs on load.
demo

\ End of Listing.


\ BitBlt.F    Examples of Raster Operations
\ Written by David R. Pochin
\ Changed to use the GDI class library by Dirk Busch

\ Examples of FillRect and BitBlt.

anew -BitBlt.f

needs gdi/gdi.f

\ Define an Object that is a child of the Class Window
:OBJECT Bltdemo <SUPER WINDOW

gdiWindowDC   tDC
gdiSolidBrush tBrushRED
gdiSolidBrush tBrushGREEN
gdiSolidBrush tBrushBLACK

ButtonControl Button_1   \ a button

:M WindowTitle: ( -- title )
        z" BitBlt V.1.1 " ;M

:M StartSize:   ( -- width height )
        550 350 ;M

:M StartPos:    ( -- x y )
        100 100 ;M

:M Close:       ( -- )
        Destroy: tDC
        Destroy: tBrushRED
        Destroy: tBrushGREEN
        Destroy: tBrushGREEN
        Close: super
        ;M

\ Set up a Button and create Pens and Brushes.
:M On_Init:     ( -- )

        \ init the brushes
        255 SetRValue: tBrushRED
          0 SetGValue: tBrushRED
          0 SetBValue: tBrushRED
        Create: tBrushRED

          0 SetRValue: tBrushGREEN
        255 SetGValue: tBrushGREEN
          0 SetBValue: tBrushGREEN
        Create: tBrushGREEN

\       0 SetRValue: tBrushBLACK \ Note that Black is the default
\       0 SetGValue: tBrushBLACK \ color, so we don't need to
\       0 SetBValue: tBrushBLACK \ set the color.
        Create: tBrushBLACK

        \ create a pushbutton to close the demo
        IDOK               SetID:   Button_1
        self               Start:   Button_1
        420 300 70 25      Move:    Button_1
        s" CLOSE"          SetText: Button_1
                          GetStyle: Button_1 BS_DEFPUSHBUTTON OR
                          SetStyle: Button_1
        ;M

\ Note: This demo was originaly written using the 'old' WindDC class.
\ The BitBlt: method of the gdiDC class is useig a different stack
\ layout. So this method was added for compatiblity.
:M BitBlt:      ( blitmode sourcex,y sourcedc sizex,y destinationx,y -- )
        2>r 2>r >r swap r> 2r> swap 2r> swap
        8reverse \ nXDest nYDest nWidth nHeight hdcSrc nXSrc nYSrc dwRop
        BitBlt: tDC ;M

:M SetUps: { left top right bottom -- }
        \ draw frames for blocks
         39  39 MoveTo: tDC 120 39 LineTo: tDC 120 120 LineTo: tDC
         39 120 LineTo: tDC  39 39 LineTo: tDC

        159  39 MoveTo: tDC 240 39 LineTo: tDC 240 120 LineTo: tDC
        159 120 LineTo: tDC 159 39 LineTo: tDC

        359  39 MoveTo: tDC 440 39 LineTo: tDC 440 120 LineTo: tDC
        359 120 LineTo: tDC 359 39 LineTo: tDC

         39 179 MoveTo: tDC 120 179 LineTo: tDC 120 260 LineTo: tDC
         39 260 LineTo: tDC  39 179 LineTo: tDC

        159 179 MoveTo: tDC 240 179 LineTo: tDC 240 260 LineTo: tDC
        159 260 LineTo: tDC 159 179 LineTo: tDC

        359 179 MoveTo: tDC 440 179 LineTo: tDC 440 260 LineTo: tDC
        359 260 LineTo: tDC 359 179 LineTo: tDC

        \ Make the source, original destination and destination blocks

        80 40 120  80 tBrushGREEN FillRect: tDC
        40 80  80 120 tBrushBLACK FillRect: tDC
        NOTSRCCOPY 40 40 GetHandle: tDC 80 80 160 40 BitBlt: self
        SRCCOPY   160 40 GetHandle: tDC 80 80 360 40 BitBlt: self

         40 220 120 260 tBrushBLACK FillRect: tDC
        200 180 240 260 tBrushBLACK FillRect: tDC
        SRCCOPY 160 180 GetHandle: tDC 80 80 360 180 BitBlt: self

        \ Setup the text
         55  16 s" Source" TextOut: tDC
        160  16 s" Destination" TextOut: tDC
        280  16 s" Blt" TextOut: tDC
        375  16 s" Result" TextOut: tDC
        260  50 s" PATPAINT" TextOut: tDC
        255 210 s" MERGECOPY" TextOut: tDC
        ;M

:M BitBlts:
        \ Top row of display. Alternatively use any of
        \  BLACKNESS WHITENESS NOTSRCCOPY SRCCOPY
        \  PATCOPY PATINVERT DSINVERT
        PATPAINT 40 40 GetHandle: tDC 80 80 360 40 BitBlt: self

        \ Bottom row of display. Aternatively use any of
        \ SRCERASE SRCINVERT SRCPAINT MERGEPAINT NOTSRCERASE
        \ SRCAND
        MERGECOPY 40 180 GetHandle: tDC 80 80 360 180 BitBlt: self
        ;M

:M On_Paint:  ( -- )          \ screen redraw procedure
        GetHandle: self GetDC: tDC
        if   tBrushRED SelectObject: tDC \ Use this brush as the current pattern

             SetUps: self
             BitBlts: self

             \ cleanup
             SelectObject: tDC drop
             Release: tDC
        then ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        OVER LOWORD ( Id )
        CASE    IDOK OF Close: self ENDOF
        ENDCASE
        0 ;M

;OBJECT

: DEMO  ( -- )
        Start: Bltdemo ;
DEMO

\ END OF LISTING


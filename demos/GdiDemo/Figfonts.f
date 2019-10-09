\ FigFonts.F   Listing for 'Win32Forth Fonts'.
\ Written by David R. Pochin
\ Changed to use the GDI class library by Dirk Busch

\ Examples of Fonts

anew -FigFonts.f

needs gdi/gdi.f

\ Define an Object that is a child object of the Class "Window".
:OBJECT Fontdemo <SUPER WINDOW

ButtonControl Button_1   \ Declare a button

gdiWindowDC tDC
gdiFont     aFont    \ Create a object of the class font
gdiFont     bFont    \ and another

:M ClassInit:   ( -- )          \ Things to do at the start of window creation.
        ClassInit: SUPER    \ Do anything the class needs.

                                 \ set the default font type for printing
        s" Impact"      SetFaceName: aFont
        24              SetHeight: aFont
        true            SetUnderline: aFont
        VARIABLE_PITCH 0x04 or FF_SWISS or
                        SetPitchAndFamily: aFont

        s" CommonBullets" SetFaceName: bFont
        2                 SetCharSet: bfont
        30                SetHeight: bFont
        14                SetWidth: bFont
        FW_NORMAL         SetWeight: bFont
        VARIABLE_PITCH 0x04 or FF_MODERN or FF_DECORATIVE or
                          SetPitchAndFamily: bFont
        ;M

:M WindowTitle: ( -- title )         \ Title for the window.
        z" Non Stock Fonts " ;M

:M StartSize:   ( -- width height )  \ Set width and height of window
        600 180 ;M

:M StartPos:    ( -- x y )           \ Set the screen origin.
        80 100  ;M

:M Close:       ( -- )               \ Do anything the class needs.
        Destroy: tDC    \ delete the dc
        Destroy: aFont  \ delete the fonts no longer needed
        Destroy: bFont
        Close: super
        ;M

:M On_Init:     ( -- )

        \ Add a button.
        IDOK             SetID: Button_1
        self             Start: Button_1
        480 140 70 25     Move: Button_1
        s" CLOSE"      SetText: Button_1
                      GetStyle: Button_1 BS_DEFPUSHBUTTON OR
                      SetStyle: Button_1

        \ create the fonts
        Create: aFont
        Create: bFont
        ;M

:M On_Paint:  ( -- )          \ screen redraw procedure
        GetHandle: self GetDC: tDC
        if
             \ Output the first text string.
             \ Example of the Forth word s" and see the method TextOut: in dc.f
             \ Note TextOut: requires the length of the string.

             aFont SelectObject: tDC
             20 30 s" aFont AaBbCcDdEeFfGgHhIiJjKkLl"  TextOut: tDC

             bFont SelectObject: tDC drop
             20 80 s" bFont AaBbCcDdEeFfGgHhIiJjKkLl"  TextOut: tDC

             \ cleanup
             SelectObject: tDC drop
             Release: tDC
        then ;M

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
                Start: Fontdemo ;
demo

\ END OF LISTING.



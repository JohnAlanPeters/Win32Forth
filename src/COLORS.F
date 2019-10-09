\ $Id: COLORS.F,v 1.5 2013/11/15 19:35:03 georgeahubert Exp $
\ COLORS.F              The Colors Class                 by Tom Zimmer

cr .( Loading Object Color...)

needs gdi/gdiStruct.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Brushes and pens for defined colors are created at program initialization
\ time and are automatically deleted when the program terminates.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: RGB           ( red green blue -- colorref )
                PC_NOCOLLAPSE   \ flag             ( for NON-palette rgb value )
                256 * +         \ flag*256 + blue
                256 * +         \ flag*256 + blue*256 + green
                256 * + ;       \ flag*256 + blue*256 + green*256 + red

: PALETTERGB    ( red green blue -- colorref )
                PC_EXPLICIT     \ flag             ( for palette rgb value )
                256 * +         \ flag*256 + blue
                256 * +         \ flag*256 + blue*256 + green
                256 * + ;       \ flag*256 + blue*256 + green*256 + red

: PALETTEINDEX  ( index -- colorref )              \ return ref of system color
                PC_RESERVED 0x1000000 * or ;

variable colors-link            \ Global private link of all colors in system
         colors-link off

IN-SYSTEM

: .colors       ( -- )          \ Displays the current set of defined colors

                colors-link @
                begin   dup
                while   dup cell+ @ cell - body> .NAME
                        12 #tab space 12 ?cr
                        @
                repeat  drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ A utility word to check that an operation about to be performed is really
\ being done on a color object, helps prevent horrible crashes
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: (?ColorCheck) ( a1 -- a1 )
                ?win-error-enabled 0= ?EXIT \ leave if error checking is not enabled
                >r colors-link @
                begin   dup
                while   dup cell+ @ r@ =        \ match this color object?
                        if      drop r> EXIT    \ leave test, passed
                        then    @
                repeat  drop
                r>drop
                forth-io .rstack
                true Abort" This is not a ColorObject!" ;

in-previous

defer ?ColorCheck   ( a1 -- a1 )     \ verify that a1 is a color object address
\in-system-ok ' (?ColorCheck) is ?ColorCheck

in-system

: ImageSet?ColorSet  ( -- )
                 TURNKEYED? if ['] noop else ['] (?ColorCheck) then is-image ?ColorCheck ;

pre-save-image-chain chain-add ImageSet?ColorSet

in-previous

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Define the class of color objects. A color object returns its object
\ address if executed at the console, use "Color: <objectname>" to obtain
\ the color reference value of a color object.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class ColorObject  <Super Object



\ local data allocated for each color object that is defined.

gdiCOLORREF colorref    \ the actual color reference value
int hbrush              \ the brush handle
int hpen                \ the pen handle
int penwidth            \ width of the pen in pixels
int PenStyle            \ the style of the pen being created

:M ZeroColor:   ( -- )
                0 to hpen
                0 to hbrush
                ;M

:M UnInitColor: ( -- )
                hpen                    \ delete any already existing pen
                if      hpen   Call DeleteObject ?win-error
                        0 to hpen
                then
                hbrush                  \ delete any already existing brush
                if      hbrush Call DeleteObject ?win-error
                        0 to hbrush
                then    ;M

:M InitColor:   ( -- )  \ default initialization method, creates a pen
                        \ and a brush for each color object.
                UnInitColor: self       \ delete previous pens/brushes
                GetColor: colorref penwidth PenStyle Call CreatePen        to hpen
                GetColor: colorref                   Call CreateSolidBrush to hbrush
                ;M

:M ClassInit:   ( -- )  \ compile time initialization for each color object
                        \ as it is defined
                0 0 0 SetRGB: colorref
                0         to hpen
                0         to hbrush
                1         to penwidth
                PS_SOLID  to PenStyle
                colors-link link,
                InitColor: [ self ]
                self ,  ;M

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ internal initialization and un-initialization routines for color objects.
\ It seems Windows doesn't like a program that creates and destroys color
\ objects repeatedly as the program executes, so we need to do this at
\ program start only.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: trim-colors   ( nfa -- nfa )
                dup colors-link full-trim ;

forget-chain chain-add trim-colors

: zero-image-colors    ( -- )
                colors-link
                begin   @ ?dup
                while   dup cell+ @
                        >image ?dup if ZeroColor: ColorObject then
                repeat  ;

pre-save-image-chain chain-add zero-image-colors

in-previous

: init-colors   ( -- )         \ initialize brushes and pens
                colors-link @
                begin   dup
                while   dup cell+ @
                        InitColor: ColorObject
                        @
                repeat  drop ;

initialization-chain chain-add init-colors

: uninit-colors ( -- )        \ delete brushes and pens
                colors-link @
                begin   dup
                while   dup cell+ @
                        UnInitColor: ColorObject
                        @
                repeat  drop ;

unload-chain chain-add-before uninit-colors

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\               ******** Start of user methods ********
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:M Color:       ( -- colorref )                 \ get the colorref value
                GetColor: colorref ;M

:M Pen:         ( -- hpen )                     \ get the color pen handle
                hpen     ;M

:M Brush:       ( -- hbrush )                   \ get the color brush handle
                hbrush   ;M

:M NewColor:    ( colorref -- ) \ set a color object to a new color ref value
                dup GetColor: colorref <>
                if   SetColor: colorref
                     InitColor: [ self ]        \ create the new  pens/brushes
                else drop
                then ;M

:M Choose:      ( hWnd -- f )                   \ let the user choose a color
                Choose: colorref
                if   InitColor: [ self ] true   \ create the new  pens/brushes
                else false
                then ;M

:M CustomColors: ( -- addr len ) \ return address and length of the user defined
                                 \ custom colors
                CustomColors: colorref ;M

:M PenWidth:    ( pen_width -- )                \ set the pen width
                1 max dup penwidth <>
                if   to penwidth
                     InitColor: [ self ]
                else drop
                then ;M

;Class


:Class ExtColorObject  <Super ColorObject

int StyleCount
int lpStyle

 Record: &LOGBRUSH
        int lbStyle
        int lbColor
        int lbHatch
;Record

\ Use InitColor: to initialize an extended color object, after first
\ setting all the appropriate parameters of the extended color object,
\ using the dotted '.' notation.

:M InitColor:   ( -- )  \ default initialization method, creates a pen
                        \ and a brush for each color object.
                UnInitColor: self       \ delete previous pens/brushes
                GetColor: colorref to lbColor \ same as colorref
                lpStyle                 \ if not NULL
                StyleCount
                &LOGBRUSH
                penwidth PenStyle  Call ExtCreatePen     to hpen
                GetColor: colorref Call CreateSolidBrush to hbrush
                ;M


:M ClassInit:   ( -- )  \ compile time initialization for each color object
                        \ as it is defined
                ClassInit: self
                \ init the LOGBRUSH structure to some defaults
                BS_SOLID  to lbStyle
                GetColor: colorref  to lbColor
                NULL      to lbHatch
                \ init remaining parameters to defaults
                PS_GEOMETRIC
                PS_SOLID or
                PS_ENDCAP_ROUND or
                PS_JOIN_ROUND or to PenStyle
                0 to StyleCount
                NULL to lpStyle
                ;M


;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Pseudo defining word for creating the color objects we always want to
\ have around.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: new-color     ( colorref -<name>- )   \ make a solid color
                >APPLICATION
                ColorObject                     \ define a new object
                NewColor: [ NewObject ]     \ and initialize it
                APPLICATION> ;

in-application

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Now define the default color objects.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  0   0   0  palettergb new-color BLACK
128 128 128  palettergb new-color GRAY
192 192 192  palettergb new-color LTGRAY
 64  64  64  palettergb new-color DKGRAY
128   0   0  palettergb new-color RED
255   0   0  palettergb new-color LTRED
  0 128   0  palettergb new-color GREEN
  0 255   0  palettergb new-color LTGREEN
  0   0 128  palettergb new-color BLUE
  0   0 255  palettergb new-color LTBLUE
128 128   0  palettergb new-color YELLOW
255 255   0  palettergb new-color LTYELLOW
204   0 204  palettergb new-color DKMAGENTA  \ JaP
128   0 128  palettergb new-color MAGENTA
255   0 255  palettergb new-color LTMAGENTA
  0 128 128  palettergb new-color CYAN
  0 255 255  palettergb new-color LTCYAN
255 255 255  palettergb new-color WHITE
128  64   0  palettergb new-color BROWN


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ A class for HATCHED colors, HatchColorObject is a superset of ColorObject
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class HatchColorObject  <Super ColorObject

\ We just redefine the initialization method to work a little differently

:M InitColor:   ( -- )                  \ define color as a hatched color
                UnInitColor: self       \ delete previous pens/brushes
                GetColor: colorref penwidth PS_SOLID Call CreatePen        to hpen
                GetColor: colorref HS_DIAGCROSS      Call CreateHatchBrush to hbrush
                ;M

;Class

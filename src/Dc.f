\ $Id: Dc.f,v 1.21 2013/12/17 19:25:22 georgeahubert Exp $

cr .( Loading Device Context and Printing...)

\ dc.f BETA 24/09/2002 arm (minor) changed old Fxxx-FILE functions to use ANS file set
\ dc.f BETA 08/10/2002 arm Consolidation


((  Changes and enhancements are noted at the end of the file.  Use Ctrl+End to
  get there instantly.
))

in-application

needs gdi/gdiDC.f
needs colors.f
needs PrintSupport.f
needs Fonts.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ WinDC class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:CLASS WinDC   <Super gdiDC

\ int hDC         \ Handle to the device context
\                 \ I can't get rid of it since some old applications
\                 \ are accesing this ivar like this: dc.hDC

synonym hdc hobject

int currentfont

:M ClassInit:   ( -- )
        ClassInit: super
        0 to currentfont
        0 to hDC
        ;M

:M PutHandle:   ( hdc -- )
\        dup to hDC
        to hObject  ;M

:M DeleteObject:  ( object -- )
        Call DeleteObject ?win-error ;M

:M GetTextMetrics:  ( tm -- )
        GetTextMetrics: super >r swap r> move ;M

:M SetTextColor:  { color_object -- }
        color_object ?ColorCheck drop
        Color: color_object SetTextColor: super drop
        ;M

:M SetBkColor:  { color_object -- }
        color_object ?ColorCheck drop
        Color: color_object SetBackgroundColor: super drop
        ;M

:M SetBkMode:   ( mode  -- )
        SetBackgroundMode: super drop ;M

:M SaveDC:      ( -- )          \ Save current DC context and objects
        Save: super drop ;M     \ including the current font.

:M RestoreDC:   ( -- )  \ restore current DC context including font
        -1 Restore: super ;M

:M SetFont:     ( font_handle -- )
        dup to currentfont
        SelectObject: self drop
        ;M

:M GetFont:     ( -- font_handle )
        currentfont ;M

:M TabbedTextOut: ( x y addr len -- text_dimensions )
        TabbedTextOut: super word-join ;M

:M LineColor:   { color_object -- }
        color_object ?ColorCheck drop
        Pen: color_object SelectObject: super drop ;M

:M PenColor:    ( color_object -- )
        LineColor: self ;M

:M BrushColor:  { color_object -- }
        color_object ?ColorCheck drop
        Brush: color_object SelectObject: super drop ;M

:M MoveTo:      ( x y -- )
        MoveTo: super 2drop ;M

:M PolyDraw:    ( tptr pptr cnt -- )
        \ is ROT right?!? I think it should be 3REVERSE (dbu)
        rot hObject Call PolyDraw ?win-error ;M

:M SetROP2:     ( mode -- oldmode )
        SetROP: super ;M

:M SetPixel:    { x y color_object -- }
        color_object ?ColorCheck drop
        Color: color_object y x hObject Call SetPixel drop ;M

:M GetPixel:    ( x y -- colorref )   \ returns a "COLORREF", not a color object
        swap hObject Call GetPixel ;M

:M BitBlt:      ( blitmode sourcex,y sourcedc sizex,y destinationx,y -- )
        2>r 2>r >r swap r> 2r> swap 2r> swap
        8reverse BitBlt: super ;M

:M StretchBlt:  ( blitmode srcsizex,y srcx,y srcdc dstsizex,y dstx,y -- )
        2>r                             \ save dstx,y
        2>r                             \ save dstsizex,y
        >r                              \ save srcdc
        2>r                             \ save srcx,y
        swap                            \ swap srcsizex,y
        2r> swap                        \ recover, swap srcx,y
        r>                              \ recover srcdc
        2r> swap                        \ recover, swap dstsizex,y
        2r> swap                        \ recover, swap dstx,y
        hObject ( 11 win-parameters ) call StretchBlt ?win-error ;M

:M FillRect:    { color_object rectangle -- }
        color_object ?ColorCheck drop
        Left: rectangle Top: rectangle Right: rectangle Bottom: rectangle
        Brush: color_object
        FillRect: super
        ;M

:M FillArea:    { left top right bottom color_object -- }
        color_object ?ColorCheck drop
        left top right bottom
        Brush: color_object
        FillRect: super
        ;M

:M FillCircle:  { x y radius -- }
        x radius - y radius - x radius + y radius +
        Ellipse: self ;M

:M Circle:      { x y radius -- }
        x radius - y radius - x radius + y radius +
        0 0 0 0 Arc: self ;M

;class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ WinPrinter class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  0 value #PAGES-UP
644 value SCREEN-WIDTH          \ Width of screen in bits
484 value SCREEN-HEIGHT         \ Height of screen in bits
  0 value PRINTING?             \ are we currently printing?
  6 value PRINTER-LPI           \ line per inch of the printer
 10 value PRINTER-CPI           \ characters per inch of the printer
 62 value PRINTER-ROWS          \ line per page of the printer
 80 value PRINTER-COLS          \ columns on printer page
  0 value PRINTER-#OUT          \ characters output on this line of printer
  0 value PRINTER-#LINE         \ lines output to the printer on this page
  0 value MULTI-PAGE?           \ multiple pages per page flag
  0 value PRINTER?              \ are we outputing to a line printer
 16 value #XINDENT              \ nominal indentation of extended lines - rls

\ rls added constants and values:

0 constant PR_SCALED
1 constant PR_RAW

0         value ?tab
1         value XLineCount
pr_scaled value PRINTER-MODE
4800      value PRINTER-HSIZE
6350      value PRINTER-VSIZE
600       value PRINTER-HRES
600       value PRINTER-VRES
false     value PRINT-EXTENDED-LINES

INTERNAL

: _calc_font_height ( --- points_high )
                83 printer-lpi / ;

EXTERNAL

defer calc_font_height

' _calc_font_height is calc_font_height

FALSE value auto-on?            \ automatic printer initialization, no dialog
FALSE value direct-print?
 TRUE value border?             \ should a border be printed on each page

: XLCnt   ( charcnt -- n )  \ Extended Line Count used for printing - rls - page
        printer-#out +
        dup printer-cols <=
        IF      drop 1
        ELSE    #xindent 1+ - printer-cols #xindent - / 1+
        THEN ;

\ a1 points to a backwards string, a2 points to a forward string.  This routine
\ scans backwards to find a space, returns a forward string from there.

: -BLSCAN1        ( a1 n1 -- a2 n2 )                            \ rls - page
        dup>r bl -scan dup
        IF      r> swap - 1+
        ELSE    drop r> + 1+ 0
        THEN ;

: SplitLine     { a1 n1 \ a2 n2 n3 n4 -- a2 n2 indent a1 n1' }   \ rls - page
        n1 printer-#out + printer-cols >
        IF      printer-cols printer-#out - to n2
                n1 n2 - to n3
                n2 #xindent min to n4
                a1 n2 + 1- n4 -blscan1 dup to n4 n3 +
                bl skip                                 ( a2 n2 )
                #xindent n4 -                           \ indent on next line
                a1 n2 n4 - -trailing
        ELSE    a1 n1 + 0 a1 n1 0
        THEN ;

:Class WinPrinter <SUPER WinDC

int page#
int #pages
int scalex
int scaley
int borderx
int bordery
int midx
int midy
int drawlist
int drawoff
int drawing?
int drawmax
int penwidth
int page-ended?
int first-printed-page
int last-printed-page
int sequential-pages?
12 constant INT-BORDER-D
17 constant EXT-BORDER-D
int int-font
MAXSTRING bytes user-message-buf
MAXSTRING bytes user-title-buf
MAXSTRING bytes border-buf

ColorObject PRINTCOLOR
ColorObject PRINTFILLCOLOR

Font hFont
Font vFont
Font tFont
Font lFont

:M SetPrinterFont: ( a1 n1 -- )
        2dup SetFaceName: hFont
        2dup SetFaceName: vFont
        2dup SetFaceName: tFont
        SetFaceName: lFont
        ;M

:M ClassInit:   ( -- )
        ClassInit: super
        0 to #pages
        1 to page#
        0 to drawlist
        0 to drawoff
        0 to drawing?
        0 to int-font
        FALSE to sequential-pages?
        65536 to drawmax
        -1 to penwidth
        user-message-buf off
        user-title-buf off
        border-buf off
                                \ set the default font type for printing
        s" Courier New" SetPrinterFont: self
        FW_NORMAL Weight: tFont
        CLIP_TT_ALWAYS ClipPrecision: tFont
        FIXED_PITCH 0x04 or FF_MODERN or PitchAndFamily: tFont
        FW_NORMAL Weight: lFont
        CLIP_TT_ALWAYS ClipPrecision: lFont
        FIXED_PITCH 0x04 or FF_MODERN or PitchAndFamily: lFont
        FW_NORMAL Weight: hFont
        CLIP_TT_ALWAYS ClipPrecision: hFont
        FIXED_PITCH 0x04 or FF_MODERN or PitchAndFamily: hFont
        FW_NORMAL Weight: vFont
        CLIP_TT_ALWAYS CLIP_LH_ANGLES or ClipPrecision: vFont
        ( orientation in tenth degree increments ) 900 Orientation: vFont
        FIXED_PITCH 0x04 or FF_MODERN or PitchAndFamily: vFont
        ;M

:M UserMessage: ( a1 n1 -- )
        user-message-buf place
        ;M

:M UserTitle:   ( a1 n1 -- )
        user-title-buf place
        ;M

:M SetPage:     ( n1 -- )       \ set the page number of next page printed
        to page#
        ;M

:M SequentialState: ( flag -- )
        to sequential-pages?
        ;M

:M RefLineColor: ( colorref -- )    \ version for the printer, pen width two
        NewColor: PRINTCOLOR
        penwidth PenWidth: PRINTCOLOR
        Pen: PRINTCOLOR GetHandle: super Call SelectObject drop
        ;M

:M RefFillArea: { left top right bottom colorref -- }
        colorref NewColor: PRINTFILLCOLOR
                    Brush: PRINTFILLCOLOR
        left top right bottom SetRect: RECT
        RECT GetHandle: super
        ( 3 win-parameters ) Call FillRect ?win-error
        ;M

\ printer resolution function

:M Width:       ( -- horizontal-dots-on-page )
\         HORZRES GetHandle: super Call GetDeviceCaps
        HORZRES GetDeviceCaps: super
        ;M

:M Height:      ( -- vertical-dots-on-page )
\         VERTRES GetHandle: super Call GetDeviceCaps
        VERTRES GetDeviceCaps: super
        ;M

:M DPI:         ( -- horizontal-dots-per-inch  vertical-dots-per-inch )
\         LOGPIXELSX GetHandle: super Call GetDeviceCaps
\         LOGPIXELSY GetHandle: super Call GetDeviceCaps
        LOGPIXELSX GetDeviceCaps: super
        LOGPIXELSY GetDeviceCaps: super
        ;M

\ Modes for SetStretchBltMode:
\
\       BLACKONWHITE  COLORONCOLOR  WHITEONBLACK  HALFTONE

:M SetStretchBltMode:  ( mode_value -- )
        GetHandle: super Call SetStretchBltMode drop
        ;M

:M Nullify:     ( -- )                  \ mark the printer hdc as not in use
        0 PutHandle: super
        0 to drawlist
        0 to drawoff
        0 to drawing?
        ;M

: set-print-quality
        DPI: self drop
        quality-print dup 0<
        IF
                CASE    DMRES_HIGH   OF DPI: self drop          ENDOF
                        DMRES_MEDIUM OF DPI: self drop 2/       ENDOF
                        DMRES_LOW    OF DPI: self drop 4 /      ENDOF
                        DMRES_DRAFT  OF DPI: self drop 8 /      ENDOF
                                        DPI: self drop swap
                ENDCASE
\ 09/08/95 10:13 tjz added the ELSE section to deal with the fact that
\ Windows NT 3.51 returns zero (0) for print quality, which was interpreted
\ as a very low resolution printer. Now we limit low resolution printing
\ to 32 DPI or higher. When a resolution lower than that is encountered,
\ then we just use the HIGHEST resolution available.
        ELSE    dup 32 <                \ if really low resolution
                IF      drop            \ then use the highest
                        DPI: self drop  \ resolution available
                THEN
        THEN    1 max / 1 max to penwidth ;

int font-height
int tall?

: PORTRAIT?     ( -- flag )             \ True if portrait mode
        tall? #pages-up 2 =             \ For 2-up, reverse mode.
        IF      0=      THEN ;

: set-rows-cols   ( -- )                                \ rls - pages
        Height: self   to PRINTER-VSIZE
        DPI: self nip  to PRINTER-VRES
        Width: self    to PRINTER-HSIZE
        DPI: self drop to PRINTER-HRES
        multi-page? 2 =
        IF
                PRINTER-VSIZE printer-cpi PRINTER-VRES
                dup>r char-width / min r> */ to PRINTER-COLS
                PRINTER-HSIZE printer-lpi PRINTER-HRES
                dup>r char-height / min r> */ 1- to PRINTER-ROWS
        ELSE
                PRINTER-VSIZE printer-lpi PRINTER-VRES
                dup>r char-height / min r>
                */ 1- to PRINTER-ROWS                   \ set lines per page
                PRINTER-HSIZE printer-cpi PRINTER-HRES
                dup>r char-width / min r>
                */ to PRINTER-COLS                      \ set columns per line
        THEN ;

: set-print-params ( -- )                       \ rls - many changes
        Height: self Width: self > to tall?     \ tall page flag
        set-rows-cols
        Width:  self int-border-d / to borderx  \ calc scaling
        Height: self int-border-d / to bordery
        Width:  self borderx 2* - dup 2/ to midx  printer-cols / to scalex
        Height: self bordery 2* - dup 2/ to midy  printer-rows 1+ / to scaley
        calc_font_height to font-height

        printer-mode
        CASE    pr_scaled
                OF      screen-width to printer-hsize
                        screen-height to printer-vsize
                ENDOF
                pr_raw
                OF      DPI: self to printer-vres to printer-hres
                        Height: self to printer-hsize
                        Width: self to printer-vsize
                ENDOF
        ENDCASE

        0 to printer-#out
        0 to printer-#line
        set-print-quality ;

:M Open:        ( -- f1 )               \ open the printer for use
        printing? 0=
        IF      auto-on?
                IF      auto-print-init
                ELSE         print-init
                THEN    dup PutHandle: super
        ELSE    GetHandle: super
        THEN
        -IF     set-print-params
                0 to #pages
        THEN
        ;M

                                        \ rls February 5th, 2002 - 3:26
:M Open2:       ( bitmapped flags topage -- f1 )    \ open the printer for use
        printing? 0=
        IF      auto-on?
                IF      3drop auto-print-init
                ELSE         print-init2
                THEN    dup PutHandle: super
        ELSE    3drop GetHandle: super
        THEN
        -IF     set-print-params
                0 to #pages
        THEN
        ;M

:M AutoOpen:    ( -- f1 )               \ open the printer for use
        printing? 0=
        IF      auto-print-init dup PutHandle: super
        ELSE    GetHandle: super
        THEN
        -IF     set-print-params
                0 to #pages
        THEN
        ;M

:M Close:       ( -- )                  \ close the printer
        ;M

:M Landscape:   ( -- )
        TRUE print-orientation dup PutHandle: super
        IF      set-print-params
                0 to #pages
        THEN
        ;M

:M Portrait:    ( -- )
        FALSE print-orientation dup PutHandle: super
        IF      set-print-params
                0 to #pages
        THEN
        ;M

:M Start:       ( -- )                  \ start a new page and document
        GetHandle: super 0=     \ if not initialized
        penwidth -1 = or        \ or penwidth hasn't been set
        IF      Open: self      \ -- f1 = true if ready to print
        ELSE    GetHandle: super
                set-print-params
        THEN
        IF      print-start
                0 to printer-#out
                0 to printer-#line
                true to printing?
        THEN
        ;M

:M End:         ( -- )                  \ end current page and document
        printing?
        IF      end-page
                true to page-ended?
                print-end
                false to printing?
        THEN
        ;M

:M Setup:       ( window_handle -- )
        print-setup ?dup
        IF      PutHandle: super
                set-rows-cols
        THEN    ;M

:M DrawlistOpen: ( -- )
        drawlist 0=
        IF      drawmax malloc to drawlist
                drawlist 0=
                s" Out of memory error while Printing!" ?ErrorBox
                drawlist drawmax erase          \ prezero buffer
                0 to drawoff
        THEN
        ;M

:M DrawlistClose: ( -- )
        drawlist
        IF      drawlist release
                    0 to drawlist
                    0 to drawoff
                65536 to drawmax
        THEN
        ;M

:M PrinterStart: ( -- )
        DrawlistOpen: self
        multi-page? 0=
        IF      0 to drawoff
        THEN
        true to drawing?
        ;M

:M DrawingOff:  ( -- )
        false to drawing?
        ;M

 1 constant P_LINETO
 2 constant P_MOVETO
 3 constant P_TEXTOT
 4 constant P_TEXTOTR
 5 constant P_TEXTOTL
 6 constant P_LINECOLOR
 7 constant P_FILLAREA
 8 constant P_PAGE
 9 constant P_MPAGE
10 constant P_SETPIXEL
11 constant P_TEXTOTF
12 constant P_BEZIERTO
13 constant P_BEGINPATH
14 constant P_ENDPATH
15 constant P_FILLPATH
16 constant P_STROKEPATH
17 constant P_STROKEANDFILL

int offsety
int c-page

\ Put a border around the screen text

: draw-border
        { \ top left bottom right midwidth midheight foot1 foot2 head1 -- }
        border?                                 \ print a border on page?
        IF                                      \ setup the location pointers
                Width:  self ext-border-d /                   to left
                Height: self ext-border-d /                   to top
                Width:  self ext-border-d / ext-border-d 1- * to right
                Height: self ext-border-d / ext-border-d 1- * to bottom
                Height: self  2/                              to midheight
                Width:  self  2/                              to midwidth
                bottom top 20 / 2* +                          to foot1
                bottom top 20 / 7 * +                         to foot2
                top 5 / 3 *                                   to head1

                left  top    MoveTo: self       \ top left corner
                right top    LineTo: self       \ top line
                right bottom LineTo: self       \ right side line
                left  bottom LineTo: self       \ bottom line
                left  top    LineTo: self       \ left line

                multi-page? ?dup                \ split the pages per page
                IF  2 =
                    IF   Tall?
                         IF   left     midheight MoveTo: self   \ left middle
                              right    midheight LineTo: self   \ right middle
                         ELSE midwidth top       MoveTo: self   \ top middle
                              midwidth bottom    LineTo: self   \ bottom middle
                         THEN
                    ELSE left     midheight MoveTo: self        \ left middle
                         right    midheight LineTo: self        \ right middle
                         midwidth top       MoveTo: self        \ top middle
                         midwidth bottom    LineTo: self        \ bottom middle
                    THEN
                THEN

                Handle: tFont SetFont: self             \ select the tiny font

                s" Date: "                                border-buf  place
                get-local-time time-buf >month,day,year"  border-buf +place
                s"   "                                    border-buf +place
                get-local-time time-buf >am/pm"           border-buf +place
                s"    "                                   border-buf +place

                left foot1
                border-buf count TextOut: self          \ display the text
                left foot2
                user-message-buf count TextOut: self    \ display user message

                #pages
                IF      multi-page?
                        IF      s" Pages: "               border-buf  place
                                page# 1- multi-page? * 1+
                                0 <# #s #>                border-buf +place
                                s"  to "                  border-buf +place
                                page# 1- multi-page? * 1+ multi-page? 1- +
                        ELSE    s" Page: "                border-buf  place
                                page#
                        THEN    0 <# #s #>                border-buf +place
                        s"  of "                          border-buf +place
                        #pages 1+ 0 <# #s #>              border-buf +place
                        right                           \ from the right edge
                                                        \ back off by text width
                        border-buf count GetTextExtent: self drop -
                        foot1
                        border-buf count TextOut: self  \ display page of pages
                THEN
                user-title-buf c@                    \ if header text?
                IF      Handle: lFont SetFont: self  \ select line printer font
                        Width: self 2/               \ middle of page
                                                     \ center the title
                        user-title-buf count GetTextExtent: self
                        drop 2/ - 0max head1
                        user-title-buf count TextOut: self \ display the header
                THEN
                Handle: hFont SetFont: self             \ select horiz font
        THEN    ;

: ?page-started ( -- )
        page-ended?
        IF      start-page
                false to page-ended?
        THEN    ;

: print-page?   ( -- f1 )
        page# first-printed-page >= ;

: p-page        ( a1 n1 -- a1 n1 )
        page-ended? 0=          \ don't do more than one in sequence
        IF      print-page?
                IF      draw-border
                        end-page
                        true to page-ended?
                THEN
        THEN    1 +to page# ;

: p-mpage       ( -- )
        c-page multi-page? 1- =
        IF      p-page
                0 to c-page
        ELSE    1 +to c-page
        THEN    ;

: x-position    ( logicalx -- physicalx )
        PRINTER-MODE pr_raw = ?EXIT
        multi-page? ?dup
        IF      2 =
                IF      tall? 0=
                        IF
                                c-page 1 and
                                IF      1+ scalex * 2/ midx +
                                ELSE
                                        1- scalex * 2/
                                THEN
                        ELSE    scalex *
                        THEN
                ELSE    c-page 1 and
                        IF      1+ scalex * 2/ midx +
                        ELSE    1- scalex * 2/
                        THEN
                THEN
        ELSE    scalex *
        THEN
        borderx + ;

: y-position    ( logicaly -- physicaly )
        PRINTER-MODE pr_raw = ?EXIT
        multi-page? ?dup
        IF      2 =
                IF      tall?
                        IF      c-page 1 and
                                IF      1+ scaley * 2/ midy +
                                ELSE    1- scaley * 2/
                                THEN
                        ELSE    scaley *
                        THEN
                ELSE    c-page 2 and
                        IF      1+ scaley * 2/ midy +
                        ELSE    1- scaley * 2/
                        THEN
                THEN
        ELSE    scaley *
        THEN
        bordery + ;

: p-lineto      ( a1 n1 -- a1 n1 )
        print-page? 0= ?exit
        ?page-started
        over 1+ dup sw@ x-position
        swap    2 + sw@ y-position LineTo: self ;

: p-moveto      ( a1 n1 -- a1 n1 )
        print-page? 0= ?exit
        ?page-started
        over 1+ dup sw@ x-position
        swap    2 + sw@ y-position MoveTo: self ;

: p-textot      ( a1 n1 -- a1 n1 )      \ horizontal text (normal)
        print-page? 0= ?exit
        ?page-started
        over 1+  dup sw@           x-position
        swap 2 + dup sw@ offsety + y-position
        swap 2 +     count        TextOut: self ;

: p-textotr     ( a1 n1 -- a1 n1 )      \ vertical text
        print-page? 0= ?exit
        ?page-started
        over 1+  dup sw@           x-position
        swap 2 + dup sw@ offsety + y-position
        swap 2 +     count Handle: vFont SetFont: self
        TextOut: self
        Handle: hFont SetFont: self ;

: p-textotl     ( a1 n1 -- a1 n1 )      \ line printer text
        print-page? 0= ?exit
        ?page-started
        over 1+  dup sw@ x-position
        swap 2 + dup sw@ y-position
        swap 2 + count Handle: lFont SetFont: self
        TextOut: self
        Handle: hFont SetFont: self ;

: p-textotf     ( a1 n1 -- a1 n1 )      \ font-specifed text out
        print-page? 0= ?exit
        ?page-started
        over 1+ @ to int-font   \ get font object
        over 5 + dup sw@
        swap 2 + dup sw@
        swap 2 + count
        Handle: int-font SetFont: self
        TextOut: self
        Handle: hfont SetFont: self ;

: p-linecolor   ( a1 n1 -- a1 n1 )
        print-page? 0= ?exit
        ?page-started
        over 1+ @ ( colorref ) RefLineColor: self ;

: p-fillarea    ( a1 n1 -- a1 n1 )
        print-page? 0= ?exit
        ?page-started
        over 1+  >r r@ sw@ x-position
        r> 2 +   >r r@ sw@ y-position
        r> 2 +   >r r@ sw@ x-position
        r> 2 +   >r r@ sw@ y-position
        r> 2 +       @ ( colorref ) RefFillArea: self ;

: p-setpixel    ( a1 n1 -- a1 n1 )
        print-page? 0= ?exit
        ?page-started
        over 1+ >r
        r@     sw@ 1- x-position
        r@ 2 + sw@ 1- y-position
        r@     sw@ 1+ x-position
        r@ 2 + sw@ 1+ y-position
        r> 4 +   @ ( colorref ) RefFillArea: self ;

: p-bezierto    ( a1 n1 -- a1 n1 )                      \ only works RAW
        over 1+ count PolyBezierTo: self ;

: p-beginpath   ( a1 n1 -- a1 n1 )
        BeginPath: self ;

: p-endpath     ( a1 n1 -- a1 n1 )
        EndPath: self ;

: p-fillpath    ( a1 n1 -- a1 n1 )
        FillPath: self ;

: p-strokepath  ( a1 n1 -- a1 n1 )
        StrokePath: self ;

: p-strokeandfill ( a1 n1 -- a1 n1 )
        StrokeAndFillPath: self ;

:M SetPageLimits:   ( -- )
        get-frompage to first-printed-page
        get-topage   to  last-printed-page
        multi-page?
        IF      first-printed-page 1 umax
                1- multi-page? / 1+ to first-printed-page
                last-printed-page 1 umax
                1- multi-page? / 1+ to last-printed-page
        THEN ;M

:M PrinterEnd:   ( -- )
        drawlist
        IF      SetPageLimits: self
                0 drawlist drawoff + !                  \ NULL terminate list
                0 to c-page
                0 to page-ended?
                sequential-pages? 0=
                IF      1 to page#
                THEN
                set-print-quality                       \ init penwidth

\ tiny font for page labeling
                0 to offsety
                scalex 100 115 */ Width: tFont
                scaley 100 130 */ Height: tFont
                Create: tFont

\ line printer font
                scalex multi-page? ?dup
                IF      2 = tall? and 0=
                        IF      2/      THEN
                THEN
                Width: lFont                            \ set font width
                scaley multi-page? ?dup
                IF      2 = tall? 0= and 0=
                        IF      2/      THEN
                THEN
                Height: lFont
                Create: lFont

\ horizontal font (normal)
                scalex multi-page? ?dup
                IF      2 = tall? and 0=
                        IF      2/      THEN
                THEN
                Width: hFont
                scaley multi-page? ?dup
                IF      2 = tall? 0= and 0=
                        IF      2/      THEN
                THEN
                Height: hFont
                Create: hFont

\ vertical font
                scalex multi-page? ?dup
                IF      2 = tall? and 0=
                        IF      2/      THEN
                THEN
                Width: vFont
                scaley multi-page? ?dup
                IF      2 = tall? 0= and 0=
                        IF      2/      THEN
                THEN
                Height: vFont Create: vFont

                Start:  self
                drawlist            \ starting at the top of the list
                BEGIN count dup     \ proceed through each record
                                    \ stop if not within desired page range
                    page# last-printed-page <= and
                WHILE over c@
                    CASE   P_LINETO OF p-lineto        ENDOF
                           P_MOVETO OF p-moveto        ENDOF
                           P_TEXTOT OF p-textot        ENDOF   \ scaled
                          P_TEXTOTR OF p-textotr       ENDOF   \ rotated
                          P_TEXTOTL OF p-textotl       ENDOF   \ LPT
                          P_TEXTOTF OF p-textotf       ENDOF   \ specific font
                        P_LINECOLOR OF p-linecolor     ENDOF
                         P_FILLAREA OF p-fillarea      ENDOF
                             P_PAGE OF p-page          ENDOF
                            P_MPAGE OF p-mpage         ENDOF
                         P_SETPIXEL OF p-setpixel      ENDOF
                         P_BEZIERTO OF p-bezierto      ENDOF
                        P_BEGINPATH OF p-beginpath     ENDOF
                          P_ENDPATH OF p-endpath       ENDOF
                         P_FILLPATH OF p-fillpath      ENDOF
                       P_STROKEPATH OF p-strokepath    ENDOF
                    P_STROKEANDFILL OF p-strokeandfill ENDOF
                    ENDCASE
                    +
                REPEAT  2drop

                page-ended? 0=
                IF      p-page
                        sequential-pages? 0=
                        IF      first-printed-page to page#
                        THEN
                THEN
                print-end
                false to printing?
                Delete: hFont
                Delete: vFont
                Delete: tFont
                Delete: lFont
        THEN
        false to drawing?
        GetHandle: super
        IF      print-close
                0 PutHandle: super
        THEN
        ;M

: drawlist_overflow? ( -- )
        drawoff drawmax MAXSTRING - u>
        IF      drawmax 65536 + dup drawlist realloc
                s" Failed to Expand the DRAWLIST!" ?ErrorBox
                to drawlist                     \ set new buffer addr
                drawlist drawmax + 65536 erase  \ clear extra buffer
                to drawmax                      \ set new buffer len
        THEN    ;

: d-c,          ( c1 -- )               \ compile a BYTE
        drawlist drawoff + c!
        1 +to drawoff drawlist_overflow? ;

: d-w,          ( w1 -- )               \ compile a WORD
        drawlist drawoff + w!
        2 +to drawoff drawlist_overflow? ;

: d-,           ( c1 -- )               \ compile a CELL
        drawlist drawoff + !
        cell +to drawoff drawlist_overflow? ;

MAXCOUNTED 10 - CONSTANT string-max     \ later 6 is added to this, and the sum
                                        \ must be less than MAXCOUNTED

: d-",          ( a1 n1 -- )            \ compile a string
        string-max min                  \ clip to max allowed string
        dup>r
        drawlist  drawoff + place
        r> 1+ +to drawoff drawlist_overflow? ;

int lastcall

:M PrinterLineto: ( x y -- )
        drawing?                        \ we are drawing
        IF      lastcall P_MOVETO =
                IF      drawlist drawoff + >r
                        2dup r@ 2 - sw@ =
                        swap r> 4 - sw@ = and 0=
                ELSE    true
                THEN
                IF
                        5 d-c,                  \ record data length is 5 bytes
                        P_LINETO to lastcall
                        P_LINETO  d-c,          \ opcode
                        swap d-w, d-w,          \ x and y
                ELSE    2drop
                        -6 +to drawoff
                        0 drawlist drawoff + !  \ null terminate list
                THEN
        ELSE    2drop
        THEN    ;M

:M PrinterMoveto: ( x y -- )
        drawing?                        \ we are drawing
        IF      5 d-c,                  \ record data length is 5 bytes
                P_MOVETO to lastcall
                P_MOVETO  d-c,          \ opcode
                swap d-w, d-w,          \ x and y
        ELSE    2drop
        THEN    ;M

:M PrinterBezierTo: ( addr cnt -- )     \ cnt is number of points
                                        \ in the array at addr
        drawing?
        IF      dup 3 mod
                IF      2drop           \ error if not multiple of 3
                ELSE    P_BEZIERTO to lastcall
                        BEGIN   dup 30 >        \ we can't exceed 253/(8*cnt)
                        WHILE   30 -            \ adjust cnt
                                242 d-c,
                                P_BEZIERTO d-c,
                                30 d-c,         \ count of "points"
                                over 240 d-",
                                30 +
                        REPEAT
                        dup
                        IF      dup 8 * 2 + c,
                                P_BEZIERTO d-c,
                                dup d-c,
                                8 * d-",
                        ELSE    2drop
                        THEN
                THEN
        ELSE    2drop
        THEN    ;M

:M PrinterBeginPath: ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_BEGINPATH to lastcall
                P_BEGINPATH d-c,        \ opcode
\ April 20th, 1998 - 16:34 tjz removed
\       ELSE    drop
        THEN    ;M

:M PrinterEndPath: ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_ENDPATH to lastcall
                P_ENDPATH d-c,          \ opcode
\ April 20th, 1998 - 16:34 tjz removed
\       ELSE    drop
        THEN    ;M

:M PrinterStrokePath: ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_STROKEPATH to lastcall
                P_STROKEPATH d-c,        \ opcode
\ April 20th, 1998 - 16:34 tjz removed
\       ELSE    drop
        THEN    ;M

:M PrinterFillPath: ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_FILLPATH to lastcall
                P_FILLPATH d-c,         \ opcode
        THEN    ;M

:M PrinterStrokeAndFill: ( -- )
        drawing?
        IF      1 d-c,                      \ record length is 1 byte + count
                P_STROKEANDFILL to lastcall
                P_STROKEANDFILL d-c,        \ opcode
        THEN    ;M

:M PrinterTextOut: ( x y addr len -- )
        drawing?                        \ we are drawing
        IF      string-max min          \ clip to max allowed string
                dup 6 +   d-c,    \ record length 2 words + opcode + string cnt
                P_TEXTOT  to lastcall
                P_TEXTOT  d-c,          \ opcode
                2swap
                swap d-w, d-w,          \ x and y
                d-",                    \ text string
        ELSE    4drop
        THEN    ;M

:M PrinterTextOutFont: ( x y addr len font_object -- )
        drawing?
        IF      >r string-max min
                dup 10 + d-c,      \ str_len+draw_len opcode font4 x2 y2 str len
                P_TEXTOTF to lastcall
                P_TEXTOTF d-c,                  \ opcode
                r> d-,                          \ font object
                2swap swap d-w,                 \ x-position (raw)
                d-w,                            \ y-position (raw)
                d-",                            \ string
        ELSE    4drop drop
        THEN    ;M

:M PrinterRotatedTextOut: ( x y addr len -- )
        drawing?                                \ we are drawing
        IF      string-max min                  \ clip to max allowed string
                dup 6 +   d-c,          \ record length 2 words + opcode + count
                P_TEXTOTR to lastcall
                P_TEXTOTR d-c,                  \ opcode
                2swap
                swap d-w, d-w,                  \ x and y
                d-",                            \ text string
        ELSE    4drop
        THEN    ;M

:M LPTPrinterTextOut: ( addr len -- )
        drawing?                                \ we are drawing
        IF      string-max min                  \ clip to max allowed string
                dup 6 +   d-c,  \ record length 2 words + opcode + string cnt
                P_TEXTOTL to lastcall
                P_TEXTOTL d-c,                  \ opcode
                printer-#out  d-w,              \ col
                printer-#line d-w,              \ row
                d-",                            \ text string
        ELSE    2drop
        THEN ;M

\ January 20th, 1997 tjz
\ changed this definition to save the color reference, rather than saving the
\ color object, since some applications, particularly WINDEMO.F, use the same
\ color object over and over again, just changing the color in the object.
\ We now save the color reference, so we can correctly regenerate the needed
\ color when printing occurs.

:M PrinterLineColor: { color_object -- }
        color_object ?ColorCheck drop
        drawing?
        IF      5 d-c,                  \ record length is 5 bytes + count
                P_LINECOLOR to lastcall
                P_LINECOLOR d-c,        \ opcode
                Color: color_object d-, \ compile the colorref of cur color obj
        THEN    ;M

:M PrinterFillArea: { left top right bottom color_object -- }
        color_object ?ColorCheck drop
        drawing?
        IF      13 d-c,                 \ record is 13 bytes + count
                P_FILLAREA to lastcall
                P_FILLAREA d-c,         \ opcode
                left  d-w, top    d-w,
                right d-w, bottom d-w,
                Color: color_object d-, \ compile the colorref of cur color obj
        THEN    ;M

:M PrinterPage:  ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_PAGE to lastcall
                P_PAGE d-c,             \ opcode
                1 +to #pages
        THEN    ;M

:M PrinterMultiPage: ( -- )
        drawing?
        IF      1 d-c,                  \ record length is 1 byte + count
                P_MPAGE to lastcall
                P_MPAGE d-c,            \ opcode
                1 +to #pages
        THEN    ;M

:M PrinterSetPixel: { xpos ypos color_object -- }
        color_object ?ColorCheck drop
        drawing?
        IF      9 d-c,                  \ record is 9 bytes + count
                P_SETPIXEL to lastcall
                P_SETPIXEL d-c,         \ opcode
                xpos d-w,
                ypos d-w,
                Color: color_object d-, \ compile the colorref of cur color obj
        THEN    ;M

1 bytes emit_buffer

:M Page:        ( -- )                  \ start a new page
        multi-page?
        IF      PrinterMultiPage: self
        ELSE         PrinterPage: self
        THEN
        0 to printer-#line
        0 to printer-#out
        ;M

:M Cr:          ( -- )
        1 +to printer-#line
        0  to printer-#out
        printer-#line printer-rows >=
        IF      Page: self
        THEN
        ;M

: >tab          ( -- )
        \ TAB-SIZE is not right, but ok for now
        printer-#out tabwidth / 1+ tabwidth *
        printer-cols 1- min printer-#out -
        BEGIN   dup 0>
        WHILE   dup spcs-max min
                spcs over dup>r LPTPrinterTextOut: self
                r> +to printer-#out -
        REPEAT drop ;

:M ?Cr:         ( n1 -- )
        printer-#out + printer-cols >
        IF      Cr: self
        THEN
        ;M

:M Emit:        ( c1 -- )
        emit_buffer c!
        emit_buffer 1 LPTPrinterTextOut: self
        1 +to printer-#out
        ;M

: Type1Line   { a1 n1 \ a2 n2 n3 -- a2 n2 n3 }          \ rls - page
        BEGIN
                a1 n1 k_tab scan to n2  to a2           \ try to print upto tab
                n1 n2 - to n3
                n1 n2 - printer-#out + printer-cols >   \ is line too long?
                IF
                        a1 n1 SplitLine dup to n1      \ Print to max - margin
                        LPTPrinterTextOut: self
                        n1 +to printer-#out             \ update current pos.
                        to n2 to n1 to a1 0
                ELSE
                        a1 n3 LPTPrinterTextOut: self   \ print to possible tab
                        n3 +to printer-#out
                        >tab a2 n2 1 /string            \ then do a tab, if any
                        to n1  to a1                    \ and
                        0 to n2
                        n1
                THEN
                0=
        UNTIL
        a1 n1 n2 ;

:M Type:  { a1 n1 \ n2 -- }                             \ rls - page
        PRINT-EXTENDED-LINES
        IF
                n1 xlcnt to XLineCount
                a1 n1 k_tab scan to n2 drop
                n2 0<> to ?tab
                a1 n1 Type1Line to n2  to n1  to a1
                XLineCount 1
                ?DO
                        Cr: self  -2 to printer-#out
                        ascii + Emit: self  ?tab
                        IF      0
                        ELSE    n2
                        THEN
                        to printer-#out
                        a1 n1 Type1Line to n2  to n1  to a1
                LOOP
        ELSE    a1 n1
                BEGIN   2dup k_tab scan 2dup 2>r nip -
                        dup>r
                        LPTPrinterTextOut: self
                        r> +to printer-#out
                        2r> dup
                WHILE   >tab
                        1 /string
                REPEAT  2drop
        THEN
        ;M

;CLASS

WinPrinter ThePrinter

INTERNAL

: start-printer  ( -- f1 )
        direct-print?
        IF true to auto-on?
        THEN
        Open: ThePrinter dup
        IF      PrinterStart: ThePrinter
        THEN    ;

EXTERNAL

                                \ rls February 5th, 2002 - 3:36
: start-printer2  ( bitmapped flags topage -- f1 )
        direct-print?
        IF true to auto-on?
        THEN
        Open2: ThePrinter dup
        IF      PrinterStart: ThePrinter
        THEN    ;

: page-setup    ( -- )
        conhndl Setup: ThePrinter  ;

: start-scaled  ( -- f1 )
        pr_scaled to printer-mode
        start-printer ;

                        \ rls February 5th, 2002 - 8:48
: start-scaled2  ( bitmapped flags topage -- f1 )
        pr_scaled to printer-mode
        start-printer2 ;

: start-raw  ( -- f1 )
        pr_raw to printer-mode
        start-printer ;

: start-raw2  ( bitmapped flags topage -- f1 )  \ rls February 5th, 2002 - 8:48
        pr_raw to printer-mode
        start-printer2 ;

: print-multi-page ( -- )
        multi-page?
        IF         PrinterEnd: ThePrinter
                DrawlistClose: ThePrinter
                false to multi-page?
                SetPageLimits: ThePrinter
        THEN    ;

: page-scaled   ( -- )
        Page: ThePrinter ;

: print-scaled  ( -- )
        multi-page? 0=
        IF             PrinterEnd: ThePrinter
                    DrawlistClose: ThePrinter
        ELSE     PrinterMultiPage: ThePrinter
                       DrawingOff: ThePrinter
                false to printing?
        THEN    ;

: single-page   ( -- )
        multi-page?
        IF      s" Spooling Printing to Windows" "message
                print-multi-page
                300 ms message-off
        THEN    ;

\ synonym 1page    single-page
\ synonym one-page single-page

: two-page      ( -- )
        2 to multi-page?
        SetPageLimits: ThePrinter ;

\ synonym 2page two-page

: four-page     ( -- )
        4 to multi-page?
        SetPageLimits: ThePrinter ;

\ synonym 4page four-page

INTERNAL

: _pemit        ( c1 -- )
        Emit: ThePrinter ;

: _ptype        ( a1 n1 -- )
        0max bounds
        ?DO     i c@ Emit: ThePrinter
        LOOP ;

: _pgetcolrow   ( -- cols rows )
        printer-cols printer-rows ;

: _pgetxy       ( -- x y )
        printer-#out printer-#line ;

: _pgotoxy      ( x y -- )
        to printer-#line to printer-#out ;

: _pcr          ( -- )
        Cr: ThePrinter ;

: _p?cr         ( n1 -- )
        ?Cr: ThePrinter ;

: _ppage        ( -- )
        Page: ThePrinter ;

EXTERNAL

: PRINTER       ( -- )
        true to printer?
        start-scaled
        IF      ['] _pemit      is emit
                ['] _ptype      is type
                ['] _pgetcolrow is getcolrow
                ['] _pgetxy     is getxy
                ['] _pgotoxy    is gotoxy
                ['] _pcr        is cr
                ['] _p?cr       is ?cr
                ['] _ppage      is cls
        ELSE    false to printer?
        THEN    ;

INTERNAL

: console-forth-io ( -- )
        print-scaled
        direct-print?
        IF      false to auto-on?
        THEN
        false to direct-print?
        false to printer? ;

' FORTH-IO is console

FORTH-IO-CHAIN CHAIN-ADD console-forth-io

EXTERNAL

: PRINT         ( -- )
        printer
        printer?
        IF      source UserTitle: ThePrinter
                interpret
        THEN    console ;

\ type filename a1 to the printer
: $fprint       { the-name \ message$ fpr$ locHdl -- }
        MAXSTRING LocalAlloc: fpr$
        MAXSTRING localAlloc: message$
        the-name $open abort" Couldn't open file!" to locHdl
        cur-line off
        printer
        printer?
        IF      s" Printing file: " message$  place
                open-path$ count    message$ +place
                                    message$ count "message
                s" File: "          message$  place
                open-path$ count    message$ +place
                                    message$ count UserMessage: ThePrinter
                cr
                BEGIN   fpr$ dup MAXCOUNTED locHdl read-line
                        abort" Read Error"
                WHILE   Type: ThePrinter cr
                REPEAT  2drop
        THEN
        console
        locHdl close-file drop
        message-off ;

: FPRINT        ( -<name>- )
        /parse-word $fprint ;

: 2print        ( -- )
        two-page fprint single-page ;

: 4print        ( -- )
        four-page fprint single-page ;

: RowString ( row -- a n )   \ address and length of row (without CR)
        &the-screen zcount  rot 0 ?DO  13 scan 1 /string 10 skip  LOOP
        2dup 13 scan nip - ;

: #print-screen ( start_line lines -- ) \ print a range of lines from saved
                                        \ Forth screen buffer
        cursor-off
        #pages-up ?dup
        IF      2 =
                IF      two-page
                ELSE    four-page
                THEN
        THEN
        printer
        printer?
        IF      ( -- start lines )
                bounds
                DO
                        i RowString
                        -trailing                         \ addr len
                        Type: ThePrinter
                        Cr: ThePrinter                    \ next line
                LOOP
        ELSE    2drop
        THEN    console single-page cursor-on ;

: print-screen  ( -- )       \ print the physical screen
        getrowoff rows       \ print from first visible row to last visible row
        #print-screen ;

: print-console ( -- )       \ print all lines used in screen save buffer
        0 getrowoff rows +   \ print from row 0 to last visible row (not lines scrolled off the bottom)
        #print-screen ;

INTERNAL

: _printer-release ( -- )               \ release the printer DC if allocated
        DrawlistClose: ThePrinter
        Close: ThePrinter ;

unload-chain chain-add-before _printer-release    \ add to termination chain

: _nullify-printer ( -- )               \ mark printer as not used yet
        Nullify: thePrinter ;

initialization-chain chain-add _nullify-printer

EXTERNAL

MODULE

\S

This file has had extensive changes by rls (Robert L. Smith, nickname: Bob).
The most important addition is the ability to print excessively long source
lines.  A new value named PRINT-EXTENDED-LINES has been added, and the Type:
function has been changed.  A number of other changes have been made to simplify
some of the complicated code in here.

2-up printing has an improved format.

\ HexViewer.F    Adapted from FileDump.f

needs ExUtils.f

:class HexViewer <super child-window

int screen-cols
int screen-rows
0 constant first-line#    \ first line number
int last-line#            \ last line number
int last-top-line#
int cur-first-line        \ current first line position
16 constant bytes/line
int buff-len              \ length of the buffer
int buff-ptr              \ address of the buffer
int eob-ptr               \ end of buffer pointer

Font fdFont

Record: ScrollInfo
    int cbSize
    int fMask
    int nMin
    int nMax
    int nPage
    int nPos
    int nTrackPos
;RecordSize: sizeof(ScrollInfo)

:M classinit:   ( -- )
        classinit: super
        sizeof(ScrollInfo) to cbSize
        SIF_ALL to fMask
        NextID to ID
        0 to buff-ptr
        0 to buff-len
        0 to eob-ptr
        200 to last-line#
        last-line# 20 - to last-top-line#
        ;M

: set-scrollinfo ( -- )
        screen-rows  to nPage
        cur-first-line to nPos
        last-line# 1- to nMax  first-line# to nMin
        true ScrollInfo SB_VERT hWnd Call SetScrollInfo drop
        ;

: set-params ( -- )
        width char-width / to screen-cols
        height char-height / to screen-rows
        last-line# screen-rows - 0max to last-top-line#
        ;

: release-buffptr   ( -- )
                    buff-ptr ?dup
                    if      release
                            0 to buff-ptr
                    then    ;
                           
: alloc-buffptr  { size -- }
                release-buffptr
                size cell+ malloc to buff-ptr ;

:M On_Init:     ( -- )
                On_Init: super
        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong drop
                 8  Width: fdFont
                14 Height: fdFont
  s" Courier" SetFaceName: fdFont
                   Create: fdFont
                ;M

:m startpos: 0 0 ;m

:m startsize: 75 char-width *  20 char-height * ;m

\ The following routines for hex viewing adapted from "Dump" in kernel
: H.R           ( n1 -- )    \ display n1 as a hex number right
                                \ justified in a field of 8 characters
                BASE @ >R HEX
                0 <# #S #> 8 OVER - +spaces append
                R> BASE ! ;


: H.2           ( n1 -- )    \ display n1 as a HEX number of n2 digits
                BASE @ >R HEX
                0 <# 2 0 ?DO # LOOP #> append
                R> BASE ! ;

: EMIT.         ( n -- )
                DUP BL 255 BETWEEN 0= IF  DROP [CHAR] .  THEN  cappend ;

: dump-line     { n -- addr cnt }  ( hex byte format with ascii )
                initbuffer
                n bytes/line * buff-ptr + dup 16 + eob-ptr >=   \ limit dump
                if      eob-ptr over -                          \ to available
                else    bytes/line                              \ characters
                then    over +no-wrap dup rot
                ?do     i h.r s"  | " append
                        i 16 +no-wrap over umin i
                        2dup
                        do      i c@ h.2
                                bl cappend
                                i j 7 + = if bl cappend then
                        loop    2dup -  16 over - 3 *  swap 8 < -  +spaces
                        s" |" append
                        do      i c@ emit.
                        loop    s" |" append
            16 +loop    drop    TheBuffer ;
            
:M on_paint: ( -- )
            0 0 GetSize: self WHITE FillArea: dc
            buff-ptr 0= ?exitm
                SaveDC: dc                      \ save device context
                Handle: fdFont SetFont: dc      \ set the font to be used
                screen-rows 1+ 0
                do 0 char-height i *
                        i cur-first-line + dup last-line# >=
                        if  drop spcs 80
                        else dump-line
                        then textout: dc
                loop
                RestoreDC: dc
                ;M

:M WindowStyle: ( -- style )            \ return the window style
                WindowStyle: super
                WS_VSCROLL or           \ add vertical scroll bar
                ;M

:M VPosition: ( n -- )   \ move to position n
        cur-first-line swap   \ save previous cur-first-line on stack
        0max last-top-line# min to cur-first-line
        cur-first-line - char-height * 0 swap Scroll: self  \ scroll rather than repaint
        set-scrollinfo ;M

:M VScroll: ( n -- )   \ move n lines up or down
        cur-first-line + VPosition: self ;M

:M Home: ( -- )
        first-line# VPosition: self ;M

:M End: ( -- )   \ move to end, in this case it's 100 bytes down to pad
        last-top-line# VPosition: self ;M

:M VPage: ( n -- )   \ down or up n pages
        screen-rows 1- * VScroll: self ;M

:M WM_VSCROLL   ( h m w l -- res )
                swap word-split >r
        CASE
                SB_BOTTOM        of          End: self   endof
                SB_TOP           of         Home: self   endof
                SB_LINEDOWN      of    1 VScroll: self   endof
                SB_LINEUP        of   -1 VScroll: self   endof
                SB_PAGEDOWN      of    1   VPage: self   endof
                SB_PAGEUP        of   -1   VPage: self   endof
                SB_THUMBPOSITION of r@ VPosition: self   endof
                SB_THUMBTRACK    of r@ VPosition: self   endof
        ENDCASE r>drop
        0 ;M

: hex-view    ( a1 n1 -- )
            dup to buff-len alloc-buffptr           \ keep my own copy, just in case
            buff-ptr buff-len move
            hwnd 0= ?exit
            buff-len bytes/line /mod swap
            if       1+
            then     to last-line#
            buff-ptr buff-len + to eob-ptr
            set-params
            home: self
            paint: self ;

:M Dump:     ( addr cnt -- )
             hex-view ;M

:m on_done: ( -- )
            release-buffptr
            Delete: fdFont
            on_done: super ;m

:M on_size: ( -- )
        set-params
        set-scrollinfo
        cur-first-line last-top-line# > IF  -1 VScroll: self  THEN
        ;M

:M AutoSize:    ( -- )
                tempRect.AddrOf GetClientRect: Parent
                0 0 Right: tempRect Bottom: tempRect \ x,y,w,h
                Move: self
                ;M
                
:M ~:           ( -- )
                release-buffptr ;m

;class

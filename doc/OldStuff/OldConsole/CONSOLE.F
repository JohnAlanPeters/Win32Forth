\ $Id: CONSOLE.F,v 1.1 2008/08/19 04:29:21 camilleforth Exp $

\    File: Console.f
\  Author: Dirk Busch
\ Created: November 9th, 2003 - 10:32 dbu
\ Updated: January 14th, 2004 - 13:09 dbu
\
\ Win32Forth Terminal I/O (Moved here from Primutil.f )

cr .( Loading... Console I/O Part 1)

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       get console window handle
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

defer conHndl ' _conHndl is conHndl \ so we can change it later


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Keyboard Mask Constant, MUST MATCH THOSE IN TERM.H !!
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

   65536 (   0x10000 ) constant function_mask \ function key maks
  131072 (   0x20000 ) constant special_mask  \ special keyboard key mask
  262144 (   0x40000 ) constant control_mask  \ control key mask
  524288 (   0x80000 ) constant shift_mask    \ shift key mask
 1048576 (  0x100000 ) constant alt_mask      \ alt key mask
 2097152 (  0x200000 ) constant mouse_mask    \ mouse operations
 4194304 (  0x400000 ) constant menu_mask     \ menu operations
    8192 (  0x002000 ) constant proc_mask     \ procedure base mask
16777216 ( 0x1000000 ) constant double_mask   \ double click mask
33554432 ( 0x2000000 ) constant down_mask     \ mouse down mask
67108864 ( 0x4000000 ) constant up_mask       \ mouse up mask


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ sound stuff
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
VARIABLE TONE_FREQ 700 TONE_FREQ !
VARIABLE TONE_DURA  50 TONE_DURA !
2 PROC Beep

: TONE          ( frequency duration-ms -- )
                swap call Beep drop ;

: BEEP!         ( frequency duration-ms -- )
                TONE_DURA ! TONE_FREQ ! ;

: _BEEP         ( -- )
                tone_freq @ tone_dura @ tone ;

defer beep   ' _beep  is beep   \ default sound stuff

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ define some deferred words with their functions, and defaults
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

defer page ' cls    is page

\ the next two words are deprecated because changeing the
\ console font doesn't realy work
defer >bold  DEPRECATED \ ' noop   is >bold  \ set bold font in console window
defer >norm  DEPRECATED \ ' noop   is >norm  \ set normal font in console window

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Some words that improve compatibility with existing F-PC code.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

synonym SP>COL COL      DEPRECATED
synonym AT-XY  gotoxy  \ ANS Version of gotoxy

: cols          ( -- n1 )               \ current screen columns
                getcolrow drop ;

: rows          ( -- n1 )               \ current screen rows
                getcolrow nip ;

\ 0 value accept-cnt                      \ current count of chars accepted
\ : _faccept      ( a1 n1 -- n2 )
\                 0 swap 0
\                 ?do     drop
\                         i to accept-cnt \ save in case we need it
\                         key
\                         case  8 of      i 1 <           \ if input is empty
\                                         if      0       \ do nothing but
\                                                 beep    \ beep at user
\                                         else    1-      \ decrement address 1
\                                                 -1      08 emit
\                                                         bl emit
\                                                         08 emit
\                                         then
\                                                                         endof
\                              27 of      dup c@ emit 1+ 1                endof
\                              13 of      i leave                         endof
\                                         dup emit
\                                         2dup swap c!    \ place the character
\                                         swap 1+ swap    \ bump the address
\                                         1 swap          \ loop increment
\                         endcase         i 1+ swap       \ incase loop completes
\                +loop    nip ;
\
\ ' _faccept is accept

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Words that position on the screen
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

 8 value tab-size
 8 value left-margin
 4 value right-margin
 0 value tab-margin
 5 value tabs-max
 0 value tabing?        \ are we tabing, default to no
 0 value first-line?    \ is this the first line of a paragraph
-8 value indent         \ indent/outdent spaces

: wrap?         ( n1 -- f1 )    \ return true if column n1 crosses into the
                                \ right margin area
                getcolrow drop right-margin - > ;


: tab-wrap?     ( n1 -- f1 )    \ return true if column exceeds the maximum
                                \ desired tabs, or crosses into the right
                                \ margin area
                dup tabs-max tab-size * >
                swap wrap? or ;

: TAB           ( -- )
                getxy drop tab-size / 1+ tab-size * col ;

: 0TAB          ( -- )          \ left margin goes to left edge of screen
                0 to tab-margin ;

: +TAB          ( --- )
                tab-size +to tab-margin
                tab-margin tab-wrap?
                IF      0tab
                THEN    ;

: -TAB          ( --- )
                tab-margin tab-size - 0 MAX DUP to tab-margin
                tab-size <
                IF      tabs-max tab-size * to tab-margin
                THEN    ;

: FIRST-LINE    ( -- )          \ set first line flag
                true to first-line?
                0tab ;

: TABING-ON     ( -- )
                true to tabing? ;

: TABING-OFF    ( -- )
                false to tabing? ;

synonym tabbing-off tabing-off
synonym tabbing-on  tabing-on

: x_CRTAB       ( -- )
                x_cr \ fixed stack overflow bug November 15th, 2003 - 13:26 dbu
                tabing? 0= ?exit
                first-line?
                if      left-margin indent + spaces
                        false to first-line?
                else    left-margin spaces
                        tab-margin spaces
                then    ;

DEFER CRTAB ' x_CRTAB IS CRTAB

: ?LINE         ( n1 -- )
                0 max getxy drop + wrap?
                if      cr
                then    ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Additional words for the console
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WINLIBRARY W32FCONSOLE.DLL
1 PROC k_fpushkey
2 PROC c_setfgbg
0 PROC c_getfg
0 PROC c_getbg
0 PROC c_thescreen
0 PROC c_charwh
2 PROC c_setcharwh
2 PROC c_resize
1 PROC c_setcursorheight
0 PROC c_getcursorheight
1 PROC c_wscroll
0 PROC c_rowoffset
0 PROC c_maxcolrow
2 PROC c_setmaxcolrow
1 PROC c_setfont

: x_pushkey     ( c1 -- )       \ push c1 into the keyboard input stream
                Call k_fpushkey drop ;

: x_"pushkeys   ( a1 n1 -- )    \ push the characters of string a1,n1
                0max 127 min bounds
                ?do     i c@ x_pushkey
                loop    ;

1 PROC GetKeyState
: x_shiftmask   ( -- mask )
                0
                17 ( VK_CONTROL ) Call GetKeyState 32768 and \ if control is down
                if control_mask or then                \ then include control bit

                16 ( VK_SHIFT ) Call GetKeyState 32768 and \ if shift is down
                if shift_mask or then ;              \ then include shift bit

: ?shift        ( -- f1 )       \ return true if shift is down
                shiftmask shift_mask and 0<> ;

: ?control      ( -- f1 )       \ return true if control is down
                shiftmask control_mask and 0<> ;

: x_cursorinview  ( -- )    \ make sure cursor is visible in the window
                ;

: x_fgbg!       ( forground background -- )
                Call c_setfgbg drop ;

: x_fg@         ( -- foreground )
                Call c_getfg ;

: x_bg@         ( -- background )
                Call c_getbg ;

: x_&the-screen ( -- a1 )       \ get the forth relative address of the users
                                \ console screen memory buffer
                Call c_thescreen ;

: x_charWH      ( -- width height )     \ get the width and height of the
                                        \ current console font
                Call c_charwh word-split swap ;

3 PROC InvalidateRect
: ConsoleRepaint ( -- ) \ redraw console window
                1 0 _conHndl call InvalidateRect drop ;

: x_SetcharWH   ( width height -- )     \ set the width and height of the
                Call c_setcharwh drop   \ current console font
                ConsoleRepaint ; \ force repaint

: x_setcolrow   ( cols rows -- )                \ set the console size
                Call c_resize drop ;

: SetConsoleFont ( hFont -- ) \ set the console font. If hFont is NULL the
                              \ default font will be set.
                call c_setfont drop
                ConsoleRepaint ; \ force repaint

\ Usage of SetConsoleFont:
\
\         Font cFont
\         16 Height: cFont
\         8 Width: cFont
\         s" Courier New" SetFaceName: cFont
\         FW_NORMAL Weight: cFont
\         Create: cFont
\         Handle: cFont SetConsoleFont
\         zHandle: cFont \ don't let Win32Forth destroy the font; the console does it !!!


synonym set-consize setcolrow

4 PROC SetWindowPos
: set-conpos    ( x y -- )                      \ set the console position
                2>r ( SWP_NOSIZE ) 1 0 0 2r> ( HWND_TOP ) 0 _conHndl
                call SetWindowPos drop ;


: x_set-cursor  ( cursor-height -- )            \ set the cursor height
                Call c_setcursorheight drop ;

: x_get-cursor  ( -- cursor-height )            \ get the cursor height
                Call c_getcursorheight ;

\ Note: The cursor hight is used by the Line Editor (in Lineedit.f) to
\ show the current insert/overstrike mode. So a direct call to
\ set-cursor, big-cursor or norm-cursor doesn't show any efect at all.
: big-cursor    ( -- )                          \ set a block cursor
                charWH nip set-cursor ;

2 value norm-height                             \ hold the norm cursor height
: norm-cursor   ( -- )                          \ set a normal cursor
                norm-height set-cursor ;

0 value havemenu?
: havemenu!     ( flag -- )
                to havemenu? ;

1 PROC GetDC
: conDC         ( -- dc )               \ get the console device context
                _conHndl call GetDC ;

0 value saveconx
0 value savecony

2 PROC ShowWindow
: show-window   ( n -- )
                _conHndl call ShowWindow drop ;

: hide-console  ( -- )
                saveconx ?exit
                getcolrow to savecony to saveconx
                ( SW_HIDE ) 0 show-window ;

: unhide-console ( -- )
                saveconx 0= ?exit
                ( SW_SHOW ) 5 show-window
                saveconx savecony setcolrow   \ resize to original size
                0 to saveconx
                0 to savecony ;

synonym show-console unhide-console

: normal-console ( -- )         \ un-minimizes a minimized console window
                ( SW_NORMAL ) 1 show-window ;

1 PROC SetFocus
: focus-console ( -- )
                _conHndl call SetFocus drop ;

: x_setrowoff   ( n1 -- )               \ set the console row offset
                Call c_wscroll drop ;

: x_getrowoff   ( -- n1 )               \ get the current console row offset
                Call c_rowoffset ;

: x_getmaxcolrow ( -- maxcols maxrows )  \ get maximum window columns
                Call c_maxcolrow word-split ;

: x_setmaxcolrow  ( maxcols maxrows -- ) \ set the saved screen area and clear
                16384 min 20 max swap    \ clip rows
                  256 min 26 max         \ clip columns
                Call c_setmaxcolrow drop ;

' X_CURSORINVIEW IS CURSORINVIEW
' X_FGBG!        IS FGBG!
' X_FG@          IS FG@
' X_BG@          IS BG@
' X_PUSHKEY      IS PUSHKEY
' X_"PUSHKEYS    IS "PUSHKEYS
' X_&THE-SCREEN  IS &THE-SCREEN
' X_CHARWH       IS CHARWH
' X_SETCHARWH    IS SETCHARWH
' X_SHIFTMASK    IS SHIFTMASK
' X_SETCOLROW    IS SETCOLROW
' X_SET-CURSOR   IS SET-CURSOR
' X_GET-CURSOR   IS GET-CURSOR
' X_SETROWOFF    IS SETROWOFF
' X_GETROWOFF    IS GETROWOFF
' X_GETMAXCOLROW IS GETMAXCOLROW
' X_SETMAXCOLROW IS SETMAXCOLROW


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Facility extension words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

SYNONYM EKEY    KEY  ( -- u )
SYNONYM EKEY?   KEY? ( -- flag )

: ekey>char     ( u -- u false | char true ) \ returns TRUE if displayable character
        dup 0 255 between ;

TRUE constant emit? ( -- flag )     \ return TRUE if its ok to emit a character

\s
\ arm removed 17/05/2005 23:36:13

\ All internal console I/O words have an x_ prefix now.
\ The following words are deprecated.
\ They are added for compatiblity to existing code only.
SYNONYM _INIT-CONSOLE x_INIT-CONSOLE	DEPRECATED
SYNONYM _INIT-SCREEN  x_INIT-SCREEN	DEPRECATED
SYNONYM _ACCEPT       x_ACCEPT		DEPRECATED
SYNONYM _TYPE         x_TYPE		DEPRECATED
SYNONYM _EMIT         x_EMIT		DEPRECATED
SYNONYM _CR           x_CR		DEPRECATED
SYNONYM _CLS          x_CLS		DEPRECATED
SYNONYM _?CR          x_?CR		DEPRECATED
SYNONYM _SIZESTATE    x_SIZESTATE	DEPRECATED
SYNONYM _GOTOXY       x_GOTOXY		DEPRECATED
SYNONYM _GETXY        x_GETXY		DEPRECATED
SYNONYM _GETCOLROW    x_GETCOLROW	DEPRECATED
SYNONYM _MARKCONSOLE  x_MARKCONSOLE	DEPRECATED

SYNONYM _BYE          k_BYE		DEPRECATED

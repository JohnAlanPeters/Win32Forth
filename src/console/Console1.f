\ $Id: Console1.f,v 1.11 2013/07/21 00:08:50 georgeahubert Exp $

\ Console1.f   ( was Console1New.f)

cr .( Loading Console1.f : Console I/O Part 1 ...)

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       get console window handle
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

defer conHndl ' _conHndl is conHndl \ so we can change it later


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Keyboard Mask Constant, MUST MATCH THOSE IN TERM.H !!
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

   65536 (   0x10000 ) constant function_mask \ function key maks
  131072 (   0x20000 ) constant special_mask  \ special keyboard key mask
  262144 (   0x40000 ) constant K-CTRL-MASK   \ control key mask
  524288 (   0x80000 ) constant K-SHIFT-MASK  \ shift key mask
 1048576 (  0x100000 ) constant K-ALT-MASK    \ alt key mask
 2097152 (  0x200000 ) constant mouse_mask    \ mouse operations
 4194304 (  0x400000 ) constant menu_mask     \ menu operations
    8192 (  0x002000 ) constant proc_mask     \ procedure base mask
16777216 ( 0x1000000 ) constant double_mask   \ double click mask
33554432 ( 0x2000000 ) constant down_mask     \ mouse down mask
67108864 ( 0x4000000 ) constant up_mask       \ mouse up mask


SYNONYM alt_mask K-ALT-MASK
SYNONYM control_mask K-CTRL-MASK
SYNONYM shift_mask K-SHIFT-MASK


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ sound stuff
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application

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

: PAGE		( -- ) \ skip to next page (PRINTER) clear screen (CONSOLE)
                cls ;
                \ Note: defined this word as CLS instead of a separate defer.
                \ This minimizes the number of defered i/o words to save and
                \ restore when switching from an i/o device to another.

\ the next two words are deprecated because changeing the
\ console font doesn't realy work
defer >bold  DEPRECATED \ ' noop   is >bold  \ set bold font in console window
defer >norm  DEPRECATED \ ' noop   is >norm  \ set normal font in console window

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Some words that improve compatibility with existing F-PC code.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: AT-XY		( x y -- ) \ synonym of GOTOXY (ANS version of GOTOXY)
                gotoxy ;
                \ Note: defined this word as GOTOXY instead of a separate defer.
                \ This minimizes the number of defered i/o words to save and
                \ restore when switching from an i/o device to another.

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

in-system

 4 value right-margin
 0 value tab-margin
 5 value tabs-max

in-application

 0 value tabing?        \ are we tabing, default to no

in-system

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

in-application

: TABING-ON     ( -- )
                true to tabing? ;

: TABING-OFF    ( -- )
                false to tabing? ;

synonym tabbing-off tabing-off
synonym tabbing-on  tabing-on

in-system

: CRTAB       ( -- )
                cr \ [cdo] because w32fconsole.dll was removed
                   \ have to check if there is still recursive call problems, cf:
                   \ x_cr \ fixed stack overflow bug November 15th, 2003 - 13:26 dbu
                tabing? 0= ?exit
                first-line?
                if      left-margin indent + spaces
                        false to first-line?
                else    left-margin spaces
                        tab-margin spaces
                then    ;

: ?LINE         ( n1 -- )
                0 max getxy drop + wrap?
                if      crtab
                then    ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Additional words for the console
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application

1 PROC GetKeyState
: shiftmask   ( -- mask )
                0
                17 ( VK_CONTROL ) Call GetKeyState 32768 and \ if control is down
                if control_mask or then                \ then include control bit

                16 ( VK_SHIFT ) Call GetKeyState 32768 and \ if shift is down
                if shift_mask or then ;              \ then include shift bit

: ?shift        ( -- f1 )       \ return true if shift is down
                shiftmask shift_mask and 0<> ;

: ?control      ( -- f1 )       \ return true if control is down
                shiftmask control_mask and 0<> ;

in-system

4 PROC SetWindowPos
: set-conpos    ( x y -- )                      \ set the console position
                2>r ( SWP_NOSIZE ) 1 0 0 2r> ( HWND_TOP ) 0 _conHndl
                call SetWindowPos drop ;
((
in-application

0 value havemenu?
: havemenu!     ( flag -- )
                to havemenu? ;

in-system
))
1 PROC GetDC
: conDC         ( -- dc )               \ get the console device context
                _conHndl call GetDC ;

\ 0 value saveconx
\ 0 value savecony

in-application

2 PROC ShowWindow
: show-window   ( n -- )
                _conHndl call ShowWindow drop ;

: hide-console  ( -- )
\                saveconx ?exit
\                getcolrow to savecony to saveconx
                ( SW_HIDE ) 0 show-window ;

: unhide-console ( -- )
\                saveconx 0= ?exit
                ( SW_SHOW ) 5 show-window
\                saveconx savecony setcolrow   \ resize to original size
\                0 to saveconx
\                0 to savecony
                ;

synonym show-console unhide-console

: normal-console ( -- )         \ un-minimizes a minimized console window
                ( SW_NORMAL ) 1 show-window ;

1 PROC SetFocus
: focus-console ( -- )
                _conHndl call SetFocus drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Facility extension words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

SYNONYM EKEY    KEY  ( -- u )
SYNONYM EKEY?   KEY? ( -- flag )

: ekey>char     ( u -- u false | char true ) \ returns TRUE if displayable character
        dup 0 255 between ;

: EKEY>FKEY ( u1 -- u2 flag )
DUP EKEY>CHAR NIP 0= ;

TRUE constant emit? ( -- flag )     \ return TRUE if its ok to emit a character

\s

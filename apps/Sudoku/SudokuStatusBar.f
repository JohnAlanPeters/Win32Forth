\ $Id: SudokuStatusBar.f,v 1.4 2008/07/18 19:41:01 rodoakford Exp $
\ SudokuStatusBar.f     StatusBar for Sudoku game
\                       Septmeber 2005  Rod Oakford

Needs Statusbar.f

cr  .( Loading Sudoku StatusBar...)
\- hStatusBar 0 value hStatusBar


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Sudoku StatusBar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object SudokuStatusBar  <Super MultiStatusBar

Create MultiWidth 200 , -1 ,   \ width of statusbar parts

:M Start: ( parent -- )
        Start: super
        MultiWidth 2 SetParts: self
        ;M

:M WindowStyle: ( -- style )
        [ WS_CHILD WS_CLIPSIBLINGS or ] literal   \ not WS_VISIBLE - start hidden, no border
        ;M

create text$  256 allot
:M GetText: ( n -- szText )   \ get text in n'th part
        text$ swap SB_GETTEXT SendMessage:Self drop  text$
        ;M

:M UpdatePart: ( text$ p -- )   >r
        dup count  r@ GetText: self zcount  compare
        IF
            count asciiz r> SetText: self
        ELSE
            r> 2drop
        THEN
        ;M

;Object


0 value StatusBarHeight

: ShowStatusBar ( -- )   Height: SudokuStatusBar to StatusBarHeight
        SW_SHOW show: SudokuStatusBar  true check: hStatusBar ;
: HideStatusBar ( -- )   0 to StatusBarHeight
        SW_HIDE show: SudokuStatusBar  false check: hStatusBar ;

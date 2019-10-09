\ $Id: PVStatusBar.f,v 1.2 2008/07/18 19:39:59 rodoakford Exp $

\ PVStatusBar.f         StatusBar for Picture Viewer by Rod Oakford
\                       February 2006

Needs PVMenu
Needs StatusBar

cr .( Loading PVStatusBar)

\- FileCount   0 value FileCount


:Object PVStatusBar  <Super MultiStatusBar

Create MultiWidth 20 , 40 , 108 , 179 , 249 , 334 , -1 ,   \ width of statusbar parts

:M Start:
        Start: super
        MultiWidth 7 SetParts: self
        ;M

:M WindowStyle: ( -- style )   \ return the window style
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

:M Clear: ( -- )   7 0 DO  0 0 i SetText: self  LOOP ;M

:M WM_LBUTTONDBLCLK ( w m h l -- res )   \ double-click in 0 part of StatusBar toggles mark
        TempRect  0 SB_GETRECT SendMessage:Self drop
        dup word-split TempRect.left TempRect.right within
        swap TempRect.top TempRect.bottom within and
        IF  IDM_TOGGLE_MARK DoCommand  THEN ;M

;Object


: UpdateFlags ( Mflag Pflag -- )
        IF  s"  P"  ELSE  s" "  THEN  pad place                 pad 1 UpdatePart: PVStatusBar
        IF  s"  M"  ELSE  s" "  THEN  pad place                 pad 0 UpdatePart: PVStatusBar
        ;

: UpdateStatusBar ( Width Height Scale a n -- )
        pad place                                               pad 6 UpdatePart: PVStatusBar
        s"  Files open: " pad place  FileCount (.) pad +place   pad 5 UpdatePart: PVStatusBar
        s"  Scale " pad place (.) pad +place  s" %" pad +place  pad 4 UpdatePart: PVStatusBar  
        s"  Height " pad place (.) pad +place                   pad 3 UpdatePart: PVStatusBar  
        s"  Width " pad place (.) pad +place                    pad 2 UpdatePart: PVStatusBar
        ;

0 value StatusBarHeight

: ShowStatusBar ( -- )   GetWindowRect: PVStatusBar nip swap - nip to StatusBarHeight
        SW_SHOW show: PVStatusBar  true check: hStatusBar ;

: HideStatusBar ( -- )   0 to StatusBarHeight
        SW_HIDE show: PVStatusBar  false check: hStatusBar ;


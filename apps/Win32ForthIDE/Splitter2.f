\ ForthForm generated splitter-window template
\ Modify according to your needs


:Object TopPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Top Pane" Textout: dc ;M

;Object


:Object BottomPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Bottom Pane" Textout: dc
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter Bar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

COLOR_BTNFACE Call GetSysColor new-color BTNFACE

:Class SplitterBar   <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height BTNFACE FillArea: dc ;M

:M On_Init:     ( -- )
        \ Remove CS_HREDRAW and CS_VREDRAW styles from all instances of
        \ class Child-Window to prevent flicker in window on sizing.
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop ;M

;Class

SplitterBar SplitterH


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter Window - the main window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any
200 value TopHeight
5 value ThicknessH


:Object SplitterWindow   <Super Window

int dragging
int mousedown

: SplitterYpos    ( -- n )   ToolBarHeight TopHeight + ;
: BottomYpos      ( -- n )   SplitterYpos ThicknessH + ;
: StatusBarYpos   ( -- n )   height StatusbarHeight - ;
: BottomHeight    ( -- n )   StatusBarYpos BottomYpos - ;
: TotalHeight     ( -- n )   StatusBarYpos ToolBarHeight - ;
: TopHeightMin    ( -- n )   TopHeight TotalHeight min ;

: position-windows ( -- )
        0  ToolBarHeight  Width  TopHeightMin  Move: TopPane
        0  BottomYpos     Width  BottomHeight  Move: BottomPane
        0  SplitterYpos   Width  ThicknessH    Move: SplitterH
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        dup ToolBarHeight StatusBarYpos within
        IF  SplitterYpos BottomYpos within  swap  0 width within  and  IF  1  ELSE  0  THEN
        ELSE  2drop 0  THEN ;

: On_Tracking ( -- )   \ set min and max values of TopHeight here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousey ToolBarHeight -  0max  TotalHeight min   thicknessH 2/ -  to TopHeight  THEN
        position-windows
        WINPAUSE ;

: On_Clicked ( -- )
        mousedown not IF  hWnd Call SetCapture drop  THEN
        true to mousedown
        Splitter to dragging
        On_Tracking ;

: On_Unclicked ( -- )
        mousedown IF  Call ReleaseCapture drop  THEN
        false to mousedown
        false to dragging ;

: On_DblClick ( -- )
        false to mousedown
        Splitter 1 = 
        IF
            TopHeight 8 >
            IF    0 thicknessH 2/ - to TopHeight
            ELSE  TopHeight BottomHeight + thicknessH - 2/ to TopHeight
            THEN
        position-windows
        THEN ;

:M WM_SETCURSOR ( h m w l -- )
        Splitter
        Case
            0  of  DefWindowProc: self  endof
            1  of  SIZENS-CURSOR    1   endof
        EndCase
        ;M

:M Classinit: ( -- )
        ClassInit: super   \ init super class
        ['] On_Clicked     SetClickFunc: self
        ['] On_Unclicked   SetUnClickFunc: self
        ['] On_Tracking    SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        ;M

\ :M WindowHasMenu: ( -- f )   true ;M

:M WindowStyle: ( -- style )
        WindowStyle: Super WS_CLIPCHILDREN or ;M

:M On_Size: ( -- )
        position-windows ;M

:M On_Init: ( -- )
        \ prevent flicker in window on sizing
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

        self Start: TopPane
        self Start: BottomPane
        self Start: SplitterH
        ;M

;Object

\ start: SplitterWindow

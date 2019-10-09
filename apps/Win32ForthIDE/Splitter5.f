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


:Object BottomLeftPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Bottom Left Pane" Textout: dc
        ;M

;Object


:Object BottomRightPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Bottom Right Pane" Textout: dc ;M

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
SplitterBar SplitterV


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter Window - the main window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any
200 value TopHeight
150 value LeftWidth
5 value ThicknessH
5 value ThicknessV


:Object SplitterWindow   <Super Window

int dragging
int mousedown

: RightXpos       ( -- n )   LeftWidth ThicknessV + ;
: RightWidth      ( -- n )   Width RightXpos - ;
: SplitterYpos    ( -- n )   ToolBarHeight TopHeight + ;
: BottomYpos      ( -- n )   SplitterYpos ThicknessH + ;
: StatusBarYpos   ( -- n )   height StatusbarHeight - ;
: BottomHeight    ( -- n )   StatusBarYpos BottomYpos - ;
: TotalHeight     ( -- n )   StatusBarYpos ToolBarHeight - ;
: LeftWidthMin    ( -- n )   LeftWidth width min ;
: TopHeightMin    ( -- n )   TopHeight TotalHeight min ;

: position-windows ( -- )
        0          ToolBarHeight  Width         TopHeightMin  Move: TopPane
        0          BottomYpos     LeftWidthMin  BottomHeight  Move: BottomLeftPane
        RightXpos  BottomYpos     RightWidth    BottomHeight  Move: BottomRightPane
        LeftWidth  BottomYpos     ThicknessV    BottomHeight  Move: SplitterV
        0          SplitterYpos   Width         ThicknessH    Move: SplitterH
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        dup ToolBarHeight StatusBarYpos within
        IF
            2dup BottomYpos height within  swap  LeftWidth RightXpos within  and
            IF  2drop  1
            ELSE  SplitterYpos BottomYpos within  swap  0 width within  and IF  2  ELSE  0  THEN
            THEN
        ELSE 2drop 0
        THEN ;

: On_Tracking ( -- )   \ set min and max values of LeftWidth and TopHeight here
        mousedown dragging or 0= ?EXIT
        dragging
        Case
            1 of  mousex  0max  width min  thicknessV 2/ -  to LeftWidth  endof
            2 of  mousey ToolBarHeight -  0max  TotalHeight min   thicknessH 2/ -  to TopHeight  endof
        EndCase
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
            LeftWidth 8 >
            IF    0 thicknessV 2/ - to LeftWidth
            ELSE  Width thicknessV - 2/  to LeftWidth
            THEN
        position-windows
        THEN ;

:M WM_SETCURSOR ( h m w l -- )
        Splitter
        Case
            0  of  DefWindowProc: self  endof
            1  of  SIZEWE-CURSOR    1   endof
            2  of  SIZENS-CURSOR    1   endof
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
        self Start: BottomLeftPane
        self Start: BottomRightPane
        self Start: SplitterH
        self Start: SplitterV
        ;M

;Object

\ start: SplitterWindow

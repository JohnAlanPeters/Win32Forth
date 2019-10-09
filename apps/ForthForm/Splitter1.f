\ ForthForm generated splitter-window template
\ Modify according to your needs


:Object LeftPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Left Pane" Textout: dc ;M

;Object


:Object RightPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super 
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        0 0 s" Right Pane" Textout: dc ;M

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

SplitterBar SplitterV


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter Window - the main window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any
150 value LeftWidth
5 value ThicknessV


:Object SplitterWindow   <Super Window

int dragging
int mousedown

: RightXpos       ( -- n )   LeftWidth ThicknessV + ;
: RightWidth      ( -- n )   Width RightXpos - ;
: LeftWidthMin    ( -- n )   LeftWidth width min ;
: StatusBarYpos   ( -- n )   height StatusbarHeight - ;
: TotalHeight     ( -- n )   Height ToolBarHeight - StatusBarHeight - ;

: position-windows ( -- )
        0          ToolBarHeight   LeftWidthMin  TotalHeight  Move: LeftPane
        RightXpos  ToolBarHeight   RightWidth    TotalHeight  Move: RightPane
        LeftWidth  ToolBarHeight   ThicknessV    TotalHeight  Move: SplitterV
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        ToolBarHeight StatusBarYpos within  swap  LeftWidth RightXpos within  and
        IF  1  ELSE  0  THEN ;

: On_Tracking ( -- )   \ set min and max values of LeftWidth here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousex  0max  width min  thicknessV 2/ -  to LeftWidth  THEN
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

        self Start: LeftPane
        self Start: RightPane
        self Start: SplitterV
        ;M

;Object

\ start: SplitterWindow

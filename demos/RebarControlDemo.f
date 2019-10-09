\ $Id: RebarControlDemo.f,v 1.1 2006/06/04 21:16:23 rodoakford Exp $

\ Demonstrates the use of a rebar control to display bands containing various controls.
\ Bands can be detached into tool windows.
\ Sunday, June 04 2006  21:44:15 Rod Oakford


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Detachable Tool Window Class \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

COLOR_BTNFACE Call GetSysColor new-color BTNFACE

:Class ToolWindow   <Super Window

int child    \ child = control, parent = rebar
\ int parent   \ needed in earlier versions of Win32Forth

:M Start: ( child -- )   \ start hidden
        hWnd
        IF  drop
        ELSE
            to child       
            GetParent: child to parent
            register-frame-window drop
            create-frame-window to hWnd
        THEN ;M

:M On_Paint: ( -- )   0 0 Width Height BTNFACE FillArea: dc ;M

:M WindowStyle: ( -- style )   [ WS_POPUP WS_CAPTION or ] literal ;M

:M ExWindowStyle: ( -- exstyle )   WS_EX_TOOLWINDOW ;M

:M StartSize: ( -- w h )   StartSize: child ;M

:M StartPos: ( -- w h )   StartPos: child ;M

:M ParentWindow: ( -- hWndparent )   GetHandle: parent ;M

: SetParentOfChild ( hWndparent -- )   GetHandle: child  call SetParent drop ;
        
:M Detach: ( -- )
        GetID: child IdToIndex: parent DeleteBand: parent
        hWnd SetParentOfChild
        SW_SHOW Show: child
        StartPos: self  StartSize: self  Move: child
        0 get-mouse-XY SetWindowPos: self
        ;M

:M Attach: ( uBand -- )
        GetHandle: parent SetParentOfChild
        child InsertChild: parent
        SW_HIDE Show: self
        ;M

:M WM_NCLBUTTONDBLCLK ( h m w l -- res )   -1 Attach: self  0 ;M

:M WM_EXITSIZEMOVE ( h m w l -- res )
        HitTest: parent  dup 1+ IF  Attach: self  ELSE  drop  THEN  0 ;M

;Class


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Some Toolbars \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Needs Toolbar.f

1 value IDM_NEW
2 value IDM_OPEN
3 value IDM_SAVE
4 value IDM_PRINT
5 value IDM_FIND
6 value IDM_REPLACE
7 value IDM_CUT
8 value IDM_COPY
9 value IDM_PASTE
10 value IDM_UNDO
11 value IDM_REDO
12 value IDM_PRINTPRE
13 value IDM_DELETE
14 value IDM_PROPERTIES
15 value IDM_HELP

:Object Toolbar1 ( parent -- )   <super Win32ToolBar

:ToolBarTable FileButtons
\   Bitmap            index id           Initial state   Initial style   tool string index
    STD_FILENEW       IDM_NEW           TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton,  
    STD_FILEOPEN      IDM_OPEN          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton,  
    STD_FILESAVE      IDM_SAVE          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
                                                                          SeparatorButton,  
    STD_PRINT         IDM_PRINT         TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
                                                                          SeparatorButton,  
    STD_FIND          IDM_FIND          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_REPLACE       IDM_REPLACE       TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
;ToolBarTable

:M WindowStyle: ( -- style )   \ start hidden
        [ WS_CHILD WS_CLIPCHILDREN or CCS_NODIVIDER or CCS_NOPARENTALIGN or CCS_NORESIZE or ] literal ;M

:M StartSize: ( -- w h )   \ start size in popup window
        hWnd
        IF
            GetButtonCount: self 1-   \ last button
            GetButtonRect: self  >r  over 2* +  rot drop  swap r> +   \ w=r+2t, h=b+t
        ELSE
            StartSize: super
        THEN ;M

:M StartPos: ( -- x y )   \ start position in popup window
        hWnd
        IF    0 GetButtonRect: self  2drop nip  0   \ x=top, y=0
        ELSE  StartPos: super
        THEN ;M

:M Start: ( parent -- )
        FileButtons IsButtonTable: self
        Start: super        
        HINST_COMMCTRL  IDB_STD_SMALL_COLOR  15 AddBitmaps: self drop
        ;M

;Object


:Object Toolbar2 ( parent -- )   <super Win32ToolBar

:ToolBarTable EditButtons
\   Bitmap            index id           Initial state   Initial style   tool string index
    STD_CUT           IDM_CUT           TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_COPY          IDM_COPY          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_PASTE         IDM_PASTE         TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_UNDO          IDM_UNDO          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_REDOW         IDM_REDO          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
;ToolBarTable

:M WindowStyle: ( -- style )   \ start hidden
        [ WS_CHILD WS_CLIPCHILDREN or CCS_NODIVIDER or CCS_NOPARENTALIGN or CCS_NORESIZE or ] literal ;M

:M StartSize: ( -- w h )   \ start size in popup window
        hWnd
        IF
            GetButtonCount: self 1-   \ last button
            GetButtonRect: self  >r  over 2* +  rot drop  swap r> +   \ w=r+2t, h=b+t
        ELSE
            StartSize: super
        THEN ;M

:M StartPos: ( -- x y )   \ start position in popup window
        hWnd
        IF    0 GetButtonRect: self  2drop nip  0   \ x=top, y=0
        ELSE  StartPos: super
        THEN ;M

:M Start: ( parent -- )
        EditButtons IsButtonTable: self
        Start: super        
        HINST_COMMCTRL  IDB_STD_SMALL_COLOR  15 AddBitmaps: self drop
        ;M

;Object


:Object Toolbar3 ( parent -- )   <super Win32ToolBar

:ToolBarTable MiscButtons
\   Bitmap            index id           Initial state   Initial style   tool string index
    STD_PRINTPRE      IDM_PRINTPRE      TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_DELETE        IDM_DELETE        TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_PROPERTIES    IDM_PROPERTIES    TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton, 
    STD_HELP          IDM_HELP          TBSTATE_ENABLED   BTNS_BUTTON    0  ToolBarButton,  
;ToolBarTable

:M WindowStyle: ( -- style )   \ start hidden
        [ WS_CHILD WS_CLIPCHILDREN or CCS_NODIVIDER or CCS_NOPARENTALIGN or CCS_NORESIZE or ] literal ;M

:M StartSize: ( -- w h )   \ start size in popup window
        hWnd
        IF
            GetButtonCount: self 1-   \ last button
            GetButtonRect: self  >r  over 2* +  rot drop  swap r> +   \ w=r+2t, h=b+t
        ELSE
            StartSize: super
        THEN ;M

:M StartPos: ( -- x y )   \ start position in popup window
        hWnd
        IF    0 GetButtonRect: self  2drop nip  0   \ x=top, y=0
        ELSE  StartPos: super
        THEN ;M

:M Start: ( parent -- )
        MiscButtons IsButtonTable: self
        Start: super        
        HINST_COMMCTRL  IDB_STD_SMALL_COLOR  15 AddBitmaps: self drop
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ A Combobox \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object TheCombo   <super ComboControl

:M StartSize: ( -- x y )   100 60 ;M   \ start size in popup window

:M Start: ( Parent -- )
        start: super
        s" Option 2" InsertString: self
        s" Option 1" InsertString: self
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ An Editbox \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

EditControl TheEdit


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The Rebar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Needs RebarControl.f

ToolWindow Toolbar1Popup
ToolWindow Toolbar2Popup
ToolWindow Toolbar3Popup
ToolWindow ComboPopup
ToolWindow EditPopup

:Object TheRebar   <Super RebarControl

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ WS_CLIPSIBLINGS WS_CLIPCHILDREN or WS_BORDER or RBS_VARHEIGHT or RBS_BANDBORDERS or RBS_DBLCLKTOGGLE or ] literal or
        ;M

: InsertToolbar1 ( uBand -- )
        Eraseband-info
        [ RBBIM_STYLE RBBIM_CHILD or RBBIM_CHILDSIZE or RBBIM_ID or ] literal to bfmask
        RBBS_CHILDEDGE to fstyle
        GetHandle: Toolbar1 to hWndChild 
        StartSize: Toolbar1  to cyMinChild to cxMinChild
        GetID: Toolbar1 to wID
        InsertBandAt: self ;

: InsertToolbar2 ( uBand -- )
        Eraseband-info
        [ RBBIM_STYLE RBBIM_CHILD or RBBIM_CHILDSIZE or RBBIM_ID or ] literal to bfmask
        RBBS_CHILDEDGE to fstyle
        GetHandle: Toolbar2 to hWndChild 
        StartSize: Toolbar2  to cyMinChild to cxMinChild
        GetID: Toolbar2 to wID
        InsertBandAt: self ;

: InsertToolbar3 ( uBand -- )
        Eraseband-info
        [ RBBIM_STYLE RBBIM_CHILD or RBBIM_CHILDSIZE or RBBIM_ID or ] literal to bfmask
        RBBS_CHILDEDGE to fstyle
        GetHandle: Toolbar3 to hWndChild 
        StartSize: Toolbar3  to cyMinChild to cxMinChild
        GetID: Toolbar3 to wID
        InsertBandAt: self ;

: InsertCombo ( uBand -- )
        Eraseband-info
        [ RBBIM_STYLE RBBIM_TEXT or RBBIM_IMAGE or RBBIM_CHILD or RBBIM_CHILDSIZE or RBBIM_ID or ] literal to bfmask
        RBBS_CHILDEDGE RBBS_BREAK or to fstyle   \ start band on a new row
        z" Combobox" to lpText
        0 to iImage
        GetHandle: TheCombo to hWndChild 
        StartSize: TheCombo to cyMinChild to cxMinChild
        GetID: TheCombo to wID
        InsertBandAt: self ;

: InsertEdit ( uBand -- )
        Eraseband-info
        [ RBBIM_STYLE RBBIM_TEXT or RBBIM_CHILD or RBBIM_CHILDSIZE or RBBIM_ID or ] literal to bfmask
        RBBS_CHILDEDGE to fstyle
        z" Editbox" to lpText
        0 to iImage
        GetHandle: TheEdit to hWndChild 
        StartSize: TheEdit to cyMinChild to cxMinChild
        GetID: TheEdit to wID
        InsertBandAt: self ;

:M InsertChild: ( uBand child -- )
        Case
            Toolbar1  of  InsertToolbar1  Endof
            Toolbar2  of  InsertToolbar2  Endof
            Toolbar3  of  InsertToolbar3  Endof
            TheCombo  of  InsertCombo     Endof
            TheEdit   of  InsertEdit      Endof
            ( default ) drop            
        EndCase
        ;M

:M DetachChild: ( wID -- )
        HitTest: self 1+ 
        IF  drop
        ELSE
            EndDrag: self
            Case
                GetID: Toolbar1  of  Detach: Toolbar1Popup  endof
                GetID: Toolbar2  of  Detach: Toolbar2Popup  endof
                GetID: Toolbar3  of  Detach: Toolbar3Popup  endof
                GetID: TheCombo  of  Detach: ComboPopup     endof
                GetID: TheEdit   of  Detach: EditPopup      endof
                ( default ) drop            
            EndCase
        THEN ;M

:M Start: ( parent -- )
        Start: super	
        0 1 ILC_COLORDDB ILC_MASK or 32 32 call ImageList_Create
        101 AppInst call LoadIcon
        over call ImageList_AddIcon drop
        RBIM_IMAGELIST SetBarInfo: self
	
        self Start: Toolbar1
        0 InsertToolbar1 
        Toolbar1 start: Toolbar1Popup
        s" Toolbar1" SetText: Toolbar1Popup

        self Start: Toolbar2
        1 InsertToolbar2 
        Toolbar2 start: Toolbar2Popup
        s" Toolbar2" SetText: Toolbar2Popup

        self Start: Toolbar3
        2 InsertToolbar3 
        Toolbar3 start: Toolbar3Popup
        s" Toolbar3" SetText: Toolbar3Popup

        self Start: TheCombo
        3 InsertCombo
        TheCombo start: ComboPopup
        s" Combobox" SetText: ComboPopup

        self Start: TheEdit
        4 InsertEdit
        TheEdit start: EditPopup
        s" Editbox" SetText: EditPopup

        0 MinimizeBand: self
        0 1 MaximizeBand: self
        0 2 MaximizeBand: self

        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ A Child Window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object TheChild   <Super Child-Window

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M

:M On_Init: ( -- )
\        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong  drop   \ needed in earlier versions of Win32Forth
        ;M

:M On_Paint: ( -- )
        0 0 width height green FillArea: dc
        TRANSPARENT SetBkMode: dc
        0 0
        15 + 2dup s" REBAR CONTROL DEMO" TextOut: dc  15 +
        15 + 2dup s" Bands can be moved by clicking and dragging on the gripper, text or image." TextOut: dc
        15 + 2dup s" Double clicking toggles the minimum/maximum size of the band." TextOut: dc
        15 + 2dup s" Bands can be detached by dragging them off the rebar." TextOut: dc
        15 + 2dup s" Double clicking the tool window attaches the band at the last position of the rebar." TextOut: dc
        15 + 2dup s" Bands can be re-attached at any position by dropping the tool window on the rebar." TextOut: dc
        15 + 2dup s" The rebar is auto-arranged when the main window is resized." TextOut: dc
        2drop ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The Main Window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super Window

:M WindowStyle: ( -- style )   WindowStyle: Super WS_CLIPCHILDREN or ;M

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M

:M WindowHasMenu: ( -- f )   true ;M

:M On_Init: ( -- )
\        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong  drop   \ needed in earlier versions of Win32Forth
        self start: TheChild
        self start: TheRebar
        ;M

:M On_Size: ( -- )
        0  Height: TheRebar  Width  Height Height: TheRebar -
        Move: TheChild
        AutoSize: TheRebar
        ;M

:M WM_NOTIFY ( hwnd msg wparam lparam -- res )
        dup 8 + @        \ fetch code from NMHDR structure
        Case
            RBN_ENDDRAG       of  dup 24 + @ ( wID ) DetachChild: TheRebar  endof
            RBN_HEIGHTCHANGE  of  On_Size: self                             endof
        EndCase
        0 ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
        over HIWORD ( notification code )
        Case
            CBN_SELCHANGE  of   cr ." Combobox selection changed"  endof
            EN_CHANGE      of   cr ." Editbox text changed"        endof
        EndCase

        over LOWORD ( command ID )  dup 1 16 within
        IF    cr ." Toolbar button " .      \ intercept Toolbar commands
        ELSE  drop  OnWmCommand: Super      \ intercept Menu commands
        THEN ;M

;Object

start: frame

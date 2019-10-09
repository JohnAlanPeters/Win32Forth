anew -TreeViewInSplitWindow.f

Needs Resources.f
Needs PopupWindow.f
Needs Treeview.f

false value turnkey?

defer OnPosition  ( window -- ) ' drop is OnPosition \ called when window panes are repositioned
defer OnInit      ( window -- ) ' drop is OnInit \ called during window On_init method


:Class NewTVC <super TreeViewControl

        Font WinFont

:M WindowStyle: ( -- style )
                WindowStyle: super
                TVS_HASLINES        or
                TVS_HASBUTTONS      or
                TVS_DISABLEDRAGDROP or
                TVS_SHOWSELALWAYS   or
                TVS_LINESATROOT     or
                ;M

int hRoot
int hSon
int hPrev

: AddItem       ( sztext hAfter hParent nChildren -- )
                tvins  /tvins  erase
                ( nChildren)      to cChildren
                ( hParent)        to hParent
                ( hAfter)         to hInsertAfter
                                  to pszText
                TVIF_TEXT TVIF_CHILDREN or
                to mask
                tvins 0 TVM_INSERTITEMA hWnd Call SendMessage
                to hPrev
                ;


: FillTreeView  ( -- )  \ Application depended
                z" Root Item"        TVI_LAST  TVI_ROOT  1  AddItem
                hPrev to hRoot
                z" First son"        hPrev     hRoot     1  AddItem
                hPrev to hSon
                z" First Grandson"   hPrev     hSon      0  AddItem
                z" Second Grandson"  hPrev     hSon      0  AddItem
                z" Second son"       hPrev     hRoot     0  AddItem
                z" Third son"        hPrev     hRoot     1  AddItem
                hPrev to hSon
                z" Third Grandson"   hPrev     hSon      0  AddItem
                ;

:M Start:       ( Parent -- )
                dup to parent
                Start: super

                8 Width: WinFont
                16 Height: WinFont
                s" Courier New" SetFaceName: WinFont
                Create: WinFont
                true Handle: WinFont WM_SETFONT hWnd CALL SendMessage drop \ activate a new font

                \ Insert items...
                FillTreeView
                ;M

: StartPopupWindow ( -- )
           hWnd get-mouse-xy
           GetWindowRect: Self 2drop
           rot + >r + r>  Hwnd Start: PopupWindow
          ;

:M On_SelChanged: { \ text$ -- f }      \ Show text of selected item in message box
                maxstring LocalAlloc: text$

                TVIF_TEXT        to mask
                hItemNew         to hItem
                text$            to pszText
                maxstring        to cchTextMax
                tvitem 0 TVM_GETITEMA  hWnd Call SendMessage drop

                \ text$ z" TreeView selection" MB_OK MessageBox: Parent drop
               StartPopupWindow
                false
                ;M

:M On_RightClick: ( -- )
                 On_SelChanged: Self
                ;M

;Class

\ ------------------------------------------------------------------------
\ Define the left part of the splitter window.
\ ------------------------------------------------------------------------

:Object LeftPane        <Super Child-Window

        int TreeView
        int EnableNotify?

:M On_Init:     ( -- )
        On_Init: super
        New> NewTVC to TreeView
        1001 SetId: TreeView
        self Start: TreeView
        true to EnableNotify?
        true to EnableNotify?

                ;M

:M WndClassStyle: ( -- style )  CS_DBLCLKS      ;M
:M Start:         ( Parent -- ) start: super    ;M
:M ExWindowStyle: ( -- style )  ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M
:M On_Paint:      ( -- )        0 0 Width Height WHITE FillArea: dc      ;M

:M On_Size:       ( -- )        AutoSize: TreeView                       ;M

:M RefreshTreeview:  ( -- )
        wait-cursor
        EnableNotify? false to EnableNotify?
        SW_HIDE Show: TreeView    \ hide,
        FillTreeView: TreeView    \ fill,
        SW_RESTORE Show: TreeView \ and show it.
        to EnableNotify?
        arrow-cursor
        ;M

:M WM_NOTIFY    ( h m w l -- f )
        dup @  GetHandle: TreeView  =
                if      Handle_Notify: TreeView
                else    false
                then
                ;M

;Object


\ ------------------------------------------------------------------------
\ Define the right part of the splitter window.
\ ------------------------------------------------------------------------

:Object RightPane       <Super Child-Window

:M On_Init:       ( -- )        On_Init: super  ;M
:M WndClassStyle: ( -- style )  CS_DBLCLKS      ;M
:M Start:         ( Parent -- ) start: super    ;M
:M ExWindowStyle: ( -- style )  ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M
:M On_Paint:      ( -- )        0 0 Width Height WHITE FillArea: dc      ;M

;Object


\ ------------------------------------------------------------------------
\ Define the line between the 2 panes.
\ ------------------------------------------------------------------------

:Object Splitter        <Super child-window


:M WindowStyle: ( -- style )
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or
        ;M

:M WndClassStyle: ( -- style )  CS_DBLCLKS                              ;M
:M On_Paint:      ( -- )        0 0 Width Height LTGRAY FillArea: dc    ;M

;Object

variable LeftWidth  200 LeftWidth !
2 value thickness


\ ------------------------------------------------------------------------
\ Define the window that contains the 2 panes.
\ ------------------------------------------------------------------------

:Object SplitterWindow        <Super Window

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any

int dragging?
int mousedown?

: LeftHeight    ( -- n )        Height StatusBarHeight - ToolBarHeight - ;
: RightHeight   ( -- n )        Height StatusBarHeight - ToolBarHeight - ;

: position-windows ( -- )
        0  ToolBarHeight  LeftWidth @  LeftHeight  Move: LeftPane
        LeftWidth @ thickness +  ToolBarHeight  Width LeftWidth @ thickness + -  RightHeight  Move: RightPane
        LeftWidth @  ToolBarHeight  thickness  LeftHeight  Move: Splitter
        self OnPosition ;

: InSplitter?   ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  LeftWidth @ dup thickness + within  and ;

\ mouse click routines for Main Window to track the Splitter movement

: DoSizing      ( -- )
        mousedown? dragging? or 0= ?EXIT
        mousex ( 1+ ) width min  thickness 2/ -
        [ thickness 2* ] literal max width  [ thickness 2* ] literal - min
        LeftWidth !
        position-windows
        WINPAUSE ;

: On_clicked    ( -- )
        mousedown? 0= IF  hWnd Call SetCapture drop  THEN
        true to mousedown?
        InSplitter? to dragging?
        DoSizing ;

: On_unclicked ( -- )
        mousedown? IF  Call ReleaseCapture drop  THEN
        false to mousedown?
        false to dragging? ;

: On_DblClick ( -- )
        false to mousedown?
        InSplitter? 0= ?EXIT
        LeftWidth @ 8 >
        IF      0 thickness 2/ -  LeftWidth !
        ELSE    132 Width 2/ min  LeftWidth !
        THEN
        position-windows
        ;

:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        ToolBarHeight dup LeftHeight + within
        swap  0 width within and
        IF  InSplitter?
                IF  SIZEWE-CURSOR
                ELSE  arrow-cursor
                THEN  1
        ELSE  DefWindowProc: self
        THEN
        ;M

:M On_Init:     ( -- )
        self Start: LeftPane
        self Start: RightPane
        self Start: Splitter
        self OnInit    \ perform user function
        ;M

:M Classinit:   ( -- )
        ClassInit: super   \ init super class
        ['] On_clicked     SetClickFunc: self
        ['] On_unclicked   SetUnClickFunc: self
        ['] DoSizing       SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        ;M

:M WindowStyle:   ( -- style )  WindowStyle: Super   WS_CLIPCHILDREN or ;M
:M WindowHasMenu: ( -- f )      true                                    ;M
:M WindowTitle:   ( -- ztitle ) z" Treeview template"                   ;M
:M WndClassStyle: ( -- style )  CS_DBLCLKS                              ;M
:M StartSize:     ( -- w h )    screen-size >r 2/ r> 2/                 ;M
:M StartPos:      ( -- x y )    CenterWindow: Self                      ;M
:M On_Size:       ( -- )        position-windows                        ;M
:M ParentWindow:  ( -- hwndParent | 0=NoParent )   parent               ;M
:M SetParent:     ( hwndparent -- )             to parent               ;M

:M On_Done:     ( h m w l -- res )
        On_Done: super 0
        bye
        ;M

;Object

MENUBAR ApplicationBar
    POPUP "File"
        MENUITEM        "Exit"          Close: SplitterWindow    ;
ENDBAR

: main  ( -- )
        Start: SplitterWindow
        ApplicationBar SetMenuBar: SplitterWindow ;

turnkey? [if]
        ' main turnkey App.exe
        s" WIN32FOR.ICO" s" App.exe" AddAppIcon
        1 pause-seconds bye
[else]
        main
[then]

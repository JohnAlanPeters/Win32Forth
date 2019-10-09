\ $Id: ListViewDemo.f,v 1.19 2011/08/10 15:58:18 georgeahubert Exp $

\ Splitter window modified to prevent flicker - May 4th, 2006 Rod
\ ForthForm generated splitter-window template
\ Modify according to your needs
\ A primarly demo to show some interactions with a ListView

Anew -ListViewDemo.f

Needs ListView.f
Needs Resources.f

false value turnkey?
20 constant FontHeight

\ ------------------------------------------------------------------------
\ Define the Listview for the left part of the window.
\ ------------------------------------------------------------------------
:object ListViewLeft <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ LVS_REPORT LVS_SHOWSELALWAYS OR LVS_SORTASCENDING or LVS_EDITLABELS or ] literal or
        ;M

;object

\ ------------------------------------------------------------------------
\ Define the Listview for the lower right part of the window.
\ ------------------------------------------------------------------------
:object ListViewRightBottom <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ LVS_REPORT  LVS_SHOWSELALWAYS OR LVS_EDITLABELS or ] literal or
        ;M

;object

\ ------------------------------------------------------------------------
\ Define the Window for the upper right part of the window.
\ ------------------------------------------------------------------------
:Object RightTopPane        <Super Child-Window

int lparmLeft
String: Out$
Font vFont

:M out$:        ( - adrOt$ )
        out$  ;M

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Init:     ( -- )
        14 Width: vFont
        FontHeight Height: vFont
        s" Courier" SetFaceName: vFont
        Create: vFont ;M

:M On_size:     ( -- )
        \ need to repaint in this child-window as the position of the
        \ text depends on its size
        Paint: self ;M

:M On_Paint:    ( -- )
        SaveDC: dc                     \ save device context
        GetSize: Self white Fillarea: dc
        Out$ c@ 0<>
        if
             vFont    SelectObject: dc
             ltblue   SetTextColor: dc
             TA_CENTER SetTextAlign: dc drop
             GetSize: self 10 -  swap 2/ swap 4 / 2dup
             Out$ zcount pad place
             s"  lParam:"  pad +place
             lparmLeft 0  (D.) pad +place pad +null
             pad count  Textout: dc
        then
        RestoreDC: dc
        ;M

:M ShowLeftSelected: ( Z$text Lparm flNew - )
        if   to lparmLeft drop paint: Self
        else 2drop
        then ;M

;Object

\ ------------------------------------------------------------------------
\ Define the left part of the splitter window.
\ ------------------------------------------------------------------------
:Object LeftPane        <Super Child-Window

int SelectedItemLeft
LV_ITEM LvItem

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Size:     ( -- )
        0 0 width height Move: ListViewLeft
        ;M

: GetParmsItem  ( nItem  - Z$text Lparm flNew )
        >r LVIF_TEXT LVIF_PARAM or SetMask: LvItem
        out$: RightTopPane SetpszText: LvItem
        maxstring SetcchTextMax: LvItem
        r@ SetiItem: LvItem
        Addr: LvItem GetItem: ListViewLeft drop  out$: RightTopPane
        GetlParam: LvItem r@ SelectedItemLeft <>
        if   r> to SelectedItemLeft true
        else r>drop false
        then ;

: HandleListViewLeft   ( msg - )
        LVNI_SELECTED -1 GetNextItem:  ListViewLeft dup  -1 =
        if   drop
        else GetParmsItem  ShowLeftSelected:  RightTopPane
        then ;

:M WM_NOTIFY    ( h m w l -- f )
        dup @ GetHandle: ListViewLeft = \ EnableNotify? and
        if  HandleListViewLeft
        then false
        ;M

:M On_Init: ( -- )
        -1 to SelectedItemLeft
        Self start: ListViewLeft
        ;M

;Object

\ ------------------------------------------------------------------------
\ Define the right part of the splitter window.
\ ------------------------------------------------------------------------
:Object RightBottomPane        <Super Child-Window

:M ExWindowStyle:       ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Size:     ( -- )
        0 0 width height Move: ListViewRightBottom
        ;M

:M On_Init: ( -- )
        Self start: ListViewRightBottom
        ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Splitter <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or
        ;M

:M WndClassStyle: ( -- style )
         \ CS_DBLCLKS only to prevent flicker in window on sizing.
         CS_DBLCLKS ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height LTGRAY FillArea: dc
        ;M

;Object

200 value LeftWidth
  2 value thickness
 30 value RightTopHeight

\ ------------------------------------------------------------------------
\ Define the the splitter window (this is the main window).
\ ------------------------------------------------------------------------
:Object SplitterWindow        <Super Window

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any

int dragging?
int mousedown?

: LeftHeight            ( -- n )
        Height StatusBarHeight - ToolBarHeight - ;

: RightBottomHeight     ( -- n )
        Height StatusBarHeight - ToolBarHeight - RightTopHeight - ;

: position-windows ( -- )
        0  ToolBarHeight  LeftWidth  LeftHeight  Move: LeftPane
        LeftWidth thickness +  ToolBarHeight  Width LeftWidth thickness + -  RightTopHeight  Move: RightTopPane
        LeftWidth thickness +  ToolBarHeight RightTopHeight +  Width LeftWidth thickness + -  RightBottomHeight  Move: RightBottomPane
        LeftWidth  ToolBarHeight  thickness  LeftHeight  Move: Splitter ;

: InSplitter?   ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  LeftWidth dup thickness + within  and ;

\ mouse click routines for Main Window to track the Splitter movement

: DoSizing      ( -- )
        mousedown? dragging? or 0= ?EXIT
        mousex ( 1+ ) width min  thickness 2/ -  to LeftWidth
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
        LeftWidth 8 >
        IF      0 thickness 2/ - to LeftWidth
        ELSE    132 Width 2/ min to LeftWidth
        THEN
        position-windows
        ;

:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        ToolBarHeight dup LeftHeight + within
        swap  0 width within and
        IF  InSplitter? IF  SIZEWE-CURSOR   ELSE  arrow-cursor  THEN  1
        ELSE  DefWindowProc: self
        THEN
        ;M

:M Classinit:   ( -- )
        ClassInit: super   \ init super class
        ['] On_clicked     SetClickFunc: self
        ['] On_unclicked   SetUnClickFunc: self
        ['] DoSizing       SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        ;M

:M WindowHasMenu: ( -- f )
                true ;M

:M WindowStyle: ( -- style )
                WindowStyle: Super
                WS_CLIPCHILDREN or ;M

:M WndClassStyle: ( -- style )
                \ CS_DBLCLKS only to prevent flicker in window on sizing.
                CS_DBLCLKS
                ;M

:M StartSize:   ( -- w h )
                screen-size >r 2/ r> 2/ ;M

:M On_Size:     ( -- )
                position-windows ;M

:M On_Init:     ( -- )
                self Start: LeftPane
                self Start: RightTopPane
                self Start: RightBottomPane
                self Start: Splitter
                ;M

:M On_Done:     ( h m w l -- res )
                Close: self
                0 call PostQuitMessage drop
                On_Done: super 0 ;M

LV_COLUMN lvc
:M InitListViewColumns: ( -- )
        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        120                                                     Setcx: lvc

        z" Location"              SetpszText: lvc
        Addr: lvc 1               InsertColumn: ListViewLeft  drop

        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        120                                                     Setcx: lvc

        z" Contact"               SetpszText: lvc
        Addr: lvc 0               InsertColumn: ListViewRightBottom

        z" Street and number"     SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRightBottom

        z" Postal code"           SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRightBottom

        z" Place"                 SetpszText: lvc
        Addr: lvc swap 1+         InsertColumn: ListViewRightBottom  drop
        ;M

LV_ITEM LvItem
:M InitListViewItems: ( -- )

        LVIF_TEXT LVIF_PARAM or SetMask:    LvItem  \ SetMask: Also erases old parameters
        0                       SetiItem:   LvItem
        31                      SetlParam:  LvItem
        z" Sweden"              SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewLeft

        LVIF_TEXT LVIF_PARAM or SetMask:    LvItem
        1+                      SetiItem:   LvItem
        32                      SetlParam:  LvItem
        z" Germany"             SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewLeft

        LVIF_TEXT               SetMask:    LvItem
        1+                      SetiItem:   LvItem
        z" America"             SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewLeft drop


        LVIF_TEXT LVIF_PARAM or SetMask:    LvItem
        0                       SetiItem:   LvItem
        41                      SetlParam:  LvItem
        z" Gordon"              SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewRightBottom



        LVIF_TEXT LVIF_PARAM or SetMask:    LvItem
        1+                      SetiItem:   LvItem
        42                      SetlParam:  LvItem
        z" Jack"                SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewRightBottom


        LVIF_TEXT               SetMask:     LvItem  \ Inserting a subitem
        dup>r                   SetiItem:    LvItem  \ Uses the index from "Jack"
        2                       SetiSubItem: LvItem
        z" 2043 VD"             SetpszText:  LvItem
        Addr: LvItem  r>        SetItemText: ListViewRightBottom


        LVIF_TEXT LVIF_PARAM or SetMask:    LvItem
        1+                      SetiItem:   LvItem
        43                      SetlParam:  LvItem
        z" Vern"                SetpszText: LvItem
        Addr: LvItem            InsertItem: ListViewRightBottom drop
        ;M

;Object

: main  ( -- )
        Start: SplitterWindow
        InitListViewColumns: SplitterWindow
        InitListViewItems: SplitterWindow
        true       LVS_EX_FULLROWSELECT SetExtendedStyle: ListViewRightBottom
        ;

turnkey? [if]
        ' main turnkey ListViewDemo.exe
        s" WIN32FOR.ICO" s" ListViewDemo.exe" AddAppIcon
        1 pause-seconds bye
[else]
        main
[then]

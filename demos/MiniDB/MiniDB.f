\ $Id: MiniDB.f,v 1.3 2011/08/10 15:58:18 georgeahubert Exp $

Anew -MiniDB.f

Needs ListView.f
Needs Resources.f
Require startdb.f
Require EditDB.f

false value turnkey?
20 constant FontHeight

: DoEdit   ( record# -- )
          Start: DBDialog ;

: DoAdd    ( -- )
          0 Start: DBDialog ;

\ ------------------------------------------------------------------------
\ Define the Listview for the database table
\ ------------------------------------------------------------------------
:object ListViewDB <super ListView

:M WindowStyle: ( -- style )
        WindowStyle: super
        [ LVS_REPORT LVS_SHOWSELALWAYS or LVS_SINGLESEL or ] literal or
        ;M

;object

\ ------------------------------------------------------------------------
\ Define the main window.
\ ------------------------------------------------------------------------
:Object SimpleDBWindow        <Super Window

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any
LV_COLUMN lvc
LV_ITEM LvItem
ButtonControl NewEntry

:M WindowHasMenu: ( -- f )
                true ;M

:M WindowStyle: ( -- style )
                WindowStyle: Super
                WS_CLIPCHILDREN or ;M

:M WndClassStyle: ( -- style )
                CS_DBLCLKS
                ;M

:M StartSize:   ( -- w h )
                screen-size >r 2/ r> 2/ ;M

:M On_Size:     ( -- )
                0 0 width height 20 -  Move: ListViewDB
                0 height 20 - width 20 Move: NewEntry
                ;M

:M On_Init:     ( -- )
                self Start: ListviewDB
                color: white SetBKColor: ListviewDB
                self               Start: NewEntry
                0 height 20 - width 20 Move: NewEntry
                s" New Record"       SetText: NewEntry
                ['] DoAdd     SetFunc: NewEntry
                ;M

:M On_Done:     ( h m w l -- res )
                Close: self
                turnkey? if 0 call PostQuitMessage drop then
                On_Done: super 0 ;M

: GetLParmItem  ( nItem  --  Lparm )
        LVIF_PARAM SetMask: LvItem
        SetiItem: LvItem
        Addr: LvItem GetItem: ListViewDB drop
        GetlParam: LvItem ;

: ItemEdit  ( -- )
        LVNI_SELECTED -1 GetNextItem:  ListViewDB dup  -1 =
        if   drop
        else GetLParmItem  DoEdit
        then ;

: HandleListViewDB   ( msg - )
        2 cells + @ case
        NM_DBLCLK of ItemEdit endof
        endcase ;

:M WM_NOTIFY    ( h m w l -- f )
        dup @ GetHandle: ListViewDB =
        if  HandleListViewDB
        then false
        ;M

:M InitListViewColumns: ( -- )

        LVCF_FMT LVCF_WIDTH LVCF_TEXT LVCF_SUBITEM or or or   Setmask: lvc
        LVCFMT_LEFT                                            Setfmt: lvc
        120                                                     Setcx: lvc

        fieldcnt: MiniDB ?dup if
        1 ?do
        i fieldname: MiniDB    drop SetpszText: lvc
        Addr: lvc i               InsertColumn: ListViewDB drop
        loop then
        ;M

:M InitListViewItems: ( -- )

        -1 begin
        fieldcnt: MiniDB ?dup if
        1 ?do
        LVIF_TEXT i 1 = if LVIF_PARAM or then SetMask:    LvItem

        i 1 = if 1+              SetiItem:   LvItem
        0 getint: MiniDB      SetlParam:  LvItem
        1 getstr: MiniDB drop SetpszText: LvItem
        Addr: LvItem             InsertItem: ListViewDB
        else
        dup                      SetiItem:    LvItem
        i 1-                     SetiSubItem: LvItem
        i getstr: MiniDB drop SetpszText:  LvItem
        Addr: LvItem  over       SetItemText: ListViewDB drop
        then
        loop then
        nextrow: MiniDB
        until drop ;M

:M RefreshListViewItems: ( -- )
        GetAllCustomers InitListViewItems: self paint: self ;m

;Object


\ Patch deferred words

:noname   ( -- )
          Dirty: DBDialog if
          s" INSERT OR REPLACE INTO Customers (id, name, surname, abode) VALUES(?,?,?,?)"
          execute: MiniDB
          record#: DBDialog -if 0 bindint: MiniDB else 0 0 0 bindstr: MiniDB then
          BindText: DBDialog
          DeleteAllItems: ListViewDB
          GetAllCustomers
          InitListViewItems: SimpleDBWindow then
          close: DBDialog ; is Add-modifyDB

:noname   ( -- )
          close: DBDialog ; is RejectDB

: main  ( -- )
 [ turnkey? ] [if] Start-database [then]
        Start: SimpleDBWindow
        GetAllCustomers
        InitListViewColumns: SimpleDBWindow
        InitListViewItems: SimpleDBWindow
        true LVS_EX_FULLROWSELECT SetExtendedStyle: ListViewDB ;

turnkey? [if]
        close: MiniDB \ Make sure database is shut before saving
        ' main turnkey MiniDB.exe
        s" WIN32FOR.ICO" s" MiniDB.exe" AddAppIcon
        1 pause-seconds bye
[else]
         main
[then]

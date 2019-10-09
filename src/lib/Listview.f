\ $Id: Listview.f,v 1.13 2011/07/06 12:04:34 georgeahubert Exp $

\ ListView.f      ListView control by Prad

anew -ListView.f

cr  .( Loading ListView.f : ListView Class...)

internal
external

( -------------------------------------------------------------------)
( Point )

warning @ warning off checkstack

:Class Point <Super Object

Record: _Point
        int x
        int y
;RecordSize: /Point

:M Addr:   ( -- a ) _Point  ;M
:M Sizeof: ( -- n ) /Point  ;M

:M Getpt: ( -- x y ) x y ;M
:M Setpt: ( x y -- ) to y to x ;M

;Class

warning !

( -------------------------------------------------------------------)
( NMHDR )

:Class NMHDR <Super Object

Record: _NMHDR
    int hwndFrom
    int idFrom
    int code
;RecordSize: /NMHDR

:M Addr:   ( -- a ) _NMHDR  ;M
:M Sizeof: ( -- n ) /NMHDR  ;M

:M GethwndFrom: ( -- hwndFrom ) hwndFrom ;M
:M GetidFrom:   ( -- idFrom )   idFrom   ;M
:M Getcode:     ( -- code )     code     ;M
:M SethwndFrom: ( hwndFrom -- ) to hwndFrom ;M
:M SetidFrom:   ( idFrom -- )   to idFrom   ;M
:M Setcode:     ( code -- )     to code     ;M

;Class

( -------------------------------------------------------------------)
( LV_ITEM )

:Class LV_ITEM <Super Object

Record: _LV_ITEM
        int mask
        int iItem
        int iSubItem
        int state
        int stateMask
        int pszText
        int cchTextMax
        int iImage
        int lParam
;RecordSize: /LV_ITEM

:M Addr:   ( -- a ) _LV_ITEM  ;M
:M Sizeof: ( -- n ) /LV_ITEM   ;M

:M GetMask:       ( -- mask )           mask       ;M
:M GetiItem:      ( -- iItem )          iItem      ;M
:M GetiSubItem:   ( -- iSubItem )       iSubItem   ;M
:M Getstate:      ( -- state )          state      ;M
:M GetstateMask:  ( -- stateMask )      stateMask  ;M
:M GetpszText:    ( -- pszText )        pszText    ;M
:M GetcchTextMax: ( -- cchTextMax )     cchTextMax ;M
:M GetiImage:     ( -- iImage )         iImage     ;M
:M GetlParam:     ( -- lParam)          lParam     ;M

:M SetMask:       ( mask -- ) _LV_ITEM /LV_ITEM erase to mask  ;M
:M SetiItem:      ( iItem -- )          to iItem      ;M
:M SetiSubItem:   ( iSubItem -- )       to iSubItem   ;M
:M Setstate:      ( state -- )          to state      ;M
:M SetstateMask:  ( stateMask -- )      to stateMask  ;M
:M SetpszText:    ( pszText -- )        to pszText    ;M
:M SetcchTextMax: ( cchTextMax -- )     to cchTextMax ;M
:M SetiImage:     ( iImage -- )         to iImage     ;M
:M SetlParam:     ( lParam-- )          to lParam     ;M

;Class

( -------------------------------------------------------------------)
( LV_DISPINFO )

:Class LV_DISPINFO <Super NMHDR

Record: _LV_DISPINFO
        int mask
        int iItem
        int iSubItem
        int state
        int stateMask
        int pszText
        int cchTextMax
        int iImage
        int lParam
;RecordSize: /LV_DISPINFO

:M Addr:   ( -- a ) _LV_DISPINFO  ;M
:M Sizeof: ( -- n ) /LV_DISPINFO  ;M

:M GetMask:        ( -- mask )          mask       ;M
:M GetiItem:       ( -- iItem  )        iItem      ;M
:M GetiSubItem:    ( -- iSubItem )      iSubItem   ;M
:M Getstate:       ( -- state )         state      ;M
:M GetstateMask:   ( -- stateMask )     stateMask  ;M
:M GetpszText:     ( -- pszText )       pszText    ;M
:M GetcchTextMax:  ( -- cchTextMax )    cchTextMax ;M
:M GetiImage:      ( -- iImage )        iImage     ;M
:M GetlParam:      ( -- lParam )        lParam     ;M

:M SetMask:        ( mask -- ) _LV_DISPINFO /LV_DISPINFO erase to mask       ;M
:M SetiItem:       ( iItem -- )         to iItem      ;M
:M SetiSubItem:    ( iSubItem -- )      to iSubItem   ;M
:M Setstate:       ( state -- )         to state      ;M
:M SetstateMask:   ( stateMask -- )     to stateMask  ;M
:M SetpszText:     ( pszText -- )       to pszText    ;M
:M SetcchTextMax:  ( cchTextMax -- )    to cchTextMax ;M
:M SetiImage:      ( iImage -- )        to iImage     ;M
:M SetlParam:      ( lParam -- )        to lParam     ;M

;Class

( -------------------------------------------------------------------)
( LV_COLUMN )

:Class LV_COLUMN <Super Object

Record: _LV_COLUMN
    int mask
    int fmt
    int cx
    int pszText
    int cchTextMax
    int iSubItem
;RecordSize: /LV_COLUMN

:M Addr:   ( -- a ) _LV_COLUMN   ;M
:M Sizeof: ( -- n ) /LV_COLUMN   ;M

:M Getmask:       ( -- mask )           mask       ;M
:M Getfmt:        ( -- fmt )            fmt        ;M
:M Getcx:         ( -- cx )             cx         ;M
:M GetpszText:    ( -- pszText )        pszText    ;M
:M GetcchTextMax: ( -- cchTextMax )     cchTextMax ;M
:M GetiSubItem:   ( -- iSubItem )       iSubItem   ;M

:M Setmask:       ( mask -- ) _LV_COLUMN /LV_COLUMN erase to mask  ;M
:M Setfmt:        ( fmt -- )            to fmt        ;M
:M Setcx:         ( cx -- )             to cx         ;M
:M SetpszText:    ( pszText -- )        to pszText    ;M
:M SetcchTextMax: ( cchTextMax -- )     to cchTextMax ;M
:M SetiSubItem:   ( iSubItem -- )       to iSubItem   ;M

;Class

( -------------------------------------------------------------------)
( LV_FINDINFO )

:Class LV_FINDINFO <Super Object

Record: _LV_FINDINFO
    int flags
    int psz
    int lParam
        int x
        int y
    int vkDirection
;RecordSize: /LV_FINDINFO

:M Addr:   ( -- a ) _LV_FINDINFO   ;M
:M Sizeof: ( -- n ) /LV_FINDINFO   ;M

:M Getflags:       ( -- flags )         flags       ;M
:M Getpsz:         ( -- psz )           psz         ;M
:M GetlParam:      ( -- lparam )        lparam      ;M
:M GetvkDirection: ( -- vkDirection )   vkDirection ;M

:M Setflags:       ( flags -- )         to flags       ;M
:M Setpsz:         ( psz -- )           to psz         ;M
:M SetlParam:      ( lparam -- )        to lparam      ;M
:M SetvkDirection: ( vkDirection -- )   to vkDirection ;M

:M Getpt:          ( -- x y ) x y       ;M
:M Setpt:          ( x y -- ) to y to x ;M

;Class

( -------------------------------------------------------------------)
( LV_HITTESTINFO )

:Class LV_HITTESTINFO <Super Object

Record: _LV_HITTESTINFO
        int x
        int y
    int flags
    int iItem
;RecordSize: /LV_HITTESTINFO

:M Addr:   ( -- a ) _LV_HITTESTINFO  ;M
:M Sizeof: ( -- n ) /LV_HITTESTINFO  ;M

:M Getflags: ( -- flags ) flags ;M
:M GetiItem: ( -- iItem ) iItem ;M

:M Setflags: ( flags -- ) to flags ;M
:M SetiItem: ( iItem -- ) to iItem ;M

:M Getpt: ( -- x y ) x y ;M
:M Setpt: ( x y -- ) to y to x ;M

;Class

( -------------------------------------------------------------------)
( LV_KEYDOWN )

:Class LV_KEYDOWN <Super NMHDR

Record: _LV_KEYDOWN
    int wVKey
    int flags
;RecordSize: /LV_KEYDOWN

:M Addr:   ( -- a ) _LV_KEYDOWN  ;M
:M Sizeof: ( -- n ) /LV_KEYDOWN  ;M

:M GetwvKey: ( -- wVKey ) wVKey  ;M
:M Getflags: ( -- flags ) flags  ;M

:M SetwvKey: ( -- ) to wVKey ;M
:M Setflags: ( -- ) to flags  ;M


;Class

( -------------------------------------------------------------------)
( NM_LISTVIEW )

:Class NM_LISTVIEW <Super NMHDR

Record: _NM_LISTVIEW
    int iItem
    int iSubItem
    INT uNewState
    INT uOldState
    INT uChanged
        int x
        int y
    int lParam
;RecordSize: /NM_LISTVIEW

:M Addr:   ( -- a ) _NM_LISTVIEW  ;M
:M Sizeof: ( -- n ) /NM_LISTVIEW  ;M

:M GetiItem:     ( -- iItem )           iItem     ;M
:M GetiSubItem:  ( -- iSubItem )        iSubItem  ;M
:M GetuNewState: ( -- uNewState )       uNewState ;M
:M GetuOldState: ( -- uOldState )       uOldState ;M
:M GetuChanged:  ( -- uChanged )        uChanged  ;M
:M GetlParam:    ( -- lParam )          lParam    ;M

:M SetiItem:     ( iItem -- )           to iItem     ;M
:M SetiSubItem:  ( iSubItem -- )        to iSubItem  ;M
:M SetuNewState: ( uNewState -- )       to uNewState ;M
:M SetuOldState: ( uOldState -- )       to uOldState ;M
:M SetuChanged:  ( uChanged -- )        to uChanged  ;M
:M SetlParam:    ( lParam -- )          to lParam    ;M

:M Getpt: ( -- x y ) x y ;M
:M Setpt: ( x y -- ) to y to x ;M


;Class

( -------------------------------------------------------------------)
( ListView Control )

:Class ListView <Super Control

\     int nmhdr    \ NMHDR           nmhdr
\     int nmlv     \ NM_LISTVIEW     nmlv
\     int lvdi     \ LV_DISPINFO     lvdi
\     int lvkd     \ LV_KEYDOWN      lvkd

:M Start:               ( Parent -- )
        to Parent
        z" SysListView32" Create-Control
        ;M

( -------------------------------------------------------------------)
( Items and SubItems )

:M DeleteAllItems:    ( -- f ) 0 0 LVM_DELETEALLITEMS SendMessage:Self ;M
:M DeleteItem:        ( iitem -- f ) 0 swap LVM_DELETEITEM SendMessage:Self ;M
:M GetItem:           ( ptem -- f ) 0 LVM_GETITEM SendMessage:Self ;M
:M GetItemCount:      ( -- n ) 0 0 LVM_GETITEMCOUNT SendMessage:Self ;M
:M GetItemSpacing:    ( fsmall -- f ) 0 swap LVM_GETITEMSPACING SendMessage:Self ;M
:M GetItemState:      ( mask i -- f ) LVM_GETITEMSTATE SendMessage:Self ;M
:M GetItemText:       ( pitem iItem -- adr count )   >r dup r>
                      LVM_GETITEMTEXT SendMessage:Self swap 5 cells+ @ swap ;M
:M GetSelectedCount:  ( -- n ) 0 0 LVM_GETSELECTEDCOUNT SendMessage:Self ;M
:M InsertItem:        ( pitem -- index | -1 ) 0 LVM_INSERTITEM SendMessage:Self ;M
:M SetItem:           ( pitem -- index | -1 ) 0 LVM_SETITEM SendMessage:Self ;M
:M SetItemCount:      ( cItems -- ) 0 swap LVM_SETITEMCOUNT SendMessage:Self ;M
:M SetItemState:      ( pitem i -- f ) LVM_SETITEMSTATE SendMessage:Self ;M
:M SetItemText:       ( pitem i -- f ) LVM_SETITEMTEXT SendMessage:Self ;M
:M SetExtendedStyle:  ( fl lvs_ex_style - ) LVM_SETEXTENDEDLISTVIEWSTYLE
                                               SendMessage:SelfDrop    ;M
( -------------------------------------------------------------------)
( Callback Items )

:M GetCallBackMask:   ( -- mask ) 0 0 LVM_GETCALLBACKMASK SendMessage:Self ;M
:M ReDrawItems:       ( iLast iFirst -- f ) LVM_REDRAWITEMS SendMessage:Self ;M
:M SetCallBackMask:   ( mask -- f ) 0 swap LVM_SETCALLBACKMASK SendMessage:Self ;M
:M Update:            ( iItem -- f ) 0 swap LVM_UPDATE SendMessage:Self ;M

( -------------------------------------------------------------------)
( Columns )

:M DeleteColumn:      ( icol -- f ) 0 swap LVM_DELETECOLUMN SendMessage:Self ;M
:M GetColumn:         ( pcol icol -- f ) LVM_GETCOLUMN SendMessage:Self ;M
:M GetColumnWidth:    ( icol -- width|0 ) 0 swap LVM_GETCOLUMNWIDTH SendMessage:Self ;M
:M GetStringWidth:    ( psz -- width|0 ) 0 LVM_GETSTRINGWIDTH SendMessage:Self ;M
:M InsertColumn:      ( pcol icol -- index|-1 ) LVM_INSERTCOLUMN SendMessage:Self ;M
:M SetColumn:         ( pcol icol -- f ) LVM_SETCOLUMN SendMessage:Self ;M
:M SetColumnWidth:    ( cx icol -- ) LVM_SETCOLUMNWIDTH SendMessage:SelfDrop ;M

( -------------------------------------------------------------------)
( Arranging, Sorting and Finding )

:M Arrange:           ( code -- f ) 0 swap LVM_ARRANGE SendMessage:Self ;M
:M FindItem:          ( plvfi iStart -- index|-1 ) LVM_FINDITEM SendMessage:Self ;M
:M GetNextItem:       ( flags iStart -- index|-1 ) LVM_GETNEXTITEM SendMessage:Self ;M
:M SortItems:         ( pfnCompare lParamsort -- f ) LVM_SORTITEMS SendMessage:Self ;M

( -------------------------------------------------------------------)
( Items Positions and Scrolling )

:M EnsureVisible:     ( fPartialOK i -- f ) LVM_ENSUREVISIBLE SendMessage:Self ;M
:M GetCountPerPage:   ( -- n ) 0 0 LVM_GETCOUNTPERPAGE SendMessage:Self ;M
:M GetItemPosition:   ( ppt i -- f ) LVM_GETITEMPOSITION SendMessage:Self ;M
:M GetItemRect:       ( prc i -- f ) LVM_GETITEMRECT SendMessage:Self ;M
:M GetOrigin:         ( lpptOrg -- f ) 0 LVM_GETORIGIN SendMessage:Self ;M
:M GetTopIndex:       ( -- index|0 ) 0 0 LVM_GETTOPINDEX SendMessage:Self ;M
:M GetViewRect:       ( prc -- f ) 0 LVM_GETVIEWRECT SendMessage:Self ;M
:M HitTest:           ( pinfo -- index|-1 ) 0 LVM_HITTEST SendMessage:Self ;M
:M Scroll:            ( dy dx -- f ) LVM_SCROLL SendMessage:Self ;M
:M SetItemPosition:   ( x y i -- f ) >r word-join r> LVM_SETITEMPOSITION SendMessage:Self ;M
:M SetItemPosition32: ( lpptNewPos iItem -- f ) LVM_SETITEMPOSITION32 SendMessage:Self ;M

( -------------------------------------------------------------------)
( Colours )

:M GetBkColor:        ( -- col ) 0 0 LVM_GETBKCOLOR SendMessage:Self ;M
:M GetTextBkColor:    ( -- col ) 0 0 LVM_GETTEXTBKCOLOR SendMessage:Self ;M
:M GetTextColor:      ( -- col ) 0 0 LVM_GETTEXTCOLOR SendMessage:Self ;M
:M SetBkColor:        ( clrBk -- f ) 0 LVM_SETBKCOLOR SendMessage:Self ;M
:M SetTextBkColor:    ( clrText -- f ) 0 LVM_SETTEXTBKCOLOR SendMessage:Self ;M
:M SetTextColor:      ( clrText -- f ) 0 LVM_SETTEXTCOLOR SendMessage:Self ;M

( -------------------------------------------------------------------)
( Miscellaneous )

:M CreateDragImage:   ( lpptUpLeft iItem -- hndl|NULL ) LVM_CREATEDRAGIMAGE SendMessage:Self ;M
:M EditLabel:         ( iItem -- hndl|NULL ) 0 swap LVM_EDITLABEL SendMessage:Self ;M
:M GetEditControl:    ( -- ) 0 0 LVM_GETEDITCONTROL SendMessage:Self ;M
:M GetImageList:      ( iImageList -- hndl|NULL ) 0 swap LVM_GETIMAGELIST SendMessage:Self ;M
:M SetImageList:      ( himl iImageList -- hndl|NULL ) LVM_SETIMAGELIST SendMessage:Self ;M

( -------------------------------------------------------------------)
( -Window Message Processing performed by a list contol- )

Comment:

The following messages are processed by the window procedure of a ListView control.
To intercept a message eg WM_CHAR :-
:M WM_CHAR ( h m w l -- f )
        ( ****Add your code here**** )
        old-WndProc CallWindowProc ;M
Failure to send this message to the old window procedure will stop the control working properly.

WM_CHAR
WM_COMMAND
WM_CREATE
WM_DESTROY
WM_ERASEBKGND
WM_GETDLGCODE
WM_GETFONT
WM_HSCROLL
WM_KEYDOWN
WM_KILLFOCUS
WM_LBUTTONDBLCLK
WM_LBUTTONDOWN
WM_NCCREATE
WM_NOTIFY - processes notification messages from the header control.
            A list view control also sends WM_NOTIFY to its
            owner window when events occur in the control.
WM_NCCREATE
WM_NCDESTROY
WM_PAINT
WM_RBUTTONDOWN
WM_SETFOCUS
WM_SETFONT
WM_SETREDRAW
WM_TIMER
WM_VSCROLL
WM_WINDOWPOSCHANGED
WM_WININICHANGE

Comment;

;Class

( -------------------------------------------------------------------)
( Helper words for WM_NOTIFY handling
( -------------------------------------------------------------------)

: LVN_GetNotifyItem     ( addr -- Item )
        3 cells + @ ;

: LVN_GetNotifySubItem  ( addr -- SubItem )
        4 cells + @ ;

: LVN_GetNotifyNewState ( addr -- NewState )
        6 cells + @ ;

: LVN_GetNotifyOldState ( addr -- OldState )
        7 cells + @ ;

: LVN_GetNotifyChanged  ( addr -- Changed )
        8 cells + @ ;

: LVN_GetNotifyParam    ( addr -- lParam )
        10 cells + @ ;

module

\s  A simple demo:

( -------------------------------------------------------------------)
( -------------------------------------------------------------------)
( Example )
( Get it all started just to see if it works )

see demos\ListViewDemo.f

( -------------------------------------------------------------------)

\ $Id: TabControlDemo.f,v 1.5 2011/08/10 15:58:18 georgeahubert Exp $
\
\ Demo for a window that contains a tabulator control.
\ Within the client area of the tabulator control listview controls
\ are displayed.
\
\ Written by Dirk Busch

needs ExControls.f
Needs ListView.f

anew -TabControlDemo.f

internal
external

\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
:class TabControlEx <super TabControl

((  This has no effect for a control as the window class is already registered
:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M
))

:M Start:	( Parent -- )
	Start: super
      CS_DBLCLKS CS_GLOBALCLASS or GCL_STYLE hWnd  Call SetClassLong  drop
( many controls don't have CS_HREDRAW and CS_VREDRAW set, this one does and will not redraw properly without help! )
	DEFAULT_GUI_FONT call GetStockObject SetFont: self
	;M

;class

\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
:class ListViewEx <super ListView

:M WindowStyle: ( -- style )
\ Return the window style.
        WindowStyle: super
        [ LVS_REPORT LVS_SHOWSELALWAYS OR LVS_EDITLABELS or ] literal or
        ;M

:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M

;class

\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
:object DemoWindow <super Window

TabControlEx	cTab
ListViewEx 	cFileList
ListViewEx 	cBrowserList

LV_ITEM   LvItem
LV_COLUMN lvc

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_CLIPCHILDREN or
        ;M

:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M

:M ReSize:	( -- )
\ Resize the controls within the main window.
        ClientSize: ctab   \  get display area before size change ( l t r b )
        AutoSize: cTab
        winRect GetClientRect: cTab   \ get whole client area after size change
        ( b ) winRect.bottom 1 - min 0 winRect 2!
        true winRect InvalidateRect: cTab   \ invalidate bottom edge
        ( r ) 0 swap winRect.right  1 - min winRect 2!  ( l t ) 2drop
        true winRect InvalidateRect: ctab   \ invalidate right edge

        ClientSize: cTab 2over d- ( x y w h )
        4dup  Move: cFileList
              Move: cBrowserList
         ;M

:M On_Size:	( -- )
\ Handle the WM_SIZE message.
	On_Size: super ReSize: self ;M

:M SelChange:	( -- )
\ Show the listview control for the currently selected tab.
	GetSelectedTab: cTab 0=
	if
	     SW_SHOW Show: cFileList   \ show cFileList before hiding cBrowserList for less flicker
           SW_HIDE Show: cBrowserList
	else
	     SW_SHOW Show: cBrowserList
           SW_HIDE Show: cFileList
	then ;M

: selchange-func  { lParam obj \ Parent -- false }
\ This function is executed when the currently selected tab has changed.
\ lParam is the adress of the Address of an NMHDR structure.
\ obj is the address of the TabControl object that has send the
\ notification message.
	GetParent: obj to Parent
	SelChange: Parent
	false ;

:M WM_NOTIFY    ( h m w l -- f )
\ Handle the notification messages of the tab control.
        dup @ GetHandle: cTab =
        if   Handle_Notify: cTab
        then false
	;M

:M StartPos:    ( -- x y )
        CenterWindow: self ;M

:M On_Init:     ( -- )
	On_Init: super

	self Start: cFileList
	self Start: cBrowserList
	self Start: cTab

	\ ------------------------------------------------------------------------

	['] selchange-func IsChangeFunc: cTab

	TCIF_TEXT IsMask: cTab
	z" Files" IsPszText: cTab
	1 InsertTab: cTab

	TCIF_TEXT IsMask: cTab
	z" Browser" IsPszText: cTab
	2 InsertTab: cTab

	\ ------------------------------------------------------------------------

        [ LVCF_FMT LVCF_WIDTH or LVCF_TEXT or LVCF_SUBITEM or ] literal Setmask: lvc
        LVCFMT_LEFT  Setfmt: lvc
        50           Setcx: lvc

        z" Files"    SetpszText: lvc
        Addr: lvc 1  InsertColumn: cFileList drop

        z" Words"    SetpszText: lvc
        Addr: lvc 1  InsertColumn: cBrowserList  drop

	\ ------------------------------------------------------------------------

        \ Note: You must first set the mask and then the other struct members !!!
        LVIF_TEXT       SetMask:    LvItem

        z" File 1"      SetpszText: LvItem
        Addr: LvItem    InsertItem: cFileList drop

        z" File 2"      SetpszText: LvItem
        Addr: LvItem    InsertItem: cFileList drop

        z" abc"       	SetpszText: LvItem
        Addr: LvItem    InsertItem: cBrowserList drop

        z" def"       	SetpszText: LvItem
        Addr: LvItem    InsertItem: cBrowserList drop

z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" File 1"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" File 2"      SetpszText: LvItem
Addr: LvItem    InsertItem: cFileList drop
z" abc"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop
z" def"       	SetpszText: LvItem
Addr: LvItem    InsertItem: cBrowserList drop

	\ ------------------------------------------------------------------------

	ReSize: self    \ resize the controls within the main window
        SelChange: self \ show the control for the currently selected tab
	;M

:M WindowTitle: ( -- Zstring )
\ Set the window caption. Default is "Window".
        z" Tabulator control Demo" ;M

;object

module

Start: DemoWindow

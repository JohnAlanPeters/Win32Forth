\ $Id: EdTabControl.f,v 1.23 2013/12/17 19:25:22 georgeahubert Exp $
\
\ Written by Dirk Busch

cr .( Loading EdTabControl...)

needs ExControls.f
needs ListView.f
needs ClassBrowser.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ some helper words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: GetNotifyWnd          ( addr -- hWnd )
\ Get the window handle to the control sending a WM_NOTIFY message.
        @ ;

: GetNotifyId           ( addr -- Id )
\ Get the identifier of the control sending a WM_NOTIFY message.
        cell+ @ ;

: GetNotifyCode         ( addr -- Code )
\ Get the notification code of the control sending a WM_NOTIFY message.
        2 cells + @ ;

0 constant PROJECT_TAB
1 constant FILE_TAB
2 constant FOLDER_TAB
3 constant VOC_TAB
4 constant CLASS_TAB
5 Constant FORM_TAB

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ the File Listview control
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class FileListView <super ListView

LV_ITEM     LvItem
LV_COLUMN   LvColumn
LV_FINDINFO LvFindInfo
int         Enable_Notify?

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_BORDER invert and \ remove WS_BORDER style
        WS_CLIPCHILDREN or
        [ LVS_REPORT LVS_SINGLESEL or LVS_SHOWSELALWAYS OR LVS_EDITLABELS or LVS_SORTASCENDING or ] literal or
        ;M

:M ExWindowStyle: ( -- )
        WS_EX_CLIENTEDGE ;M

:M Start:       ( Parent -- )
        Start: super

        true to Enable_Notify?

        [ LVCF_FMT LVCF_WIDTH or LVCF_TEXT or LVCF_SUBITEM or ] literal SetMask: LvColumn
        LVCFMT_LEFT  Setfmt:     LvColumn
        200          Setcx:      LvColumn
        z" Files"    SetpszText: LvColumn

        Addr: LvColumn 1 InsertColumn: self drop
        ;M

:M FindFile:    ( addr -- )
\ Find a file in the list view.
\ addr is the object address of the mdi child window
        LVFI_PARAM SetFlags:  LvFindInfo
                   SetlParam: LvFindInfo
        Addr: LvFindInfo -1 FindItem: self
        ;M

:M RemoveFile:  ( addr -- )
\ Remove a file from the list view.
\ addr is the object address of the mdi child window
        FindFile: self dup -1 <>
        if   DeleteItem: self
        then drop
        ;M

create $buffer 1024 allot
: FileNameToBuffer { addr1 -- addr2 }
\ addr1 is the object address of the mdi child window
        GetFileName: addr1
        count "TO-PATHEND"

        dup 0= if 2drop s" Unnamed File" then
        $buffer place $buffer +null $buffer 1+
        ;

:M AddFile:     { addr -- }
\ Add a file to the list view.
\ addr is the object address of the mdi child window
        addr FindFile: self -1 =
        if   LVIF_TEXT LVIF_PARAM or
             LVIF_STATE or           SetMask:    LvItem
             LVIS_SELECTED           Setstate:   LvItem
             addr                    SetlParam:  LvItem
             addr FileNameToBuffer   SetpszText: LvItem

             Addr: LvItem InsertItem: self drop
        then ;M

:M SetFileState:  ( state addr -- )
\ Set the state of a file to the list view.
\ addr is the object address of the mdi child window
        FindFile: self dup -1 <>
        if   LVIF_STATE SetMask:      LvItem
                        Setstate:     LvItem
             -1         SetstateMask: LvItem

             false to Enable_Notify?
             Addr: LvItem swap SetItemState: self drop
             true to Enable_Notify?
        else drop
        then ;M

:M UpdateFileName: { addr -- }
\ Update the Filename in the list view.
\ addr is the object address of the mdi child window
        addr FindFile: self dup -1 <>
        if   LVIF_TEXT             SetMask:    LvItem
             addr FileNameToBuffer SetpszText: LvItem

             false to Enable_Notify?
             Addr: LvItem swap SetItemText: self drop
             true to Enable_Notify?
        else drop
        then ;M



:M Handle_Notify: ( h m w l -- f )
\ Handle the notification messages of the listview control.
        Enable_Notify?
        if   dup GetNotifyCode LVN_ITEMCHANGED =
             if   false to Enable_Notify?
                  LVN_GetNotifyParam OnSelect
                  true to Enable_Notify?
             else drop
             then
        then false ;M

;class

fload ProjectWindow.f
fload edfilepane.f
fload edforthform.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ an extended TabControl class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class TabControlEx <super TabControl

:M Start:	( Parent -- )
	TCS_MULTILINE AddStyle: self
	Start: super
	DEFAULT_GUI_FONT call GetStockObject SetFont: self
	;M

:M InsertTab:   ( index -- ndx )
\ *G Inserts a new tab into the tab control. ndx is index of added tab or -1
        tc_item swap TCM_INSERTITEM SendMessage:Self ;M

;class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ The Tabulator window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
:class TabWindow <super Child-Window

TabControlEx	   cTab
FileListView 	   cFileList
ClassBrowserWindow cClassTree
ClassBrowserWindow cVocTree


:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M

:M ReSize:	( -- )
\ Resize the controls within the main window.
        AutoSize: cTab

        ClientSize: cTab 2over d- ( x y w h )
        4dup Move: cFileList
        4dup Move: ProjectWindow
        4dup Move: cClassTree
 	4dup Move: cVocTree
        4dup Move: TheFolderView
        4dup Move: frmDebugDlg
	     detached? not
	     if		4dup Move: FormWindow
	     then
	4drop
        ;M

:M On_Size:	( -- )
\ Handle the WM_SIZE message.
        ReSize: self ;M

: ShowFiles     ( -- )
        SW_SHOW Show: cFileList   \ show before hide
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: cClassTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then	;

: ShowProject   ( -- )
        SW_SHOW Show: ProjectWindow
        SW_HIDE Show: cFileList
        SW_HIDE Show: cVocTree
        SW_HIDE Show: cClassTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then	;

: ShowVocs      ( -- )
        SW_SHOW Show: cVocTree
        SW_HIDE Show: cFileList
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cClassTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then	;

: ShowClasses   ( -- )
        SW_SHOW Show: cClassTree
        SW_HIDE Show: cFileList
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then	;

: ShowFolderView   ( -- )
        SW_SHOW Show: TheFolderView
        SW_HIDE Show: cClassTree
        SW_HIDE Show: cFileList
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then	;

: ShowFormWindow   ( -- )
        detached? not
        if	SW_SHOW Show: FormWindow
        then
        SW_HIDE Show: cClassTree
        SW_HIDE Show: cFileList
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        ;

: ShowDebugForm   ( -- )
        SW_SHOW Show: frmDebugDlg
        SW_HIDE Show: cClassTree
        SW_HIDE Show: cFileList
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: TheFolderView
        detached? not
        if	SW_HIDE Show: FormWindow
        then
        ;

:M InitBrowsers: ( -- )
        AddVocabularies: cVocTree
        AddClasses: cClassTree ;M

:M InitVocBrowser: ( -- )
        AddVocabularies: cVocTree ;M

:M InitClassBrowser: ( -- )
        AddClasses: cClassTree ;M

:M SelChange:	( -- )
\ Show the control for the currently selected tab.
	GetSelectedTab: cTab
        case    projtab#    of ShowProject    endof
                filetab#    of ShowFiles      endof
                dirtab#     of ShowFolderView endof
                voctab#     of ShowVocs       endof
                classtab#   of ShowClasses    endof
                formtab#    of ShowFormWindow endof
                debugtab#   of ShowDebugForm  endof
        endcase ;M

: selchange-func  { lParam obj \ Parent -- false }
\ This function is executed when the currently selected tab has changed.
\ lParam is the adress of the Address of an NMHDR structure.
\ obj is the address of the TabControl object that has send the
\ notification message.
	GetParent: obj to Parent
	SelChange: Parent
	false ;

:M ShowTab:	( n -- )
\ show tab n
	SetSelectedTab: ctab
	SelChange: self ;M

:M WM_NOTIFY    ( h m w l -- f )
\ Handle the notification messages of the controls.
        dup GetNotifyWnd GetHandle: cTab =
        if   Handle_Notify: cTab
        else dup GetNotifyWnd GetHandle: cFileList =
             if   Handle_Notify: cFileList
             else dup  GetNotifyWnd GetHandle: cClassTree =
                  if   Handle_Notify: cClassTree
                  else dup  GetNotifyWnd GetHandle: cVocTree =
                       if   Handle_Notify: cVocTree
                       else \ dup  GetNotifyWnd GetHandle: ProjectWindow =
                            \ if   Handle_Notify: ProjectWindow
                            \ else
                            false
        then then then then ;M

: HideAllWindows        ( -- )
        SW_HIDE Show: cFileList   \ show before hide
        SW_HIDE Show: ProjectWindow
        SW_HIDE Show: cVocTree
        SW_HIDE Show: cClassTree
        SW_HIDE Show: TheFolderView
        SW_HIDE Show: frmDebugDlg
        detached? not
        if	SW_HIDE Show: FormWindow
        then    ;

: DeleteAllTabs        ( -- )
        DeleteAllTabs: ctab
        -1 dup to projtab#
           dup to filetab#
           dup to dirtab#
           dup to classtab#
           dup to voctab#
           dup to debugtab#
           detached? not
           if   dup to formtab#
           then drop
           0 to tabcount ;

:M AddFormTab:	( -- )
	detached? not
	if	formtab# -1 <> ?exitm
		TCIF_TEXT IsMask: cTab
		z" Form Designer" IsPszText: cTab
		tabcount InsertTab: cTab to formtab#
	then	;M


:M DeleteFormTab:	( -- )
		formtab# -1 = ?exitm
		formtab# DeleteTab: ctab
		-1 to formtab#
		;M

: ShowSelectedTabs   { \ ndx -- }
        0 to ndx
	show-projtab?
	if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Project" IsPszText: cTab
                ndx InsertTab: cTab to projtab#
        then
        show-filetab?
        if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Files" IsPszText: cTab
                ndx InsertTab: cTab to filetab#
        then
        show-dirtab?
	if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Directory" IsPszText: cTab
                ndx InsertTab: cTab to dirtab#
        then
        show-voctab?
        if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Vocabularies" IsPszText: cTab
                ndx InsertTab: cTab to voctab#
        then
        show-classtab?
	if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Classes" IsPszText: cTab
                ndx InsertTab: ctab to classtab#
        then
        show-debugtab?
	if      1 +to ndx
                TCIF_TEXT IsMask: cTab
                z" Debug" IsPszText: cTab
                ndx InsertTab: ctab to debugtab#
        then
        show-formtab?
        if      detached? not
                if      1 +to ndx
                        TCIF_TEXT IsMask: cTab
                        z" Form Designer" IsPszText: cTab
                        ndx InsertTab: cTab to formtab#
                then
        then    ndx to tabcount         \ save total number of tabs added
        IDM_SHOWPROJECT_TAB DoCommand  ;

:M Refresh:     ( -- )
        HideAllWindows
        DeleteAllTabs
        ShowSelectedTabs
        Resize: self
        ;M

:M On_Init:     ( -- )
	self Start: cFileList
	self Start: ProjectWindow
	self Start: cVocTree
	self Start: cClassTree
	self Start: TheFolderView
	self Start: frmDebugDlg

	detached? not
	if	self Start: FormWindow
	then
	self Start: cTab   \ must be started last

	\ ------------------------------------------------------------------------

	['] selchange-func IsChangeFunc: cTab

	Refresh: self

        SelChange: self \ show the control for the currently selected tab

        ;M

:M AddFile:     ( addr -- )
\ Add a file to the file list view.
        AddFile: cFileList ;M

:M RemoveFile:  ( addr -- )
\ Remove a file from the file list view.
        RemoveFile: cFileList ;M

:M DeSelectFile:  ( addr -- )
\ DeSelect a file in the file list view.
        0 swap SetFileState: cFileList ;M

:M SelectFile:  ( addr -- )
\ Select a file in the file list view.
        LVIS_SELECTED swap SetFileState: cFileList ;M

:M UpdateFileName:  ( addr -- )
\ Update the filename in the file list view.
        UpdateFileName: cFileList ;M

:M FindFile:	( addr -- f )
		FindFile: cFileList ;M

;class

TabWindow cTabWindow

\s

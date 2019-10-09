\ $Id: Main.f,v 1.79 2014/04/16 17:57:05 georgeahubert Exp $

\    File: Main.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Donnerstag, Juni 10 2004 - dbu
\ Updated: Saturday, May 06 2006 - dbu
\
\ This Editor based on the "Scintilla source code edit control".
\ See www.scintilla.org for more information about the control.

cr .( Loading Win32Forth IDE...)

ANEW -Main.f

only forth also editor definitions \ put all words into the EDITOR vocabulary

true  value sysgen

s" apps\win32forthIDE" "fpath+
s" apps\win32forthIDE\forms" "fpath+
s" apps\win32forthIDE\res" "fpath+

load-dialog WINEDIT     \ load the dialogs for WinEd (some of them are recycled here)
needs Mdi.f
needs AcceleratorTables.f
needs MultiOpen.f
needs HtmlControl.f
needs ScintillaControl.f
needs file.f
needs RegistryWindowPos.f
needs RecentFiles.f
needs src\lib\Resources.f
needs excontrols.f

0 value ActiveChild   \ the active MDI child window
0 value CurrentWindow \ the control in the active MDI child window
0 value ActiveBrowser \ the MDI child window used for source browsing
0 value ActiveRemote  \ the MDI child window used for remote opening a file from the console
0 value ACCEL-HNDL    \ handle of the AcceleratorKeyTable
0 value MainWindow    \ the address of the main window object
0 value TheProject    \ the address of the Project window object
0 value TheFormBar    \ address of toolbar for form designer
0 value ActiveForm    \ current form
0 value FormList      \ pointer to list of open forms
0 value ActiveCoder   \ the MDI child window used for editing form code
0 value UpdateSelectionMode?
SC_SEL_STREAM value SelectionMode       \ default mode for editing

ReadFile ViewerFile

true        value CreateBackup?
SC_EOL_CRLF value EOL
false       value ViewEOL?
false       value ViewWhiteSpace?
false       value ViewLineNumbers?
true        value SaveAllBeforeCompile?
true        value Colorize?
8           value TabSize
true        value UseTabs?
true        value ShowToolbar?
true        value ShowStatusbar?
true        value StripTrailingWhitespace?
true        value FinalNewLine?
false       value CompileProject?
false	    value autoindent?
false 	    value with-tabs?
false	    value include-libs?
150 175     2value BookMarksPos
225 450     2value BookMarksSize
false value autosavesession?        \ save/restore default IDE session?

true value show-projtab?
true value show-filetab?
true value show-formtab?
true value show-classtab?
true value show-voctab?
true value show-dirtab?
true value show-debugtab?

-1 value projtab#
-1 value filetab#
-1 value formtab#
-1 value classtab#
-1 value voctab#
-1 value dirtab#
-1 value debugtab#
0 value tabcount
0 value frmDebugDlg     \ allow forward referencing

150 Constant IDT_FILETIME
false value intimer?
true value autodetect?
false value checking?   \ in process of checking for change
false value virtualspace?       \ allow caret to be positioned beyond end of line
false value multiselections?     \ multiple text selections in editor
\ true value multipaste?  \ not getting this one to work yet, maybe I don't fully understand

0 constant FT_SOURCE
1 constant FT_HTML
2 constant FT_BINARY
3 constant FT_BITMAP

0 constant NO_SPLIT
1 constant HORIZ_SPLIT
2 constant VERT_SPLIT

Color: WHITE value back-color             \ default font background color
Color: BLACK value fore-color             \ default font color
Color: WHITE value caret-backcolor        \ current line color
Color: LTGRAY value select-backcolor      \ selection background color
Color: BLACK value select-forecolor       \ selection font color
Color: BLACK value browse-forecolor	  \ browse mode foreground color
Color: LTGRAY value browse-backcolor	  \ browse mode background color

defer Compile-File   ' beep is Compile-File
defer HandleW32FMsg  ' noop is HandleW32FMsg
defer NewBrowseChild ' noop is NewBrowseChild
defer NewEditWindow  ' noop is NewEditWindow
defer Update         ' noop is Update
defer OnSelect       ' drop is OnSelect   \ called when item is selected in the file listview

needs EdToolbar.f
needs EdStatusbar.f
needs EdMenu.f

AcceleratorTable AccelTable \ create the Accelerator-Key-Table

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       the 'Find text in Files' dialog
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs EdFindInFiles.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Splitter window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class WinSplitter <Super child-window

:M WindowStyle: ( -- style )   \ return the window style
        WindowStyle: super
        [ WS_DISABLED WS_CLIPSIBLINGS or ] literal or
        ;M

:M On_Paint: ( -- )            \ screen redraw method
        0 0 Width Height LTGRAY FillArea: dc
        ;M

:M WndClassStyle: ( -- style )
        \ CS_DBLCLKS only to prevent flicker in window on sizing.
        CS_DBLCLKS ;M

;Class

WinSplitter Splitter

\  **************** Tab Windows for the Editor *****************************

:Object OpenFilesTab <Super TabControl

:M Start:	( Parent -- )
	Start: super
        [ CS_DBLCLKS CS_GLOBALCLASS or ] literal GCL_STYLE hWnd  Call SetClassLong  drop
	;M

;Object

TCS_BUTTONS TCS_MULTILINE or TCS_FLATBUTTONS or AddStyle: OpenFilesTab
Font TabFont
Font DefaultEditorFont
S" Fixedsys" SetFaceName: DefaultEditorFont
9 SetHeight: DefaultEditorFont
DefaultEditorFont value EditorFont

: GetFileTabChild ( ndx -- child ) \ ndx must be valid
		TCIF_PARAM IsMask: OpenFilesTab
		GetTabInfo: OpenFilesTab
                LParam: OpenFilesTab  ;

: AddFileTab    ( -- )
                z" <Untitled>" IsPsztext: OpenFilesTab
                ActiveChild IsLParam: OpenFilesTab
                TCIF_TEXT TCIF_PARAM or IsMask: OpenFilesTab
                GetTabCount: OpenFilesTab dup InsertTab: OpenFilestab
                SetSelectedTab: OpenFilesTab
                Resize: MainWindow ;

: TabFile?	( -- n ) \ n=#open files | 0
		GetTabCount: OpenFilesTab dup 0> ?exit
		drop 0 ;

: UpdateFileTab { \ ThisChild --  }
                ActiveChild 0= ?exit
                Gethandle: OpenFilesTab Call IsWindow 0= ?exit
                TabFile? ?dup
                if      0
                        do      i GetFileTabChild dup to ThisChild
                                if	GetFileName: ThisChild count
					ThisChild ActiveCoder <>	\ we prefer the full name for this one
					if	"TO-PATHEND"
					then    dup 0=
					if      2drop s" <Untitled>"
					then    new$ dup>r place
                                        GetFileType: ThisChild FT_SOURCE =
                                        if      ?Modified: ThisChild
                                                if      s" *" r@ +place \ visual indicator
                                                then
                                        then    r> count asciiz IsPsztext: OpenFilesTab
					TCIF_TEXT IsMask: OpenFilesTab
					i SetTabInfo: OpenFilesTab
				then
                        loop
                then    ;

: OnTabChanged  ( l obj-- )
                2drop
                GetSelectedTab: OpenFilesTab GetFileTabChild
                OnSelect false ; ' OnTabChanged IsChangeFunc: OpenFilestab

: ShowFileTab   ( -- )
                TabFile? ?dup
                if      0
                        do      i GetFileTabChild ActiveChild =
                                if      i SetSelectedTab: OpenFilesTab leave
                                then
                        loop
                then    ;

: DeleteFileTab   { ThisChild -- }
                TabFile? ?dup
                if      0
                        do      i GetFileTabChild ThisChild =
                                if      i DeleteTab: OpenFilesTab leave
                                then
                        loop
                then    ;

0 value tab-index	\ tab which was right clicked

: CloseTabFile	( ndx -- )
                GetFileTabChild dup ActiveChild =
		if	drop IDM_CLOSE DoCommand
		else	GetHandle: [ ] CloseChild: MainWindow
		then	update ;

: CloseSelectedTabFile	( -- )
	tab-index CloseTabFile update ;

: CloseTabsRight	( -- )
		Begin	tab-index 1+ GetTabCount: OpenfilesTab <
		while	tab-index 1+ CloseTabFile
		Repeat	;

: CloseTabsLeft	( -- )
		Begin	-1 +to tab-index
			tab-index 0 >=
		While	tab-index CloseTabFile
		Repeat	;

: CloseAllOthers ( -- )
                GetTabCount: OpenFilesTab 1- tab-index >
                if      CloseTabsRight
                then    tab-index 0>
                if      CloseTabsLeft
                then    update ;

: CompileTabFile	( -- )
	tab-index GetFileTabChild >r
	GetFileType: [ r@ ] FT_SOURCE =
	if	SaveAllBeforeCompile?
		if	IDM_SAVE_ALL DoCommand
		then	Compile: [ r@ ]
	then	r>drop ;

: ReloadTabFile ( -- )
	tab-index GetFileTabChild >r
	GetFileType: [ r@ ] FT_SOURCE =
	if      ReloadFile: [ r@ ]
	then    r>drop ;

: SetActiveRemote	( -- )
		tab-index GetFileTabChild >r
		GetFileType: [ r@ ] FT_SOURCE =
		if	r@ to ActiveRemote
		then	r>drop update ;

PopupBar TabPopup

Popup ""
         MenuItem "Close"     CloseSelectedTabFile    ;
         :MenuItem mnurel "Reload" ReloadTabFile ;
         MenuSeparator
         :MenuItem mnucae "Close all other files" CloseAllOthers ;
         :MenuItem mnucar "Close all files to right"  CloseTabsRight  ;
         :MenuItem mnucal "Close all files to left"    CloseTabsLeft   ;
         MenuSeparator
         :MenuItem mnucmp "Compile" CompileTabFile ;
EndBar

: check-menu-funcs	( -- )
			GetTabCount: OpenFilesTab dup 1- tab-index > Enable: mnucar     \ close all right
			1 > Enable: mnucae      \ close all other files
			tab-index 0> Enable: mnucal     \ close all left
			tab-index GetFileTabChild >r GetFileType: [ r@ ] FT_SOURCE =
			dup Enable: mnucmp      \ compilable source file
			GetFileName: [ r@ ] c@ 0<> and Enable: mnurel   \ reloadable file
		        r>drop ;

: OnTabButton?	{ \ htinfo -- f  }	\ was the mouse right clicked on a tab button?, f = -1 if no, tab index if yes
                3 cells localalloc: htinfo
		GetHandle: OpenFilesTab get-mouse-xy swap htinfo 2!
		htinfo 0 TCM_HITTEST GetHandle: OpenFilesTab Call SendMessage  	\ -1 means it wasn't on a tab
		;

: Handle_TabRightClick	 ( -- )
		OnTabButton? dup to tab-index  -1 <>
		if	check-menu-funcs
			GetHandle:  Mainwindow dup get-mouse-xy rot Track: TabPopup
		then	;

: control-key?	( -- f )	\ console not available in IDE so ?control doesn't work
		VK_CONTROL Call GetKeyState 0x8000 and ;

: shift-key?	( -- f )	\ console not available in IDE
		VK_SHIFT Call GetKeyState 0x8000 and ;

\ ************************************************************************************

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ the tabulator control for the left part of the window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs EdTabControl.f
needs EdPreferences.f
needs EdReplace.f



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Define the left part of the splitter window. In this window a
\ Tab Control will be used to show the open files the Class Browser and
\ the Project.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object LeftPane        <Super Child-Window

:M ExWindowStyle:    ( -- style )
        ExWindowStyle: Super WS_EX_CLIENTEDGE or ;M

:M On_Size:     ( -- )
        AutoSize: cTabWindow ;M

:M On_Init:     ( -- )
        On_Init: super
        self Start: cTabWindow
        ;M

:M WndClassStyle: ( -- style )
        \ CS_DBLCLKS only to prevent flicker in window on sizing.
        CS_DBLCLKS ;M

;Object

: show-proj-tab      ( -- )
        projtab# -1 <>
        if      projtab# ShowTab: cTabWindow
        else    tabcount 1 >
                if      0 ShowTab: cTabWindow
                then
        then    ; IDM_SHOWPROJECT_TAB SetCommand

: show-form-tab	( -- )
		detached?
		if	DeleteFormTab: cTabWindow		\ delete tab first
			GetHandle: DetachedFormWindow 0=	\ if not opened
			if	Close: FormWindow		\ close this
				Start: DetachedFormWindow	\ and start this
				show-proj-tab		\ default
                                Resize: cTabWindow
			then
		else	Close: DetachedFormWindow
			AddFormTab: cTabWindow			\ create tab
			GetHandle: FormWindow 0=
			if	cTabWindow Start: FormWindow
				Resize: cTabWindow
			then	formtab# ShowTab: cTabWindow	\ and show it
		then	ActiveForm
		if	UpdateStatus: ActiveForm
		then	doUpdate
		; IDM_SHOW_FORMTAB SetCommand

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Background tasks for class browsers \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Needs Task.f

0 proc GetCurrentThread
2 proc SetThreadPriority
1 proc CloseHandle

0 value OpbjectPointer

: Below ( -- )
   OpbjectPointer op !
   THREAD_PRIORITY_BELOW_NORMAL GetCurrentThread SetThreadPriority drop ;

0 :NoName ( -- ) Below InitVocBrowser:   cTabWindow ; Task-Block Constant VocInitTask
0 :NoName ( -- ) Below InitClassBrowser: cTabWindow ; Task-Block Constant ClassInitTask
0 :NoName ( -- ) Below UpDateFiles:    TheDirectory ; Task-Block Constant UpdateTask


: InitClassBrowsers ( -- )
        op @ to OpbjectPointer
        VocInitTask   dup run-task 0= abort" Failed to start background Task"
        task>handle @ call CloseHandle drop
        ClassInitTask dup run-task 0= abort" Failed to start background Task"
        task>handle @ call CloseHandle drop ;

:NoName UpdateTask    dup run-task 0= abort" Failed to start background Task"
        task>handle @ call CloseHandle drop ; is UpdateAsTask

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define application window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super MDIFrameWindow

create RegPath$ ," win32forthIDE\"

\ --------------------------------------------------------------------------
\ Splitter window support
\ --------------------------------------------------------------------------
  0 value ToolBarHeight    \ set to height of toolbar if any
  0 value StatusBarHeight  \ set to height of status bar if any
225 value LeftWidth
  2 value thickness

int dragging?
int mousedown?

: ClientHeight            ( -- n )
        Height StatusBarHeight - ToolBarHeight - ;

:M ReSize:      { \ x y -- }
        ShowToolbar?   if Height: TheRebar  else 0 then to ToolBarHeight
        ShowStatusbar? if Height: ScintillaStatusbar else 0 then to StatusBarHeight

        0  ToolBarHeight  LeftWidth  ClientHeight Move: LeftPane

        LeftWidth thickness +  ToolBarHeight 2dup to y to x
        Width LeftWidth thickness + - ClientHeight with-tabs?
        if	Move: OpenFilesTab
		ClientSize: OpenFilesTab 2over d- 2>r x y d+ 2r> Move: MDIClient
		Paint: OpenFilesTab
	else	Move: MDIClient
	then
        LeftWidth  ToolBarHeight  thickness  ClientHeight  Move: Splitter

        ShowToolbar?   if  AutoSize: TheRebar  then
        ShowStatusbar? if  Redraw: ScintillaStatusbar  then
       ;M

: InSplitter?   ( -- f1 )   \ is cursor on splitter window
        hWnd get-mouse-xy
        0 height within
        swap  LeftWidth dup thickness + within  and ;

\ mouse click routines for Main Window to track the Splitter movement

: DoSizing      ( -- )
        mousedown? dragging? or 0= ?EXIT
        dragging? \ don't resize if showing tabs and we click in tab header area
	if	mousex ( 1+ ) width min  thickness 2/ -  to LeftWidth
	then	ReSize: self
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
        IF   0 thickness 2/ - to LeftWidth
        ELSE 132 Width 2/ min to LeftWidth
        THEN ReSize: self ;

:M WM_SETCURSOR ( h m w l -- )
        hWnd get-mouse-xy
        ToolBarHeight dup ClientHeight + within
        swap  0 width within and
        IF  InSplitter? IF  SIZEWE-CURSOR   ELSE  arrow-cursor  THEN  1
        ELSE  DefFrameProc
        THEN
        ;M

\ --------------------------------------------------------------------------
\ --------------------------------------------------------------------------

:M Classinit: ( -- )
        ClassInit: super
        MainMenu to CurrentMenu

        false to dragging?
        false to mousedown?

        ['] On_clicked     SetClickFunc: self
        ['] On_unclicked   SetUnClickFunc: self
        ['] DoSizing       SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        ;M

:M InitRegistry: ( -- )
                \ set the base registry string
                PROGREG-SET-BASE-PATH
                RegPath$ count progreg +place progreg +null ;M

:M WindowMenuNo: ( -- n )
                WINDOW-MENU ;M   \ the Window menu where the child window titles will be placed

:M WindowHasMenu: ( -- f )
                True ;M

:M WindowStyle: ( -- style )
                WindowStyle: SUPER
                WS_CLIPCHILDREN or
                ;M

:M ExWindowStyle: ( -- exstyle )
                WS_EX_ACCEPTFILES ;M

:M DropFiles:   { hndl message wParam lParam \ drop$ -- res }
                SetForegroundWindow: self
                MAXSTRING LocalAlloc: drop$
                0 0 -1 wParam Call DragQueryFile
                0 DO MAXCOUNTED drop$ 1+ i wParam Call DragQueryFile drop$ c!
                     drop$ IDM_OPEN_RECENT_FILE DoCommand
                LOOP
                wParam Call DragFinish ;M

:M WM_DROPFILES ( hndl message wParam lParam -- res )
                DropFiles: self ;M

:M WindowTitle: ( -- z" )
                z" Win32Forth IDE" ;M

:M MinSize:     ( -- width height )
                450 20  ;M   \ prevent menu wrapping onto another line

int WindowState

:M On_Size:     ( h m w -- )
                to WindowState   \ get WindowState, don't save size of maximised or minimised window
                Resize: self
                ;M

:M WM_ACTIVATEAPP ( hndl message wParam lParam -- res )
                drop true = ActiveChild 0<> and
                if   SetFocus: ActiveChild
                then 0 ;M

: "GetDefault   ( a1 n1 -- a2 n2 )
                s" Settings" RegGetString ;

: "SetDefault   ( a1 n1 a2 n2 -- )
                s" Settings" RegSetString ;

: "GetDefaultValue ( addr n -- n1 flag ) \ read a value from registry
                "GetDefault dup
                if   number? >r d>s r>
                else 2drop 0 false
                then ;

: "GetDefault2Value ( addr n -- d1 flag ) \ read a 2value from registry
                "GetDefault dup
                if   number?
                else 2drop 0.0 false
                then ;

: (SaveRecentFiles) { addr len menu -- }
                addr len s" File1" 9 1
                DO   2dup + 1- i 48 + swap c!
                     4dup i GetRecentFile: menu count
                     2rot 2rot 2swap RegSetString
                LOOP 4drop ;

: (RestoreRecentFiles) { addr len menu -- }
                8 SetNumber: menu
                addr len s" File1" 9 1
                DO   2dup + 1- 57 i - swap c!
                     4dup 2swap RegGetString
                     2dup FILE-STATUS nip 0= \ we only add the file's witch still exist
                     IF   pad place pad Insert: menu
                     ELSE 2drop
                     THEN
                LOOP 4drop ;

: SaveRecentFiles ( -- )
                s" Recent Files" RecentFiles (SaveRecentFiles) ;

: RestoreRecentFiles ( -- )
                s" Recent Files" RecentFiles (RestoreRecentFiles) ;

: SaveRecentProjectFiles ( -- )
                s" Recent Project Files" RecentProjectFiles (SaveRecentFiles) ;

: RestoreRecentProjectFiles ( -- )
                s" Recent Project Files" RecentProjectFiles (RestoreRecentFiles) ;

: SaveRecentFormFiles ( -- )
                s" Recent Form Files" RecentFormFiles (SaveRecentFiles) ;

: RestoreRecentFormFiles ( -- )
                s" Recent Form Files" RecentFormFiles (RestoreRecentFiles) ;

: save-defaults ( -- )
                base @ >r decimal \ MUST be in decimal when saving defaults
                InitRegistry: self

                CreateBackup?    s>d (d.) s" Backup"          "SetDefault
                EOL              s>d (d.) s" EOL"             "SetDefault
                ViewEOL?         s>d (d.) s" ViewEOL"         "SetDefault
                ViewWhiteSpace?  s>d (d.) s" WhiteSpace"      "SetDefault
                CaseSensitive?   s>d (d.) s" CaseSensitive"   "SetDefault
                sub-dirs?        s>d (d.) s" SubDirectories"  "SetDefault
                all-occur?       s>d (d.) s" AllOccurances"   "SetDefault
                Colorize?        s>d (d.) s" Colorize"        "SetDefault
                ViewLineNumbers? s>d (d.) s" ViewLineNumbers" "SetDefault
                TabSize          s>d (d.) s" TabSize"         "SetDefault
                UseTabs?         s>d (d.) s" UseTabs"         "SetDefault
                ShowToolbar?     s>d (d.) s" ShowToolbar"     "SetDefault
                ShowStatusbar?   s>d (d.) s" ShowStatusbar"   "SetDefault
                FinalNewLine?    s>d (d.) s" FinalNewLine"    "SetDefault
                LeftWidth        s>d (d.) s" LeftWidth"       "SetDefault
                CompileProject?  s>d (d.) s" CompileProject"  "SetDefault
                SaveAllBeforeCompile?    s>d (d.) s" SaveAllBeforeCompile" "SetDefault
                StripTrailingWhitespace? s>d (d.) s" StripTrailingSpaces"  "SetDefault
                Back-Color       s>d (d.) s" BackColor"       "SetDefault
                Fore-Color       s>d (d.) s" ForeColor"       "SetDefault
                Caret-BackColor  s>d (d.) s" CaretBackColor"  "SetDefault
                Select-ForeColor s>d (d.) s" SelectForeColor" "SetDefault
                Select-BackColor s>d (d.) s" SelectBackColor" "SetDefault
                Browse-ForeColor s>d (d.) s" BrowseForeColor" "SetDefault
                Browse-BackColor s>d (d.) s" BrowseBackColor" "SetDefault
		AutoIndent?      s>d (d.) s" AutoIndent"      "SetDefault
		With-Tabs?       s>d (d.) s" TabsInEditor"    "SetDefault
		BookMarksPos	     (d.) s" BookMarksPosition" "SetDefault
		BookMarksSize	     (d.) s" BookMarksSize"   "SetDefault
		AutoProperty?	 s>d (d.) s" AutoProperty"    "SetDefault
		SingleControl?   s>d (d.) s" SingleControl"   "SetDefault
		SaveOrigin: Monitor
                MonitorLeft      s>d (d.) s" MonitorLeft"     "SetDefault
                MonitorTop       s>d (d.) s" MonitorTop"      "SetDefault
		Detached?	 s>d (d.) s" Detached"	      "SetDefault
		AutoDetect?      s>d (d.) s" AutoDetect"      "SetDefault
		AutoSaveSession? s>d (d.) s" AutoSaveSession" "SetDefault
		VirtualSpace?    s>d (d.) s" VirtualSpace"    "SetDefault
		MultiSelections? s>d (d.) s" MultiSelections" "SetDefault
                show-projtab?    s>d (d.) s" ShowProjectTab"  "SetDefault
                show-filetab?    s>d (d.) s" ShowFileTab"     "SetDefault
                show-formtab?    s>d (d.) s" ShowFormTab"     "SetDefault
                show-classtab?   s>d (d.) s" ShowClassTab"    "SetDefault
                show-voctab?     s>d (d.) s" ShowVocTab"      "SetDefault
                show-dirtab?     s>d (d.) s" ShowDirTab"      "SetDefault
                show-debugtab?   s>d (d.) s" ShowDebugTab"    "SetDefault

		GetFaceName: EditorFont   s" TextFont"        "SetDefault
		GetHeight: EditorFont
				 s>d (d.) s" TextFontSize"    "SetDefault

                WindowState SIZE_RESTORED =
                if   StartPos: self s>d (d.) s" WindowTop"    "SetDefault
                                    s>d (d.) s" WindowLeft"   "SetDefault
                     Width: self    s>d (d.) s" WindowWidth"  "SetDefault
                     Height: self   s>d (d.) s" WindowHeight" "SetDefault
                then

                mask-ptr count s" SearchMask" "SetDefault
                find-buf count s" SearchText" "SetDefault
                search-path count s" SearchPath" "SetDefault
                path-ptr: TheProject count s" ProjectSearchPath" "SetDefault

                SaveRecentFiles
                SaveRecentProjectFiles
                SaveRecentFormFiles
                autosavesession?
                if      IDM_SAVEDEFAULT_SESSION DoCommand
                then

\                 SetRegistryKey: ControlToolBar
\                 true SaveRestore: ControlToolBar

                r> base !
                ; IDM_SAVEDEFAULTS SetCommand

: load-defaults ( -- )
                base @ >r decimal \ MUST be in decimal when loading defaults
                InitRegistry: self

                s" Backup"          "GetDefaultValue 0= IF drop true           THEN to CreateBackup?
                s" EOL"             "GetDefaultValue 0= IF drop SC_EOL_CRLF    THEN to EOL
                s" ViewEOL"         "GetDefaultValue 0= IF drop false          THEN to ViewEOL?
                s" WhiteSpace"      "GetDefaultValue 0= IF drop SCWS_INVISIBLE THEN to ViewWhiteSpace?
                s" CaseSensitive"   "GetDefaultValue 0= IF drop true           THEN to CaseSensitive?
                s" SubDirectories"  "GetDefaultValue 0= IF drop true           THEN to sub-dirs?
                s" AllOccurances"   "GetDefaultValue 0= IF drop true           THEN to all-occur?
                s" Colorize"        "GetDefaultValue 0= IF drop true           THEN to Colorize?
                s" ViewLineNumbers" "GetDefaultValue 0= IF drop true           THEN to ViewLineNumbers?
                s" TabSize"         "GetDefaultValue 0= IF drop 8              THEN to TabSize
                s" UseTabs"         "GetDefaultValue 0= IF drop true           THEN to UseTabs?
                s" FinalNewLine"    "GetDefaultValue 0= IF drop true           THEN to FinalNewLine?
                s" LeftWidth"       "GetDefaultValue 0= IF drop 225            THEN to LeftWidth
                s" CompileProject"  "GetDefaultValue 0= IF drop true           THEN to CompileProject?

                s" SaveAllBeforeCompile"    "GetDefaultValue 0= IF drop true   THEN to SaveAllBeforeCompile?
                s" StripTrailingWhitespace" "GetDefaultValue 0= IF drop true   THEN to StripTrailingWhitespace?

                s" BackColor"       "GetDefaultValue 0= IF  drop Back-Color THEN to Back-Color
                s" ForeColor"       "GetDefaultValue 0= IF  drop Fore-Color THEN to Fore-Color
                s" CaretBackColor"  "GetDefaultValue 0= IF  drop Caret-BackColor THEN to Caret-BackColor
                s" SelectBackColor" "GetDefaultValue 0= IF drop Select-BackColor THEN to Select-BackColor
                s" SelectForeColor" "GetDefaultValue 0= IF  drop Select-ForeColor THEN to Select-ForeColor
                s" BrowseForeColor" "GetDefaultValue 0= IF  drop Browse-ForeColor THEN to Browse-ForeColor
                s" BrowseBackColor" "GetDefaultValue 0= IF  drop Browse-BackColor THEN to Browse-BackColor

		s" AutoIndent"      "GetDefaultValue 0= IF drop false THEN to autoindent?
		s" TabsInEditor"    "GetDefaultValue 0= IF drop false THEN to with-tabs?
		s" BookMarksPosition" "GetDefault2Value IF 2to BookMarksPos ELSE 2drop then
		s" BookMarksSize"     "GetDefault2Value IF 2to BookMarksSize ELSE 2drop THEN
		s" AutoProperty"    "GetDefaultValue 0= IF drop false THEN to AutoProperty?
		s" SingleControl"   "GetDefaultValue 0= IF drop true THEN to SingleControl?
                s" MonitorLeft"     "GetDefaultValue if to MonitorLeft    else drop then
                s" MonitorTop"      "GetDefaultValue if to MonitorTop     else drop then
                s" Detached"        "GetDefaultValue if to detached?  else drop then
                s" AutoDetect"      "GetDefaultValue if to autodetect? else drop then
                s" AutoSaveSession" "GetDefaultValue if to autosavesession? else drop then
                s" VirtualSpace"    "GetDefaultValue if to virtualspace? else drop then
                s" MultiSelections" "GetDefaultValue if to multiselections? else drop then
                s" ShowProjectTab"  "GetDefaultValue if to show-projtab? else drop then
                s" ShowFileTab"     "GetDefaultValue if to show-filetab? else drop then
                s" ShowFormTab"     "GetDefaultValue if to show-formtab? else drop then
                s" ShowClassTab"    "GetDefaultValue if to show-classtab? else drop then
                s" ShowVocTab"      "GetDefaultValue if to show-voctab?  else drop then
                s" ShowDirTab"      "GetDefaultValue if to show-dirtab? else drop then
                s" ShowDebugTab"    "GetDefaultValue if to show-debugtab? else drop then
                s" TextFont"        "GetDefault -IF 2dup SetFaceName: EditorFont THEN 2drop
                s" TextFontSize"    "GetDefaultValue if SetHeight: EditorFont else drop then

                s" SearchText"     "GetDefault -IF 2dup "CLIP" find-buf place THEN 2drop
                s" SearchPath"     "GetDefault -IF 2dup "CLIP" search-path place THEN 2drop
                s" SearchMask"     "GetDefault -IF 2dup "CLIP" mask-ptr place THEN 2drop
                s" ProjectSearchPath" "GetDefault -IF 2dup "CLIP" path-ptr: TheProject place THEN 2drop

                s" ShowToolbar"    "GetDefaultValue 0= IF drop true           THEN dup to ShowToolbar? Show: TheRebar
                s" ShowStatusbar"  "GetDefaultValue 0= IF drop true           THEN dup to ShowStatusbar? Show: ScintillaStatusbar

                RestoreRecentFiles
                RestoreRecentProjectFiles
                RestoreRecentFormFiles
                autosavesession?
                if      IDM_LOADDEFAULT_SESSION DoCommand
                then

\                 SetRegistryKey: ControlToolBar
\                 false SaveRestore: ControlToolBar

                r> base ! ;

:M StartSize:   ( -- w h )
                base @ >r decimal \ MUST be in decimal when loading defaults
                InitRegistry: self
                s" WindowWidth"  "GetDefaultValue 0= IF drop 400 THEN
                s" WindowHeight" "GetDefaultValue 0= IF drop 400 THEN
                r> base ! ;M

:M StartPos:    ( -- x y )
                base @ >r decimal \ MUST be in decimal when loading defaults
                InitRegistry: self
                s" WindowLeft" "GetDefaultValue 0= IF drop 0 THEN
                s" WindowTop"  "GetDefaultValue 0= IF drop 0 THEN
                r> base ! ;M

:M DefaultIcon: ( -- hIcon )  \ return the default icon handle for window
                LoadAppIcon ;M

:M WndClassStyle: ( -- style )
                CS_DBLCLKS ;M

:M On_Init:     ( -- )
                self to MainWindow
                InitScintillaControl \ Dienstag, August 03 2004 dbu
                AccelTable EnableAccelerators \ init the accelerator table
                s" MS Sans Serif" SetFaceName: TabFont
                8 Width: TabFont
                Create: TabFont
                self Start: ScintillaStatusbar
                self Start: TheRebar
                self Start: LeftPane
                self Start: Splitter
                EnableToolbar
                On_Init: super
\         WS_CLIPCHILDREN -Style: mdiclient
\         WS_CLIPsiblings -Style: mdiclient
                self Start: OpenFilesTab        \ start after mdiclient
                load-defaults
		Refresh: cTabWindow
		show-form-tab	\ show the form designer whether detached or not
		Adjust-Monitor
                TabPopup SetPopupBar: self	\ start the popup
                Update
                show-proj-tab	\ always default
                NULL 1000 IDT_FILETIME GetHandle: self Call SetTimer drop
                ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                over LOWORD ( command ID ) dup
                IsCommand? IF DoCommand \ intercept Toolbar and shortkey commands
                ELSE case
                        GetID: HelpBox of       over HIWORD CBN_SELCHANGE  =
                                                if   GetSelectedString: HelpBox
                                                     GetSomeHelp
                                                then
                                       endof
                        GetID: FindBox of       over HIWORD CBN_SELCHANGE  =
                                                if   GetSelectedString: FindBox
                                                     Find-The-Text
                                                then
                                       endof
                        drop OnWmCommand: Super \ intercept Menu commands
                        0
                    endcase
                THEN ;M

:M WM_RBUTTONDOWN ( h m w l -- res )
		OnTabButton? -1 <>
		if	WM_RBUTTONDOWN WM: Super 	\ handle it normally
		else 	0 								\ forget it
		then	;M

:M WM_CLOSE     ( h m w l -- res )
                save-defaults        \ save properties in registry
                CloseAll: self
                NotCancelled              \ if we don't cancel the close
                IF   ExitScintillaControl \ terminate the Scintilla control
                     AccelTable DisableAccelerators \ free the accelerator table
                     DestroyWindow: Self   \ Destroy the window
                ELSE 1                    \ else abort program termination
                THEN ;M

:M On_Done:     ( -- )
		Delete: TabFont
		IDT_FILETIME GetHandle: self Call KillTimer drop
\+ sysgen       0 call PostQuitMessage drop
                On_Done: Super ;M

:M WM_INITMENU  ( h m w l -- res )  \ enable/disable the menu items
                EnableMenuBar ;M

:M MessageBox:  ( szText szTitle style -- result )
                3reverse hWnd Call MessageBox ;M

:M WM_NOTIFY    { h m w l -- res }
                l 2 cells+ @ RBN_HEIGHTCHANGE =   \ Rebar height has changed
                                                  \ must NOT resize rebar on RBN_AUTOSIZE
                if    Resize: self
                then  l GetNotifyWnd dup>r GetHandle: pToolBar = ToolTipHandle: pToolBar r@ = or
                if      w l Handle_Notify: pToolBar
                else    r@ GetHandle: ControlToolBar = ToolTipHandle: ControlToolBar r@ = or
                        if      w l Handle_Notify: ControlToolbar
                        else    r@ GetHandle: OpenFilesTab =
                                if      l GetNotifyCode NM_RCLICK =
					if	Handle_TabRightClick false
					else	w l Handle_Notify: OpenFilesTab
					then
                                else    false
                                then
                        then
                then    r>drop
                ;M

:M WM_COPYDATA  ( hndl msg wParam lParam -- result )   \ respond to Win32Forth messages
                HandleW32FMsg ;M

:M Activate:
        GetActive: self drop   \ maximised flag
        IF  false SetRedraw: self  THEN
        Activate: super
        true SetRedraw: self
        WS_CLIPCHILDREN -Style: ActiveChild
        Paint: ActiveChild
        WS_CLIPCHILDREN +Style: ActiveChild
        ;M

int FileNotFound
2 CallBack: FindFile { hChild lparam -- f }
                hChild Call GetParent MDIClient: self =
                IF   MAXCOUNTED temp$ hChild Call GetWindowText
                     temp$ swap lParam count caps-compare to FileNotFound
                     FileNotFound 0= IF hChild Activate: self ( beep ) THEN
                THEN FileNotFound ;  \ FALSE if found

:M FileNotFound: ( Filename$ -- f )   \ child window is activated if file is already open
                TRUE to FileNotFound
                &FindFile EnumChildWindows: self drop
                FileNotFound ;M

: CheckFileTime ( -- )
                autodetect? 0= ?exit
                intimer? ?exit
                ActiveChild 0= ?exit            \ no file opened
                IsEditWnd? 0= ?exit
		?BrowseMode: ActiveChild ?exit
                GetLastWriteTime: ActiveChild d0= ?exit          \ new file
                CompareFileTime: ActiveChild 0=                 \ file has changed
                if      true to intimer? true to checking?
                        MB_YESNO MB_ICONQUESTION or MB_APPLMODAL or
                        z" Warning"
                        z" The current file has been modified outside the IDE. Do you want to reload it?"
                        GetHandle: self
                        Call MessageBox IDYES =
                        if      ReloadFile: ActiveChild
                        else    SyncWriteTime: ActiveChild      \ set both times the same
                        then    false to intimer? false to checking?
                then    ;

: CheckIfDoneDebugging ( -- )
\ if debugging and console is closed disable debugging functions
                w32fForth IsRunning? 0= ActiveRemote 0<> and
                if      debugtab# -1 <>
                        if      Clear: frmDebugDlg
                                false GetHandle: frmDebugDlg Call EnableWindow drop
                        then
                then    ;

: HandleTimer   ( -- ) \ routine for timer functions, add any others here
                CheckFileTime
                CheckIfDoneDebugging
                ;

:M WM_TIMER     ( h m w l -- )
                over IDT_FILETIME =
                if      HandleTimer
                then    0 ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WM_USER 0x0201 + constant WM_SAVE
WM_USER 0x0202 + constant WM_UPDATE

0 value LastActiveChild \ the object address of the child window that was activated at last

:Class MDIChild <Super MDIChildWindow
        int ChildWindow \ the child window for this MDI-Child
        int ChildParent \ the parent class of this MDI-Child

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_CLIPCHILDREN or
                GetActive: Frame 0= or IF WS_MAXIMIZE or THEN  \ start new child maximised unless
                ;M                                             \ the active child is not maximised

:M DefaultIcon: ( -- hIcon )
                s" src\res\SciEditMDI.ico" Prepend<home>\ LoadIconFile ;M

:M GetFileName: ( -- addr )
                GetFileName: ChildParent ;M

:M UpdateFileName: ( -- )
                self UpdateFileName: cTabWindow \ update the File in the file list
                UpDateFileTab
                ;M

: RefreshColors   ( -- )
                  GetFileType: ChildParent FT_SOURCE <> ?exit
                  ?BrowseMode: ChildParent
                  if	browse-forecolor browse-backcolor
                  else	fore-color back-color
                  then	SetColors: ChildParent
                  caret-backcolor SetCaretBackColor: ChildParent
		  Select-ForeColor Select-BackColor SetSelectionColor: ChildParent
                  EditorFont SetFont: ChildWindow	\ tuck it here so splitter windows are also updated
                  ;

0 value Starting?
:M Start:       ( parent -- )
		true to Starting?
                Start: super
                self start: ChildWindow
                0 0 Width Height Move: ChildWindow
                self AddFile: cTabWindow \ add the file to the file list
\ 		SetFocus: ChildWindow
		SetFocus: self
		false to Starting?
		RefreshColors
                AddFileTab
		;M

:M ?Modified:   ( -- f )
                ?Modified: ChildParent ;M

:M GetFileType: ( -- n )
                GetFileType: ChildParent ;M

:M UpdateStatusBar: ( -- )
                ShowToolbar?
                if   Update: ScintillaStatusbar
                then ;M

:M On_SetFocus: ( -- )          \ A child window can be selected by clicking on it,
                                \ selecting it from the Window menu or using CTRL+F6
                SetFocus: ChildWindow
                ChildWindow to CurrentWindow
                self to ActiveChild
                Update: ChildParent
                UpdateStatusBar: self
                EnableToolbar
\                 self SelectFile: cTabWindow \ select the in the file list
                ShowFileTab
                SetWindowTitle: ChildParent
                ;M

:M On_Size:     ( h m w l -- h m w l )
                0 0 Width Height Move: ChildWindow ;M

\ :M On_ChildActivate:  ( -- )
\ cr ." On_ChildActivate: entry" self h.
\                 self LastActiveChild <>
\                 if   LastActiveChild 0<>
\                      if LastActiveChild DeSelectFile: cTabWindow then \ deselect the in the file list
\                      self dup to LastActiveChild SelectFile: cTabWindow \ select the in the file list
\                 then
\ cr ." On_ChildActivate: exit" self h.
\                 ;M

\ :M On_ChildActivate:  ( -- )
\ cr ." On_ChildActivate: entry " self h.
\ Starting? 0=
\ if
\                 self SelectFile: cTabWindow \ select the in the file list
\ then
\ cr ." On_ChildActivate: exit " self h.
\                 ;M

: ?SaveMessage  ( -- n )   \ IDYES, IDNO or IDCANCEL
                s" Do you want to save " pad place
                GetFileName: ChildParent count "to-pathend" pad +place
                s"  ?" pad +place  pad +NULL
                pad 1+ z" Win32Forth IDE"
                [ MB_ICONEXCLAMATION  MB_YESNOCANCEL or ] literal
                hWnd MessageBox ;

:M On_Close:    ( -- f )   \ True = close, False = cancel close
                ?Modified: self
                IF   ?SaveMessage
                     Case
                        IDCANCEL           Of                       FALSE Endof
                        IDYES              Of SaveFile: ChildParent TRUE  Endof
                        ( otherwise IDNO ) TRUE  swap
                     EndCase
                ELSE TRUE
                THEN
                dup dup to NotCancelled
                IF                        \ if we don't cancel the close
                     GetFileName: ChildParent Insert: RecentFiles \ save filename in recent files list
                     self RemoveFile: cTabWindow \ remove the file from the file list
                     self DeleteFileTab
                     self ActiveRemote = if Clear: frmDebugDlg then
                     GetHandle: self Destroy: Frame \ sugested by Rod Oakford
                     ChildWindow dispose  \ then close the child window
                     self dispose         \ and dispose of both the
                                          \ EditControl and the child window
                THEN	Resize: MainWindow
                ;M

1024 constant sizeof(linebuf)
create linebuf sizeof(linebuf) allot linebuf sizeof(linebuf) erase

: ?indent    { n \ curln prevlinelength linelength -- } \ adapted from Scintilla docs
 		n 0x0A = autoindent? and
 		if	GetCurrentPos: ChildWindow LineFromPosition: ChildWindow to curln
			curln LineLength: ChildWindow to linelength
			true \ curln 0> linelength 2 <= and
			if	curln 1- LineLength: ChildWindow to prevlinelength
				prevlinelength sizeof(linebuf) <
				if	curln 1- linebuf GetLine: ChildWindow to prevlinelength
					0 linebuf prevlinelength + c!
					linebuf prevlinelength bounds
					do	i c@ bl over <> swap 0x09 <> and
						if	0 i c! leave
						then
					loop	linebuf ReplaceSel: ChildWindow
				then
			then
		then	;

:M GetColumn:	( -- n )
		maxstring new$ GetCurLine: ChildWindow ;M

:M WM_NOTIFY    ( h m w l -- res )
                GetFileType: self FT_SOURCE =
                if   dup 2 cells + @ SCN_UPDATEUI =
                     if   UpdateStatusBar: self
                          EnableToolbar
                          UpdateFileTab
                     else 4 cells+ @ ?indent
		     then
                then false
                ;M

:M WM_CONTEXTMENU ( hwnd msg wparam lparam -- res )
                GetFileType: self FT_SOURCE =
                if   ?BrowseMode: ChildParent
                     if   VK_CONTROL Call GetKeyState 0x8000 and
                          if   <Hyper: ChildParent
                          else Hyper>: ChildParent
                          then
                     then
                then 0 ;M

:M WM_SAVE      ( -- ) \ save the current file if modified
                GetFileType: self FT_SOURCE =
                if   ?Modified: self
                     if   SaveFile: ChildParent
                     then
                then ;M

:M WM_UPDATE    ( -- ) \ save the current child from global variables
                GetFileType: self FT_SOURCE =
                if   Update: ChildParent
                     RefreshColors
                     UpdateSelectionMode? if
                     SelectionMode SetSelectionMode: ChildWindow  \ update
 \                    SelectionMode SC_SEL_STREAM = if
                       false to UpdateSelectionMode?
 \                      then
                     then
\                     SelectionMode
                     virtualspace?
                     if         [ SCVS_USERACCESSIBLE SCVS_RECTANGULARSELECTION or ] LITERAL
                     else       SCVS_NONE
                     then       0 swap SCI_SETVIRTUALSPACEOPTIONS GetHandle: ChildWindow send-window
                     multiselections?
                     if         1
                     else       0
                     then       0 swap SCI_SETMULTIPLESELECTION GetHandle: ChildWindow send-window
\                      multipaste?
\                      if         1
\                      else       0
\                      then       0 swap SCI_SETMULTIPASTE GetHandle: ChildWindow send-window
                then ;M

:M ChildWindow:	( -- n )
		ChildWindow ;M

:M GetSplitType:	( -- n )
			NO_SPLIT ;M

;Class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Editor, HexDump and ImageDisplay Child Window classes
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs SavePrompt.frm
needs ScintillaMDI.f
fload ScintillaHyperMDI.f
fload EdHexViewer.f
fload EdImageWindow.f
needs EdSplitterWindow.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define HTML Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class HtmlChild   <Super MDIChild

max-path 2 + bytes FileName

:M GetTextLength: ( -- n )
                0 ;M

:M Start:       ( parent -- )
                New> HtmlControl to ChildWindow
                self to ChildParent
                0 FileName !
                Start: super
                ;M

:M On_Close:    ( -- )
                On_Close: super
                self ActiveChild = if 0 to ActiveChild then
                UpdateStatusBar
                EnableToolbar
                ;M

:M SetFileName: ( addr len -- )
                FileName place FileName +null
                UpdateFileName: super
                ;M

:M GetFileName: ( -- addr )
                FileName ;M

:M SetWindowTitle: ( -- )
                GetFileName: self count SetText: super ;M

:M SetURL:      ( Url cnt -- )
                2dup SetFileName: self
                GoURL: ChildWindow
                SetWindowTitle: self ;M

:M ?Modified:   ( -- f )
                false ;M

:M GetFileType: ( -- n )
                FT_HTML ;M

:M Update:      ( -- )
                ;M

:M GoBack:      ( -- )
                GoBack: ChildWindow ;M

:M GoForward:   ( -- )
                GoForward: ChildWindow ;M

;Class

\ Window class for optional means of adding code to forms
\ Allows the full power of the IDE editor to be used when adding code to forms
:Class CodeChild   <Super HyperEditorChild

max-path 2 + bytes FileName
0 value CodeFlag
0 value CurrentForm
0 value CurrentControl


:M GetFileName: ( -- addr )
                FileName ;M

:M SetFileName: ( addr len -- )
                FileName place FileName +null
                UpdateFileName: super
                ;M

:M SetWindowTitle: ( -- )
                GetFileName: self count SetText: super
                ;M

: UpdateName	( -- )
		join$(
			s" Code:"
			FormName: CurrentForm count
			s" ."
			CodeFlag
			case
				FLAG_GLOBAL	of	s" Global"		endof
				FLAG_LOCAL	of	s" Local"		endof
				FLAG_ONINIT	of	s" OnInit"		endof
				FLAG_ONDONE	of	s" OnDone"		endof
				FLAG_CODE	of	GetName: CurrentControl	endof
				s" " rot
			endcase
		)join$  count SetFileName: self SetWindowTitle: self ;

:M Refresh:	( flag -- )
		{ \ pos -- }
		to CodeFlag
                ActiveForm to CurrentForm
                ActiveControl: ActiveForm to CurrentControl
                CodeFlag FLAG_CODE = CurrentControl 0= and ?exitm
                CodeFlag
		case
			FLAG_GLOBAL	of	GlobalCode: CurrentForm
						GetGlobalCursorPos: CurrentForm to pos
					endof
			FLAG_LOCAL	of	LocalCode: CurrentForm
						GetLocalCursorPos: CurrentForm to pos
					endof
			FLAG_ONINIT	of	OnInitCode: CurrentForm
						GetOnInitCursorPos: CurrentForm to pos
					endof
			FLAG_ONDONE	of	OnDoneCode: CurrentForm
						GetOnDoneCursorPos: CurrentForm to pos
					endof
			FLAG_CODE	of	ControlCode: CurrentControl
						GetCursorPos: CurrentControl to pos
					endof
			0 to pos false	swap
		endcase	( addr )  dup 0=
		if	drop pad dup off
		then	dup SetText: ChildWindow Highlight-Code
		pos GotoPos: ChildWindow	\ return to last editing position
		SetSavePoint: ChildWindow	\ mark as not modified yet
		UpdateName Update		\ and update
		self to ActiveChild
		ShowFileTab
		;M

:M SaveCode:	{ \ pos -- }
\ some error checking, just in case the unexpected or unusual happens
                GetModify: ChildWindow 0= ?exitm
                CurrentForm  0= ?exitm
                GetHandle: CurrentForm Call IsWindow 0= ?exitm
                CodeFlag FLAG_CODE = CurrentControl 0= and ?exitm
                GetCurrentPos: ChildWindow to pos \ we will save the last editing position so we can return to it
                CodeFlag
		case
			FLAG_GLOBAL	of	pos SetGlobalCursorPos: CurrentForm
						GlobalCode: CurrentForm
					endof
			FLAG_LOCAL	of	pos SetLocalCursorPos: CurrentForm
						LocalCode: CurrentForm
					endof
			FLAG_ONINIT	of	pos SetOnInitCursorPos: CurrentForm
						OnInitCode: CurrentForm
					endof
			FLAG_ONDONE	of	pos SetOnDoneCursorPos: CurrentForm
						OnDoneCode: CurrentForm
					endof
			FLAG_CODE	of	pos SetCursorPos: CurrentControl
						ControlCode: CurrentControl
					endof
				false swap
		endcase	( addr )  ?dup
		if	GetTextLength: ChildWindow 1+ GetText: ChildWindow
			SetSavePoint: ChildWindow
			Update
			IsModified: CurrentForm
			RefreshCodeWindow
		then	;M

\ Override the following
:M SaveFile:	( -- )
		SaveCode: self ;M

:M SaveFileAs:	( -- )
		SaveCode: self ;M

:M SaveBeforeCloseing: ( -- )
                SaveCode: self ;M

:M Start:       ( parent -- )
                0 FileName !
                Start: super
                self to ActiveCoder
                RefreshColors
                false to CodeFlag
                ;M

:M On_Close:    ( -- f )
                On_Close: super dup
                if	0 to ActiveCoder
			false to show-code?	\ reset by closing window
			UpdateStatusBar
			EnableToolbar
		then	;M

:M On_Command:  { ncode id -- res }
		id GetId: ChildWindow =
		if	ncode
			case	SCEN_KILLFOCUS 	of	SaveCode: Self		endof \ autosave
			endcase
		then	;M
\
:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID ) 2>r
	WM_COMMAND WM: Super
	2r> On_Command: Self
         ;M

;Class

: NewCodeWnd    ( -- ) \ open a new child window for adding code to forms
                ActiveCoder 0=
                if	New> CodeChild to ActiveChild
			MDIClientWindow: Frame Start: ActiveChild
                then GetHandle: ActiveCoder Activate: Frame ; ' NewCodeWnd is NewCodeWindow

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       some helper words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:noname         ( -- )
                UpdateStatusBar
                EnableToolbar
                ?EnableFormMenuItems
                0 0 WM_UPDATE SendMessageToAllChildren: Frame
                UpdateFileTab
                ?EnableDebugWindow
                ; is Update

: NewEditWnd    ( -- ) \ open a new child window for editing
                New> HyperEditorChild to ActiveChild
                MDIClientWindow: Frame Start: ActiveChild ;
' NewEditWnd is NewEditWindow

: NewHtmlWnd    ( -- ) \ open a new child window for displaying HTML-Files
                New> HtmlChild to ActiveChild
                MDIClientWindow: Frame Start: ActiveChild ;

:noname         ( -- ) \ open a new child window for browsing the source files
                       \ used by 'the class and vocabulary browser' and the
                       \ 'Find text in Files' dialog
                ActiveBrowser 0=
                if   NewEditWnd ActiveChild to ActiveBrowser
                then GetHandle: ActiveBrowser Activate: Frame ;  is NewBrowseChild

: NewRemoteChild ( -- ) \ open a new child window used to open a file
                        \ remotely by the Win32Forth console
\ Tuesday, November 11 2008 - always open a new child for active remote, prevents
\ a compile error from replacing an active file - EAB
                true \ ActiveRemote 0=
                if   NewEditWnd ActiveChild to ActiveRemote
                then GetHandle: ActiveRemote Activate: Frame ;

: (OpenHtmlFile) ( adr len -- )
                { \ temp$ -- }
                MAX-PATH 2 + LocalAlloc: temp$
                temp$ place
                temp$ FileNotFound: Frame
                if   NewHtmlWnd
                     temp$ count SetURL: ActiveChild
                then  Update ;

: (OpenSourceFile) ( adr len -- )
                { \ temp$ -- }
                MAX-PATH 2 + LocalAlloc: temp$
                temp$ place
                temp$ FileNotFound: Frame
                if   NewEditWnd
                     temp$ count OpenNamedFile: ActiveChild drop
                then  Update
                ; ' (OpenSourceFile) is OpenSource

: (OpenBinaryFile) ( adr len -- )
                { \ temp$ -- }
                MAX-PATH 2 + LocalAlloc: temp$
                temp$ place
                temp$ FileNotFound: Frame
                if   NewHexViewWnd
                     temp$ count SetFileName: ActiveChild
                     GetBuffer: ViewerFile Dump: ActiveChild
                then Update ;

: (OpenImageFile) ( adr len -- )
                { \ temp$ -- }
                MAX-PATH 2 + LocalAlloc: temp$
                temp$ place
                temp$ FileNotFound: Frame
                if   NewImageViewWnd
                     temp$ count SetFileName: ActiveChild
                then Update ;

: (OpenRemoteFile) ( adr len -- )
                { \ temp$ -- }
                MAX-PATH 2 + LocalAlloc: temp$
                temp$ place
                temp$ FileNotFound: Frame
                if   NewRemoteChild
                     temp$ count OpenNamedFile: ActiveChild drop
                else ActiveChild to ActiveRemote
                then Update ;

: OpenedByExtension? { addr cnt -- f } \ f=true if filed opened
                  addr cnt ".ext-only" pad place pad uppercase
                  case	s" .FF"		"of	addr cnt (OpenForm)	true endof
			s" .TDF"	"of	addr cnt LoadToolBarFile: frmCreateToolBar
									true endof
			s" .MDF"	"of	IDM_FORM_CREATEMENU DoCommand
						addr cnt Load: TheMenu
									true endof
			s" .SES"	"of	addr cnt temp$ place
						nostack1 temp$ ['] $fload catch drop
									true endof
			false swap
		  endcase dup if Update then ;

:noname         ( addr -- )
\ This is called from the File listview when a file is selected.
\ addr is the object address of the mdi child window
                GetHandle: [ ] Activate: Frame Update ; is OnSelect

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       the Win32Forth console interface support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
fload EdHtmlPreview.f
fload EdDebug.f
fload EdRemote.f
fload EdCompile.f
needs EdBookMarks.f
needs MsgBoxBuilder.frm

: MessageBoxBuilder ( -- )
        GetHandle: MainWindow SetParentWindow: frmMsgBoxBuilder
        Start: frmMsgBoxBuilder ; IDM_MSGBOX_BUILDER SetCommand

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define the Menu commands
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

fload EdCommand.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Handle MDI Accelerators: ALT+ - (minus), CTRL+ F4, CTRL+ F6
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DoMDIMsg      ( pMsg f  -- pMsg f )
                dup MDIClient: Frame 0<> and
                IF   drop dup MDIClient: Frame Call TranslateMDISysAccel 0=
                THEN ; msg-chain chain-add DoMDIMsg

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Accelerator Table - support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AccelTable table

        \ falgs               key-code  command-id

        \ File menu
        FCONTROL                'N'     IDM_NEW_SOURCE_FILE     ACCELENTRY
        FCONTROL                'O'     IDM_OPEN_SOURCE_FILE    ACCELENTRY
        FCONTROL                'S'     IDM_SAVE                ACCELENTRY
        FALT                    'S'     IDM_SAVE_ALL            ACCELENTRY
        FCONTROL                'P'     IDM_PRINT               ACCELENTRY
\       FCONTROL                'R'     IDM_RELOAD              ACCELENTRY
        FSHIFT FCONTROL or      'O'     IDM_OPEN_HIGHLIGHTED_FILE       ACCELENTRY

        \ Edit menu
        FCONTROL                'F'     IDM_FIND_TEXT           ACCELENTRY
        FCONTROL                VK_F3   IDM_FIND_TEXT           ACCELENTRY
        0                       VK_F3   IDM_FIND_NEXT           ACCELENTRY
        FSHIFT                  VK_F3   IDM_FIND_PREVIOUS       ACCELENTRY
        FCONTROL                'R'     IDM_REPLACE_TEXT        ACCELENTRY

        FALT                    'D'     IDM_INSERT_DATE         ACCELENTRY
        FALT                    'T'     IDM_INSERT_DATE&TIME    ACCELENTRY
        FALT                    'C'     IDM_COMMENT_BLOCK       ACCELENTRY
        FALT                    'U'     IDM_UNCOMMENT_BLOCK     ACCELENTRY
        FSHIFT FCONTROL or      'F'     IDM_FIND_IN_FILES       ACCELENTRY

        \ DexH menu
        FALT                    'G'     IDM_DEX_GLOSSARY         ACCELENTRY
        FALT                    'P'     IDM_DEX_PARAGRAPH        ACCELENTRY
        FALT FCONTROL or        'C'     IDM_DEX_CODE_PARAGRAPH   ACCELENTRY
        FALT                    'B'     IDM_DEX_STYLE_BOLD       ACCELENTRY
        FALT                    'I'     IDM_DEX_STYLE_ITALIC     ACCELENTRY
        FALT FCONTROL or        'T'     IDM_DEX_STYLE_TYPEWRITER ACCELENTRY

        \ Properties menu
        0                       VK_F7   IDM_BROWSE              ACCELENTRY

        \ Win32Forth menu
\        0			VK_F6   IDM_BUILD_CODE_TREE     ACCELENTRY
        0			VK_F8   IDM_COMPILE_LINE	ACCELENTRY
        0			VK_F9	IDM_COMPILE_SELECTION	ACCELENTRY
        0                       VK_F12  IDM_COMPILE             ACCELENTRY
        0                       VK_F11  IDM_DEBUG               ACCELENTRY
        0                       VK_F10  IDM_HTML_PREVIEW        ACCELENTRY
        FCONTROL                'B'     IDM_SET_BREAK_POINT     ACCELENTRY

        \ Help menu
        0                       VK_F1   IDM_W32F_DOC            ACCELENTRY
        FCONTROL                VK_F1   IDM_WORDHELP            ACCELENTRY
        FCONTROL                '+'     IDM_ZOOMIN              ACCELENTRY
        FCONTROL                '-'     IDM_ZOOMOUT             ACCELENTRY


Frame HandlesThem

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       command line handling
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: strip-cmdline ( addr cnt -- addr2 cnt2 )
                [CHAR] " skip [CHAR] ' skip BL skip
                [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS ;

: kparse        ( a n char -- a' n' a len )
                -rot 2dup 2>r rot dup>r scan r> skip 2r> 2 pick - ;

: ParseNum      ( a n -- a' n' d1 f1 )
                bl kparse -trailing number? ;

: Command>Edit  ( -- n addr )
                CmdLine strip-cmdline
                pad place 0 pad ;

: HandleCmdLine { \ bBrowse bEdit #line -- } \ simple command-line handling
                CMDLINE ?dup
                if   false to bBrowse
                     true to bEdit
                     0 to #line

                     over c@ UPC [char] / =
                     if   over char+ c@ UPC [char] B = to bBrowse
                          over char+ c@ UPC [char] E = to bEdit
                          swap 3 chars + swap 3 chars -
                     then

                     2dup ParseNum
                     if   d>s to #line 2nip
                     else 4drop
                     then

                     strip-cmdline

                     2dup OpenedByExtension?
                     if		2drop exit
                     then	2dup IsProjectFile?
                     if (open-project)
                     else
                         2dup IsHtmlFile?
                         if   (OpenHtmlFile)
                         else Command>edit bEdit if $edit else $browse then
                         then
                     then
                else drop
                then ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       The word to start the application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
: Main          ( -- )
\ Removed setting the thread priority of the main task. It blocks the system
\ too much and isn't really needed (Montag, Oktober 09 2006, dbu).
                w32fsharep 0=
                if w32fshareName 1024 open-share ?dup
                   if  to w32fshareh
                       to w32fsharep
                   then
                   Command>edit $edit
                   CloseSharedMemory
                   bye
                then
                start: Frame
                GetHandle: frame hwndOwner !  DefaultPrinter   \ initialise PSD and PD
\+ sysgen       GetHandle: Frame Enablew32fMsg   \ inter-process comm
                InitClassBrowsers
\+ sysgen       HandleCmdLine
\in-system-ok   forthform also testvocab also definitions
\+ sysgen	program-path-init
                ;

[defined] sysgen [if]
       : InitDir ( -- ) current-dir$ count SetDir: SourceFileOpenDialog ;
       Initialization-chain Chain-add InitDir

       &forthdir count &appdir place   \ create in the Win32Forth folder

       w32fIDE to NewAppID             \ set w32f communication & messaging
       false to RunUnique
       NoConsoleBoot                   \ no console needed, will start MessageLoop

       ' Main ' SAVE catch win32forthIDE.exe checkstack

\       \ Use this in case the no console doen't work for some reason
\       : mainsaved ( -- ) \ for "special case" of win32forthIDE
\         main
\         messageloop
\         ;
\       ConsoleHiddenBoot
\       ' Mainsaved ' SAVE catch win32forthIDE.exe checkstack

      \ Use this to have a full console for debugging purpose
\       : mainsaved ( -- ) \ for "special case" of win32forthIDE
\         main
\         messageloop
\         ;
\       ' Mainsaved ' SAVE catch win32forthIDE.exe checkstack

        &appdir off
        throw

        \ add the resources to the exe file

version# ((version)) 0. 2swap >number 3drop 7 < dup [if] winver winnt4 < and [then] 0=
[if]

                &forthdir count pad place
                s" win32forthIDE.exe" pad +place
                pad count "path-file drop AddToFile

                CREATEPROCESS_MANIFEST_RESOURCE_ID RT_MANIFEST s" res\win32forthIDE.exe.manifest" "path-file drop  AddResource
                101 s" res\win32forthIDE.ico" "path-file drop AddIcon

                false EndUpdate

        [else]  \ For V6.xx.xx older OSs
               s" src\res\SciEditMDI.ico" s" win32forthIDE.exe" Prepend<home>\ AddAppIcon
        [then]

        Require Checksum.f
        s" win32forthIDE.exe" prepend<home>\ (AddCheckSum)

       1 pause-seconds bye
[else]
       Main
[then]

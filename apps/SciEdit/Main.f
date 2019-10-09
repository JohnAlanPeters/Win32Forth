\ $Id: Main.f,v 1.27 2007/05/13 07:52:26 dbu_de Exp $

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

cr .( Loading SciEdit...)

ANEW -Main.f

only forth also editor definitions \ put all words into the EDITOR vocabulary

true value sysgen

s" apps\SciEdit"   "fpath+
s" apps\wined\res" "fpath+

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

0 value ActiveChild   \ the active MDI child window
0 value CurrentWindow \ the control in the active MDI child window
0 value ActiveBrowser \ the MDI child window used for source browsing
0 value ActiveRemote  \ the MDI child window used for remote opening a file from the console
0 value ACCEL-HNDL    \ handle of the AcceleratorKeyTable

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
true        value HandleW32FMsg?
true        value StripTrailingWhitespace?
true        value FinalNewLine?

0 constant FT_SOURCE
1 constant FT_HTML

needs EdToolbar.f
needs EdStatusbar.f
needs EdMenu.f

defer Compile-File  ' beep is Compile-File
defer CloseBrowser  ' beep is CloseBrowser
defer HandleW32FMsg ' noop is HandleW32FMsg

AcceleratorTable AccelTable \ create the Accelerator-Key-Table

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       the 'Find text in Files' dialog
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

needs EdFindInFiles.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define application window
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object Frame   <Super MDIFrameWindow

create RegPath$ ," SciEdit\"

:M Classinit:   ( -- )
                ClassInit: super
                MainMenu to CurrentMenu ;M

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
                WS_CLIPCHILDREN or ;M

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
                z" SciEdit" ;M

: AdjustWindowSize      { width height win -- }
                SWP_SHOWWINDOW SWP_NOZORDER or SWP_NOMOVE or
                height width
                0 0     \ ignore position
                0       \ ignore z-order
                win Call SetWindowPos drop ;

:M ReSize:      ( -- )
                0
                ShowToolbar?   if  Height: TheRebar  else  0  then
                width
                height
                ShowStatusbar? if  Height: ScintillaStatusbar -  then
                ShowToolbar?   if  Height: TheRebar -  then
                Move: MDIClient

                ShowToolbar?   if  Width Height: TheRebar GetHandle: TheRebar AdjustWindowSize  then
                ShowStatusbar? if  Redraw: ScintillaStatusbar  then
                ;M

:M MinSize: ( -- width height )   412  0  ;M   \ prevent menu wrapping onto another line

int WindowState
:M On_Size:     ( h m w -- )
                to WindowState   \ get WindowState, don't save size of maximised or minimised window
                ReSize: self
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

: SaveRecentFiles ( -- )
                s" Recent Files" s" File1" 9 1
                DO   2dup + 1- i 48 + swap c!
                     4dup i GetRecentFile: RecentFiles count
                     2rot 2rot 2swap RegSetString
                LOOP 4drop ;

: RestoreRecentFiles ( -- )
                8 SetNumber: RecentFiles
                s" Recent Files" s" File1" 9 1
                DO   2dup + 1- 57 i - swap c!
                     4dup 2swap RegGetString
                     2dup FILE-STATUS nip 0= \ we only add the file's witch still exist
                     IF   pad place pad Insert: RecentFiles
                     ELSE 2drop
                     THEN
                LOOP 4drop ;

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
                HandleW32FMsg?   s>d (d.) s" HandleW32FMsg"   "SetDefault
                FinalNewLine?    s>d (d.) s" FinalNewLine"    "SetDefault
                SaveAllBeforeCompile?    s>d (d.) s" SaveAllBeforeCompile" "SetDefault
                StripTrailingWhitespace? s>d (d.) s" StripTrailingSpaces"  "SetDefault

                WindowState SIZE_RESTORED =
                if   StartPos: self s>d (d.) s" WindowTop"    "SetDefault
                                    s>d (d.) s" WindowLeft"   "SetDefault
                     Width: self    s>d (d.) s" WindowWidth"  "SetDefault
                     Height: self   s>d (d.) s" WindowHeight" "SetDefault
                then

                mask-ptr    count s" SearchMask" "SetDefault
                find-buf    count s" SearchText" "SetDefault
                search-path count s" SearchPath" "SetDefault

                SaveRecentFiles

                SetRegistryKey: ControlToolBar
                true SaveRestore: ControlToolBar

                r> base !
                ;

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
                s" HandleW32FMsg"   "GetDefaultValue 0= IF drop true           THEN to HandleW32FMsg?
                s" FinalNewLine"    "GetDefaultValue 0= IF drop true           THEN to FinalNewLine?
                s" SaveAllBeforeCompile"    "GetDefaultValue 0= IF drop true   THEN to SaveAllBeforeCompile?
                s" StripTrailingWhitespace" "GetDefaultValue 0= IF drop true   THEN to StripTrailingWhitespace?

                s" SearchText"     "GetDefault -IF 2dup "CLIP" find-buf    place THEN 2drop
                s" SearchPath"     "GetDefault -IF 2dup "CLIP" search-path place THEN 2drop
                s" SearchMask"     "GetDefault -IF 2dup "CLIP" mask-ptr    place THEN 2drop

                s" ShowToolbar"    "GetDefaultValue 0= IF drop true           THEN dup to ShowToolbar? Show: TheRebar
                s" ShowStatusbar"  "GetDefaultValue 0= IF drop true           THEN dup to ShowStatusbar? Show: ScintillaStatusbar

                RestoreRecentFiles

                SetRegistryKey: ControlToolBar
                false SaveRestore: ControlToolBar

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

:M WndClassStyle: ( -- style )   CS_DBLCLKS ;M

:M On_Init:     ( -- )
                InitScintillaControl \ Dienstag, August 03 2004 dbu
                AccelTable EnableAccelerators \ init the accelerator table
                self Start: ScintillaStatusbar
                self Start: TheRebar
                EnableToolbar
                On_Init: super
                load-defaults
                ;M

:M OnWmCommand: ( hwnd msg wparam lparam -- hwnd msg wparam lparam )
                over LOWORD ( command ID ) dup
                IsCommand? IF DoCommand \ intercept Toolbar and shortkey commands
                ELSE drop OnWmCommand: Super \ intercept Menu commands
                THEN ;M

:M WM_CLOSE     ( h m w l -- res )
                CloseAll: self
                NotCancelled              \ if we don't cancel the close
                IF   CloseBrowser         \ close the browser window
                     save-defaults        \ save properties in registry
                     ExitScintillaControl \ terminate the Scintilla control
                     AccelTable DisableAccelerators \ free the accelerator table
                     bye                  \ then terminate the program
                ELSE 1                    \ else abort program termination
                THEN ;M

:M On_Done:     ( -- )
                Turnkeyed? IF 0 call PostQuitMessage drop THEN
                On_Done: Super ;M

:M WM_INITMENU  ( h m w l -- res )  \ enable/disable the menu items
                EnableMenuBar ;M

:M MessageBox:  ( szText szTitle style -- result )
                3reverse hWnd Call MessageBox ;M

:M WM_NOTIFY    ( h m w l -- res )
                Handle_Notify: ControlToolbar ;M

:M Win32Forth:  ( hndl msg wParam lParam -- )   \ respond to Win32Forth messages
                HandleW32FMsg ;M

int FileNotFound
2 CallBack: FindFile { hChild lparam -- f }
		hChild Call GetParent MDIClient: self =
		IF   MAXCOUNTED temp$ hChild Call GetWindowText
		     temp$ swap lParam count caps-compare to FileNotFound
		     FileNotFound 0= IF hChild Activate: self beep THEN
		THEN FileNotFound ;  \ FALSE if found

:M FileNotFound: ( Filename$ -- f )   \ child window is activated if file is already open
		TRUE to FileNotFound
		&FindFile EnumChildWindows: self drop
		FileNotFound ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

WM_USER	0x0201 + constant WM_SAVE
WM_USER	0x0202 + constant WM_UPDATE

:Class MDIChild <Super MDIChildWindow
	int ChildWindow \ the child window for this MDI-Child
	int ChildParent \ the parent class of this MDI-Child

:M WindowStyle: ( -- style )
		WindowStyle: super
		WS_CLIPCHILDREN or
		GetActive: Frame 0= or IF WS_MAXIMIZE or THEN  \ start new child maximised unless
		;M                                             \ the active child is not maximised

:M DefaultIcon: ( -- hIcon )
		s" res\SciEditMDI.ico" Prepend<home>\ LoadIconFile ;M

:M Start:	( parent -- )
		Start: super
		self start: ChildWindow
		0 0 Width Height Move: ChildWindow
		SetFocus: ChildWindow
		;M

:M ?Modified:	( -- f )
		?Modified: ChildParent ;M

:M GetFileType:	( -- n )
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
		EnableToolbar ;M

:M On_Size:	( h m w l -- h m w l )
		0 0 Width Height Move: ChildWindow ;M

: ?SaveMessage	( -- n )   \ IDYES, IDNO or IDCANCEL
		s" Do you want to save " pad place
		GetFileName: ChildParent count "to-pathend" pad +place
		s"  ?" pad +place  pad +NULL
		pad 1+ z" SciEdit"
		[ MB_ICONEXCLAMATION  MB_YESNOCANCEL or ] literal
		hWnd MessageBox ;

:M On_Close:	( -- f )   \ True = close, False = cancel close
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
		     GetHandle: self Destroy: Frame \ sugested by Rod Oakford
		     ChildWindow dispose  \ then close the child window
		     self dispose         \ and dispose of both the
					  \ EditControl and the child window
		THEN
		;M

:M WM_NOTIFY    ( h m w l -- res )
		GetFileType: self FT_SOURCE =
		if   2 cells + @ SCN_UPDATEUI =
                     if   UpdateStatusBar: self
  		          EnableToolbar
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

:M WM_SAVE	( -- ) \ save the current file if modified
		GetFileType: self FT_SOURCE =
		if   ?Modified: self
		     if   SaveFile: ChildParent
                     then
		then ;M

:M WM_UPDATE	( -- ) \ save the current child from global variables
		GetFileType: self FT_SOURCE =
		if   Update: ChildParent
		then ;M

;Class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define EDITOR Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

fload ScintillaMDI.f
fload ScintillaHyperMDI.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define HTML Child Window class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Class HtmlChild   <Super MDIChild

max-path 2 + bytes FileName

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
                ;M

:M GetFileName: ( -- addr )
                FileName ;M

:M SetWindowTitle: ( -- )
                GetFileName: self count SetText: super ;M

:M SetURL:      ( zUrl -- )
                dup zcount SetFileName: self
                SetURL: ChildWindow
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

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       some helper words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Update	( -- )
		UpdateStatusBar
		EnableToolbar
		0 0 WM_UPDATE SendMessageToAllChildren: Frame ;

: NewEditWnd	( -- ) \ open a new child window for editing
		New> HyperEditorChild to ActiveChild
		MDIClientWindow: Frame Start: ActiveChild ;

: NewHtmlWnd	( -- ) \ open a new child window for displaying HTML-Files
		New> HtmlChild to ActiveChild
		MDIClientWindow: Frame Start: ActiveChild ;

: NewBrowseChild ( -- ) \ open a new child window for browsing the source files
                        \ used by 'the class and vocabulary browser' and the
			\ 'Find text in Files' dialog
		ActiveBrowser 0=
		if   NewEditWnd ActiveChild to ActiveBrowser
		then GetHandle: ActiveBrowser Activate: Frame ;

: NewRemoteChild ( -- ) \ open a new child window used to open a file
                        \ remotly by the Win32Forth console
		ActiveRemote 0=
		if   NewEditWnd ActiveChild to ActiveRemote
		then GetHandle: ActiveRemote Activate: Frame ;

: (OpenHtmlFile) ( adr len -- )
		{ \ temp$ -- }
		MAX-PATH 2 + LocalAlloc: temp$
		temp$ place
		temp$ FileNotFound: Frame
		if   NewHtmlWnd
		     temp$ count asciiz SetURL: ActiveChild
		then Update ;

: (OpenSourceFile) ( adr len -- )
		{ \ temp$ -- }
		MAX-PATH 2 + LocalAlloc: temp$
		temp$ place
		temp$ FileNotFound: Frame
		if   NewEditWnd
		     temp$ count OpenNamedFile: ActiveChild
		then Update ;

: (OpenRemoteFile) ( adr len -- )
		{ \ temp$ -- }
		MAX-PATH 2 + LocalAlloc: temp$
		temp$ place
		temp$ FileNotFound: Frame
		if   NewRemoteChild
		     temp$ count OpenNamedFile: ActiveChild
		else ActiveChild to ActiveRemote
		then Update ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       the Win32Forth console interface support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

fload EdDebug.f
fload EdRemote.f
fload EdCompile.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       the Class and vocabulary browser
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

fload ClassBrowser.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Define the Menu commands
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

fload EdCommand.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Handle MDI Accelerators: ALT+ - (minus), CTRL+ F4, CTRL+ F6
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DoMDIMsg	( pMsg f  -- pMsg f )
		dup MDIClient: Frame 0<> and
		IF   drop dup MDIClient: Frame Call TranslateMDISysAccel 0=
		THEN ; msg-chain chain-add DoMDIMsg

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\	Accelerator Table - support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

AccelTable table

	\ falgs		      key-code  command-id

	\ File menu
	FCONTROL 		'N'	IDM_NEW_SOURCE_FILE	ACCELENTRY
	FCONTROL 		'O'	IDM_OPEN_SOURCE_FILE	ACCELENTRY
	FCONTROL 		'S'	IDM_SAVE      		ACCELENTRY
	FALT     		'S'	IDM_SAVE_ALL		ACCELENTRY
	FCONTROL 		'P'	IDM_PRINT      		ACCELENTRY
\	FCONTROL 		'R'	IDM_RELOAD		ACCELENTRY
	FSHIFT FCONTROL or 	'O'	IDM_OPEN_HIGHLIGHTED_FILE	ACCELENTRY

	\ Edit menu
	FCONTROL 		'F'	IDM_FIND_TEXT		ACCELENTRY
	FCONTROL 		VK_F3	IDM_FIND_TEXT		ACCELENTRY
	0        		VK_F3	IDM_FIND_NEXT		ACCELENTRY
\	FSHIFT   		VK_F3	IDM_FIND_PREVIOUS	ACCELENTRY

	FALT     		'D'	IDM_INSERT_DATE		ACCELENTRY
	FALT     		'T'	IDM_INSERT_DATE&TIME	ACCELENTRY
	FALT     		'C'	IDM_COMMENT_BLOCK	ACCELENTRY
	FALT     		'U'	IDM_UNCOMMENT_BLOCK	ACCELENTRY
	FSHIFT FCONTROL or 	'F'	IDM_FIND_IN_FILES	ACCELENTRY

	\ DexH menu
	FALT     		'G'	IDM_DEX_GLOSSARY	 ACCELENTRY
	FALT     		'P'	IDM_DEX_PARAGRAPH	 ACCELENTRY
	FALT FCONTROL or	'C'	IDM_DEX_CODE_PARAGRAPH	 ACCELENTRY
	FALT     		'B'	IDM_DEX_STYLE_BOLD	 ACCELENTRY
	FALT     		'I'	IDM_DEX_STYLE_ITALIC	 ACCELENTRY
	FALT FCONTROL or	'T'	IDM_DEX_STYLE_TYPEWRITER ACCELENTRY

	\ Properties menu
        0        		VK_F7	IDM_BROWSE		ACCELENTRY

	\ Win32Forth menu
        0        		VK_F12	IDM_COMPILE		ACCELENTRY
        0        		VK_F11	IDM_DEBUG		ACCELENTRY

	\ Help menu
        FCONTROL 		VK_F1	IDM_W32F_ANS_HELP	ACCELENTRY
	FSHIFT                  VK_F1   IDM_API_HELP            ACCELENTRY
        0        		VK_F1	IDM_W32F_DOC		ACCELENTRY
        FALT     		VK_F1	IDM_ANS_DOC		ACCELENTRY

Frame HandlesThem

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\	command line handling
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: strip-cmdline ( addr cnt -- addr2 cnt2 )
                [CHAR] " skip [CHAR] ' skip BL skip
                [CHAR] " -TRAILCHARS [CHAR] ' -TRAILCHARS BL -TRAILCHARS ;

: kparse        ( a n char -- a' n' a len )
                -rot 2dup 2>r rot dup>r scan r> skip 2r> 2 pick - ;

: ParseNum      ( a n -- a' n' d1 f1 )
                bl kparse -trailing number? ;

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

		     2dup IsHtmlFile?
		     if   (OpenHtmlFile)
		     else (OpenRemoteFile) ActiveChild
                          if   bBrowse SetBrowseMode: ActiveChild
                               #line 1- GotoLine: ActiveChild
                          then
		     then
                else drop
                then ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       The word to start the application
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Main          ( -- )
                start: Frame
                GetHandle: frame hwndOwner !  DefaultPrinter   \ initialise PSD and PD
                init-shared-type
                ['] sciedit_win32forth-message is win32forth-message
                HandleCmdLine
                Turnkeyed? IF  Begin key drop again  THEN
                ;

[defined] sysgen [IF]

: InitDir       ( -- )
                current-dir$ count SetDir: SourceFileOpenDialog ;

Initialization-chain Chain-add InitDir

: my-hello      ( -- )
                init-console
                if   initialization-chain do-chain
                then
                exception@ if bye then
                default-application ;

                ' my-hello is default-hello

                &forthdir count &appdir place
                \ create SciEditMdi.exe in the Win32Forth folder
                0 0 ' Main ' Application catch SciEditMdi.exe checkstack
                &appdir off
                throw

                s" src\res\SciEditMDI.ico" s" SciEditMdi.exe" Prepend<home>\ AddAppIcon


                1 pause-seconds bye
[else]
                s" src\res\SciEditMDI.ico" s" SciEditMdi.exe" Prepend<home>\ AddAppIcon
                Main
[then]

\ $Id: EdToolbar.f,v 1.18 2011/06/14 03:59:41 ezraboyce Exp $

\    File: EdToolbar.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juli 04 2004  - dbu
\ Updated: Mittwoch, Juli 28 2004 - dbu
\
\ Toolbar support for SciEdit

cr .( Loading Scintilla Toolbar...)

needs CommandID.f
needs bitmap.f        \ bitmap loading routines
needs toolbar.f       \ Windows toolbar class
needs RebarControl.f

anew -ScintillaToolbar.f

ComboBox helpbox
s" Type text and press ENTER to get help on word" BInfo: helpbox place
ComboBox findbox
s" Type text and press ENTER for case-insensitive search from current position" BInfo: findbox place
INTERNAL

EXTERNAL

false value ButtonText?
true value FlatToolBar?

\ -----------------------------------------------------------------------------------
\ Main-Toolbar
\ -----------------------------------------------------------------------------------

:Object ControlToolbar     <super Win32ToolBar

load-bitmap ControlBitmaps "res\toolbar.bmp"

\ -----------------------------------------------------------------------------------
\ Main-Toolbar
\ -----------------------------------------------------------------------------------

\ Define tool tips (texts that gives a short description of the buttons function)
\ These correspond to bitmap images in the loaded bitmap
:ToolStrings ControlToolTips
        ts," New file... (Ctrl+N)"
        ts," Open file... (Ctrl+O)"
        ts," Save file (Ctrl+S)"
        ts," Save all files (Alt+S)"
        ts," Cut (Ctrl+X)"
        ts," Copy (Ctrl+C)"
        ts," Paste (Ctrl+V)"
        ts," Undo (Ctrl+Z)"
        ts," Redo (Ctrl+Y)"
        ts," Search... (Ctrl+F)"
        ts," Search next (F3)"
        ts," Find Text in Files... (Ctrl+Shift+F)"
        ts," Compile"
        ts," Close file"
        ts," Close all"
        ts," Back"
        ts," Forward"
	ts," Browse"
        ts," Search previous (Shift+F3)"
        ts," Search and Replace (Ctrl+R)"
;ToolStrings

\ Define button strings ( text that can optionally be displayed on the button
:ToolStrings ControlToolStrings
        ts," New"
        ts," Open"
        ts," Save"
        ts," Save all"
        ts," Cut"
        ts," Copy"
        ts," Paste"
        ts," Undo"
        ts," Redo"
        ts," Search"
        ts," Search next"
        ts," Find Text in Files"
        ts," Compile"
        ts," Close"
        ts," Close all"
        ts," Back"
        ts," Forward"
	ts," Browse"
        ts," Search previous"
        ts," Replace"
;ToolStrings

\ Define all toolbar buttons in this application.

:ToolBarTable ControlTable
\  Bitmap index id                      Initial state    Initial style      tool string index
  1             IDM_NEW_SOURCE_FILE     TBSTATE_ENABLED  TBSTYLE_BUTTON     0 ToolBarButton,
  2             IDM_OPEN_SOURCE_FILE    TBSTATE_ENABLED  TBSTYLE_BUTTON     1 ToolBarButton,
  3             IDM_SAVE                TBSTATE_ENABLED  TBSTYLE_BUTTON     2 ToolBarButton,
  4             IDM_SAVE_ALL            TBSTATE_ENABLED  TBSTYLE_BUTTON     3 ToolBarButton,
  20            IDM_CLOSE               TBSTATE_ENABLED  TBSTYLE_BUTTON    13 ToolBarButton,
  21            IDM_CLOSE_ALL           TBSTATE_ENABLED  TBSTYLE_BUTTON    14 ToolBarButton,
                                                                            SeparatorButton,
  5             IDM_CUT                 TBSTATE_ENABLED  TBSTYLE_BUTTON     4 ToolBarButton,
  6             IDM_COPY                TBSTATE_ENABLED  TBSTYLE_BUTTON     5 ToolBarButton,
  7             IDM_PASTE               TBSTATE_ENABLED  TBSTYLE_BUTTON     6 ToolBarButton,
                                                                            SeparatorButton,
  18            IDM_UNDO                TBSTATE_ENABLED  TBSTYLE_BUTTON     7 ToolBarButton,
  19            IDM_REDO                TBSTATE_ENABLED  TBSTYLE_BUTTON     8 ToolBarButton,
                                                                            SeparatorButton,
  11            IDM_FIND_TEXT           TBSTATE_ENABLED  TBSTYLE_BUTTON     9 ToolBarButton,
  12            IDM_FIND_NEXT           TBSTATE_ENABLED  TBSTYLE_BUTTON    10 ToolBarButton,
  13            IDM_FIND_PREVIOUS       TBSTATE_ENABLED  TBSTYLE_BUTTON    18 ToolBarButton,
  25            IDM_REPLACE_TEXT        TBSTATE_ENABLED  TBSTYLE_BUTTON    19 ToolBarButton,
  10            IDM_FIND_IN_FILES       TBSTATE_ENABLED  TBSTYLE_BUTTON    11 ToolBarButton,
                                                                            SeparatorButton,
  8             IDM_COMPILE             TBSTATE_ENABLED  TBSTYLE_BUTTON    12 ToolBarButton,
                                                                            SeparatorButton,
  22            IDM_BACK                TBSTATE_ENABLED  TBSTYLE_BUTTON    15 ToolBarButton,
  23            IDM_FORWARD             TBSTATE_ENABLED  TBSTYLE_BUTTON    16 ToolBarButton,
  24            IDM_BROWSE              TBSTATE_ENABLED  TBSTYLE_BUTTON    17 ToolBarButton,

;ToolBarTable

int hbitmap
72 constant LargeButtonWidth     \ for buttons with text
48 constant LargeButtonHeight
24 constant SmallButtonWidth     \ a little bigger than Windows default
18 constant SmallButtonHeight
18 constant #buttons

:M ClassInit:   ( -- )
                ClassInit: super
                0 to hbitmap
                ;M

:M Start:       ( parent -- )
                ControlTable         IsButtonTable: self
                ControlToolTips         IsToolTips: self

                ButtonText?
                if      ControlToolStrings
                else    NULL
                then    IsButtonStrings: self

                Start: super

                \ set button size
                ButtonText?
                if      LargeButtonWidth LargeButtonHeight
                else    SmallButtonWidth SmallButtonHeight
                then    word-join 0 TB_SETBUTTONSIZE SendMessage:Self drop

                \ set bitmap size
                16 18 word-join 0 TB_SETBITMAPSIZE SendMessage:Self drop

                ControlBitmaps usebitmap   \ create bitmap handle
                map-transparent               \ use system colors for background
                GetDc: self dup>r CreateDIBitmap to hbitmap
                r> ReleaseDc: self
                hbitmap \ do we have a handle?
                if   0 hbitmap #buttons AddBitmaps: self drop
                then ;M

:M SetRegistryKey: ( -- ) \ Set-up registry key for toolbar customization data...
                s" SOFTWARE\" pad place
                PROGREG count pad +place
                s" Settings" pad +place
                pad +null pad count drop \ Registry sub-key
                z" Toolbar"
                SetRegistryKey: super
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ TBSTYLE_TOOLTIPS TBSTYLE_WRAPABLE or ( CCS_ADJUSTABLE or ) nostack1
                CCS_NOPARENTALIGN or CCS_NORESIZE or CCS_NODIVIDER or ] LITERAL or
                FlatToolBar?
                if      TBSTYLE_FLAT  or
                then
                ;M

:M On_Done:     ( -- )
                hbitmap
                if      hbitmap Call DeleteObject drop
                        0 to hbitmap
                then    On_Done: super
                ;M

:M On_ToolBarChange: ( -- f )                   \ User has changed toolbar
                Autosize: self false
                Update
                ;M

;Object

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ The Project Toolbar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object ptoolbar        <Super Win32Toolbar

load-bitmap ptoolbarBitmap "ToolbarBitmaps.bmp"

:ToolStrings ptoolbarTooltips
        ts," New Project"
        ts," Open Project"
        ts," Save Project"
        ts," Delete item"
        ts," Build Project"
        ts," Archive project"
        ts," Add files"
        ts," Copy project files"
;ToolStrings

:ToolBarTable ptoolbarTable
\ Bmp ndx     ID       Initial Style    Initial State     Tooltip Ndx
\ The default state and style for all buttons are enabled and button style
\ You can modify as desired
  0        IDM_NEW_PRJ     TBSTATE_ENABLED  TBSTYLE_BUTTON    0 ToolBarButton,
  1        IDM_OPEN_PRJ    TBSTATE_ENABLED  TBSTYLE_BUTTON    1 ToolBarButton,
  2        IDM_SAVE_PRJ    TBSTATE_ENABLED  TBSTYLE_BUTTON    2 ToolBarButton,
  3        IDM_DELETE_PRJ  TBSTATE_ENABLED  TBSTYLE_BUTTON    3 ToolBarButton,
  4        IDM_BUILD_PRJ   TBSTATE_ENABLED  TBSTYLE_BUTTON    4 ToolBarButton,
\  5        IDM_ZIP_PRJ     TBSTATE_ENABLED  TBSTYLE_BUTTON    5 ToolBarButton,
  6        IDM_ADD_PRJ     TBSTATE_ENABLED  TBSTYLE_BUTTON    6 ToolBarButton,
\  7        IDM_COPY_PRJ    TBSTATE_ENABLED  TBSTYLE_BUTTON    7 ToolBarButton,
;ToolBarTable

int hbitmap

:M ClassInit:  ( -- )
        ClassInit: super
        0 to hbitmap
        ;M

:M Start:   ( parent -- )
        ptoolbarTable         IsButtonTable: self
        ptoolbarTooltips        IsTooltips: self

        Start: super

        16 18 word-join 0 TB_SETBITMAPSIZE hwnd call SendMessage drop   \ smaller height of toolbar

        ptoolbarbitmap usebitmap
        map-3Dcolors            \ use system colors for background
        GetDc: self dup CreateDIBitmap to hbitmap   \ create bitmap handle from memory image
        ReleaseDc: self
        hbitmap      \ do we have a handle?
        if      0 hbitmap 8 AddBitmaps: self drop
        then
        ;M

:M WindowStyle:  ( -- style )
                WindowStyle: super
                [ TBSTYLE_TOOLTIPS TBSTYLE_WRAPABLE or nostack1
                CCS_NOPARENTALIGN or CCS_NORESIZE or CCS_NODIVIDER or ] LITERAL or
                FlatToolBar?
                if      TBSTYLE_FLAT  or
                then
                ;M

:M On_Done:   ( -- )
        hbitmap
        if      hbitmap Call DeleteObject drop
                0 to hbitmap
        then    On_Done: super
        ;M

;Object

\ -----------------------------------------------------------------------------------
\ Rebar
\ -----------------------------------------------------------------------------------

:Object TheRebar          <super RebarControl

Font TextFont

: insert-band   ( hWnd fstyle size -- )
                to cx
                to fstyle
                to hWndChild

       [ RBBIM_CHILD RBBIM_CHILDSIZE or RBBIM_STYLE or RBBIM_SIZE or RBBIM_TEXT or ] LITERAL
                to bfmask
                0 to cxMinChild
                22 to cyMinChild
                25 to cyChild       \ band height
                200 to cyMaxChild   \ max band height
                1 to cyIntegral
\                450 to cx           \ band width
                InsertBand: self ;


: add-toolbars  ( -- )
                999 SetID: ControlToolBar
                self Start: ControlToolBar

                eraseband-info GetHandle: ControlToolBar
                [ RBBS_GRIPPERALWAYS RBBS_CHILDEDGE or ] literal 550 insert-band
                ;

: add-projtoolbar  ( -- )
                self Start: pToolBar

                eraseband-info GetHandle: pToolBar
                [ RBBS_GRIPPERALWAYS RBBS_CHILDEDGE or ] literal 200 insert-band
                ;

: add-helpbox  ( -- )
             \   WS_CLIPSIBLINGS AddStyle: helpbox
                self Start: helpbox

                eraseband-info GetHandle: helpbox
		z" Help on:" to lptext
                [ RBBS_GRIPPERALWAYS RBBS_CHILDEDGE or ] literal 150 insert-band
                ;

: add-findbox   ( -- )
                self Start: findbox

                eraseband-info GetHandle: findbox
		z" Quick find:" to lptext
                [ RBBS_GRIPPERALWAYS RBBS_CHILDEDGE or ] literal 250 insert-band
                ;

:M Start:       ( parent -- )

                s" MS Sans Serif" SetFaceName: TextFont
                8 Width: TextFont
                Create: TextFont

                Start: super
                hwnd
                if  add-toolbars
                    add-findbox
                    add-projtoolbar
		    add-helpbox
                    Handle: TextFont dup SetFont: HelpBox
                                         SetFont: FindBox
                then ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
                [ ( WS_CLIPCHILDREN ) WS_BORDER  RBS_VARHEIGHT or RBS_BANDBORDERS or RBS_AUTOSIZE or ] literal or
                ;M

:M Close:       ( -- )
                Close: ControlToolBar
                Close: pToolBar
                Delete: TextFont
                Close: super ;M

:M Height:      ( -- h )
                GetWindowRect: self nip swap - nip ;M

:M Show:        ( f -- )
                if SW_SHOW else SW_HIDE then Show: super ;M

;object

: GetSomeHelp    { addr cnt \ cfa -- }
\in-system-ok   addr cnt "CLIP" "anyfind 	\ find it if it exist		\
		swap to cfa
                if   addr cnt InsertString: helpbox	\ save string
		     0 0 ExecHelp drop           \ launch help or put it in front
                     addr cnt msgpad place                \ try to show word from help
                     msgpad dup c@ 1+ WM_WORDHELP w32fHelp Sendw32fMsg
                     0=                          \ if not in help database, show source
                     if   cfa
\in-system-ok		  get-viewfile
			  drop count
                          rot msgpad !
                          dup 1+ >r msgpad cell+ place
                          msgpad r> cell+ WM_LINEFILE w32fHelp Sendw32fMsg drop
                     then
                else beep
                then ;

\ copied from WinED
: myWmChar      ( h m w l obj -- res )
        2 pick VK_RETURN  =             \ if return
        if      GetText: [  ]      \ get adr,len of edit control text
                GetSomeHelp
                false
        else	 drop true
	then	;

' myWmChar SetWmChar: helpbox

: find-the-text { addr cnt -- }
		cnt 0= ?exit
                addr cnt InsertString: findbox
                GetFileType: ActiveChild FT_SOURCE = cnt 0<> and
                if      addr cnt Find: ActiveChild Update
                then    ;


: findWMChar    ( h m w l obj -- res )
        2 pick VK_RETURN  =             \ if return
        if      GetText: [  ]      \ get adr,len of edit control text
                find-the-text
                false
        else	 drop true
	then	;
' findWMChar SetWmChar: findbox

\ -----------------------------------------------------------------------------------
\ -----------------------------------------------------------------------------------

: CompileActiveChild? ( -- f )
                ActiveChild
                if   GetTextLength: ActiveChild
                else false
                then ;

: Compile?      ( -- f )
                CompileProject?
                if   GetBuildFile: TheProject nip 0=
                     if CompileActiveChild? else true then
                else CompileActiveChild?
                then ;

: EnableToolbar ( -- )

                \ Editor toolbar
                ActiveChild
                if   GetFileType: ActiveChild FT_SOURCE =
                     if
                           ?Modified: ActiveChild 0<> ?BrowseMode: ActiveChild not and   IDM_SAVE EnableButton: ControlToolbar
                           ?Selection: ActiveChild       IDM_CUT           EnableButton: ControlToolbar
                           ?Selection: ActiveChild       IDM_COPY          EnableButton: ControlToolbar
                           CanPaste: ActiveChild         IDM_PASTE         EnableButton: ControlToolbar
                           CanUndo: ActiveChild          IDM_UNDO          EnableButton: ControlToolbar
                           CanRedo: ActiveChild          IDM_REDO          EnableButton: ControlToolbar
                           GetTextLength: ActiveChild    IDM_FIND_TEXT     EnableButton: ControlToolbar
                           ?Find:         ActiveChild    IDM_FIND_NEXT     EnableButton: ControlToolbar
                           ?Find:         ActiveChild    IDM_FIND_PREVIOUS EnableButton: ControlToolbar
\                           GetTextLength: ActiveChild    IDM_REPLACE_TEXT  EnableButton: ControlToolbar
                           GetTextLength: ActiveChild    IDM_BROWSE        EnableButton: ControlToolbar
                           GetTextLength: ActiveChild    Enable: findbox

                     else
                          false IDM_SAVE          EnableButton: ControlToolbar
                          false IDM_CUT           EnableButton: ControlToolbar
                          false IDM_COPY          EnableButton: ControlToolbar
                          false IDM_PASTE         EnableButton: ControlToolbar
                          false IDM_UNDO          EnableButton: ControlToolbar
                          false IDM_REDO          EnableButton: ControlToolbar
                          false IDM_FIND_TEXT     EnableButton: ControlToolbar
                          false IDM_FIND_NEXT     EnableButton: ControlToolbar
                          false IDM_FIND_PREVIOUS EnableButton: ControlToolbar
\                          false IDM_REPLACE_TEXT  EnableButton: ControlToolbar
                          false IDM_REDO          EnableButton: ControlToolbar
			  false IDM_BROWSE        EnableButton: ControlToolbar
                          false                         Enable: findbox
                     then

                     true IDM_SAVE_ALL       EnableButton: ControlToolbar
                     true IDM_CLOSE          EnableButton: ControlToolbar
                     true IDM_CLOSE_ALL      EnableButton: ControlToolbar

                     true IDM_BACK           EnableButton: ControlToolbar
                     true IDM_FORWARD        EnableButton: ControlToolbar
                else
                     false IDM_SAVE          EnableButton: ControlToolbar
                     false IDM_SAVE_ALL      EnableButton: ControlToolbar
                     false IDM_CLOSE         EnableButton: ControlToolbar
                     false IDM_CLOSE_ALL     EnableButton: ControlToolbar

                     false IDM_CUT           EnableButton: ControlToolbar
                     false IDM_COPY          EnableButton: ControlToolbar
                     false IDM_PASTE         EnableButton: ControlToolbar
                     false IDM_UNDO          EnableButton: ControlToolbar

                     false IDM_FIND_TEXT     EnableButton: ControlToolbar
                     false IDM_FIND_NEXT     EnableButton: ControlToolbar
                     false IDM_FIND_PREVIOUS EnableButton: ControlToolbar
\                     false IDM_REPLACE_TEXT  EnableButton: ControlToolbar
                     false IDM_REDO          EnableButton: ControlToolbar

                     false IDM_BACK          EnableButton: ControlToolbar
                     false IDM_FORWARD       EnableButton: ControlToolbar
		     false IDM_BROWSE        EnableButton: ControlToolbar
                     false                         Enable: findbox
                then

                Compile? IDM_COMPILE EnableButton: ControlToolbar

                \ Project toolbar
                true IDM_NEW_PRJ EnableButton: ptoolbar
                true IDM_OPEN_PRJ EnableButton: ptoolbar
                GetBuildFile: TheProject nip 0<>
                dup IDM_SAVE_PRJ   EnableButton: ptoolbar
\                dup IDM_DELETE_PRJ EnableButton: ptoolbar
\                dup IDM_BUILD_PRJ  EnableButton: ptoolbar
\                dup IDM_ADD_PRJ    EnableButton: ptoolbar
\                dup IDM_ZIP_PRJ    EnableButton: ptoolbar
\                    IDM_COPY_PRJ   EnableButton: ptoolbar
                drop
\                false IDM_ZIP_PRJ  EnableButton: ptoolbar
\                false IDM_COPY_PRJ EnableButton: ptoolbar
                ;

MODULE




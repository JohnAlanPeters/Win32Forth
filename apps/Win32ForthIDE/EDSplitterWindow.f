\ EdSplitterWindow.f
\ Allow dual viewing and editing of a file.

:Class WindowPane   <Super Child-Window

int TheEditor
int myparent

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M Classinit: ( -- )
        ClassInit: super   \ init super class
        0 to TheEditor
        0 to myparent
        ;M

:M On_Init:	( -- )
		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop
 		hwnd GetHandle: TheEditor Call	SetParent drop
		;M

:M On_Size:	( -- )
		0 0 Width Height Move: TheEditor
		;M

:M HandleofEditor:	( -- )
			GetHandle: TheEditor
			;M

:M SetEditor:	( addr -- ) \ addr = editor object
		to TheEditor ;M

:M WM_NOTIFY	{ h m w l \ GrandParent -- }	\ let gran take care of it
		GetParent: Self GetParent: [ ] to GrandParent
		l w WM_NOTIFY GetHandle: GrandParent Call SendMessage drop ;M

:M WM_COMMAND	( h m w l -- res )
		GetHandle: TheEditor =
		if	HIWORD SCEN_SETFOCUS =
			if	GetParent: Self to myparent
				TheEditor GetParent: myparent SetPrimaryEditor: [ ]
			then
		then	0 ;M

;Class

:Class VertSplitterWindow   <Super Child-Window

int dragging
int mousedown
int LeftWidth
5 value ThicknessV

WinSplitter SplitV
WindowPane PrimaryPane \ main editing window
WindowPane SecondaryPane \ clone editing window

: RightXpos       ( -- n )   LeftWidth ThicknessV + ;
: RightWidth      ( -- n )   Width RightXpos - ;
: LeftWidthMin    ( -- n )   LeftWidth width min ;
: StatusBarYpos   ( -- n )   height  ;
: TotalHeight     ( -- n )   Height ;

: position-windows ( -- )
        0          0   LeftWidthMin  TotalHeight  Move: PrimaryPane
        RightXpos  0   RightWidth    TotalHeight  Move: SecondaryPane
        LeftWidth  0   ThicknessV    TotalHeight  Move: SplitV
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        0 StatusBarYpos within  swap  LeftWidth RightXpos within  and
        IF  1  ELSE  0  THEN ;

: On_Tracking ( -- )   \ set min and max values of LeftWidth here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousex  0max  width min  thicknessV 2/ -  to LeftWidth  THEN
        position-windows
        WINPAUSE ;

: On_Clicked ( -- )
        mousedown not IF  hWnd Call SetCapture drop  THEN
        true to mousedown
        Splitter to dragging
        On_Tracking ;

: On_Unclicked ( -- )
        mousedown IF  Call ReleaseCapture drop  THEN
        false to mousedown
        false to dragging ;

: On_DblClick ( -- )
        false to mousedown
        Splitter 1 =
        IF
            LeftWidth 8 >
            IF    0 thicknessV 2/ - to LeftWidth
            ELSE  Width thicknessV - 2/  to LeftWidth
            THEN
        position-windows
        THEN ;

:M WM_SETCURSOR ( h m w l -- )
        Splitter
        Case
            0  of  DefWindowProc: self  endof
            1  of  SIZEWE-CURSOR    1   endof
        EndCase
        ;M

:M Classinit: ( -- )
        ClassInit: super   \ init super class
        ['] On_Clicked     SetClickFunc: self
        ['] On_Unclicked   SetUnClickFunc: self
        ['] On_Tracking    SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        false to mousedown
        250 to LeftWidth
        ;M

:M On_Size: ( -- )
        position-windows ;M

:M On_Init: ( -- )
        \ prevent flicker in window on sizing
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

        self Start: PrimaryPane
        self Start: SecondaryPane
        self Start: SplitV

	\ sync the two editors
	0 0 SCI_GETDOCPOINTER HandleOfEditor: PrimaryPane Call SendMessage
	0 SCI_SETDOCPOINTER HandleOfEditor: SecondaryPane Call SendMessage drop

        ;M

:M SetEditors:	( addr1 addr2 -- addr )
		SetEditor: SecondaryPane SetEditor: PrimaryPane ;M

;Class

:Class VSplitterChild   <Super HyperEditorChild

VertSplitterWindow  SplitW
ScintillaControl MirrorEditor
int TheChild

:M Start:       ( parent -- )
                Start: super
                self Start: MirrorEditor
                ChildWindow to TheChild			\ save original
                ChildWindow MirrorEditor SetEditors: SplitW
                self Start: Splitw
                0 0 Width Height Move: SplitW
                ChildWindow >r MirrorEditor to ChildWindow
                InitLexer: self
                STYLE_DEFAULT z" Fixedsys" StyleSetFont: ChildWindow
                WordChars 1+ SetWordChars: ChildWindow
                RefreshColors
                ShowLineNumbers: ChildWindow
		r> to ChildWindow
               ;M


:M On_Size:     ( h m w l -- h m w l )
                0 0 Width Height Move: SplitW ;M

:M WM_UPDATE    ( -- ) \ save the current child from global variables
		ChildWindow >r
		TheChild ?dup
		if	to ChildWindow
			Update: self
			RefreshColors		\ main window
			MirrorEditor to ChildWindow
			RefreshColors		\ clone window
			Update: self
		then    r> to ChildWindow 	\ restore
                ;M

:M GetSplitType:	( -- n )
		VERT_SPLIT ;M

:M WM_NOTIFY    ( h m w l -- res )
                dup 2 cells + @ SCN_UPDATEUI =
                if	UpdateStatusBar: self
			EnableToolbar
			UpdateFileTab
                else 	ChildWindow >r
			TheChild ?dup
			if	to ChildWindow
				4 cells+ @ dup ?indent
				MirrorEditor to ChildWindow
				?indent
			then	r> to ChildWindow
		then    false
                ;M

:M SetPrimaryEditor:	( editor -- )
		to ChildWindow
		ChildWindow to CurrentWindow ;M

:M On_Close:	( -- )
		TheChild to ChildWindow		\ restore original for disposing
		On_Close: Super
		;M

:M ClassInit:	( -- )
		ClassInit: Super
		0 to TheChild
		;M

;Class

: NewVSplitWnd  ( -- )
                New> VSplitterChild to ActiveChild
                MDIClientWindow: Frame Start: ActiveChild ;

:Class HorizSplitterWindow   <Super Child-Window

WinSplitter SplitterH
WindowPane PrimaryPane	\ main editor window
WindowPane SecondaryPane \ clone editor window

\ 0 value ToolBarHeight    \ set to height of toolbar if any
\ 0 value StatusBarHeight  \ set to height of status bar if any
int TopHeight
5 value ThicknessH

int dragging
int mousedown

: SplitterYpos    ( -- n )   TopHeight ;
: BottomYpos      ( -- n )   SplitterYpos ThicknessH + ;
: StatusBarYpos   ( -- n )   height ;
: BottomHeight    ( -- n )   StatusBarYpos BottomYpos - ;
: TotalHeight     ( -- n )   StatusBarYpos  ;
: TopHeightMin    ( -- n )   TopHeight TotalHeight min ;

: position-windows ( -- )
        0  0  		  Width  TopHeightMin  Move: PrimaryPane
        0  BottomYpos     Width  BottomHeight  Move: SecondaryPane
        0  SplitterYpos   Width  ThicknessH    Move: SplitterH
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        dup 0 StatusBarYpos within
        IF  SplitterYpos BottomYpos within  swap  0 width within  and  IF  1  ELSE  0  THEN
        ELSE  2drop 0  THEN ;

: On_Tracking ( -- )   \ set min and max values of TopHeight here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousey  TotalHeight min   thicknessH 2/ -  to TopHeight  THEN
        position-windows
        WINPAUSE ;

: On_Clicked ( -- )
        mousedown not IF  hWnd Call SetCapture drop  THEN
        true to mousedown
        Splitter to dragging
        On_Tracking ;

: On_Unclicked ( -- )
        mousedown IF  Call ReleaseCapture drop  THEN
        false to mousedown
        false to dragging ;

: On_DblClick ( -- )
        false to mousedown
        Splitter 1 =
        IF
            TopHeight 8 >
            IF    0 thicknessH 2/ - to TopHeight
            ELSE  TopHeight BottomHeight + thicknessH - 2/ to TopHeight
            THEN
        position-windows
        THEN ;

:M WM_SETCURSOR ( h m w l -- )
        Splitter
        Case
            0  of  DefWindowProc: self  endof
            1  of  SIZENS-CURSOR    1   endof
        EndCase
        ;M

:M Classinit: ( -- )
        ClassInit: super   \ init super class
        ['] On_Clicked     SetClickFunc: self
        ['] On_Unclicked   SetUnClickFunc: self
        ['] On_Tracking    SetTrackFunc: self
        ['] On_DblClick    SetDblClickFunc: self
        false to mousedown
        200 to TopHeight
        ;M

:M On_Size: ( -- )
        position-windows ;M


:M On_Init: ( -- )
        \ prevent flicker in window on sizing
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

        self Start: PrimaryPane
        self Start: SecondaryPane
        self Start: SplitterH

	\ sync the two editors
	0 0 SCI_GETDOCPOINTER HandleOfEditor: PrimaryPane Call SendMessage
	0 SCI_SETDOCPOINTER HandleOfEditor: SecondaryPane Call SendMessage drop
        ;M


:M SetEditors:	( addr1 addr2 -- addr )
		SetEditor: SecondaryPane SetEditor: PrimaryPane ;M

;Class

:Class HSplitterChild   <Super HyperEditorChild

HorizSplitterWindow  SplitW
ScintillaControl MirrorEditor
int TheChild

:M Start:       ( parent -- )
                Start: super
                self Start: MirrorEditor
                ChildWindow to TheChild			\ save original
                ChildWindow MirrorEditor SetEditors: SplitW
                self Start: Splitw
                0 0 Width Height Move: SplitW
                ChildWindow >r MirrorEditor to ChildWindow
                InitLexer: self
                STYLE_DEFAULT z" Fixedsys" StyleSetFont: ChildWindow
                WordChars 1+ SetWordChars: ChildWindow
                RefreshColors
                ShowLineNumbers: ChildWindow
		r> to ChildWindow
               ;M


:M On_Size:     ( h m w l -- h m w l )
                0 0 Width Height Move: SplitW ;M

:M WM_UPDATE    ( -- ) \ save the current child from global variables
		ChildWindow >r
		TheChild ?dup
		if	to ChildWindow
			Update: self
			RefreshColors		\ main window
			MirrorEditor to ChildWindow
			RefreshColors		\ clone window
			Update: self
		then    r> to ChildWindow 	\ restore
                ;M

:M GetSplitType:	( -- n )
		HORIZ_SPLIT ;M

:M WM_NOTIFY    ( h m w l -- res )
                dup 2 cells + @ SCN_UPDATEUI =
                if	UpdateStatusBar: self
			EnableToolbar
			UpdateFileTab
                else 	ChildWindow >r
			TheChild ?dup
			if	to ChildWindow
				4 cells+ @ dup ?indent
				MirrorEditor to ChildWindow
				?indent
			then	r> to ChildWindow
		then    false
                ;M

:M SetPrimaryEditor:	( editor -- )
		to ChildWindow
		ChildWindow to CurrentWindow ;M

:M On_Close:	( -- )
		TheChild to ChildWindow		\ restore original for disposing
		On_Close: Super
		;M

:M ClassInit:	( -- )
		ClassInit: Super
		0 to TheChild
		;M

;Class

: NewHSplitWnd  ( -- )
                New> HSplitterChild to ActiveChild
                MDIClientWindow: Frame Start: ActiveChild ;

: TabPosition   { ThisChild -- n } \ position of file in tab window
                TCIF_PARAM IsMask: OpenFilesTab
                GetTabCount: OpenFilesTab dup 0>
                if      1+ 0
                        do      i GetTabInfo: OpenFilesTab
                                Lparam: OpenFilesTab ThisChild =
                                if      i leave
                                then
                        loop
                else    -1
                then    ;

: SwapTabs	{ child1 child2 \ l1 l2 -- }
		GetTabCount: OpenFilesTab 0> not ?exit
		child1 child2 1- 0max = ?exit
		TCIF_PARAM IsMask: OpenFilesTab
		child1 GetTabInfo: OpenFilesTab
		LParam: OpenFilesTab to l1
		TCIF_PARAM IsMask: OpenFilesTab
		child2 GetTabInfo: OpenFilesTab
		LParam: OpenFilesTab to l2
		TCIF_PARAM IsMask: OpenFilesTab
		child1 SetTabInfo: OpenFilesTab
		l1 IsLparam: OpenFilesTab
		TCIF_PARAM IsMask: OpenFilesTab
		child2 SetTabInfo: OpenFilesTab ;

: SplitWindow	{ win-func split-type \ modified? curpos textbuf textlen name$ browsing? -- }
		ActiveChild 0= ?exit
		ActiveChild ActiveCoder = ?exit		\ no splitting for code window
		GetFileType: ActiveChild FT_SOURCE <> ?exit
		GetSplitType: ActiveChild split-type = ?exit
		new$ to name$ name$ off
		GetTextLength: CurrentWindow 1+ to textlen	\ get text buffer size
		textlen malloc to textbuf			\ allocate buffer
		textbuf textlen GetText: CurrentWindow		\ retrieve text
		?Modified: ActiveChild to modified?		\ get modified status
		GetCurrentPos: CurrentWindow to curpos		\ position in document
		GetFileName: ActiveChild count name$ place	\ file name
		?BrowseMode: ActiveChild to browsing?
		SetSavepoint: CurrentWindow			\ mark as not modified
		ActiveChild >r
		win-func execute
		textbuf SetText: CurrentWindow
		name$ count SetFileName: ActiveChild
		curpos GotoPos: CurrentWindow
		modified? 0= IF SetSavePoint: CurrentWindow THEN
		browsing? SetBrowseMode: ActiveChild
		textbuf release
		r@ TabPosition ActiveChild TabPosition SwapTabs
		r> GetHandle: [ ] CloseChild: Frame
		Update
		SetFocus: ActiveChild
		 ;

: SplitWindowVertical	( -- )
		['] NewVSplitWnd VERT_SPLIT SplitWindow ; IDM_SPLIT_VERTICAL SetCommand

: SplitWindowHorizontal	( -- )
		['] NewHSplitWnd HORIZ_SPLIT SplitWindow ; IDM_SPLIT_HORIZONTAL SetCommand

: UnSplitWindow	( -- )
		['] NewEditWindow NO_SPLIT SplitWindow ; IDM_NO_SPLIT_WINDOW SetCommand

\ : SplitWindowHorizontal	{ \ modified? curpos textbuf textlen name$ -- }
\ 		ActiveChild 0= ?exit
\ 		GetFileType: ActiveChild FT_SOURCE <> ?exit
\ 		GetSplitType: ActiveChild HORIZ_SPLIT = ?exit
\ 		new$ to name$ name$ off
\ 		GetTextLength: CurrentWindow 1+ to textlen	\ get text buffer size
\ 		textlen malloc to textbuf			\ allocate buffer
\ 		textbuf textlen GetText: CurrentWindow		\ retrieve text
\ 		?Modified: ActiveChild to modified?		\ get modified status
\ 		GetCurrentPos: CurrentWindow to curpos		\ position in document
\ 		GetFileName: ActiveChild count name$ place	\ file name
\ 		SetSavepoint: CurrentWindow			\ mark as not modified
\ 		ActiveChild >r
\ 		NewHSplitWnd
\ 		textbuf SetText: CurrentWindow
\ 		name$ count SetFileName: ActiveChild
\ 		curpos GotoPos: CurrentWindow
\ 		modified? 0= IF SetSavePoint: CurrentWindow THEN
\ 		textbuf release
\ 		r@ TabPosition ActiveChild TabPosition SwapTabs
\ 		r> GetHandle: [ ] CloseChild: Frame
\ 		Update
\ 		SetFocus: ActiveChild ; IDM_SPLIT_HORIZONTAL SetCommand
\
\ : SplitWindowVertical	{ \ modified? curpos textbuf textlen name$ -- }
\ 		ActiveChild 0= ?exit
\ 		GetFileType: ActiveChild FT_SOURCE <> ?exit
\ 		GetSplitType: ActiveChild VERT_SPLIT = ?exit
\ 		new$ to name$ name$ off
\ 		GetTextLength: CurrentWindow 1+ to textlen	\ get text buffer size
\ 		textlen malloc to textbuf			\ allocate buffer
\ 		textbuf textlen GetText: CurrentWindow		\ retrieve text
\ 		?Modified: ActiveChild to modified?		\ get modified status
\ 		GetCurrentPos: CurrentWindow to curpos		\ position in document
\ 		GetFileName: ActiveChild count name$ place	\ file name
\ 		SetSavepoint: CurrentWindow			\ mark as not modified
\ 		ActiveChild >r
\ 		NewVSplitWnd
\ 		textbuf SetText: CurrentWindow
\ 		name$ count SetFileName: ActiveChild
\ 		curpos GotoPos: CurrentWindow
\ 		modified? 0= IF SetSavePoint: CurrentWindow THEN
\ 		textbuf release
\ 		r@ TabPosition ActiveChild TabPosition SwapTabs
\ 		r> GetHandle: [ ] CloseChild: Frame
\ 		Update
\ 		SetFocus: ActiveChild ; IDM_SPLIT_VERTICAL SetCommand
\
\ : UnSplitWindow	{ \ modified? curpos textbuf textlen name$ -- }
\ 		ActiveChild 0= ?exit
\ 		GetFileType: ActiveChild FT_SOURCE <> ?exit
\ 		GetSplitType: ActiveChild NO_SPLIT = ?exit
\ 		new$ to name$ name$ off
\ 		GetTextLength: CurrentWindow 1+ to textlen	\ get text buffer size
\ 		textlen malloc to textbuf			\ allocate buffer
\ 		textbuf textlen GetText: CurrentWindow		\ retrieve text
\ 		?Modified: ActiveChild to modified?		\ get modified status
\ 		GetCurrentPos: CurrentWindow to curpos		\ position in document
\ 		GetFileName: ActiveChild count name$ place	\ file name
\ 		SetSavepoint: CurrentWindow			\ mark as not modified
\ 		ActiveChild >r
\ 		NewEditWindow
\ 		textbuf SetText: CurrentWindow
\ 		name$ count SetFileName: ActiveChild
\ 		curpos GotoPos: CurrentWindow
\ 		modified? 0= IF SetSavePoint: CurrentWindow THEN
\ 		textbuf release
\ 		r@ TabPosition ActiveChild TabPosition SwapTabs
\ 		r> GetHandle: [ ] CloseChild: Frame
\ 		Update
\ 		SetFocus: ActiveChild ; IDM_NO_SPLIT_WINDOW SetCommand

\s

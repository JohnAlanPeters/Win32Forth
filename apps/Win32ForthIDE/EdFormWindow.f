\ EdFormWindow.f

load-bitmap formbitmap "res\FFBITMAPS.BMP"
\ bitmaps for controls
load-bitmap Static_Bitmap "static.bmp"
load-bitmap PictureBitmap "picture.bmp"

:Object FormBar        <Super Win32Toolbar

:ToolStrings FormBarTooltips
          ts," New Form"
          ts," Open Form"
          ts," Save Form"
          ts," Help"
          ts," Delete control"
          ts," Copy to clipboard"
          ts," Compile to file(.frm)"
          ts," Test active form"
          ts," Move to back"
          ts," Move to front"
          ts," Edit active form"
          ts," Change TAB order"
          ts," Save all modified forms"
          ts," Load session"
          ts," Save session"
          ts," Select a Control"
          ts," Bitmap Button"
          ts," Label,press <ctrl> for static label"
          ts," TextBox,press <ctrl> for Multiline Textbox"
          ts," GroupBox"
          ts," PushButton"
          ts," CheckBox"
          ts," RadioButton"
          ts," ComboBox,press <ctrl> for ComboList box"
          ts," ListBox,press <ctrl> for MultiList Box"
          ts," Horizontal Scroll"
          ts," Vertical Scroll"
          ts," Generic Control"
          ts," FileListWindow"
          ts," Tab Control"
;ToolStrings

:ToolBarTable FormBarTable
\  Bitmap index    id            Initial state    Initial style      tool string index
  13            IDM_FORM_NEW          TBSTATE_ENABLED  TBSTYLE_BUTTON      0 ToolBarButton,
  14            IDM_FORM_OPEN         TBSTATE_ENABLED  TBSTYLE_BUTTON      1 ToolBarButton,
  15            IDM_FORM_SAVE         TBSTATE_ENABLED  TBSTYLE_BUTTON      2 ToolBarButton,
  27            IDM_FORM_SAVEALL      TBSTATE_ENABLED  TBSTYLE_BUTTON     12 ToolBarButton,
  28            IDM_FORM_LOADSESSION  TBSTATE_ENABLED  TBSTYLE_BUTTON     13 ToolBarButton,
  29            IDM_FORM_SAVESESSION  TBSTATE_ENABLED  TBSTYLE_BUTTON     14 ToolBarButton,
  25            IDM_FORM_TABORDER     TBSTATE_ENABLED  TBSTYLE_BUTTON     11 ToolBarButton,
  21            IDM_FORM_MOVETOBACK   TBSTATE_ENABLED  TBSTYLE_BUTTON      8 ToolBarButton,
  22            IDM_FORM_MOVETOFRONT  TBSTATE_ENABLED  TBSTYLE_BUTTON      9 ToolBarButton,
  17            IDM_FORM_DELETE       TBSTATE_ENABLED  TBSTYLE_BUTTON      4 ToolBarButton,
  18            IDM_FORM_COPY         TBSTATE_ENABLED  TBSTYLE_BUTTON      5 ToolBarButton,
  19            IDM_FORM_WRITE        TBSTATE_ENABLED  TBSTYLE_BUTTON      6 ToolBarButton,
  20            IDM_FORM_TEST         TBSTATE_ENABLED  TBSTYLE_BUTTON      7 ToolBarButton,
  24            IDM_FORM_EDITOR       TBSTATE_ENABLED  TBSTYLE_BUTTON     10 ToolBarButton,
								             SeparatorButton,
   0            IDM_FORM_SELECT       TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 15 ToolBarButton,
   1            IDM_FORM_BITMAP       TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 16 ToolBarButton,
   2            IDM_FORM_LABEL        TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 17 ToolBarButton,
   3            IDM_FORM_TEXTBOX      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 18 ToolBarButton,
   4            IDM_FORM_GROUPBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 19 ToolBarButton,
   5            IDM_FORM_PUSHBUTTON   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 20 ToolBarButton,
   6            IDM_FORM_CHECKBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 21 ToolBarButton,
   7            IDM_FORM_RADIOBUTTON  TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 22 ToolBarButton,
   8            IDM_FORM_COMBOBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 23 ToolBarButton,
   9            IDM_FORM_LISTBOX      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 24 ToolBarButton,
  10            IDM_FORM_HORIZSCROLL  TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 25 ToolBarButton,
  11            IDM_FORM_VERTSCROLL   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 26 ToolBarButton,
  12            IDM_FORM_GENERIC      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 27 ToolBarButton,
  30            IDM_FORM_FILEWINDOW   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 28 ToolBarButton,
  31            IDM_FORM_TABCONTROL   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 29 ToolBarButton,
;ToolBarTable

int hbitmap
29 constant #buttons

:M ClassInit:  ( -- )
        ClassInit: super
        0 to hbitmap
        401 to id
        ;M

:M Start:   ( parent -- )
        FormBarTable         IsButtonTable: self
        FormBarTooltips        IsTooltips: self

        Start: super

        24 24 word-join 0 TB_SETBUTTONSIZE hwnd Call SendMessage drop
        16 15 word-join 0 TB_SETBITMAPSIZE hwnd call SendMessage drop

        FormBitmap  usebitmap  map-3Dcolors
        \ create bitmap handle from memory image
        GetDc: self dup CreateDIBitmap to hbitmap
        ReleaseDc: self
        hbitmap      \ do we have a handle?
        if      0 hbitmap #buttons AddBitmaps: self drop
        then
        ;M

:M WindowStyle:  ( -- style )
        WindowStyle: super
        TBSTYLE_TOOLTIPS or
        TBSTYLE_FLAT  or
        TBSTYLE_WRAPABLE or
        ;M

:M On_Done:   ( -- )
        hbitmap
        if      hbitmap Call DeleteObject drop
                0 to hbitmap
        then    On_Done: super
        ;M

;Object

:Object TopPane   <Super Child-Window

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M


:M ClassInit:   ( -- )
        ClassInit: super
        ;M

:M On_Init:     ( -- )
        FormBar to TheFormBar

        self Start: TheFormBar

        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

        ;M

:M WM_NOTIFY    ( h m w l -- f )
        Handle_Notify: TheFormBar
        ;M

:M On_Size:      ( -- )
        AutoSize: TheFormBar
        ;M

: setnext       ( nexttype -- )
                to NextControlType true to newcontrol? ;

: ?TypeTextBox  ( --  type )
                control-key?       \ control key pressed while buttonclicked?
                if      TypeMultiLineBox
                else    TypeTextBox
                then    ;

: ?TypeLabel    ( -- type )
                control-key?        \ control key pressed while buttonclicked?
                if      TypeStaticBitmap
                else    TypeLabel
                then    ;

: ?TypeComboBox ( -- type )
                control-key?         \ control key pressed while buttonclicked?
                if      TypeComboListBox
                else    TypeComboBox
                then    ;

: ?TypeListBox  ( -- type )
                control-key?          \ control key pressed while buttonclicked?
                if      TypeMultiListBox
                else    TypeListBox
                then    ;

:M On_Command:  { hCtrl ncode bid -- f }
                bid dup to buttonid
                case
                        IDM_FORM_BITMAP         of   TypeBitMapButton setnext 		 endof
                        IDM_FORM_LABEL          of   ?TypeLabel       setnext 		 endof
                        IDM_FORM_TEXTBOX        of   ?TypeTextBox     setnext 		 endof
                        IDM_FORM_GROUPBOX       of   TypeGroupBox     setnext 		 endof
                        IDM_FORM_PUSHBUTTON     of   TypePushButton   setnext 		 endof
                        IDM_FORM_CHECKBOX       of   TypeCheckBox     setnext 		 endof
                        IDM_FORM_RADIOBUTTON    of   TypeRadioButton  setnext 		 endof
                        IDM_FORM_COMBOBOX       of   ?TypeComboBox    setnext 		 endof
                        IDM_FORM_LISTBOX        of   ?TypeListBox     setnext 		 endof
                        IDM_FORM_HorizScroll    of   TypeHorizScroll  setnext 		 endof
                        IDM_FORM_VertScroll     of   TypeVertScroll   setnext 		 endof
                        IDM_FORM_Generic        of   TypeGeneric      setnext 		 endof
                        IDM_FORM_FILEWINDOW     of   TypeFileWindow   setnext 		 endof
                        IDM_FORM_TABCONTROL     of   TypeTabControl   setnext 		 endof
\ for some inexplicable reason these next three aren't working from look-up table
                        IDM_FORM_DELETE         of DeleteControl 			 endof
                        IDM_FORM_MOVETOBACK	of MoveToBack				 endof
                        IDM_FORM_MOVETOFRONT    of MoveToFront				 endof
                        bid IsCommand?  if bid DoCommand then
                        0 to NextControlType false to newcontrol?
                endcase ;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: self
        0 ;M

:M Close:  ( -- )
        Close: FormBar
        Close: super
        ;M

:M On_Paint: ( -- )
        0 0 GetSize: self FormColor FillArea: dc
        ;M

;Object

needs formmonitor.f

\ We will use two child windows to separate the status labels from the monitor window
Child-Window PartitionI
:Object PartitionII	<Super Child-window

:M On_Paint:    0 0 Width Height Formcolor Fillarea: dc ;M

:M On_Init:	( -- )
		self Start: Monitor
		;M

;Object

:Object FormStats   <Super Child-Window

:M On_Paint: ( -- )
        0 0 Width Height FormColor FillArea: dc
        ;M

:M On_Init:	( -- )
		CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

		self Start: PartitionI
		self Start: PartitionII

		PartitionI Start: lblControlName
		Handle: ControlFont SetFont: lblControlName

		PartitionI Start: lblSize
		Handle: ControlFont SetFont: lblSize

		PartitionI Start: lblPosition
		Handle: ControlFont SetFont: lblPosition

		PartitionI Start: lblFormName
		Handle: ControlFont SetFont: lblFormName

		PartitionI Start: lblModified
		Handle: ControlFont SetFont: lblModified

		;M

:M On_Size:	( -- )
\ set the divisions
		0 0 Width 130 Move: PartitionI
		0 145 Width Height 145 - Move: PartitionII

		0   0 Width 25 Move: lblFormName		\ relative
		0  26 Width 25 Move: lblControlName		\ to
		0  52 Width 25 Move: lblPosition		\ their
		0  78 Width 25 Move: lblSize			\ parent
		0 104 Width 25 Move: lblModified
		;M

;Object

:Object CodeWin   <Super Child-Window

WinSplitter SplitterH
0 value ToolBarHeight    \ set to height of toolbar if any
25 value StatusBarHeight  \ set to height of status bar if any
200 value TopHeight
5 value ThicknessH
75 constant btnwidth

int dragging
int mousedown

: SplitterYpos    ( -- n )   ToolBarHeight TopHeight + ;
: BottomYpos      ( -- n )   SplitterYpos ThicknessH + ;
: StatusBarYpos   ( -- n )   height StatusbarHeight - ;
: BottomHeight    ( -- n )   StatusBarYpos BottomYpos - ;
: TotalHeight     ( -- n )   StatusBarYpos ToolBarHeight - ;
: TopHeightMin    ( -- n )   TopHeight TotalHeight min ;

: position-windows ( -- )
        0  ToolBarHeight  Width  TopHeightMin  Move: FormPane
        0  BottomYpos     Width  BottomHeight  Move: ControlsPane
        0  SplitterYpos   Width  ThicknessH    Move: SplitterH
        1 StatusBarYPos 2dup 	btnwidth 25    Move: btnPreview
        btnwidth 2+ under+  	btnwidth 25    Move: btnTestForm
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        dup ToolBarHeight StatusBarYpos within
        IF  SplitterYpos BottomYpos within  swap  0 width within  and  IF  1  ELSE  0  THEN
        ELSE  2drop 0  THEN ;

: On_Tracking ( -- )   \ set min and max values of TopHeight here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousey ToolBarHeight -  0max  TotalHeight min   thicknessH 2/ -  to TopHeight  THEN
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
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: Super WS_CLIPCHILDREN or ;M

:M On_Size: ( -- )
        position-windows
        Paint: Parent 	\ refresh tab control
        Paint: FormPane
        Paint: ControlsPane
        Paint: SplitterH
        Paint: btnPreview
        Paint: btnTestForm
        ;M

:M On_Init: ( -- )
        \ prevent flicker in window on sizing
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

        self Start: FormPane
        self Start: ControlsPane
        self Start: SplitterH

        self Start: btnPreview
        s" Preview Code" SetText: btnPreview
        Handle: ControlFont SetFont: btnPreview

        self Start: btnTestForm
        s" Test" SetText: btnTestForm
        Handle: ControlFont SetFont: btnTestForm

        ;M

:M On_Command:  { ncode id -- }
		id
		case	GetId: btnPreview	of	Start: CodePreviewWindow	endof
			GetID: btnTestForm	of	TestSelection			endof
	        endcase
		;M

:M WM_COMMAND   ( hwnd msg wparam lparam -- res )
        over HIWORD ( notification code ) rot LOWORD ( ID )
        On_Command: Self
        false ;M

:M On_Paint:    ( -- )
                0 0 Width Height FormColor FillArea: dc
                ;M

;Object

:Object BottomPane   <Super Child-Window

TabControl InfoWindow

:M WndClassStyle:       ( -- style )
\ Set the style member of the the WNDCLASS structure.
        CS_DBLCLKS ;M

:M ReSize:	( -- )
\ Resize the controls within the main window.
        AutoSize: InfoWindow

        ClientSize: InfoWindow 2over d- ( x y w h )
        4dup Move: frmProperties++
	4dup Move: FormStats
	     Move: CodeWin
        ;M

:M On_Size:	( -- )
\ Handle the WM_SIZE message.
        ReSize: self Paint: Infowindow ;M

: ShowStats     ( -- )
        SW_SHOW Show: FormStats   \ show before hide
        SW_HIDE Show: frmProperties++
        SW_HIDE Show: CodeWin
        ;

: ShowProperties   ( -- )
        SW_SHOW Show: frmProperties++
        SW_HIDE Show: FormStats
        SW_HIDE Show: CodeWin
        ;

: ShowCode   ( -- )
        SW_HIDE Show: frmProperties++
        SW_HIDE Show: FormStats
        SW_SHOW Show: CodeWin
        ;

:M SelChange:	( -- )
\ Show the control for the currently selected tab.
	GetSelectedTab: InfoWindow
        case    0 	of ShowProperties    	endof
                1    	of ShowStats       	endof
                2	of ShowCode		endof
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
	SetSelectedTab: InfoWindow
	SelChange: self ;M

:M On_Init:     ( -- )
	self Start: FormStats
	self Start: frmProperties++
	self Start: CodeWin

	TCS_FLATBUTTONS AddStyle: InfoWindow
	self Start: InfoWindow   \ must be started last
	Handle: ControlFont SetFont: InfoWindow

	['] selchange-func IsChangeFunc: InfoWindow

	TCIF_TEXT IsMask: InfoWindow
	z" Properties" IsPszText: InfoWindow
	1 InsertTab: InfoWindow

	TCIF_TEXT IsMask: InfoWindow
	z" Status" IsPszText: InfoWindow
	2 InsertTab: InfoWindow

	TCIF_TEXT IsMask: InfoWindow
	z" Code Editor" IsPszText: InfoWindow
	3 InsertTab: InfoWindow

        SelChange: self \ show the control for the currently selected tab

        ;M

:M ExWindowStyle: ( -- style )
        ExWindowStyle: Super
        WS_EX_CLIENTEDGE or ;M

:M On_Paint: ( -- )
        0 0 Width Height white FillArea: dc
        ;M

:M WM_NOTIFY  ( h m w l -- f )
                Handle_Notify: InfoWindow
                ;M

:M Close:	( -- )
		Close: FormStats
		Close: frmProperties++
		Close: CodeWin
		Close: Super
		;M

;Object

: ShowCodeEditorTab	( -- )
		true to show-code?		\ open code editing window
		2 ShowTab: BottomPane		\ switch tab
		IDM_FORM_ADDCODE DoCommand 	\ and refresh
		;

:Object FormWindow   <Super Child-Window

0 value ToolBarHeight    \ set to height of toolbar if any
0 value StatusBarHeight  \ set to height of status bar if any
125 value TopHeight
5 value ThicknessH

WinSplitter SplitterH

int dragging
int mousedown

: SplitterYpos    ( -- n )   ToolBarHeight TopHeight + ;
: BottomYpos      ( -- n )   SplitterYpos ThicknessH + ;
: StatusBarYpos   ( -- n )   height StatusbarHeight - ;
: BottomHeight    ( -- n )   StatusBarYpos BottomYpos - ;
: TotalHeight     ( -- n )   StatusBarYpos ToolBarHeight - ;
: TopHeightMin    ( -- n )   TopHeight TotalHeight min ;

: position-windows ( -- )
        0  ToolBarHeight  Width  TopHeightMin  Move: TopPane
        0  BottomYpos     Width  BottomHeight  Move: BottomPane
        0  SplitterYpos   Width  ThicknessH    Move: SplitterH
        ;

: Splitter ( -- n )   \ the splitter window the cursor is on
        hWnd get-mouse-xy
        dup ToolBarHeight StatusBarYpos within
        IF  SplitterYpos BottomYpos within  swap  0 width within  and  IF  1  ELSE  0  THEN
        ELSE  2drop 0  THEN ;

: On_Tracking ( -- )   \ set min and max values of TopHeight here
        mousedown dragging or 0= ?EXIT
        dragging
        IF  mousey ToolBarHeight -  0max  TotalHeight min   thicknessH 2/ -  to TopHeight  THEN
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
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: Super WS_CLIPCHILDREN or ;M

:M On_Size: ( -- )
        position-windows
        Paint: Parent 	\ refresh tab control
        Paint: TopPane
        Paint: BottomPane
        Paint: SplitterH
        ;M

: InitBitmaps	( -- ) \ create default bitmap handles for bitmap buttons
                PictureBitmap usebitmap   \ create bitmap handle
                GetDc: self dup>r CreateDIBitmap to picturebmp
                Static_Bitmap usebitmap
                r@ CreateDIBitmap to staticbmp
                r> ReleaseDc: self ;

:M On_Init: ( -- )
        \ prevent flicker in window on sizing
        CS_DBLCLKS GCL_STYLE hWnd  Call SetClassLong  drop

	COLOR_BTNFACE Call GetSysColor NewColor: FormColor

	InitBitmaps

        s" MS Sans Serif" SetFaceName: ControlFont
        8 Width: ControlFont
        Create: ControlFont

        self Start: TopPane
        self Start: BottomPane
        self Start: SplitterH
        ;M

:M Close:	( -- )
		Close: TopPane
		Close: BottomPane
		Close: SplitterH
		Delete: ControlFont
                picturebmp ?dup
                if      Call DeleteObject drop
                        0 to picturebmp
                then    staticbmp ?dup
                if      Call DeleteObject drop
                        0 to staticbmp
                then    Close: Super
		;M

;Object

:Object DetachedFormWindow		<Super Window

4 200  2value XYPos  \ save screen location of form
220 300 2value StartingSize

:M On_Size:	( -- )
		detached?
		if	0 0 GetSize: self Move: FormWindow
		then	;M

:M On_Init:	( -- )
		detached?
		if	GetHandle: FormWindow 0=
			if	self Start: FormWindow
			then
		then	;M

:M Close:	( -- )
		detached?
		if 	Close: FormWindow
		then	Close: Super ;M

:M WindowTitle:	( -- ztitle )
		z" Form Designer"
		;M

:M ParentWindow:	( -- )
			GetHandle: MainWindow
			;M

:M On_Done:    ( -- )
                originx originy 2to XYPos
                Width Height 2to StartingSize
                On_Done: super
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M StartSize:    ( -- w  h )
		StartingSize ;M

;Object

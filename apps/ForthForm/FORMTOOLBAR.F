\ FormToolbar.f         Toolbar support for ForthForm

\ enumerate IDs for toolbar buttons
100 to enum-value
  enum: IDC_SELECT
        IDC_BITMAP
        IDC_LABEL
        IDC_TEXTBOX
        IDC_GROUPBOX
        IDC_PUSHBUTTON
        IDC_CHECKBOX
        IDC_RADIOBUTTON
        IDC_COMBOBOX
        IDC_LISTBOX
        IDC_HORIZSCROLL
        IDC_VERTSCROLL
        IDC_GENERIC
        IDC_NEW
        IDC_OPEN
        IDC_SAVE
        IDC_HELP
        IDC_DELETE
        IDC_COPY
        IDC_COMPILE
        IDC_TEST
        IDC_BACK     \ function move to back
        IDC_FRONT    \ move to front
        IDC_CONSOLE
        IDC_EDITOR
        IDC_TAB
        IDC_SAVEALL
        IDC_LOADSESSION
        IDC_SAVESESSION
        IDC_FILEWINDOW
        IDC_TABCONTROL ;

24 value defbuttonwidth
72 constant LargeButtonWidth     \ for buttons with text
48 constant LargeButtonHeight
24 constant SmallButtonWidth      \ a little bigger than Windows default
24 constant SmallButtonHeight

:Object ControlToolbar     <super Win32ToolBar

load-bitmap ControlBitmaps "ffbitmaps.bmp"

:ToolStrings ControlToolTips
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

\ Define button strings ( text that can optionally be displayed on the button )
:ToolStrings ControlToolStrings
          ts," Select"
          ts," Bitmap"
          ts," Label"
          ts," TextBox"
          ts," GroupBox"
          ts," PushButton"
          ts," CheckBox"
          ts," RadioButton"
          ts," ComboBox"
          ts," ListBox"
          ts," HScroll"
          ts," VScroll"
          ts," Generic"
          ts," File"
          ts," Tab"
;ToolStrings

:ToolBarTable ControlTable
\  Bitmap index    id            Initial state    Initial style      tool string index
   0            IDC_SELECT       TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  0 ToolBarButton,
   1            IDC_BITMAP       TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  1 ToolBarButton,
   2            IDC_LABEL        TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  2 ToolBarButton,
   3            IDC_TEXTBOX      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  3 ToolBarButton,
   4            IDC_GROUPBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  4 ToolBarButton,
   5            IDC_PUSHBUTTON   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  5 ToolBarButton,
   6            IDC_CHECKBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  6 ToolBarButton,
   7            IDC_RADIOBUTTON  TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  7 ToolBarButton,
   8            IDC_COMBOBOX     TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  8 ToolBarButton,
   9            IDC_LISTBOX      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP  9 ToolBarButton,
ToolBarTableExtraButtons:
  10            IDC_HORIZSCROLL  TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 10 ToolBarButton,
  11            IDC_VERTSCROLL   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 11 ToolBarButton,
  12            IDC_GENERIC      TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 12 ToolBarButton,
  30            IDC_FILEWINDOW   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 13 ToolBarButton,
  31            IDC_TABCONTROl   TBSTATE_ENABLED  TBSTYLE_CHECKGROUP 14 ToolBarButton,
;ToolBarTable

int hbitmap
15 constant #buttons

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
                then    over to defbuttonwidth
                word-join 0 TB_SETBUTTONSIZE SendMessage:Self drop

                \ set bitmap size
                16 18 word-join 0 TB_SETBITMAPSIZE SendMessage:Self drop

                ControlBitmaps usebitmap   \ create bitmap handle
                map-transparent             \ use system color for background
                GetDc: self dup>r CreateDIBitmap to hbitmap
                r> ReleaseDc: self
                hbitmap     \ do we have a handle?
                if      0 hbitmap #buttons AddBitmaps: self drop
                then
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
 [  TBSTYLE_TOOLTIPS TBSTYLE_WRAPABLE or CCS_ADJUSTABLE or CCS_NOPARENTALIGN or CCS_NORESIZE or ] LITERAL or
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
                Autosize: self
                UpdateSystem                    \ enable or disable appropiate buttons
                false
                ;M

:M StartSize: ( -- w h )   \ start size in popup window
        hWnd
        IF
            GetButtonCount: self 1-   \ last button
            GetButtonRect: self  >r  over 2* +  rot drop  swap r> +   \ w=r+2t, h=b+t
        ELSE
            StartSize: super
        THEN ;M

:M StartPos: ( -- x y )   \ start position in popup window
        hWnd
        IF    0 GetButtonRect: self  2drop nip  0   \ x=top, y=0
        ELSE  StartPos: super
        THEN ;M

;Object

:Object MainToolbar     <super Win32ToolBar

load-bitmap MainBitmaps "ffbitmaps.bmp" \ have to load them separately for some reason

\ Define tool tips (texts that gives a short description of the buttons function)
\ These correspond to bitmap images in the loaded bitmap
:ToolStrings MainToolTips
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
          ts," Toggle display of console"
          ts," Edit active form"
          ts," Change TAB order"
          ts," Win API help"
          ts," Save all modified forms"
          ts," Load session"
          ts," Save session"
;ToolStrings

\ Define button strings ( text that can optionally be displayed on the button )
:ToolStrings MainToolStrings
          ts," New"
          ts," Open"
          ts," Save"
          ts," Help"
          ts," Delete"
          ts," Copy"
          ts," Compile"
          ts," Test"
          ts," Back"
          ts," Front"
          ts," Console"
          ts," Edit"
          ts," Tab Order"
          ts," API"
          ts," Save all"
          ts," Load"
          ts," Save"
;ToolStrings

:ToolBarTable MainTable
\  Bitmap index    id            Initial state    Initial style      tool string index
  13            IDC_NEW          TBSTATE_ENABLED  TBSTYLE_BUTTON      0 ToolBarButton,
  14            IDC_OPEN         TBSTATE_ENABLED  TBSTYLE_BUTTON      1 ToolBarButton,
  15            IDC_SAVE         TBSTATE_ENABLED  TBSTYLE_BUTTON      2 ToolBarButton,
\                                                                        SeparatorButton,
  25            IDC_TAB          TBSTATE_ENABLED  TBSTYLE_BUTTON     12 ToolBarButton,
  21            IDC_BACK         TBSTATE_ENABLED  TBSTYLE_BUTTON      8 ToolBarButton,
  22            IDC_FRONT        TBSTATE_ENABLED  TBSTYLE_BUTTON      9 ToolBarButton,
  17            IDC_DELETE       TBSTATE_ENABLED  TBSTYLE_BUTTON      4 ToolBarButton,
\                                                                        SeparatorButton,
  18            IDC_COPY         TBSTATE_ENABLED  TBSTYLE_BUTTON      5 ToolBarButton,
  19            IDC_COMPILE      TBSTATE_ENABLED  TBSTYLE_BUTTON      6 ToolBarButton,
  20            IDC_TEST         TBSTATE_ENABLED  TBSTYLE_BUTTON      7 ToolBarButton,
\                                                                        SeparatorButton,
  24            IDC_EDITOR       TBSTATE_ENABLED  TBSTYLE_BUTTON     11 ToolBarButton,
  16            IDC_HELP         TBSTATE_ENABLED  TBSTATE_WRAP or
                                                  TBSTYLE_BUTTON      3 ToolBarButton,
\                                                                        SeparatorButton,
\                                                                        SeparatorButton,
ToolBarTableExtraButtons:
  23            IDC_CONSOLE      TBSTATE_ENABLED  TBSTYLE_BUTTON     10 ToolBarButton,
  27            IDC_SAVEALL      TBSTATE_ENABLED  TBSTYLE_BUTTON     14 ToolBarButton,
  28            IDC_LOADSESSION  TBSTATE_ENABLED  TBSTYLE_BUTTON     15 ToolBarButton,
  29            IDC_SAVESESSION  TBSTATE_ENABLED  TBSTYLE_BUTTON     16 ToolBarButton,
;ToolBarTable

int hbitmap
16 constant #buttons

:M ClassInit:   ( -- )
                ClassInit: super
                0 to hbitmap
                ;M

:M Start:       ( parent -- )
                MainTable         IsButtonTable: self
                MainToolTips         IsToolTips: self

                Start: super

                \ set button size
                ButtonText?
                if      LargeButtonWidth LargeButtonHeight
                else    SmallButtonWidth SmallButtonHeight
                then    over to defbuttonwidth
                word-join 0 TB_SETBUTTONSIZE SendMessage:Self drop

                \ set bitmap size
                16 18 word-join 0 TB_SETBITMAPSIZE SendMessage:Self drop

                MainBitmaps usebitmap   \ create bitmap handle
                map-transparent             \ use system color for background
                GetDc: self dup>r CreateDIBitmap to hbitmap
                r> ReleaseDc: self
                hbitmap     \ do we have a handle?
                if      0 hbitmap #buttons AddBitmaps: self drop
                then
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: super
 [  TBSTYLE_TOOLTIPS TBSTYLE_WRAPABLE or CCS_ADJUSTABLE or CCS_NOPARENTALIGN or CCS_NORESIZE or ] LITERAL or
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
                Autosize: self
                UpdateSystem                    \ enable or disable appropiate buttons
                false
                ;M

:M StartSize: ( -- w h )   \ start size in popup window
        hWnd
        IF
            GetButtonCount: self 1-   \ last button
            GetButtonRect: self  >r  over 2* +  rot drop  swap r> +   \ w=r+2t, h=b+t
        ELSE
            StartSize: super
        THEN ;M

:M StartPos: ( -- x y )   \ start position in popup window
        hWnd
        IF    0 GetButtonRect: self  2drop nip  0   \ x=top, y=0
        ELSE  StartPos: super
        THEN ;M

;Object

ComboListBox FormPicker \ list of forms

:Object TheRebar          <super RebarControl

: add-combobox  ( -- )
                eraseband-info
                WS_CLIPSIBLINGS AddStyle: FormPicker
                self Start: FormPicker
                Handle: ControlFont SetFont: FormPicker
[ RBBIM_CHILD RBBIM_CHILDSIZE or RBBIM_TEXT or RBBIM_STYLE or  RBBIM_SIZE or ] LITERAL
                to bfmask
                z" List of Forms" to lptext
                Gethandle: FormPicker to hwndchild
                0 to cxMinChild
                20 to cyMinChild
                20 to cyChild
                200 to cyMaxChild
                1 to cyIntegral
                200 to cx
                RBBS_GRIPPERALWAYS    \ RBBS_VARIABLEHEIGHT or
                RBBS_CHILDEDGE or
                to fstyle
                InsertBand: self ;

: add-controltoolbar   ( -- )
                eraseband-info
                self Start: ControlToolBar
[ RBBIM_CHILD  RBBIM_CHILDSIZE or  RBBIM_STYLE or  RBBIM_SIZE or RBBIM_ID or ] LITERAL
                to bfmask
                GetHandle: ControlToolBar to hwndchild
                25 to cyMinChild 0 to cxMinChild
                200 to cx
                GetID: ControlToolbar to wID
                RBBS_CHILDEDGE RBBS_GRIPPERALWAYS or to fstyle
                InsertBand: self ;

: add-maintoolbar   ( -- )
                eraseband-info
                self Start: MainToolBar
[ RBBIM_CHILD  RBBIM_CHILDSIZE or  RBBIM_STYLE or  RBBIM_SIZE or RBBIM_ID or ] LITERAL
                to bfmask
                GetHandle: MainToolBar to hwndchild
                25 to cyMinChild 0 to cxMinChild
                400 to cx
                GetID: MainToolbar to wID
                RBBS_GRIPPERALWAYS RBBS_CHILDEDGE or to fstyle
                InsertBand: self ;

:M WindowStyle: ( -- style )
                WindowStyle: super
                WS_CLIPSIBLINGS or  WS_CLIPCHILDREN or CCS_NODIVIDER or
                RBS_VARHEIGHT or RBS_BANDBORDERs or WS_BORDER or
                RBS_AUTOSIZE or CCS_NOPARENTALIGN or \ RBS_DBLCLKTOGGLE or
                align_rebar 1 and
                if    CCS_VERT or // align_rebar is odd if this is a vertical bar
                then  align_rebar BOTTOM =
                if    CCS_BOTTOM or
                then  align_rebar RIGHT =
                if    CCS_RIGHT or
                then  align_rebar LEFT =
                if    CCS_LEFT or
                then  ;M

:M Width:	( -- w )
		getwindowrect: self drop nip swap - ;M


:M ClassInit:   ( -- )
                ClassInit: Super
                self link-formwindow
                ;M

'1' constant idd_combo
'2' constant idd_main
'3' constant idd_controls

: add-children	( -- )
		rebar$ c@ 0=	\ from scratch?
                if      add-maintoolbar
                        add-controltoolbar
                        align_rebar 1 and 0=
                        if    add-combobox
                        then   exit
                then	rebar$ count bounds
		?do	i c@
			case	idd_combo	of	add-combobox		endof
				idd_main	of	add-maintoolbar		endof
				idd_controls	of	add-controltoolbar	endof
			endcase
		loop	;

:M Start:       ( parent -- )
                Start: super
                hwnd
		if	add-children
		then	;M

:M GetOrder:    ( -- addr cnt )
		rebar$ off align_rebar 1 and
		if	2	\ combo box not included for left or right
		else	3
		then	0
		do	eraseband-info
			RBBIM_CHILD to bfmask
			REBARBANDINFO i RB_GETBANDINFO SendMessage:Self
			if	hwndchild
				case	GetHandle: FormPicker	of	idd_combo	endof
					GetHandle: MainToolBar  of	idd_main	endof
					GetHandle: ControlToolbar of	idd_controls	endof
					( default ) 0 swap
				endcase
			then	?dup
			if	rebar$ c+place
			then
		loop	rebar$ count ;M

:M Close:       ( -- )
                Close: ControlToolBar
                Close: MainToolBar
                Close: FormPicker
                Close: super ;M


;object

\s

\ TABPROPERTYWINDOW.FRM
\- textbox needs excontrols.f


:Object frmPropertiesWindow                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
720 70  2value XYPos  \ save screen location of form

TabControl TabProperties
\ Coordinates and dimensions for btnApply
22  value btnApplyX
287  value btnApplyY
108  value btnApplyW
40  value btnApplyH
\ Coordinates and dimensions for btnClose
132  value btnCloseX
287  value btnCloseY
108  value btnCloseW
40  value btnCloseH

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Properties+"
                ;M

:M StartSize:   ( -- width height )
                261 333 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M WM_NOTIFY  ( h m w l -- f )
\ if this form has more than one tab control this handler will need to be modified
                Handle_Notify: TabProperties
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: TabProperties
                4 3 252 276 Move: TabProperties
                Handle: Winfont SetFont: TabProperties

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ CONTROLPROPERTYII.FRM
\- textbox needs excontrols.f

GroupBox grpOrientation
TextBox txtName
TextBox txtCaption
SpinnerControl spnXPos
SpinnerControl spnYPos
SpinnerControl spnWidth
SpinnerControl spnHeight
TextBox txtToolTip
TextBox txtBitmap
PushButton btnBrowse
GroupRadioButton radLeft
RadioButton radCenter
RadioButton radRight
RadioButton radLefttext
CheckBox chkGroup
CheckBox chkGlobal
CheckBox chkSpinner
PushButton btnPrevious
PushButton btnNext

:Object frmEditProperties                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpOptions
GroupBox grpControls
Label lblName
Label lblCaption
Label lblXpos
Label lblYPos
Label lblWidth
Label lblHeight
Label lblTooltip
Label lblBitmap

:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                419  to id     \ set child id, changeable
                \ Insert your code here
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowStyle:  ( -- style )
                WS_CHILD 
                ;M

:M Start:       ( Parent -- )
                to parent
                register-child-window drop
                create-child-window to hWnd ;M 

:M WindowTitle: ( -- ztitle )
                z" Control Properties"
                ;M

:M StartSize:   ( -- width height )
                258 259 
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOptions
                153 139 87 74 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                BS_CENTER +Style: grpOptions
                s" Options" SetText: grpOptions

                self Start: grpControls
                8 201 141 43 Move: grpControls
                Handle: Winfont SetFont: grpControls
                BS_CENTER +Style: grpControls
                s" Control" SetText: grpControls

                self Start: grpOrientation
                8 139 141 60 Move: grpOrientation
                Handle: Winfont SetFont: grpOrientation
                BS_CENTER +Style: grpOrientation
                s" Justification" SetText: grpOrientation

                self Start: lblName
                1 4 39 14 Move: lblName
                Handle: Winfont SetFont: lblName
                SS_RIGHT +Style: lblName
                s" Name:" SetText: lblName

                self Start: lblCaption
                1 20 39 14 Move: lblCaption
                Handle: Winfont SetFont: lblCaption
                SS_RIGHT +Style: lblCaption
                s" Caption:" SetText: lblCaption

                self Start: lblXpos
                2 44 39 14 Move: lblXpos
                Handle: Winfont SetFont: lblXpos
                SS_RIGHT +Style: lblXpos
                s" XPos:" SetText: lblXpos

                self Start: lblYPos
                102 44 37 14 Move: lblYPos
                Handle: Winfont SetFont: lblYPos
                SS_RIGHT +Style: lblYPos
                s" YPos:" SetText: lblYPos

                self Start: lblWidth
                2 69 39 17 Move: lblWidth
                Handle: Winfont SetFont: lblWidth
                SS_RIGHT +Style: lblWidth
                s" Width:" SetText: lblWidth

                self Start: lblHeight
                102 69 36 14 Move: lblHeight
                Handle: Winfont SetFont: lblHeight
                SS_RIGHT +Style: lblHeight
                s" Height:" SetText: lblHeight

                self Start: lblTooltip
                1 96 39 14 Move: lblTooltip
                Handle: Winfont SetFont: lblTooltip
                SS_RIGHT +Style: lblTooltip
                s" ToolTip:" SetText: lblTooltip

                self Start: lblBitmap
                1 112 39 14 Move: lblBitmap
                Handle: Winfont SetFont: lblBitmap
                SS_RIGHT +Style: lblBitmap
                s" Bitmap:" SetText: lblBitmap

                self Start: txtName
                44 3 175 17 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: txtCaption
                44 21 175 17 Move: txtCaption
                Handle: Winfont SetFont: txtCaption

                self Start: spnXPos
                44 42 50 21 Move: spnXPos
                Handle: Winfont SetFont: spnXPos
                \ set default values, easily changed 
                0 1024 SetRange: spnXPos
                1 SetValue: spnXPos

                self Start: spnYPos
                142 42 50 21 Move: spnYPos
                Handle: Winfont SetFont: spnYPos
                \ set default values, easily changed 
                0 1024 SetRange: spnYPos
                1 SetValue: spnYPos

                self Start: spnWidth
                44 66 50 21 Move: spnWidth
                Handle: Winfont SetFont: spnWidth
                \ set default values, easily changed 
                0 1024 SetRange: spnWidth
                1 SetValue: spnWidth

                self Start: spnHeight
                142 66 50 21 Move: spnHeight
                Handle: Winfont SetFont: spnHeight
                \ set default values, easily changed 
                0 1024 SetRange: spnHeight
                1 SetValue: spnHeight

                self Start: txtToolTip
                44 96 175 15 Move: txtToolTip
                Handle: Winfont SetFont: txtToolTip

                self Start: txtBitmap
                44 112 175 15 Move: txtBitmap
                Handle: Winfont SetFont: txtBitmap

                self Start: btnBrowse
                223 112 18 14 Move: btnBrowse
                Handle: Winfont SetFont: btnBrowse
                s" ..." SetText: btnBrowse

                self Start: radLeft
                12 153 50 17 Move: radLeft
                Handle: Winfont SetFont: radLeft
                s" Left" SetText: radLeft

                self Start: radCenter
                83 153 50 16 Move: radCenter
                Handle: Winfont SetFont: radCenter
                s" Center" SetText: radCenter

                self Start: radRight
                12 172 46 16 Move: radRight
                Handle: Winfont SetFont: radRight
                s" Right" SetText: radRight

                self Start: radLefttext
                83 172 57 16 Move: radLefttext
                Handle: Winfont SetFont: radLefttext
                s" Lefttext" SetText: radLefttext

                self Start: chkGroup
                163 152 62 17 Move: chkGroup
                WS_GROUP +Style: chkGroup
                Handle: Winfont SetFont: chkGroup
                s" Group" SetText: chkGroup

                self Start: chkGlobal
                163 171 62 17 Move: chkGlobal
                Handle: Winfont SetFont: chkGlobal
                s" Global" SetText: chkGlobal

                self Start: chkSpinner
                163 190 62 17 Move: chkSpinner
                Handle: Winfont SetFont: chkSpinner
                s" Spinner" SetText: chkSpinner

                self Start: btnPrevious
                17 217 49 20 Move: btnPrevious
                WS_GROUP +Style: btnPrevious
                Handle: Winfont SetFont: btnPrevious
                BS_RIGHT +Style: btnPrevious
                s" &Previous" SetText: btnPrevious

                self Start: btnNext
                90 217 49 20 Move: btnNext
                Handle: Winfont SetFont: btnNext
                s" &Next" SetText: btnNext

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ CREATEMENUFORMII.FRM
\- textbox needs excontrols.f


:Object frmDefineMenu                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
270 170  2value XYPos  \ save screen location of form

GroupBox grpFunction
GroupBox grpAdd
Label lblMenu
\ Coordinates and dimensions for tvMenuTree
8  value tvMenuTreeX
28  value tvMenuTreeY
373  value tvMenuTreeW
115  value tvMenuTreeH
Label lblMenuText
TextBox txtMenutext
PushButton btnClear
Label lblName
TextBox txtName
PushButton btnPopup
PushButton btnSubMenu
PushButton btnMenuItem
PushButton btnSeparator
PushButton btnNew
PushButton btnDelete
PushButton btnRename
PushButton btnEdit
PushButton btnClipboard
PushButton btnSave
PushButton btnLoad
PushButton btnTest
PushButton btnClose

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Define Menu"
                ;M

:M StartSize:   ( -- width height )
                389 289 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpFunction
                119 171 75 87 Move: grpFunction
                Handle: Winfont SetFont: grpFunction
                s" Options" SetText: grpFunction

                self Start: grpAdd
                8 171 95 114 Move: grpAdd
                Handle: Winfont SetFont: grpAdd
                s" Add" SetText: grpAdd

                self Start: lblMenu
                8 8 41 17 Move: lblMenu
                Handle: Winfont SetFont: lblMenu
                s" Menu:" SetText: lblMenu

                self Start: lblMenuText
                11 150 50 16 Move: lblMenuText
                Handle: Winfont SetFont: lblMenuText
                s" MenuText:" SetText: lblMenuText

                self Start: txtMenutext
                65 150 106 17 Move: txtMenutext
                Handle: Winfont SetFont: txtMenutext

                self Start: btnClear
                178 150 25 17 Move: btnClear
                Handle: Winfont SetFont: btnClear
                s" &C" SetText: btnClear

                self Start: lblName
                210 150 35 17 Move: lblName
                Handle: Winfont SetFont: lblName
                s" Name:" SetText: lblName

                self Start: txtName
                243 150 137 17 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: btnPopup
                10 186 86 21 Move: btnPopup
                Handle: Winfont SetFont: btnPopup
                s" &Popup" SetText: btnPopup

                self Start: btnSubMenu
                10 209 86 21 Move: btnSubMenu
                Handle: Winfont SetFont: btnSubMenu
                s" &Submenu" SetText: btnSubMenu

                self Start: btnMenuItem
                10 232 86 21 Move: btnMenuItem
                Handle: Winfont SetFont: btnMenuItem
                s" &MenuItem" SetText: btnMenuItem

                self Start: btnSeparator
                10 255 86 23 Move: btnSeparator
                Handle: Winfont SetFont: btnSeparator
                s" Men&uSeparator" SetText: btnSeparator

                self Start: btnNew
                127 186 60 21 Move: btnNew
                Handle: Winfont SetFont: btnNew
                s" &New Menu" SetText: btnNew

                self Start: btnDelete
                127 209 60 21 Move: btnDelete
                Handle: Winfont SetFont: btnDelete
                s" &Delete" SetText: btnDelete

                self Start: btnRename
                127 232 60 21 Move: btnRename
                Handle: Winfont SetFont: btnRename
                s" &Rename" SetText: btnRename

                self Start: btnEdit
                215 186 69 26 Move: btnEdit
                Handle: Winfont SetFont: btnEdit
                s" &Edit" SetText: btnEdit

                self Start: btnClipboard
                286 186 69 26 Move: btnClipboard
                Handle: Winfont SetFont: btnClipboard
                s" Cl&ipboard" SetText: btnClipboard

                self Start: btnSave
                215 214 69 26 Move: btnSave
                Handle: Winfont SetFont: btnSave
                s" Sa&ve" SetText: btnSave

                self Start: btnLoad
                286 214 69 26 Move: btnLoad
                Handle: Winfont SetFont: btnLoad
                s" &Load" SetText: btnLoad

                self Start: btnTest
                215 242 69 26 Move: btnTest
                Handle: Winfont SetFont: btnTest
                s" &Test" SetText: btnTest

                self Start: btnClose
                286 242 69 26 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" C&lose" SetText: btnClose

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ CREATEPROPERTYFORM.FRM
\- textbox needs excontrols.f


:Object frmPropertyForm                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
350 285  2value XYPos  \ save screen location of form

GroupBox grpOptions
Label lblName
Label lblCaption
TextBox txtName
TextBox txtCaption
CheckBox chkDefault
CheckBox chkMultiLine
CheckBox chkButtonTabs
CheckBox chkComPile
PushButton btnTest
PushButton btnEdit
PushButton btnClipBoard
PushButton btnClose

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Compile Property Form"
                ;M

:M StartSize:   ( -- width height )
                359 187 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOptions
                63 61 158 115 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                s" Options" SetText: grpOptions

                self Start: lblName
                16 18 52 18 Move: lblName
                Handle: Winfont SetFont: lblName
                SS_RIGHT +Style: lblName
                s" Name:" SetText: lblName

                self Start: lblCaption
                16 38 52 18 Move: lblCaption
                Handle: Winfont SetFont: lblCaption
                SS_RIGHT +Style: lblCaption
                s" Caption:" SetText: lblCaption

                self Start: txtName
                72 16 150 18 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: txtCaption
                72 36 150 18 Move: txtCaption
                Handle: Winfont SetFont: txtCaption

                self Start: chkDefault
                72 75 139 22 Move: chkDefault
                WS_GROUP +Style: chkDefault
                Handle: Winfont SetFont: chkDefault
                s" Add Default Buttons" SetText: chkDefault

                self Start: chkMultiLine
                72 99 139 22 Move: chkMultiLine
                Handle: Winfont SetFont: chkMultiLine
                s" Multi-Line Tabs" SetText: chkMultiLine

                self Start: chkButtonTabs
                72 123 139 22 Move: chkButtonTabs
                Handle: Winfont SetFont: chkButtonTabs
                s" Button Tabs" SetText: chkButtonTabs

                self Start: chkComPile
                72 147 139 22 Move: chkComPile
                Handle: Winfont SetFont: chkComPile
                s" Compile Forms to Disk" SetText: chkComPile

                self Start: btnTest
                244 15 97 23 Move: btnTest
                WS_GROUP +Style: btnTest
                Handle: Winfont SetFont: btnTest
                s" &Test" SetText: btnTest

                self Start: btnEdit
                244 40 97 23 Move: btnEdit
                Handle: Winfont SetFont: btnEdit
                s" &Edit" SetText: btnEdit

                self Start: btnClipBoard
                244 65 97 23 Move: btnClipBoard
                Handle: Winfont SetFont: btnClipBoard
                s" Clip&Board" SetText: btnClipBoard

                self Start: btnClose
                244 90 97 23 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" &Close" SetText: btnClose

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ CREATETOOLBARFORM.FRM
\- textbox needs excontrols.f


:Object frmDefineToolbar                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
255 110  2value XYPos  \ save screen location of form

GroupBox grpTBButton
GroupBox grpState
GroupBox grpStyle
GroupBox grpStyles
GroupBox grpTOptions
GroupBox grpButtonInfo
GroupBox grpBitmapInfo
Label lblName
TextBox txtName
Label lblToolbar
TextBox txtBitmapFile
PushButton btnBrowse
CheckBox chkExcludePath
Label lblWidth
SpinnerControl spnBmpWidth
Label lblHeight
SpinnerControl spnBmpHeight
Label lblBWidth
SpinnerControl spnBtnWidth
Label lblbtnHeight
SpinnerControl spnBtnHeight
CheckBox chkFlat
CheckBox chkText
CheckBox chkCustomizable
CheckBox chkTooltips
CheckBox chkWrap
CheckBox chkList
CheckBox chkBottom
CheckBox chkNoDivider
CheckBox chkNoMoveY
CheckBox chkAltDrag
\ Coordinates and dimensions for imgButton
22  value imgButtonX
223  value imgButtonY
64  value imgButtonW
64  value imgButtonH
PushButton btnAdd
PushButton btnDelete
PushButton btnPrevious
PushButton btnNext
PushButton btnFirst
PushButton btnLast
PushButton btnMoveUp
PushButton btnMoveDown
Label lblDescription
TextBox txtDescription
Label lblTooltip
TextBox txtTooltip
Label lblButtonText
TextBox txtButtonText
CheckBox chkExtra
CheckBox chkAuto
CheckBox chkSeparator
CheckBox chkButton
CheckBox chkCheck
CheckBox chkCheckGroup
CheckBox chkGroup
CheckBox chkPressed
CheckBox chkGrayed
CheckBox chkEnabled
CheckBox chkChecked
CheckBox chkHidden
CheckBox chkWrapped
PushButton btnNew
PushButton btnOpen
PushButton btnSave
PushButton btnTest
PushButton btnView
PushButton btnRefresh
PushButton btnClose

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Define Toolbar"
                ;M

:M StartSize:   ( -- width height )
                592 422 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpTBButton
                6 204 476 215 Move: grpTBButton
                Handle: Winfont SetFont: grpTBButton
                s" Toolbar Button" SetText: grpTBButton

                self Start: grpState
                221 305 186 103 Move: grpState
                Handle: Winfont SetFont: grpState
                s" Default State" SetText: grpState

                self Start: grpStyle
                11 305 187 103 Move: grpStyle
                Handle: Winfont SetFont: grpStyle
                s" Default Style" SetText: grpStyle

                self Start: grpStyles
                139 110 231 92 Move: grpStyles
                Handle: Winfont SetFont: grpStyles
                s" Toolbar Styles" SetText: grpStyles

                self Start: grpTOptions
                10 110 117 68 Move: grpTOptions
                Handle: Winfont SetFont: grpTOptions
                s" Toolbar Options" SetText: grpTOptions

                self Start: grpButtonInfo
                221 50 192 49 Move: grpButtonInfo
                Handle: Winfont SetFont: grpButtonInfo
                s" Button Info" SetText: grpButtonInfo

                self Start: grpBitmapInfo
                10 50 195 50 Move: grpBitmapInfo
                Handle: Winfont SetFont: grpBitmapInfo
                s" Bitmap Info" SetText: grpBitmapInfo

                self Start: lblName
                12 17 40 18 Move: lblName
                Handle: Winfont SetFont: lblName
                s" Name:" SetText: lblName

                self Start: txtName
                45 17 100 18 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: lblToolbar
                160 17 37 18 Move: lblToolbar
                Handle: Winfont SetFont: lblToolbar
                SS_RIGHT +Style: lblToolbar
                s" Bitmap:" SetText: lblToolbar

                self Start: txtBitmapFile
                200 17 200 18 Move: txtBitmapFile
                Handle: Winfont SetFont: txtBitmapFile

                self Start: btnBrowse
                405 17 18 18 Move: btnBrowse
                Handle: Winfont SetFont: btnBrowse
                s" ..." SetText: btnBrowse

                self Start: chkExcludePath
                428 17 80 18 Move: chkExcludePath
                Handle: Winfont SetFont: chkExcludePath
                s" Exclude path" SetText: chkExcludePath

                self Start: lblWidth
                31 72 31 16 Move: lblWidth
                Handle: Winfont SetFont: lblWidth
                s" Width:" SetText: lblWidth

                self Start: spnBmpWidth
                65 68 46 22 Move: spnBmpWidth
                Handle: Winfont SetFont: spnBmpWidth
                \ set default values, easily changed 
                0 1024 SetRange: spnBmpWidth
                1 SetValue: spnBmpWidth

                self Start: lblHeight
                112 72 33 16 Move: lblHeight
                Handle: Winfont SetFont: lblHeight
                s" Height" SetText: lblHeight

                self Start: spnBmpHeight
                149 68 46 22 Move: spnBmpHeight
                Handle: Winfont SetFont: spnBmpHeight
                \ set default values, easily changed 
                0 1024 SetRange: spnBmpHeight
                1 SetValue: spnBmpHeight

                self Start: lblBWidth
                225 72 38 16 Move: lblBWidth
                Handle: Winfont SetFont: lblBWidth
                SS_RIGHT +Style: lblBWidth
                s" Width" SetText: lblBWidth

                self Start: spnBtnWidth
                266 68 46 22 Move: spnBtnWidth
                Handle: Winfont SetFont: spnBtnWidth
                \ set default values, easily changed 
                0 1024 SetRange: spnBtnWidth
                1 SetValue: spnBtnWidth

                self Start: lblbtnHeight
                314 72 39 16 Move: lblbtnHeight
                Handle: Winfont SetFont: lblbtnHeight
                SS_RIGHT +Style: lblbtnHeight
                s" Height" SetText: lblbtnHeight

                self Start: spnBtnHeight
                356 68 46 22 Move: spnBtnHeight
                Handle: Winfont SetFont: spnBtnHeight
                \ set default values, easily changed 
                0 1024 SetRange: spnBtnHeight
                1 SetValue: spnBtnHeight

                self Start: chkFlat
                15 126 78 20 Move: chkFlat
                WS_GROUP +Style: chkFlat
                Handle: Winfont SetFont: chkFlat
                s" Flat" SetText: chkFlat

                self Start: chkText
                15 145 110 20 Move: chkText
                Handle: Winfont SetFont: chkText
                s" Show Button Text" SetText: chkText

                self Start: chkCustomizable
                145 126 92 16 Move: chkCustomizable
                WS_GROUP +Style: chkCustomizable
                Handle: Winfont SetFont: chkCustomizable
                s" Customizable" SetText: chkCustomizable

                self Start: chkTooltips
                145 144 92 16 Move: chkTooltips
                Handle: Winfont SetFont: chkTooltips
                s" Use Tooltips" SetText: chkTooltips

                self Start: chkWrap
                145 162 92 16 Move: chkWrap
                Handle: Winfont SetFont: chkWrap
                s" Wrap Buttons" SetText: chkWrap

                self Start: chkList
                145 180 98 16 Move: chkList
                Handle: Winfont SetFont: chkList
                s" List Button Text" SetText: chkList

                self Start: chkBottom
                246 126 98 16 Move: chkBottom
                Handle: Winfont SetFont: chkBottom
                s" Align to Bottom" SetText: chkBottom

                self Start: chkNoDivider
                246 144 98 16 Move: chkNoDivider
                Handle: Winfont SetFont: chkNoDivider
                s" No Divider Line" SetText: chkNoDivider

                self Start: chkNoMoveY
                246 162 102 17 Move: chkNoMoveY
                Handle: Winfont SetFont: chkNoMoveY
                s" No Vertical Move" SetText: chkNoMoveY

                self Start: chkAltDrag
                246 180 98 16 Move: chkAltDrag
                Handle: Winfont SetFont: chkAltDrag
                s" Use Alt To Drag" SetText: chkAltDrag

                self Start: btnAdd
                92 220 67 19 Move: btnAdd
                Handle: Winfont SetFont: btnAdd
                s" Add" SetText: btnAdd

                self Start: btnDelete
                92 241 67 19 Move: btnDelete
                Handle: Winfont SetFont: btnDelete
                s" Delete" SetText: btnDelete

                self Start: btnPrevious
                92 262 67 19 Move: btnPrevious
                Handle: Winfont SetFont: btnPrevious
                s" Previous" SetText: btnPrevious

                self Start: btnNext
                92 283 67 19 Move: btnNext
                Handle: Winfont SetFont: btnNext
                s" Next" SetText: btnNext

                self Start: btnFirst
                162 220 67 19 Move: btnFirst
                Handle: Winfont SetFont: btnFirst
                s" First" SetText: btnFirst

                self Start: btnLast
                162 241 67 19 Move: btnLast
                Handle: Winfont SetFont: btnLast
                s" Last" SetText: btnLast

                self Start: btnMoveUp
                162 262 67 19 Move: btnMoveUp
                Handle: Winfont SetFont: btnMoveUp
                s" Move Up" SetText: btnMoveUp

                self Start: btnMoveDown
                162 283 67 19 Move: btnMoveDown
                Handle: Winfont SetFont: btnMoveDown
                s" Move Down" SetText: btnMoveDown

                self Start: lblDescription
                245 223 58 16 Move: lblDescription
                Handle: Winfont SetFont: lblDescription
                SS_RIGHT +Style: lblDescription
                s" Description:" SetText: lblDescription

                self Start: txtDescription
                309 220 167 17 Move: txtDescription
                Handle: Winfont SetFont: txtDescription

                self Start: lblTooltip
                245 241 58 16 Move: lblTooltip
                Handle: Winfont SetFont: lblTooltip
                SS_RIGHT +Style: lblTooltip
                s" Tooltip:" SetText: lblTooltip

                self Start: txtTooltip
                309 239 167 17 Move: txtTooltip
                Handle: Winfont SetFont: txtTooltip

                self Start: lblButtonText
                245 259 58 16 Move: lblButtonText
                Handle: Winfont SetFont: lblButtonText
                SS_RIGHT +Style: lblButtonText
                s" Button Text:" SetText: lblButtonText

                self Start: txtButtonText
                309 258 167 17 Move: txtButtonText
                Handle: Winfont SetFont: txtButtonText

                self Start: chkExtra
                245 281 100 25 Move: chkExtra
                Handle: Winfont SetFont: chkExtra
                s" Extra Button" SetText: chkExtra

                self Start: chkAuto
                349 282 100 25 Move: chkAuto
                Handle: Winfont SetFont: chkAuto
                s" Auto Mode" SetText: chkAuto

                self Start: chkSeparator
                23 320 81 23 Move: chkSeparator
                WS_GROUP +Style: chkSeparator
                Handle: Winfont SetFont: chkSeparator
                s" Separator" SetText: chkSeparator

                self Start: chkButton
                23 345 81 23 Move: chkButton
                Handle: Winfont SetFont: chkButton
                s" Button" SetText: chkButton

                self Start: chkCheck
                23 370 81 23 Move: chkCheck
                Handle: Winfont SetFont: chkCheck
                s" Check" SetText: chkCheck

                self Start: chkCheckGroup
                106 320 81 23 Move: chkCheckGroup
                Handle: Winfont SetFont: chkCheckGroup
                s" CheckGroup" SetText: chkCheckGroup

                self Start: chkGroup
                106 345 81 23 Move: chkGroup
                Handle: Winfont SetFont: chkGroup
                s" Group" SetText: chkGroup

                self Start: chkPressed
                231 318 69 25 Move: chkPressed
                WS_GROUP +Style: chkPressed
                Handle: Winfont SetFont: chkPressed
                s" Pressed" SetText: chkPressed

                self Start: chkGrayed
                231 345 69 25 Move: chkGrayed
                Handle: Winfont SetFont: chkGrayed
                s" Grayed" SetText: chkGrayed

                self Start: chkEnabled
                231 372 69 25 Move: chkEnabled
                Handle: Winfont SetFont: chkEnabled
                s" Enabled" SetText: chkEnabled

                self Start: chkChecked
                302 318 69 25 Move: chkChecked
                Handle: Winfont SetFont: chkChecked
                s" Checked" SetText: chkChecked

                self Start: chkHidden
                302 345 69 25 Move: chkHidden
                Handle: Winfont SetFont: chkHidden
                s" Hidden" SetText: chkHidden

                self Start: chkWrapped
                302 372 69 25 Move: chkWrapped
                Handle: Winfont SetFont: chkWrapped
                s" Wrap" SetText: chkWrapped

                self Start: btnNew
                520 56 60 32 Move: btnNew
                WS_GROUP +Style: btnNew
                Handle: Winfont SetFont: btnNew
                s" &New" SetText: btnNew

                self Start: btnOpen
                520 90 60 32 Move: btnOpen
                Handle: Winfont SetFont: btnOpen
                s" &Open" SetText: btnOpen

                self Start: btnSave
                520 124 60 32 Move: btnSave
                Handle: Winfont SetFont: btnSave
                s" &Save" SetText: btnSave

                self Start: btnTest
                520 158 60 32 Move: btnTest
                WS_GROUP +Style: btnTest
                Handle: Winfont SetFont: btnTest
                s" &Test" SetText: btnTest

                self Start: btnView
                520 192 60 32 Move: btnView
                Handle: Winfont SetFont: btnView
                s" S&ource" SetText: btnView

                self Start: btnRefresh
                520 226 60 32 Move: btnRefresh
                Handle: Winfont SetFont: btnRefresh
                s" &Refresh" SetText: btnRefresh

                self Start: btnClose
                520 260 60 32 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" &Close" SetText: btnClose

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then
                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop
                     \ reset focus to parent if we have one
                     ParentWindow: self Call SetFocus drop
                then
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ FORMPAD.FRM
\- textbox needs excontrols.f


:Object frmFormPad                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
150 175  2value XYPos  \ save screen location of form

\ Coordinates and dimensions for scnEditor
3  value scnEditorX
10  value scnEditorY
484  value scnEditorW
305  value scnEditorH
PushButton btnSaveToDisk
PushButton btnCompile
PushButton btnExit

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" FormPad"
                ;M

:M StartSize:   ( -- width height )
                620 320 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: btnSaveToDisk
                489 10 125 30 Move: btnSaveToDisk
                Handle: Winfont SetFont: btnSaveToDisk
                s" &Save to Disk" SetText: btnSaveToDisk

                self Start: btnCompile
                489 42 125 30 Move: btnCompile
                Handle: Winfont SetFont: btnCompile
                s" &Compile" SetText: btnCompile

                self Start: btnExit
                489 290 125 27 Move: btnExit
                Handle: Winfont SetFont: btnExit
                s" E&xit" SetText: btnExit

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then
                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop
                     \ reset focus to parent if we have one
                     ParentWindow: self Call SetFocus drop
                then
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ FORMPROPERTY.FRM
\- textbox needs excontrols.f


:Object frmEditFormProperties                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpOptions
GroupBox grpSuperClass
Label lblName
TextBox TxtName
Label lblTitle
TextBox TxtTitle
Label lblXPos
SpinnerControl spnXpos
Label lblYpos
SpinnerControl spnYpos
Label lblWidth
SpinnerControl spnWidth
Label lblHeight
SpinnerControl spnHeight
CheckBox chkModal
CheckBox chkStatusBar
CheckBox chkSave
GroupRadioButton radDialogWindow
RadioButton radChildWindow
CheckBox chkChildState
RadioButton radMdiDialogWindow

:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                420  to id     \ set child id, changeable
                \ Insert your code here
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowStyle:  ( -- style )
                WS_CHILD 
                ;M

:M Start:       ( Parent -- )
                to parent
                register-child-window drop
                create-child-window to hWnd ;M 

:M WindowTitle: ( -- ztitle )
                z" Edit Form Properties"
                ;M

:M StartSize:   ( -- width height )
                237 268 
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOptions
                16 99 216 58 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                s" Options" SetText: grpOptions

                self Start: grpSuperClass
                15 157 217 82 Move: grpSuperClass
                Handle: Winfont SetFont: grpSuperClass
                s" Compile As" SetText: grpSuperClass

                self Start: lblName
                5 6 52 17 Move: lblName
                Handle: Winfont SetFont: lblName
                SS_RIGHT +Style: lblName
                s" Name:" SetText: lblName

                self Start: TxtName
                61 6 163 16 Move: TxtName
                Handle: Winfont SetFont: TxtName

                self Start: lblTitle
                5 24 52 17 Move: lblTitle
                Handle: Winfont SetFont: lblTitle
                SS_RIGHT +Style: lblTitle
                s" Title" SetText: lblTitle

                self Start: TxtTitle
                61 25 163 16 Move: TxtTitle
                Handle: Winfont SetFont: TxtTitle

                self Start: lblXPos
                24 47 33 17 Move: lblXPos
                Handle: Winfont SetFont: lblXPos
                SS_RIGHT +Style: lblXPos
                s" XPos:" SetText: lblXPos

                self Start: spnXpos
                61 44 46 21 Move: spnXpos
                Handle: Winfont SetFont: spnXpos
                \ set default values, easily changed 
                0 1024 SetRange: spnXpos
                1 SetValue: spnXpos

                self Start: lblYpos
                118 47 31 17 Move: lblYpos
                Handle: Winfont SetFont: lblYpos
                SS_RIGHT +Style: lblYpos
                s" YPos:" SetText: lblYpos

                self Start: spnYpos
                155 44 46 21 Move: spnYpos
                Handle: Winfont SetFont: spnYpos
                \ set default values, easily changed 
                0 1024 SetRange: spnYpos
                1 SetValue: spnYpos

                self Start: lblWidth
                24 74 36 20 Move: lblWidth
                Handle: Winfont SetFont: lblWidth
                SS_RIGHT +Style: lblWidth
                s" Width:" SetText: lblWidth

                self Start: spnWidth
                61 72 46 21 Move: spnWidth
                Handle: Winfont SetFont: spnWidth
                \ set default values, easily changed 
                0 1024 SetRange: spnWidth
                1 SetValue: spnWidth

                self Start: lblHeight
                118 74 34 17 Move: lblHeight
                Handle: Winfont SetFont: lblHeight
                s" Height:" SetText: lblHeight

                self Start: spnHeight
                155 72 46 21 Move: spnHeight
                Handle: Winfont SetFont: spnHeight
                \ set default values, easily changed 
                0 1024 SetRange: spnHeight
                1 SetValue: spnHeight

                self Start: chkModal
                25 117 84 17 Move: chkModal
                WS_GROUP +Style: chkModal
                Handle: Winfont SetFont: chkModal
                s" Modal Form" SetText: chkModal

                self Start: chkStatusBar
                148 117 78 17 Move: chkStatusBar
                Handle: Winfont SetFont: chkStatusBar
                s" Status Bar" SetText: chkStatusBar

                self Start: chkSave
                25 136 121 14 Move: chkSave
                Handle: Winfont SetFont: chkSave
                s" Save screen location" SetText: chkSave

                self Start: radDialogWindow
                25 171 115 20 Move: radDialogWindow
                Handle: Winfont SetFont: radDialogWindow
                s" Dialog Window" SetText: radDialogWindow

                self Start: radChildWindow
                25 193 115 19 Move: radChildWindow
                Handle: Winfont SetFont: radChildWindow
                s" Child Window" SetText: radChildWindow

                self Start: chkChildState
                141 193 86 19 Move: chkChildState
                Handle: Winfont SetFont: chkChildState
                s" Initially hidden" SetText: chkChildState

                self Start: radMdiDialogWindow
                25 214 115 19 Move: radMdiDialogWindow
                Handle: Winfont SetFont: radMdiDialogWindow
                s" MDI Dialog Window" SetText: radMdiDialogWindow

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ GROUPACTION.FRM
\- textbox needs excontrols.f


:Object frmGroupAction                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpMove
GroupBox grpArrange
GroupBox grpSize
GroupBox grpAlign
PushButton btnLeft
PushButton btnRight
PushButton btnTop
PushButton btnBottom
PushButton btnHorizontal
PushButton btnVertical
PushButton btnTallest
PushButton btnShortest
PushButton btnWidest
PushButton btnNarrowest
PushButton btnToBox
TextBox txtValue
GroupRadioButton radPosition
RadioButton radHeight
RadioButton radWidth
\ Coordinates and dimensions for imgbtnUp
56  value imgbtnUpX
141  value imgbtnUpY
32  value imgbtnUpW
32  value imgbtnUpH
\ Coordinates and dimensions for imgbtnRight
96  value imgbtnRightX
172  value imgbtnRightY
32  value imgbtnRightW
32  value imgbtnRightH
\ Coordinates and dimensions for imgbtnDown
56  value imgbtnDownX
200  value imgbtnDownY
32  value imgbtnDownW
32  value imgbtnDownH
\ Coordinates and dimensions for imgbtnLeft
16  value imgbtnLeftX
172  value imgbtnLeftY
32  value imgbtnLeftW
32  value imgbtnLeftH

:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                421  to id     \ set child id, changeable
                \ Insert your code here
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowStyle:  ( -- style )
                WS_CHILD 
                ;M

:M Start:       ( Parent -- )
                to parent
                register-child-window drop
                create-child-window to hWnd ;M 

:M WindowTitle: ( -- ztitle )
                z" Select Action"
                ;M

:M StartSize:   ( -- width height )
                210 253 
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpMove
                10 128 195 115 Move: grpMove
                Handle: Winfont SetFont: grpMove
                s" Adjust Position/Size" SetText: grpMove

                self Start: grpArrange
                10 68 79 58 Move: grpArrange
                Handle: Winfont SetFont: grpArrange
                s" Arrange" SetText: grpArrange

                self Start: grpSize
                123 6 79 117 Move: grpSize
                Handle: Winfont SetFont: grpSize
                s" Size to" SetText: grpSize

                self Start: grpAlign
                10 6 108 62 Move: grpAlign
                Handle: Winfont SetFont: grpAlign
                s" Align to box" SetText: grpAlign

                self Start: btnLeft
                15 20 47 19 Move: btnLeft
                Handle: Winfont SetFont: btnLeft
                s" &Left" SetText: btnLeft

                self Start: btnRight
                64 20 47 19 Move: btnRight
                Handle: Winfont SetFont: btnRight
                s" &Right" SetText: btnRight

                self Start: btnTop
                15 41 47 19 Move: btnTop
                Handle: Winfont SetFont: btnTop
                s" &Top" SetText: btnTop

                self Start: btnBottom
                64 41 47 19 Move: btnBottom
                Handle: Winfont SetFont: btnBottom
                s" &Bottom" SetText: btnBottom

                self Start: btnHorizontal
                15 83 66 17 Move: btnHorizontal
                Handle: Winfont SetFont: btnHorizontal
                s" &Horizontally" SetText: btnHorizontal

                self Start: btnVertical
                15 102 66 17 Move: btnVertical
                Handle: Winfont SetFont: btnVertical
                s" &Vertically" SetText: btnVertical

                self Start: btnTallest
                127 20 66 17 Move: btnTallest
                Handle: Winfont SetFont: btnTallest
                s" Ta&llest" SetText: btnTallest

                self Start: btnShortest
                127 39 66 19 Move: btnShortest
                Handle: Winfont SetFont: btnShortest
                s" &Shortest" SetText: btnShortest

                self Start: btnWidest
                127 60 66 17 Move: btnWidest
                Handle: Winfont SetFont: btnWidest
                s" &Widest" SetText: btnWidest

                self Start: btnNarrowest
                127 79 66 19 Move: btnNarrowest
                Handle: Winfont SetFont: btnNarrowest
                s" &Narrowest" SetText: btnNarrowest

                self Start: btnToBox
                127 100 66 17 Move: btnToBox
                Handle: Winfont SetFont: btnToBox
                s" To Bo&x" SetText: btnToBox

                self Start: txtValue
                50 176 44 21 Move: txtValue
                Handle: Winfont SetFont: txtValue

                self Start: radPosition
                137 148 62 19 Move: radPosition
                Handle: Winfont SetFont: radPosition
                s" Position" SetText: radPosition

                self Start: radHeight
                137 169 62 19 Move: radHeight
                Handle: Winfont SetFont: radHeight
                s" Height" SetText: radHeight

                self Start: radWidth
                137 189 62 19 Move: radWidth
                Handle: Winfont SetFont: radWidth
                s" Width" SetText: radWidth

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ PREFERENCES.FRM
\- textbox needs excontrols.f

CheckBox chkFlatToolBar
CheckBox chkButtonText
CheckBox chkShowMonitor
CheckBox chkShowReleaseNotes
CheckBox chkSingleControl
CheckBox chkAutoProperty
GroupRadioButton radAlignTop
RadioButton radAlignBottom
RadioButton radAlignLeft
RadioButton radAlignRight
PushButton btnOk
PushButton btnCancel

:Object frmPreferences                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
150 175  2value XYPos  \ save screen location of form

GroupBox grpAlign
GroupBox grpOther
GroupBox grpToolBar

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Preferences"
                ;M

:M StartSize:   ( -- width height )
                302 257 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpAlign
                172 6 109 100 Move: grpAlign
                Handle: Winfont SetFont: grpAlign
                s" Rebar Position" SetText: grpAlign

                self Start: grpOther
                8 77 158 109 Move: grpOther
                Handle: Winfont SetFont: grpOther
                s" Options" SetText: grpOther

                self Start: grpToolBar
                9 6 140 65 Move: grpToolBar
                Handle: Winfont SetFont: grpToolBar
                s" Toolbar" SetText: grpToolBar

                self Start: chkFlatToolBar
                16 21 79 18 Move: chkFlatToolBar
                Handle: Winfont SetFont: chkFlatToolBar
                s" Flat Style" SetText: chkFlatToolBar

                self Start: chkButtonText
                16 43 122 18 Move: chkButtonText
                Handle: Winfont SetFont: chkButtonText
                s" Show Text in Buttons" SetText: chkButtonText

                self Start: chkShowMonitor
                16 102 114 18 Move: chkShowMonitor
                Handle: Winfont SetFont: chkShowMonitor
                s" Show Monitor" SetText: chkShowMonitor

                self Start: chkShowReleaseNotes
                16 121 125 18 Move: chkShowReleaseNotes
                Handle: Winfont SetFont: chkShowReleaseNotes
                s" Show Release Notes" SetText: chkShowReleaseNotes

                self Start: chkSingleControl
                16 141 137 18 Move: chkSingleControl
                Handle: Winfont SetFont: chkSingleControl
                s" Click adds single control" SetText: chkSingleControl

                self Start: chkAutoProperty
                16 161 145 18 Move: chkAutoProperty
                Handle: Winfont SetFont: chkAutoProperty
                s" Auto display properties" SetText: chkAutoProperty

                self Start: radAlignTop
                180 21 61 19 Move: radAlignTop
                Handle: Winfont SetFont: radAlignTop
                s" Top" SetText: radAlignTop

                self Start: radAlignBottom
                180 42 61 19 Move: radAlignBottom
                Handle: Winfont SetFont: radAlignBottom
                s" Bottom" SetText: radAlignBottom

                self Start: radAlignLeft
                180 63 61 19 Move: radAlignLeft
                Handle: Winfont SetFont: radAlignLeft
                s" Left" SetText: radAlignLeft

                self Start: radAlignRight
                180 84 61 19 Move: radAlignRight
                Handle: Winfont SetFont: radAlignRight
                s" Right" SetText: radAlignRight

                self Start: btnOk
                74 218 58 22 Move: btnOk
                WS_GROUP +Style: btnOk
                Handle: Winfont SetFont: btnOk
                s" &Ok" SetText: btnOk

                self Start: btnCancel
                144 218 58 22 Move: btnCancel
                Handle: Winfont SetFont: btnCancel
                s" &Cancel" SetText: btnCancel

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then
                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop
                     \ reset focus to parent if we have one
                     ParentWindow: self Call SetFocus drop
                then
                \ Insert your code here
                On_Done: super
                ;M

;Object


\ SPLITTERWINDOW.FRM
\- textbox needs excontrols.f


:Object frmSplitterWindow                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
150 175  2value XYPos  \ save screen location of form

GroupBox grpOptions
\ Coordinates and dimensions for imgType1
11  value imgType1X
17  value imgType1Y
90  value imgType1W
72  value imgType1H
\ Coordinates and dimensions for imgType2
104  value imgType2X
17  value imgType2Y
90  value imgType2W
72  value imgType2H
\ Coordinates and dimensions for imgType3
11  value imgType3X
92  value imgType3Y
90  value imgType3W
72  value imgType3H
\ Coordinates and dimensions for imgType4
104  value imgType4X
90  value imgType4Y
90  value imgType4W
71  value imgType4H
\ Coordinates and dimensions for imgType5
11  value imgType5X
165  value imgType5Y
90  value imgType5W
72  value imgType5H
\ Coordinates and dimensions for imgType6
104  value imgType6X
166  value imgType6Y
90  value imgType6W
72  value imgType6H
GroupRadioButton radTest
RadioButton radEdit
RadioButton radClipboard
CheckBox radChild-Window
PushButton btnExit

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Select Splitter Window Template"
                ;M

:M StartSize:   ( -- width height )
                339 247 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOptions
                208 17 125 125 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                s" Compile Options" SetText: grpOptions

                self Start: radTest
                221 32 103 21 Move: radTest
                Handle: Winfont SetFont: radTest
                s" Test" SetText: radTest

                self Start: radEdit
                221 55 103 21 Move: radEdit
                Handle: Winfont SetFont: radEdit
                s" Edit" SetText: radEdit

                self Start: radClipboard
                221 78 103 21 Move: radClipboard
                Handle: Winfont SetFont: radClipboard
                s" Copy to clipboard" SetText: radClipboard

                self Start: radChild-Window
                221 115 103 18 Move: radChild-Window
                WS_GROUP +Style: radChild-Window
                Handle: Winfont SetFont: radChild-Window
                s" as Child-Window" SetText: radChild-Window

                self Start: btnExit
                208 177 118 45 Move: btnExit
                Handle: Winfont SetFont: btnExit
                s" &Close" SetText: btnExit

                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here
                On_Done: super
                ;M

;Object



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

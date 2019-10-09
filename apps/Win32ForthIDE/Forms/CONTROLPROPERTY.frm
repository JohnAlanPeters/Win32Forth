\ CONTROLPROPERTY.FRM
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
ComboListBox cmblstIDs
PushButton btnChangeFont

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
Label lblIDs


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                672  to id     \ set child id, changeable
                \ Insert your code here, e.g initialize variables, values etc.
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
                255 305 
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
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
                7 219 116 42 Move: grpControls
                Handle: Winfont SetFont: grpControls
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

                self Start: lblIDs
                126 235 34 20 Move: lblIDs
                Handle: Winfont SetFont: lblIDs
                SS_RIGHT +Style: lblIDs
                s" SetID:" SetText: lblIDs

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
                17 235 49 20 Move: btnPrevious
                WS_GROUP +Style: btnPrevious
                Handle: Winfont SetFont: btnPrevious
                BS_RIGHT +Style: btnPrevious
                s" &Previous" SetText: btnPrevious

                self Start: btnNext
                68 235 49 20 Move: btnNext
                Handle: Winfont SetFont: btnNext
                s" &Next" SetText: btnNext

                self Start: cmblstIDs
                161 233 86 20 Move: cmblstIDs
                Handle: Winfont SetFont: cmblstIDs

                self Start: btnChangeFont
                18 270 66 20 Move: btnChangeFont
                Handle: Winfont SetFont: btnChangeFont
                s" Change Font" SetText: btnChangeFont

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

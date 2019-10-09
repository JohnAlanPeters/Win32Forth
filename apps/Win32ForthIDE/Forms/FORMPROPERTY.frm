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
RadioButton radTrayWindow
CheckBox chkmin


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                706  to id     \ set child id, changeable
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowTitle: ( -- ztitle )
                z" Edit Form Properties"
                ;M

:M StartSize:   ( -- width height )
                238 301 
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
                ;M

:M WM_COMMAND   ( h m w l -- res )
                dup 0=      \ id is from a menu if lparam is zero
                if        WM_COMMAND wm: super
                else      over LOWORD ( ID ) self   \ object address on stack
                          WMCommand-Func ?dup    \ must not be zero
                          if        execute
                          else    2drop   \ drop ID and object address
                          then
                then      0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Init:     ( -- )
                On_Init: Super
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOptions
                15 99 216 58 Move: grpOptions
                Handle: Winfont SetFont: grpOptions
                s" Options" SetText: grpOptions

                self Start: grpSuperClass
                15 159 216 109 Move: grpSuperClass
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
                24 136 121 17 Move: chkSave
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

                self Start: radTrayWindow
                25 237 115 19 Move: radTrayWindow
                Handle: Winfont SetFont: radTrayWindow
                s" Tray Window" SetText: radTrayWindow

                self Start: chkmin
                148 136 100 17 Move: chkmin
                Handle: Winfont SetFont: chkmin
                s" Min Box" SetText: chkmin

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

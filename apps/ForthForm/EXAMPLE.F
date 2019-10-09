anew tstfrmExample
needs excontrols.f
\ Comment out any of the following lines if they are not needed
needs bitmap.f

TextBox txtName
TextBox txtAddress
TextBox txtCity
TextBox txtCountry
CheckBox chkWin32Forth
CheckBox chkSwiftForth
CheckBox chkOther
TextBox txtFileName
PushButton btnBrowse
PushButton btnOk
PushButton btnCancel
PushButton Button4
CheckBox Check4

:Object frmExample                <Super DialogWindow

Font WinFont
' 2drop value OnWmCommand   \ function pointer for WM_COMMAND


Label lblName
Label lblAddress
Label lblCity
Label lblCountry
GroupBox grpForthProgrammer
Label lblFile
RadioButton Radio1
Label Label6
ColorObject FrmColor      \ the background color

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

:M ExWindowStyle:  ( -- exstyle )
                ExWindowStyle: super
                \ Insert your code here
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- parent | 0 if no parent )
                hwndparent
                ;M

:M SetParentWindow:  ( parentwindow -- ) \ set owner window
                to hwndparent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Forthform Example"
                ;M

:M StartSize:   ( -- width height )
                505 262
                ;M

:M MinSize:     ( -- width height )
                StartSize: self
                ;M

:M MaxSize:     ( -- width height )
                StartSize: self
                ;M

:M StartPos:    ( -- x y )
                64 213
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_KillFocus: ( h m w l -- )
                \ Insert your code here
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                self Start: lblName
                33 22 45 17 Move: lblName
                Handle: Winfont SetFont: lblName
                SS_RIGHT +Style: lblName
                s" Name:" SetText: lblName

                self Start: lblAddress
                33 41 45 17 Move: lblAddress
                Handle: Winfont SetFont: lblAddress
                SS_RIGHT +Style: lblAddress
                s" Address:" SetText: lblAddress

                self Start: lblCity
                33 60 45 17 Move: lblCity
                Handle: Winfont SetFont: lblCity
                SS_RIGHT +Style: lblCity
                s" City:" SetText: lblCity

                self Start: lblCountry
                33 79 45 17 Move: lblCountry
                Handle: Winfont SetFont: lblCountry
                SS_RIGHT +Style: lblCountry
                s" Country:" SetText: lblCountry

                self Start: txtName
                83 22 236 17 Move: txtName
                Handle: Winfont SetFont: txtName

                self Start: txtAddress
                83 41 236 17 Move: txtAddress
                Handle: Winfont SetFont: txtAddress

                self Start: txtCity
                83 60 236 17 Move: txtCity
                Handle: Winfont SetFont: txtCity

                self Start: txtCountry
                83 79 236 17 Move: txtCountry
                Handle: Winfont SetFont: txtCountry

                self Start: grpForthProgrammer
                28 109 270 63 Move: grpForthProgrammer
                Handle: Winfont SetFont: grpForthProgrammer
                s" Forth Programmer" SetText: grpForthProgrammer

                self Start: chkWin32Forth
                44 127 81 19 Move: chkWin32Forth
                WS_GROUP +Style: chkWin32Forth
                Handle: Winfont SetFont: chkWin32Forth
                s" Win32Forth" SetText: chkWin32Forth

                self Start: chkSwiftForth
                127 127 81 19 Move: chkSwiftForth
                Handle: Winfont SetFont: chkSwiftForth
                s" SwiftForth" SetText: chkSwiftForth

                self Start: chkOther
                210 127 81 19 Move: chkOther
                Handle: Winfont SetFont: chkOther
                s" Other" SetText: chkOther

                self Start: txtFileName
                61 184 221 18 Move: txtFileName
                Handle: Winfont SetFont: txtFileName

                self Start: btnBrowse
                289 184 62 19 Move: btnBrowse
                Handle: Winfont SetFont: btnBrowse
                s" Browse" SetText: btnBrowse

                self Start: btnOk
                40 227 119 31 Move: btnOk
                WS_GROUP +Style: btnOk
                Handle: Winfont SetFont: btnOk
                s" &Ok" SetText: btnOk

                self Start: btnCancel
                200 227 119 31 Move: btnCancel
                Handle: Winfont SetFont: btnCancel
                s" &Cancel" SetText: btnCancel

                self Start: lblFile
                16 184 42 16 Move: lblFile
                Handle: Winfont SetFont: lblFile
                SS_RIGHT +Style: lblFile
                s" File:" SetText: lblFile

                self Start: Button4
                382 23 103 23 Move: Button4
                Handle: Winfont SetFont: Button4
                s" These were" SetText: Button4

                self Start: Check4
                382 52 98 19 Move: Check4
                Handle: Winfont SetFont: Check4
                s" added after" SetText: Check4

                self Start: Radio1
                382 80 95 18 Move: Radio1
                Handle: Winfont SetFont: Radio1
                s" the demo" SetText: Radio1

                self Start: Label6
                382 114 91 17 Move: Label6
                Handle: Winfont SetFont: Label6
                s" was written" SetText: Label6

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then
                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                OnWMCommand ?dup    \ must not be zero
                if        execute
                else        2drop   \ drop ID and object address
                then        0 ;M

:M SetCommand:  ( cfa -- )  \ set OnWMCommand function
                to OnWMCommand
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop then
                \ Insert your code here
                On_Done: super
                ;M

;Object

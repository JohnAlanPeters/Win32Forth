\ CREATEPROPERTYFORM.FRM
\- textbox needs excontrols.f


:Object frmPropertyForm                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
350 285  2value XYPos  \ save screen location of form

GroupBox grpOrder
GroupBox grpOptions
Label lblName
Label lblCaption
TextBox txtName
TextBox txtCaption
CheckBox chkDefault
CheckBox chkMultiLine
CheckBox chkButtonTabs
CheckBox chkComPile
ListBox lstOrder
PushButton btnMoveup
PushButton btnMoveDown
PushButton btnTest
PushButton btnCompile
PushButton btnClipBoard
PushButton btnLoad
PushButton btnSave
PushButton btnRefresh
PushButton btnClose


:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ N.B if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Compile Property Form"
                ;M

:M StartSize:   ( -- width height )
                488 226 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
                ;M

:M WM_COMMAND   ( h m w l -- res )
                dup 0=      \ id is from a menu if lparam is zero
                if        over LOWORD CurrentMenu if dup DoMenu: CurrentMenu then
                          CurrentPopup if dup DoMenu: CurrentPopup then drop
                else	  over LOWORD ( ID ) self   \ object address on stack
                          WMCommand-Func ?dup    \ must not be zero
                          if        execute
                          else    2drop   \ drop ID and object address
                          then
                then      0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: grpOrder
                238 16 238 130 Move: grpOrder
                Handle: Winfont SetFont: grpOrder
                s" Tab Order" SetText: grpOrder

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
                s" Merge Forms to Disk File" SetText: chkComPile
                s" Compile all forms in sheet to single disk file" BInfo: chkComPile place

                self Start: lstOrder
                251 36 136 93 Move: lstOrder
                Handle: Winfont SetFont: lstOrder
                s" List showing order of forms in sheet" BInfo: lstOrder place

                self Start: btnMoveup
                399 34 70 25 Move: btnMoveup
                Handle: Winfont SetFont: btnMoveup
                s" Move Up" SetText: btnMoveup
                s" Move form up in tab order" BInfo: btnMoveup place

                self Start: btnMoveDown
                399 61 70 25 Move: btnMoveDown
                Handle: Winfont SetFont: btnMoveDown
                s" Move Down" SetText: btnMoveDown
                s" Move form down in tab order" BInfo: btnMoveDown place

                self Start: btnTest
                29 190 60 23 Move: btnTest
                WS_GROUP +Style: btnTest
                Handle: Winfont SetFont: btnTest
                s" &Test" SetText: btnTest
                s" Test the sheet obviously!" BInfo: btnTest place

                self Start: btnCompile
                91 190 60 23 Move: btnCompile
                Handle: Winfont SetFont: btnCompile
                s" Compile" SetText: btnCompile
                s" Compile property sheet and save to a disk file" BInfo: btnCompile place

                self Start: btnClipBoard
                153 190 60 23 Move: btnClipBoard
                Handle: Winfont SetFont: btnClipBoard
                s" Clip&Board" SetText: btnClipBoard
                s" Compile property sheet and copy text to the clipboard" BInfo: btnClipBoard place

                self Start: btnLoad
                215 190 60 23 Move: btnLoad
                Handle: Winfont SetFont: btnLoad
                s" Load" SetText: btnLoad
                s" Load a property sheet definition file" BInfo: btnLoad place

                self Start: btnSave
                277 190 60 23 Move: btnSave
                Handle: Winfont SetFont: btnSave
                s" Save" SetText: btnSave
                s" Save to a property sheet definition file" BInfo: btnSave place

                self Start: btnRefresh
                339 190 60 23 Move: btnRefresh
                Handle: Winfont SetFont: btnRefresh
                s" Refresh" SetText: btnRefresh
                s" Update list of forms for property sheet" BInfo: btnRefresh place

                self Start: btnClose
                401 190 60 23 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" &Close" SetText: btnClose
                s" All done!" BInfo: btnClose place

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                originx originy 2to XYPos
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

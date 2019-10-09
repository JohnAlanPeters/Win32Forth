\ CREATEMENUFORM.FRM
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

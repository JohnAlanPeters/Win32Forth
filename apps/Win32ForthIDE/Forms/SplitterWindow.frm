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

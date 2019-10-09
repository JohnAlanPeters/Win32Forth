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

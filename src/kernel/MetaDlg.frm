\ METADLG.FRM
\- textbox needs excontrols.f


:Object MetaDlg                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

GroupBox Group1
PushButton BtnOK
PushButton BtnCancel
PushButton BtnRestore
Label Label1
Label Label2
Label Label3
TextBox TxtAppMem
TextBox TxtSysMem
TextBox TxtCodeMem

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

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Win32Forth Meta Compiler"
                ;M

:M StartSize:   ( -- width height )
                440 137
                ;M

:M StartPos:    ( -- x y )
                350  175
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: Group1
                21 11 238 107 Move: Group1
                Handle: Winfont SetFont: Group1
                s" Memory size (bytes)" SetText: Group1

                self Start: BtnOK
                290 24 130 23 Move: BtnOK
                Handle: Winfont SetFont: BtnOK
                s" Build" SetText: BtnOK

                self Start: BtnCancel
                290 55 130 23 Move: BtnCancel
                Handle: Winfont SetFont: BtnCancel
                s" Cancel" SetText: BtnCancel

                self Start: BtnRestore
                290 87 130 22 Move: BtnRestore
                Handle: Winfont SetFont: BtnRestore
                s" Restore default values" SetText: BtnRestore

                self Start: Label1
                30 36 96 21 Move: Label1
                Handle: Winfont SetFont: Label1
                s" Application space :" SetText: Label1

                self Start: Label2
                30 60 92 25 Move: Label2
                Handle: Winfont SetFont: Label2
                s" System space :" SetText: Label2

                self Start: Label3
                30 81 86 18 Move: Label3
                Handle: Winfont SetFont: Label3
                s" Code space :" SetText: Label3

                self Start: TxtAppMem
                144 33 80 21 Move: TxtAppMem
                Handle: Winfont SetFont: TxtAppMem

                self Start: TxtSysMem
                144 56 80 20 Move: TxtSysMem
                Handle: Winfont SetFont: TxtSysMem

                self Start: TxtCodeMem
                144 78 80 21 Move: TxtCodeMem
                Handle: Winfont SetFont: TxtCodeMem

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
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop
                     \ reset focus to parent if we have one
                     ParentWindow: self Call SetFocus drop
                then
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

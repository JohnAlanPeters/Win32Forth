\ CHOOSEICON.FRM
\- textbox Require excontrols.f


FileOpenDialog GetIconFileDlg "Select Icon File" "Icon Files|*.ico|"
create iconfile 0 , max-path allot
false value continue?	\ continue compiling?


:Object frmGetIconFile                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
350 175  2value XYPos  \ save screen location of form

Label lblIconFile
TextBox txtIconFile
PushButton btnChoose
PushButton btnContinue
PushButton btnCancel
PushButton btnClear


: On_btnChoose   ( h m w l -- )  \ what to do when btnChoose control has been clicked
	hwnd Start: GetIconFileDlg dup c@
	if	count SetText: txtIconFile
	else	drop
	then	
; 

: On_btnContinue   ( h m w l -- )  \ what to do when btnContinue control has been clicked
true to continue?
GetText: txtIconFile -trailing iconfile place
Close: self
; 

: On_btnCancel   ( h m w l -- )  \ what to do when btnCancel control has been clicked
false to continue?
Close: self
; 

: On_btnClear   ( h m w l -- )  \ what to do when btnClear control has been clicked
s" " SetText: txtIconFile
; 

: frmDefaultCommand	( h m w l id obj -- )
                drop
                case
                    GetID: btnChoose            of On_btnChoose         endof
                    IDCONTINUE                  of On_btnContinue       endof
                    IDCANCEL                    of On_btnCancel         endof
                    GetID: btnClear             of On_btnClear          endof
                endcase    ;

: OnInitFunction      ( -- )   \ executed after form and all controls have been created
iconfile count SetText: txtIconFile
; 


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
                z" Choose Icon"
                ;M

:M StartSize:   ( -- width height )
                351 83 
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M Start:  ( -- )
                Start: Super
                Begin WinPause Hwnd 0= Until
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


                self Start: lblIconFile
                6 18 46 18 Move: lblIconFile
                Handle: Winfont SetFont: lblIconFile
                SS_RIGHT +Style: lblIconFile
                s" IconFile:" SetText: lblIconFile

                self Start: txtIconFile
                54 18 234 18 Move: txtIconFile
                Handle: Winfont SetFont: txtIconFile

                self Start: btnChoose
                291 18 27 16 Move: btnChoose
                Handle: Winfont SetFont: btnChoose
                s" ..." SetText: btnChoose

                IDCONTINUE SetID: btnContinue
                self Start: btnContinue
                86 53 82 25 Move: btnContinue
                Handle: Winfont SetFont: btnContinue
                s" Continue" SetText: btnContinue

                IDCANCEL SetID: btnCancel
                self Start: btnCancel
                170 53 82 25 Move: btnCancel
                Handle: Winfont SetFont: btnCancel
                s" Cancel" SetText: btnCancel

                self Start: btnClear
                320 18 27 16 Move: btnClear
                Handle: Winfont SetFont: btnClear
                s" C" SetText: btnClear

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then

                ['] frmDefaultCommand SetCommand: self

                OnInitFunction 

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
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

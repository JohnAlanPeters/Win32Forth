\ PLAYER4.FRM
\- textbox needs excontrols.f

PushButton PauseButton
PushButton StopButton
PushButton NextButton
PushButton BackButton
PushButton ForwardButton

:Object ControlCenter                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

PushButton Button6

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or 
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                parent
                ;M

:M SetParent:  ( hwndparent -- ) \ set owner window
                to parent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Player 4th - control center"
                ;M

:M StartSize:   ( -- width height )
                395 40 
                ;M

:M StartPos:    ( -- x y )
                150  175
                ;M

:M Close:        ( -- )
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont drop

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: PauseButton
                10 10 95 21 Move: PauseButton
                Handle: Winfont SetFont: PauseButton
                s" Pause / Resume" SetText: PauseButton

                self Start: StopButton
                110 10 95 20 Move: StopButton
                Handle: Winfont SetFont: StopButton
                s" Stop " SetText: StopButton

                self Start: NextButton
                212 10 95 20 Move: NextButton
                Handle: Winfont SetFont: NextButton
                s" Next" SetText: NextButton

                self Start: BackButton
                319 10 30 20 Move: BackButton
                Handle: Winfont SetFont: BackButton
                s" <<" SetText: BackButton

                self Start: ForwardButton
                354 10 30 20 Move: ForwardButton
                Handle: Winfont SetFont: ForwardButton
                s" >>" SetText: ForwardButton

                self Start: Button6
                336 19 43 0 Move: Button6
                Handle: Winfont SetFont: Button6
                s" Button6" SetText: Button6

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
                \ Insert your code here
                On_Done: super
                ;M

;Object

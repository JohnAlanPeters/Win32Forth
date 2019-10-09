\ SAVEPROMPT.FRM
\- textbox needs excontrols.f

Label lblSaveMsg

WM_USER 1000 + Constant IDBACKUP
0 value answer
create SavePromptMsg ," File on disk has changed. Continue?" 200 allot


:Object frmSavePrompt                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

PushButton btnYes
PushButton btnNo
PushButton btnBackup
\ Coordinates and dimensions for imgStop
10  value imgStopX
16  value imgStopY
36  value imgStopW
38  value imgStopH

StaticIcon iconStop



: On_btnYes   ( h m w l -- )  \ what to do when btnYes control has been clicked
IDYES to answer
Close: self
; 

: On_btnNo   ( h m w l -- )  \ what to do when btnNo control has been clicked
IDNO to answer
Close: self
; 

: On_btnBackup   ( h m w l -- )  \ what to do when btnBackup control has been clicked
IDBACKUP to answer
Close: self
; 

: frmDefaultCommand	( h m w l id obj -- )
                drop
                case
                    GetID: btnYes               of On_btnYes            endof
                    GetID: btnNo                of On_btnNo             endof
                    GetID: btnBackup            of On_btnBackup         endof
                endcase    ;

: OnInitFunction      ( -- )   \ executed after form and all controls have been created
0 to answer

self Start: iconStop
imgStopX imgStopY imgStopW imgStopH Move: iconStop
IDI_HAND NULL Call LoadIcon SetImage: iconStop

SavePromptMsg count SetText: lblSaveMsg
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

:M SetParentWindow:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Warning"
                ;M

:M StartSize:   ( -- width height )
                368 126 
                ;M

:M StartPos:    ( -- x y )
                350  175
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


                self Start: lblSaveMsg
                49 23 315 62 Move: lblSaveMsg
                Handle: Winfont SetFont: lblSaveMsg
                SS_CENTER +Style: lblSaveMsg
                s" File on disk has been changed. Continue?" SetText: lblSaveMsg

                self Start: btnYes
                39 93 100 25 Move: btnYes
                Handle: Winfont SetFont: btnYes
                s" Yes" SetText: btnYes

                self Start: btnNo
                141 93 100 25 Move: btnNo
                Handle: Winfont SetFont: btnNo
                s" No" SetText: btnNo

                self Start: btnBackup
                243 93 100 25 Move: btnBackup
                Handle: Winfont SetFont: btnBackup
                s" Backup First!" SetText: btnBackup

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
                ParentWindow: self   \ if modal form re-enable parent
                if   1 ParentWindow: self Call EnableWindow drop
                     \ reset focus to parent if we have one
                     ParentWindow: self Call SetFocus drop
                then
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

\ EDPROMPT.FRM
\- textbox needs excontrols.f


:Object frmPrompt                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
150 175  2value XYPos  \ save screen location of form

Label lblPrompt
Label lblReplaceString
PushButton btnYes
PushButton btnNo
PushButton btncancel
PushButton btnYesToAll


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
                z" Please confirm"
                ;M

:M StartSize:   ( -- width height )
                325 120 
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


                self Start: lblPrompt
                30 10 282 17 Move: lblPrompt
                Handle: Winfont SetFont: lblPrompt
                s" Replace this highlighted occurrence?" SetText: lblPrompt

                self Start: lblReplaceString
                30 29 282 17 Move: lblReplaceString
                Handle: Winfont SetFont: lblReplaceString
                s" " SetText: lblReplaceString

                self Start: btnYes
                21 85 68 25 Move: btnYes
                Handle: Winfont SetFont: btnYes
                s" Yes" SetText: btnYes

                self Start: btnNo
                91 85 68 25 Move: btnNo
                Handle: Winfont SetFont: btnNo
                s" No" SetText: btnNo

                self Start: btncancel
                161 85 68 25 Move: btncancel
                Handle: Winfont SetFont: btncancel
                s" Cancel" SetText: btncancel

                self Start: btnYesToAll
                231 85 68 25 Move: btnYesToAll
                Handle: Winfont SetFont: btnYesToAll
                s" Yes To All" SetText: btnYesToAll

                ParentWindow: self   \ if this is a modal form disable parent
                if   0 ParentWindow: self Call EnableWindow drop then

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

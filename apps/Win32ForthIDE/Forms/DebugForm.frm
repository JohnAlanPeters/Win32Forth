\ DEBUGFORM.FRM
\- textbox needs excontrols.f


:Object frmDebug                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

PushButton btnStep
PushButton btnInto
PushButton btnOutOf
PushButton btnSteps
PushButton btnBreak
PushButton btnRun
PushButton btnBP
PushButton btnHere
Label lblDebugging
ListBox lstWords
Label lblData
ListBox lstDStack
RadioButton radDecimal
RadioButton radHex
Label lblReturn
ListBox lstRStack
PushButton btnInquire
TextBox txtResult
PushButton btnSetBP


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                699  to id     \ set child id, changeable
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowStyle:  ( -- style )
                WS_CHILD 
                ;M

:M Start:       ( Parent -- )
                to parent
                register-child-window drop
                create-child-window to hWnd ;M 

:M WindowTitle: ( -- ztitle )
                z" Debug"
                ;M

:M StartSize:   ( -- width height )
                261 589 
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


                self Start: btnStep
                12 10 76 26 Move: btnStep
                Handle: Winfont SetFont: btnStep
                s" Single Step" SetText: btnStep
                s" execute a single step" BInfo: btnStep place

                self Start: btnInto
                90 10 76 26 Move: btnInto
                Handle: Winfont SetFont: btnInto
                s" Nest" SetText: btnInto
                s" nest into definition" BInfo: btnInto place

                self Start: btnOutOf
                168 10 76 26 Move: btnOutOf
                Handle: Winfont SetFont: btnOutOf
                s" Unnest" SetText: btnOutOf
                s" unnest from definition" BInfo: btnOutOf place

                self Start: btnSteps
                12 41 76 26 Move: btnSteps
                Handle: Winfont SetFont: btnSteps
                s" Step until key" SetText: btnSteps
                s" run continuous till key press" BInfo: btnSteps place

                self Start: btnBreak
                90 41 153 26 Move: btnBreak
                Handle: Winfont SetFont: btnBreak
                s" Skip next branch word" SetText: btnBreak
                s" Jump over next Word" BInfo: btnBreak place

                self Start: btnRun
                12 72 76 26 Move: btnRun
                Handle: Winfont SetFont: btnRun
                s" Run" SetText: btnRun
                s" done, run the program" BInfo: btnRun place

                self Start: btnBP
                90 72 76 26 Move: btnBP
                Handle: Winfont SetFont: btnBP
                s" Restart BP" SetText: btnBP
                s" proceed to definition again" BInfo: btnBP place

                self Start: btnHere
                168 72 76 26 Move: btnHere
                Handle: Winfont SetFont: btnHere
                s" Break here" SetText: btnHere
                s" stop here next time" BInfo: btnHere place

                self Start: lblDebugging
                8 106 241 19 Move: lblDebugging
                Handle: Winfont SetFont: lblDebugging
                s" " SetText: lblDebugging

                self Start: lstWords
                3 135 250 80 Move: lstWords
                Handle: Winfont SetFont: lstWords

                self Start: lblData
                6 228 68 16 Move: lblData
                Handle: Winfont SetFont: lblData
                s" Data Stack" SetText: lblData

                self Start: lstDStack
                6 250 173 113 Move: lstDStack
                Handle: Winfont SetFont: lstDStack

                self Start: radDecimal
                181 250 64 23 Move: radDecimal
                Handle: Winfont SetFont: radDecimal
                s" Decimal" SetText: radDecimal

                self Start: radHex
                181 275 64 25 Move: radHex
                Handle: Winfont SetFont: radHex
                s" Hex" SetText: radHex

                self Start: lblReturn
                6 378 76 16 Move: lblReturn
                Handle: Winfont SetFont: lblReturn
                s" Return Stack" SetText: lblReturn

                self Start: lstRStack
                6 400 248 121 Move: lstRStack
                Handle: Winfont SetFont: lstRStack

                self Start: btnInquire
                6 527 67 26 Move: btnInquire
                Handle: Winfont SetFont: btnInquire
                s" Data Inquire" SetText: btnInquire
                s" inquire for the value of a data item" BInfo: btnInquire place

                self Start: txtResult
                79 527 175 26 Move: txtResult
                Handle: Winfont SetFont: txtResult

                self Start: btnSetBP
                6 560 250 26 Move: btnSetBP
                Handle: Winfont SetFont: btnSetBP
                s" Set Break Point" SetText: btnSetBP

                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

\ IDEFORM.FRM
\- textbox needs excontrols.f

CheckBox chkAutoSession
CheckBox chkProject
CheckBox chkFile
CheckBox chkDirectory
CheckBox chkVocabulary
CheckBox chkClass
CheckBox chkForm
CheckBox chkDebug

:Object frmIDE                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpVisibleTabs


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                717  to id     \ set child id, changeable
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
                z" IDE"
                ;M

:M StartSize:   ( -- width height )
                218 277 
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


                self Start: chkAutoSession
                16 10 155 24 Move: chkAutoSession
                Handle: Winfont SetFont: chkAutoSession
                s" Auto Save/Restore Session" SetText: chkAutoSession

                self Start: chkProject
                16 60 155 27 Move: chkProject
                Handle: Winfont SetFont: chkProject
                s" Project Tab" SetText: chkProject

                self Start: chkFile
                16 89 155 25 Move: chkFile
                Handle: Winfont SetFont: chkFile
                s" File Tab" SetText: chkFile

                self Start: chkDirectory
                16 116 155 25 Move: chkDirectory
                Handle: Winfont SetFont: chkDirectory
                s" Directory Tab" SetText: chkDirectory

                self Start: chkVocabulary
                16 143 155 25 Move: chkVocabulary
                Handle: Winfont SetFont: chkVocabulary
                s" Vocabulary Tab" SetText: chkVocabulary

                self Start: chkClass
                16 170 155 25 Move: chkClass
                Handle: Winfont SetFont: chkClass
                s" Class Tab" SetText: chkClass

                self Start: chkForm
                16 197 155 25 Move: chkForm
                Handle: Winfont SetFont: chkForm
                s" Form Tab" SetText: chkForm

                self Start: chkDebug
                16 224 155 25 Move: chkDebug
                Handle: Winfont SetFont: chkDebug
                s" Debug Tab" SetText: chkDebug

                self Start: grpVisibleTabs
                5 47 196 216 Move: grpVisibleTabs
                Handle: Winfont SetFont: grpVisibleTabs
                s" Visible Tabs" SetText: grpVisibleTabs

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

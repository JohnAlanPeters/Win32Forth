\ EDITORFORM.FRM
\- textbox needs excontrols.f

PushButton btnForeground
PushButton btnBackground
PushButton btnCurrentline
PushButton btnSelectFore
PushButton btnSelectBack
PushButton btnBrowseFore
PushButton btnBrowseBack
PushButton btnPreview
\ Coordinates and dimensions for foreChild
130  value foreChildX
30  value foreChildY
34  value foreChildW
25  value foreChildH
\ Coordinates and dimensions for BackChild
130  value BackChildX
58  value BackChildY
34  value BackChildW
25  value BackChildH
\ Coordinates and dimensions for CurrentChild
130  value CurrentChildX
86  value CurrentChildY
34  value CurrentChildW
25  value CurrentChildH
\ Coordinates and dimensions for SelForeChild
130  value SelForeChildX
114  value SelForeChildY
34  value SelForeChildW
25  value SelForeChildH
\ Coordinates and dimensions for SelBackChild
130  value SelBackChildX
142  value SelBackChildY
34  value SelBackChildW
25  value SelBackChildH
CheckBox chkAutoIndent
CheckBox chkShowTabs
CheckBox chkAutoDetect
CheckBox chkVirtual
CheckBox chkMultiSelect
PushButton btnFont
\ Coordinates and dimensions for BrowseForeChild
130  value BrowseForeChildX
170  value BrowseForeChildY
34  value BrowseForeChildW
25  value BrowseForeChildH
\ Coordinates and dimensions for BrowsebackChild
130  value BrowsebackChildX
198  value BrowsebackChildY
34  value BrowsebackChildW
25  value BrowsebackChildH

:Object frmEditor                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpEditorOptions
GroupBox grpColors


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                716  to id     \ set child id, changeable
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
                z" Editor"
                ;M

:M StartSize:   ( -- width height )
                409 279 
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


                self Start: grpEditorOptions
                191 16 183 197 Move: grpEditorOptions
                Handle: Winfont SetFont: grpEditorOptions
                s" Options" SetText: grpEditorOptions

                self Start: grpColors
                16 14 162 246 Move: grpColors
                Handle: Winfont SetFont: grpColors
                s" Colors" SetText: grpColors

                self Start: btnForeground
                28 30 100 26 Move: btnForeground
                Handle: Winfont SetFont: btnForeground
                s" ForeGround" SetText: btnForeground

                self Start: btnBackground
                28 58 100 26 Move: btnBackground
                Handle: Winfont SetFont: btnBackground
                s" BackGround" SetText: btnBackground

                self Start: btnCurrentline
                28 86 100 26 Move: btnCurrentline
                Handle: Winfont SetFont: btnCurrentline
                s" Current Line" SetText: btnCurrentline

                self Start: btnSelectFore
                28 114 100 26 Move: btnSelectFore
                Handle: Winfont SetFont: btnSelectFore
                s" Select Foreground" SetText: btnSelectFore

                self Start: btnSelectBack
                28 142 100 26 Move: btnSelectBack
                Handle: Winfont SetFont: btnSelectBack
                s" Select Background" SetText: btnSelectBack

                self Start: btnBrowseFore
                28 170 100 26 Move: btnBrowseFore
                Handle: Winfont SetFont: btnBrowseFore
                s" Browse Foreground" SetText: btnBrowseFore

                self Start: btnBrowseBack
                28 198 100 26 Move: btnBrowseBack
                Handle: Winfont SetFont: btnBrowseBack
                s" Browse Background" SetText: btnBrowseBack

                self Start: btnPreview
                28 232 100 25 Move: btnPreview
                Handle: Winfont SetFont: btnPreview
                s" Preview" SetText: btnPreview

                self Start: chkAutoIndent
                203 32 160 25 Move: chkAutoIndent
                Handle: Winfont SetFont: chkAutoIndent
                s" AutoIndent" SetText: chkAutoIndent

                self Start: chkShowTabs
                203 59 160 25 Move: chkShowTabs
                Handle: Winfont SetFont: chkShowTabs
                s" Show Tabs" SetText: chkShowTabs

                self Start: chkAutoDetect
                203 86 160 25 Move: chkAutoDetect
                Handle: Winfont SetFont: chkAutoDetect
                s" Auto detect disk file changes" SetText: chkAutoDetect
                s" Option to update active file if it has been changed on disk" BInfo: chkAutoDetect place

                self Start: chkVirtual
                203 113 160 25 Move: chkVirtual
                Handle: Winfont SetFont: chkVirtual
                s" Allow caret beyond end of line" SetText: chkVirtual
                s" Set to allow caret to be positioned anywhere in document" BInfo: chkVirtual place

                self Start: chkMultiSelect
                203 140 160 25 Move: chkMultiSelect
                Handle: Winfont SetFont: chkMultiSelect
                s" Multiple text selections" SetText: chkMultiSelect
                s" Use ctrl key and drag to select multiple text" BInfo: chkMultiSelect place

                self Start: btnFont
                203 185 166 22 Move: btnFont
                Handle: Winfont SetFont: btnFont
                s" Text Font:" SetText: btnFont
                s" Select text font for all editor windows" BInfo: btnFont place

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

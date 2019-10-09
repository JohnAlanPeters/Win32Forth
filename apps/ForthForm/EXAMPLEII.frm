\ EXAMPLE.FRM
\- textbox needs excontrols.f
\- -filelister.f needs filelister.f   \ folder browser

FileWindow dirbox
TextBox txtpath
PushButton btnDelete
PushButton btnChoose
PushButton btnClose
ComboListBox CmbLstFilters

:Object frmExample                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
StatusBar TheStatusBar

Label lblPath

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
                z" Example - Directory Viewer"
                ;M

:M StartSize:   ( -- width height )
                345 455 
                ;M

:M StartPos:    ( -- x y )
                150  175
                ;M

:M Close:        ( -- )
                Close: dirbox
                \ Insert your code here
                Close: super
                ;M

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                self Start: TheStatusBar


                self Start: dirbox
                8 37 225 358 Move: dirbox

                self Start: lblPath
                9 9 72 19 Move: lblPath
                Handle: Winfont SetFont: lblPath
                s" Selected Path:" SetText: lblPath

                self Start: txtpath
                83 9 247 21 Move: txtpath
                Handle: Winfont SetFont: txtpath

                self Start: btnDelete
                239 40 100 25 Move: btnDelete
                Handle: Winfont SetFont: btnDelete
                s" &Delete File" SetText: btnDelete

                self Start: btnChoose
                239 69 100 25 Move: btnChoose
                Handle: Winfont SetFont: btnChoose
                s" Choose &Folder" SetText: btnChoose

                self Start: btnClose
                239 364 100 25 Move: btnClose
                Handle: Winfont SetFont: btnClose
                s" &Close" SetText: btnClose

                self Start: CmbLstFilters
                8 401 224 20 Move: CmbLstFilters
                Handle: Winfont SetFont: CmbLstFilters

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

:M On_Size:      ( -- )
                Redraw: TheStatusBar
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here
                On_Done: super
                ;M

;Object

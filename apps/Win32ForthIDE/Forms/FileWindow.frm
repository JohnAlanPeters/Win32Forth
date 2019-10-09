\ FILEWINDOW.FRM
\- textbox needs excontrols.f
needs folderview.f   \ folder browser

\ Coordinates and dimensions for imgButton1
9 value imgButton1X
4 value imgButton1Y
24 value imgButton1W
22 value imgButton1H
\ Coordinates and dimensions for ImgButton2
43 value ImgButton2X
4 value ImgButton2Y
24 value ImgButton2W
22 value ImgButton2H
\ Coordinates and dimensions for ImgButton3
77 value ImgButton3X
4 value ImgButton3Y
24 value ImgButton3W
22 value ImgButton3H
\ Coordinates and dimensions for ImgButton4
111 value ImgButton4X
4 value ImgButton4Y
24 value ImgButton4W
22 value ImgButton4H
\ Coordinates and dimensions for ImgButton5
145 value ImgButton5X
4 value ImgButton5Y
24 value ImgButton5W
22 value ImgButton5H
ComboListBox cmblstPathPicker
FolderViewer TheDirectory
ComboListBox CmbLstFilters

:Object frmFileWindow                <Super Child-Window

Font WinFont
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                384 to id     \ set child id, changeable
                \ Insert your code here
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowTitle: ( -- ztitle )
                z" Select File"
                ;M

:M StartSize:   ( -- width height )
                184 449
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

                self Start: TheDirectory
                2 50 180 371 Move: TheDirectory
                CS_DBLCLKS GCL_STYLE GetHandle: TheDirectory  Call SetClassLong  drop
                WS_CLIPSIBLINGS +Style: TheDirectory
\                LVS_LIST SetView: TheDirectory

                self Start: CmbLstFilters
                2 423 180 23 Move: CmbLstFilters
                Handle: Winfont SetFont: CmbLstFilters
                WS_CLIPSIBLINGS +Style: CmbLstFilters

                self Start: cmblstPathPicker
                2 30 180 17 Move: cmblstPathPicker
                Handle: Winfont SetFont: cmblstPathPicker
                WS_CLIPSIBLINGS +Style: cmblstPathPicker

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

:M WndClassStyle: ( -- style )
                \ CS_DBLCLKS only to prevent flicker in window on sizing.
                CS_DBLCLKS ;M

;Object

\- textbox needs excontrols.f


:Object Form_search_path                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 
\ 0 value hWndParent   \ window handle of the parent of form

TextBox tb1
TextBox tb2
TextBox tb3
TextBox tb4
TextBox tb5
TextBox tb6
TextBox tb7
PushButton bt1
PushButton bt2
PushButton bt3
PushButton bt4
PushButton bt5
PushButton bt6
PushButton bt7
PushButton btOk
PushButton btCancel

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

:M SetParent:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Setup search path"
                ;M

:M StartSize:   ( -- width height )
                288 233 
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


                self Start: tb1
                30 20 200 23 Move: tb1
                Handle: Winfont SetFont: tb1
                WS_CHILD WindowStyle: tb1

                self Start: tb2
                30 42 200 23 Move: tb2
                Handle: Winfont SetFont: tb2
                WS_CHILD WindowStyle: tb1

                self Start: tb3
                30 63 200 23 Move: tb3
                Handle: Winfont SetFont: tb3

                self Start: tb4
                30 83 200 25 Move: tb4
                Handle: Winfont SetFont: tb4

                self Start: tb5
                30 106 200 23 Move: tb5
                Handle: Winfont SetFont: tb5

                self Start: tb6
                30 127 200 23 Move: tb6
                Handle: Winfont SetFont: tb6

                self Start: tb7
                30 149 200 23 Move: tb7
                Handle: Winfont SetFont: tb7

                self Start: bt1
                231 22 30 20 Move: bt1
                Handle: Winfont SetFont: bt1
                s" ......." SetText: bt1

                self Start: bt2
                231 44 30 20 Move: bt2
                Handle: Winfont SetFont: bt2
                s" ......." SetText: bt2

                self Start: bt3
                231 65 30 20 Move: bt3
                Handle: Winfont SetFont: bt3
                s" ......." SetText: bt3

                self Start: bt4
                231 86 30 20 Move: bt4
                Handle: Winfont SetFont: bt4
                s" ......." SetText: bt4

                self Start: bt5
                231 108 30 20 Move: bt5
                Handle: Winfont SetFont: bt5
                s" ......." SetText: bt5

                self Start: bt6
                231 130 30 20 Move: bt6
                Handle: Winfont SetFont: bt6
                s" ......." SetText: bt6

                self Start: bt7
                231 151 30 20 Move: bt7
                Handle: Winfont SetFont: bt7
                s" ......." SetText: bt7

                self Start: btOk
                40 190 100 25 Move: btOk
                Handle: Winfont SetFont: btOk
                s" OK" SetText: btOk

                self Start: btCancel
                150 190 100 25 Move: btCancel
                Handle: Winfont SetFont: btCancel
                s" Cancel" SetText: btCancel

                CatalogPath first-path" SetText: tb1
                CatalogPath next-path"  SetText: tb2
                CatalogPath next-path"  SetText: tb3
                CatalogPath next-path"  SetText: tb4
                CatalogPath next-path"  SetText: tb5
                CatalogPath next-path"  SetText: tb6
                CatalogPath next-path"  SetText: tb7
                ;M

: AskFolder ( - adr cnt )
        z" Add to search path:"
        temp$ GetHandle: self  BrowseForFolder
        temp$ dup +null count
 ;

: AddToPath  ( str cnt - )
   dup 0>
        if      CatalogPath "path+
        else    2drop
        then
 ;

: SaveSearchPath ( -- )
   CatalogPath  off
   GetText: tb1 AddToPath
   GetText: tb2 AddToPath
   GetText: tb3 AddToPath
   GetText: tb4 AddToPath
   GetText: tb5 AddToPath
   GetText: tb6 AddToPath
   GetText: tb7 AddToPath
   Close: Self
 ;

: HandleButtons  ( Action/Button - )
            case
                GetId: bt1      of      AskFolder SetText: tb1  endof
                GetId: bt2      of      AskFolder SetText: tb2  endof
                GetId: bt3      of      AskFolder SetText: tb3  endof
                GetId: bt4      of      AskFolder SetText: tb4  endof
                GetId: bt5      of      AskFolder SetText: tb5  endof
                GetId: bt6      of      AskFolder SetText: tb6  endof
                GetId: bt7      of      AskFolder SetText: tb7  endof
                GetId: btOk     of      SaveSearchPath          endof
                GetId: btCancel of      Close: Self             endof
            endcase
 ;

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID ) self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute drop HandleButtons
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

\s

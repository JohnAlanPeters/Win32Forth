\ Define object to allow changing the tab order of controls in a form

:Object TabForm                <Super DialogWindow

Font WinFont
ListBox TabList
BitmapButton UpButton
BitmapButton DownButton
PushButton OkButton
PushButton CancelButton
0 value changed?
0 value controllist
0 value #controls
0 value upbitmap
0 value downbitmap
0 value tActiveForm
106 75  2value XYPos

load-bitmap scrlup "scrlup.bmp"
load-bitmap scrldn "scrldown.bmp"

\ The controls will be ordered in a temporary buffer. This buffer will then
\ be written back to the control list .

: listbuffer    ( -- addr )     \ temp buffer for controls
                here 200 + ;

: memswap       ( n1 n2 -- ) \ swap contents of listbuffer pointed to by indices n1, n2
                listbuffer +cells >r
                listbuffer +cells dup @         ( addr*n1 [addr*n1] )
                r@ @ -rot r> ! ! ;

: InitTabList     ( -- ) \ load controls into listbuffer, display in controls in list
                Clear: TabList    \ reset
                #controls 1+ 1          \ not zero based
                do      i >Link#: ControlList
                        Data@: ControlList dup
                        GetName: [ ] asciiz AddString: TabList
                        listbuffer i 1- cells+ !        \ init buffer
                loop    0 SetSelection: TabList
                false to changed? ;     \ marked as not modified

: UpTabList       ( -- )  \ shift one up in list
                GetCurrent: TabList ?dup      \ if not the first selection
                if      dup>r GetString: TabList
                        r@    DeleteString: TabList
                        r@ dup 1- memswap       \ order listbuffer
                        asciiz r> 1- 0max dup>r
                              InsertString: TabList
                        r>    SetSelection: TabList
                        true to changed?        \ marked as modified
                then    ;

: DownTabList     { \ cursel cnt -- }   \ shift one down in list
                GetCurrent: TabList to cursel GetCount: TabList to cnt
                cursel cnt 1- 0max <>   \ if not at end of list
                if      cursel GetString: TabList
                        cursel DeleteString: TabList
                        cursel dup 1+ memswap           \ order listbuffer
                        asciiz cursel 1+ cnt 1- min dup>r
                               InsertString: TabList
                        r>     SetSelection: TabList
                        true to changed?
                then    ;

: UpdateList    ( -- )  \ save changes in listbuffer to control list
                #controls 1+ 1
                do      i >Link#: ControlList
                        listbuffer i 1- cells+ @ Data!: ControlList
                loop    ( Paint: ActiveForm ) ;

:M ClassInit:   ( -- )
                ClassInit: super
\                s" Courier New Bold" SetFaceName: WinFont
                ;M

:M WindowStyle: ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

:M WindowTitle: ( -- ztitle )
                z" Change Tab Order"
                ;M

:M StartSize:   ( -- width height )
                295 216
                ;M

:M StartPos:    ( -- x y )
                XYPos
                ;M

:M ParentWindow: ( -- hwnd )
                GetHandle: MainWindow
                ;M

:M On_Init:     ( -- )
                Call InitCommonControls drop

                Create: WinFont drop

                scrlup usebitmap   \ create bitmap handle
                GetDc: self dup>r CreateDIBitmap to upbitmap
                scrldn usebitmap
                r@ CreateDIBitmap to downbitmap
                r> ReleaseDc: self

                ControlList: ActiveForm to ControlList
                #Controls: ActiveForm to #controls
                ActiveForm to tActiveForm

                self                   Start: TabList
                28 11 143 189           Move: TabList
                Handle: Winfont      SetFont: TabList
                InitTabList

                self                    Start: UpButton
                180 12 32 32             Move: UpButton
                upbitmap SetBitmap: UpButton
                s" Move selection up in list" ToolString: UpButton

                self                    Start: DownButton
                180 72 32 32             Move: DownButton
                downbitmap SetBitmap: DownButton
                s" Move selection down in list" ToolString: DownButton

                IDOK                    SetID: OkButton
                self                    Start: OkButton
                180 130 100 34           Move: OkButton
                Handle: Winfont       SetFont: OkButton
                s" &Ok"               SetText: OkButton

                IDCANCEL                SetID: CancelButton
                self                    Start: CancelButton
                180 170 100 34           Move: CancelButton
                Handle: Winfont       SetFont: CancelButton
                s" &Cancel"           SetText: CancelButton
                0 GetHandle: tActiveform call EnableWindow drop  \ disable parent
                ;M

:M Close:        ( -- )
                changed?
                if      UpdateList
                        IsModified: tActiveForm
                        RefreshCodeWindow
                then    Close: super
                ;M

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID )
                case
                        GetId: UpButton      of  UpTabList    endof
                        GetId: DownButton    of  DownTabList  endof
                        IDOK                 of  Close: self  endof
                        IDCANCEL             of  Close: super endof
                endcase
                0 ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self FormColor FillArea: dc
                ;M

:M On_Done:     ( -- )
                Delete: WinFont
                originx originy 2to XYPos   \ save screen location
                1 GetHandle: tActiveForm call EnableWindow drop  \ re-enable parent
\                SetFocus: MainWindow
                upbitmap ?dup
                if      Call DeleteObject drop
                        0 to upbitmap
                then    downbitmap ?dup
                if      Call DeleteObject drop
                        0 to downbitmap
                then    On_Done: super
                ;M


;Object

: TabOrder      ( -- )
                GetHandle: TabForm ?exit   \ already open
                ActiveForm 0= ?exit
                #Controls: ActiveForm 0= ?exit
                Start: TabForm ; IDM_FORM_TabOrder SetCommand
\s

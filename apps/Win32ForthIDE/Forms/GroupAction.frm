\ GROUPACTION.FRM
\- textbox needs excontrols.f


:Object frmGroupAction                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

GroupBox grpMove
GroupBox grpArrange
GroupBox grpSize
GroupBox grpAlign
PushButton btnLeft
PushButton btnRight
PushButton btnTop
PushButton btnBottom
PushButton btnHorizontal
PushButton btnVertical
PushButton btnTallest
PushButton btnShortest
PushButton btnWidest
PushButton btnNarrowest
PushButton btnToBox
TextBox txtValue
GroupRadioButton radPosition
RadioButton radHeight
RadioButton radWidth
\ Coordinates and dimensions for imgbtnUp
56  value imgbtnUpX
141  value imgbtnUpY
32  value imgbtnUpW
32  value imgbtnUpH
\ Coordinates and dimensions for imgbtnRight
96  value imgbtnRightX
172  value imgbtnRightY
32  value imgbtnRightW
32  value imgbtnRightH
\ Coordinates and dimensions for imgbtnDown
56  value imgbtnDownX
200  value imgbtnDownY
32  value imgbtnDownW
32  value imgbtnDownH
\ Coordinates and dimensions for imgbtnLeft
16  value imgbtnLeftX
172  value imgbtnLeftY
32  value imgbtnLeftW
32  value imgbtnLeftH

:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                416  to id     \ set child id, changeable
                \ Insert your code here
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
                z" Select Action"
                ;M

:M StartSize:   ( -- width height )
                210 253 
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


                self Start: grpMove
                10 128 195 115 Move: grpMove
                Handle: Winfont SetFont: grpMove
                s" Adjust Position/Size" SetText: grpMove

                self Start: grpArrange
                10 68 79 58 Move: grpArrange
                Handle: Winfont SetFont: grpArrange
                s" Arrange" SetText: grpArrange

                self Start: grpSize
                123 6 79 117 Move: grpSize
                Handle: Winfont SetFont: grpSize
                s" Size to" SetText: grpSize

                self Start: grpAlign
                10 6 108 62 Move: grpAlign
                Handle: Winfont SetFont: grpAlign
                s" Align to box" SetText: grpAlign

                self Start: btnLeft
                15 20 47 19 Move: btnLeft
                Handle: Winfont SetFont: btnLeft
                s" &Left" SetText: btnLeft

                self Start: btnRight
                64 20 47 19 Move: btnRight
                Handle: Winfont SetFont: btnRight
                s" &Right" SetText: btnRight

                self Start: btnTop
                15 41 47 19 Move: btnTop
                Handle: Winfont SetFont: btnTop
                s" &Top" SetText: btnTop

                self Start: btnBottom
                64 41 47 19 Move: btnBottom
                Handle: Winfont SetFont: btnBottom
                s" &Bottom" SetText: btnBottom

                self Start: btnHorizontal
                15 83 66 17 Move: btnHorizontal
                Handle: Winfont SetFont: btnHorizontal
                s" &Horizontally" SetText: btnHorizontal

                self Start: btnVertical
                15 102 66 17 Move: btnVertical
                Handle: Winfont SetFont: btnVertical
                s" &Vertically" SetText: btnVertical

                self Start: btnTallest
                127 20 66 17 Move: btnTallest
                Handle: Winfont SetFont: btnTallest
                s" Ta&llest" SetText: btnTallest

                self Start: btnShortest
                127 39 66 19 Move: btnShortest
                Handle: Winfont SetFont: btnShortest
                s" &Shortest" SetText: btnShortest

                self Start: btnWidest
                127 60 66 17 Move: btnWidest
                Handle: Winfont SetFont: btnWidest
                s" &Widest" SetText: btnWidest

                self Start: btnNarrowest
                127 79 66 19 Move: btnNarrowest
                Handle: Winfont SetFont: btnNarrowest
                s" &Narrowest" SetText: btnNarrowest

                self Start: btnToBox
                127 100 66 17 Move: btnToBox
                Handle: Winfont SetFont: btnToBox
                s" To Bo&x" SetText: btnToBox

                self Start: txtValue
                50 176 44 21 Move: txtValue
                Handle: Winfont SetFont: txtValue

                self Start: radPosition
                137 148 62 19 Move: radPosition
                Handle: Winfont SetFont: radPosition
                s" Position" SetText: radPosition

                self Start: radHeight
                137 169 62 19 Move: radHeight
                Handle: Winfont SetFont: radHeight
                s" Height" SetText: radHeight

                self Start: radWidth
                137 189 62 19 Move: radWidth
                Handle: Winfont SetFont: radWidth
                s" Width" SetText: radWidth

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

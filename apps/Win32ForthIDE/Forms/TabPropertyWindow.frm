\ TABPROPERTYWINDOW.FRM
\- textbox needs excontrols.f


:Object frmPropertiesWindow                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color 

TabControl TabProperties
\ Coordinates and dimensions for btnApply
22  value btnApplyX
343  value btnApplyY
108  value btnApplyW
40  value btnApplyH
\ Coordinates and dimensions for btnClose
132  value btnCloseX
343  value btnCloseY
108  value btnCloseW
40  value btnCloseH


:M ClassInit:   ( -- )
                ClassInit: super
                +dialoglist  \ allow handling of dialog messages
                677  to id     \ set child id, changeable
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M Display:     ( -- ) \ unhide the child window
                SW_SHOWNORMAL Show: self ;M

:M Hide:        ( -- )   \ hide the...aughhh but you know that!
                SW_HIDE Show: self ;M

:M WindowTitle: ( -- ztitle )
                z" Properties+"
                ;M

:M StartSize:   ( -- width height )
                265 389 
                ;M

:M WM_NOTIFY  ( h m w l -- f )
\ N.B if this form has more than one tab control this handler will need to be modified
                Handle_Notify: TabProperties
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
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

:M On_Init:     ( -- )
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont 

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor


                self Start: TabProperties
                4 3 258 335 Move: TabProperties
                Handle: Winfont SetFont: TabProperties

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

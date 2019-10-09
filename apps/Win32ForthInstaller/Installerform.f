Anew Installerform.f

\- textbox Require excontrols.f

0 value IdOnClose

string: TitleInstallForm
s" Warning: OVERWRITING a previous Win32Forth installation." TitleInstallForm place

0 value LinksOnDesktop-
0 value LinksInMenu-


:Object InstallForm                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

PushButton Button1
PushButton Button2
GroupBox Group1
CheckBox Check1
CheckBox Check2
Label Label1


:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M WindowStyle:  ( -- style )
                 WS_DLGFRAME
                ;M

\ N.B if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                TitleInstallForm dup +null 1+
                ;M

:M StartSize:   ( -- width height )
                480 263
                ;M

:M StartPos:    ( -- x y )
                CenterWindow: Self
                ;M

:M Close:        ( -- )
                \ Insert your code here, e.g any data entered in form that needs to be saved
                Close: super
                ;M

: HandleId  ( Id - )
                IsButtonChecked?: Check1 to LinksOnDesktop-
                IsButtonChecked?: Check2 to LinksInMenu-
                to IdOnClose
                close: Self ;

: HandleButtons  ( Action/Button - )
            case
                IDOK     of IDOK     HandleId endof
                IDcancel of IDcancel HandleId endof
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

:M On_Init:     ( -- )
                On_Init: Super
                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                IDOK SetID: Button1
                self Start: Button1
                130 210 100 25 Move: Button1
                Handle: Winfont SetFont: Button1
                s" Yes" SetText: Button1

                IDCANCEL SetID: Button2
                self Start: Button2
                240 210 100 25 Move: Button2
                Handle: Winfont SetFont: Button2
                s" No" SetText: Button2

                self Start: Check1
                150 60 210 27 Move: Check1
                true Check: Check1
                Handle: Winfont SetFont: Check1
                s" Add shorcuts on the desktop" SetText: Check1

                self Start: Check2
                150 100 210 28 Move: Check2
                Handle: Winfont SetFont: Check2
                s" Add shortcuts to the Start menu" SetText: Check2
                win8 winver =
                    if    false Check: Check2  Disable: Check2
                    else  true  Check: Check2
                    then

                self Start: Group1
                131 27 212 111 Move: Group1
                Handle: Winfont SetFont: Group1
                s" Options" SetText: Group1

                self Start: Label1
                149 160 220 44 Move: Label1
                Handle: Winfont SetFont: Label1
                s" Would you like to install Win32Forth?" SetText: Label1

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

\s

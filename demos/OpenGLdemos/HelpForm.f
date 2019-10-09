\ Helpform.f

\- textbox needs excontrols.f

aNew -Helpform.f

: $|  ( -<line>- )
    0 temp$ !
    source 3 /string temp$ +place
    crlf$ count temp$  +place
    here temp$ c@ allot
    temp$ 1+ swap temp$ c@ cmove
    (source) @ >IN !
 ; immediate

: :long$ create  -1 ,
     does> lcount
 ; immediate

: ;long$  ( - )
  here last @ name> cell+ dup>r - r> ! \ Store the lcount
  0 ,                                  \ Add a zero
 ;

0 value zHelpText$

: zHelpText  ( adr cnt - )
   drop to zHelpText$
 ;

:Object HelpForm                <Super DialogWindow

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

\ Font setting definitions
Font MText1-font
: Set-MText1-font ( -- )
                -14          Height: MText1-font
                0             Width: MText1-font
                0        Escapement: MText1-font
                0       Orientation: MText1-font
                400          Weight: MText1-font
                0           CharSet: MText1-font
                3      OutPrecision: MText1-font
                2     ClipPrecision: MText1-font
                1           Quality: MText1-font
                49   PitchAndFamily: MText1-font
                s" Courier New" SetFacename: MText1-font ;

MultiLineTextBox MText1
PushButton btOK


:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here, e.g initialize variables, values etc.
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW WS_DLGFRAME or
                ;M

\ N.B if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                z" Help"
                ;M

:M StartSize:   ( -- width height )
                611 490

                ;M

:M StartPos:    ( -- x y )
                 CenterWindow: Self swap width 2/ + 60 + swap 14 +
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

: FormAction  { id obj -- }
   id IDOK = if  close: Self then
;

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Init:     ( -- )
              \  On_Init: Super
                ['] FormAction SetCommand: self

                s" MS Sans Serif" SetFaceName: WinFont
                8 Width: WinFont
                Create: WinFont

                \ set form color to system color
                COLOR_BTNFACE Call GetSysColor NewColor: FrmColor

                1000 SetTextLimit: MText1
                self Start: MText1
                30 32 556 383 Move: MText1
                Set-MText1-font
                Create: MText1-font
                Handle: MText1-font SetFont: MText1
                zHelpText$  SetTextZ: MText1

                true ReadOnly: MText1
                10 5 SetMargins: MText1

                IDOK SetID: btOK
                self Start: btOK
                253 440 100 25 Move: btOK
                Handle: Winfont SetFont: btOK
                s" OK" SetText: btOK
                ;M

:M start:       ( -- )
                start: Super
                ;M


:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M On_Done:    ( -- )
                Delete: WinFont
                Delete: MText1-font
                \ Insert your code here, e.g delete fonts, any bitmaps etc.
                On_Done: super
                ;M

;Object

: ShowHelp ( zHelpText cnt - )
   zHelpText close: HelpForm start: HelpForm
 ;

\s Use:

:long$ InitialText$
$| zHelpText$ has not been set.
$| Use zHelpText first.
$| zHelpText expects a long counted 0 terminated string.
  ;long$

InitialText$ zHelpText

 start: HelpForm abort \ Activate this line for a demo.
\s


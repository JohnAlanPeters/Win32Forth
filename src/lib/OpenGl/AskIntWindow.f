Anew -AskIntWindow.f

\- textbox needs excontrols.f


:Object AskIntWindow                <Super Child-Window

Font WinFont           \ default font
' 2drop value WmCommand-Func   \ function pointer for WM_COMMAND
ColorObject FrmColor      \ the background color

Label Lbl_txt
SpinnerControl Spinner1
PushButton Bt_ok
PushButton BT_Cancel
int CFA-OK
int StartValue
maxstring bytes title$
100 constant IDspinner1

:M ClassInit:   ( -- )
                ClassInit: super
                \ Insert your code here
                ;M

:M WindowStyle:  ( -- style )
                WS_POPUPWINDOW  WS_DLGFRAME  or
                ;M

\ if this form is a modal form a non-zero parent must be set
:M ParentWindow:  ( -- hwndparent | 0 if no parent )
                hWndParent
                ;M

:M SetParent:  ( hwndparent -- ) \ set owner window
                to hWndParent
                ;M

:M WindowTitle: ( -- ztitle )
                title$ +null  title$ 1+
                ;M

:M StartSize:   ( -- width height )
                300 130
                ;M

:M StartPos:    ( -- x y )
                CenterWindow: Self
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


                self Start: Lbl_txt
                20 20 109 22 Move: Lbl_txt
                Handle: Winfont SetFont: Lbl_txt
                s" The new value is:" SetText: Lbl_txt

                IDspinner1 SetID: Spinner1
                self Start: Spinner1
                141 20 96 22 Move: Spinner1
                SetDecimal: Spinner1
                0 32767  SetRange: Spinner1  \ Minimum and maximum range.
                StartValue SetValue: Spinner1        \ Starting value
                Handle: Winfont SetFont: Spinner1

                IDOK SetID: Bt_ok
                self Start: Bt_ok
                20 60 100 25 Move: Bt_ok
                Handle: Winfont SetFont: Bt_ok
                s" Ok" SetText: Bt_ok

                IDcancel SetID: BT_Cancel
                self Start: BT_Cancel
                140 60 100 25 Move: BT_Cancel
                Handle: Winfont SetFont: BT_Cancel
                s" Cancel" SetText: BT_Cancel
                ;M

: HandleButtons  ( Action/Button - )
            case
                IDOK     of GetValue: Spinner1 close: Self CFA-OK execute endof
                IDcancel of close: Self   endof
            endcase
 ;

:M WM_COMMAND   ( h m w l -- res )
                over LOWORD ( ID )  self   \ object address on stack
                WMCommand-Func ?dup    \ must not be zero
                if        execute drop HandleButtons
                else        2drop   \ drop ID and object address
                then       0 ;M

:M SetCommand:  ( cfa -- )  \ set WMCommand function
                to WMCommand-Func
                ;M

:M On_Paint:    ( -- )
                0 0 GetSize: self Addr: FrmColor FillArea: dc
                ;M

:M Start:       (  s"title" cnt StartValue cfa-ok -- )
                to cfa-ok
                to StartValue
                title$ place
                start: super
                SetFocus: Spinner1.TheBox
                0 0 word-join EM_SETSEL GetHandle: Spinner1.TheBox Call SendMessage
          \      Select: Spinner1 \ Will be possible in the future
                ;M


:M On_Done:    ( -- )
                Delete: WinFont
                \ Insert your code here TextBox.f
                On_Done: super
                ;M

;Object

: ForAskedInteger  ( parent s"title" cnt offset cfa-ok - )
        Start: AskIntWindow
 ;

\s Use:

 0 s" Enter the desired framespeed:" 20  ' . ForAskedInteger  \s Press OK and see the value in the console.

\s

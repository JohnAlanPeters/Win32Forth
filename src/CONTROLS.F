\ $Id: CONTROLS.F,v 1.15 2013/12/17 19:25:22 georgeahubert Exp $

\ CONTROLS.F            Additional controls     by Freidrick Prinz

\ September 7th, 1999 - 22:48 tjz corrected a bug reported by Jos v.c. Ven,
\ seems I forgot to initialize the super class of EditControl when I added
\ some enhancements.

\ July 29th, 1999 - 15:16 tjz enhanced EditControl and ComboControl to
\ make them generalized enough to put an edit field on a ToolBar.

\ January 9th, 1996 - 13:57 tjz Modified and updated both this file and
\ Win32Forth to make this kind of thing easier.  Added CONTROL.F to the
\ Win32Forth system

\ *D doc\classes\
\ *! Controls
\ *T Controls -- Classes for standard windows controls.

Require Control.f

cr .( Loading Low Level Controls...)

synonym ClientRect wRect

\ *W <a name="EditControl"></a>
\ *S EditControl class
:Class EditControl <Super CONTROL
\ *G Class for Edit controls.
\ ** An edit control is a rectangular control window typically used in a dialog
\ ** box to permit the user to enter and edit text by typing on the keyboard.

\ pointers to filter function to allow key capturing.

int pWmChar      \ function returns '0' if it handled message, non-zero otherwise
int pWmKeyDown   \ function returns '0' if it handled message, non-zero otherwise
int pWmKillFocus \ function returns '0' if it handled message, non-zero otherwise

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: Super
                0 to pWmChar
                0 to pWmKeyDown
                0 to pWmKillFocus
                ;M

:M StartSize:   ( -- width height )
\ *G Get the start size of the control. Default size is 100 x 25.
                100 25 ;M

:M WindowStyle: ( -- Style )
\ *G Get the window style of the control. Default style is:
\ ** WS_BORDER, WS_TABSTOP and ES_AUTOHSCROLL.
                WindowStyle: SUPER
                [ WS_BORDER WS_TABSTOP OR ES_AUTOHSCROLL OR ] literal OR \ allow horizontal scrolling
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent
                z" EDIT" Create-Control
                ;M

:M SetWmChar:   ( pWmChar -- )
\ *G Install the WM_CHAR filter function.
                to pWmChar ;M

:M SetWmKeyDown: ( pWmKeyDown -- )
\ *G Install the WM_KEYDOWN filter function.
                to pWmKeyDown ;M

\ *P Install these filter functions if you want to capture certain keys, like
\ ** Return or F3, or whatever.

:M SetWmKillFocus: ( pWmKillFocus -- )
\ *G Install the WM_KILLFOCUS filter function.
                to pWmKillFocus ;M

:M SubClass:    ( hWnd Parent -- )
\ *G Subclass this control.
                to parent
                to hWnd
                subclass
                ;M

: ?pexecute     ( hwnd msg wparm lparm pfunction -- result )
                -IF  self swap execute
                     -IF  DROP
                          old-wndproc CallWindowProc
                     THEN
                ELSE drop old-wndproc CallWindowProc
                THEN ;

:M WM_CHAR      ( h m w l -- res )      \ normal & control chars
                pWmChar ?pexecute ;M

((
\ example function to process WM_CHAR messages
: myWmChar      ( h m w l obj -- res )
                2 pick VK_RETURN  =
                IF      GetText: [ ]    \ get adr,len of edit control text
                        ...<process WM_CHAR message>...
                        FALSE           \ we already processed this message
                ELSE    drop            \ discard object
                        TRUE            \ and use default processing
                THEN    ;
))

:M WM_KEYDOWN   ( h m w l -- res )      \ normal & control chars
                pWmKeyDown ?pexecute ;M

:M WM_KILLFOCUS ( h m w l -- res )      \ Allow intervention on kill focus
                pWmKillFocus ?pexecute ;M

:M WM_SETCURSOR { hndl msg wparam lparam -- res }
                EraseRect: WinRect                \ init to zeros
                WinRect GetClientRect: self
                hWnd get-mouse-xy Top: WinRect  Bottom: WinRect between
                over Left: WinRect Right: WinRect between and
                IF   ibeam-cursor
                     1
                ELSE DROP
                     hndl msg wparam lparam DefaultWindowProc
                THEN ;M

;Class
\ *G End of EditControl class

\ *W <a name="ComboControl"></a>
\ *S ComboControl class
:Class ComboControl <Super CONTROL
\ *G Class for editable combo box controls.

EditControl ComboEdit

:M StartSize:   ( -- width height )
\ *G Get the start size of the control
                100 100 ;M

:M WindowStyle: ( -- Style )
\ *G Get the window style of the control. The default style is:
\ ** CBS_DROPDOWN, WS_VSCROLL, WS_TABSTOP, WS_VISIBLE and ES_AUTOHSCROLL.
                WindowStyle: SUPER
                [ CBS_DROPDOWN WS_VSCROLL OR WS_TABSTOP OR WS_VISIBLE OR ES_AUTOHSCROLL OR ] literal OR
                ;M

\ Install these filter functions if you want to capture certain keys, like
\ Return or F3, or whatever.

:M SetWmChar:   ( pWmChar -- )
\ *G install the WM_CHAR filter function for the EditControl of the combo box.
                SetWmChar: ComboEdit ;M

:M SetWmKeyDown: ( pWmKeyDown -- )
\ *G install the WM_KEYDOWN filter function for the EditControl of the combo box.
                SetWmKeyDown: ComboEdit ;M

:M SetWmKillFocus: ( pWmKillFocus -- )
\ *G install the WM_KILLFOCUS filter function for the EditControl of the combo box.
                SetWmKillFocus: ComboEdit ;M

:M InsertString: ( adr len -- )
\ *G Insert a string into the combo box
                hWnd NULL =             \ must have a valid handle
                IF      2drop           \ just discard if not running
                ELSE    2dup SetText: ComboEdit
                        asciiz
                        dup 0 CB_FINDSTRINGEXACT
                        GetID: self SendDlgItemMessage: parent dup CB_ERR = \ if it's not in list
                        IF      DROP
                                0 CB_INSERTSTRING
                                GetID: self SendDlgItemMessage: parent drop
                                0 0 CB_SETCURSEL        \ set first as current item
                                GetID: self SendDlgItemMessage: parent drop
                        ELSE    NIP                     \ discard string
                                0 swap CB_SETCURSEL     \ set found item as current item
                                GetID: self SendDlgItemMessage: parent drop
                        THEN
                THEN
                ;M

:M GetString:   ( adr index -- )
\ *G Use: GetString: to get indexed items out of the combo box string list
\ ** Use: GetText: to get the current combo box string.
                swap dup>r 1+ swap
                CB_GETLBTEXT
                GetID: self SendDlgItemMessage: parent 0 max r> c!
                ;M

:M GetCount:    ( -- n1 )
\ *G Use: GetCount: to get the count of items in the combo box string list.
                0 0 CB_GETCOUNT
                GetID: self SendDlgItemMessage: parent 0 max
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent
                z" COMBOBOX" Create-Control
\ new subclass the embedded EditControl, so we can handle WM_CHAR & WM_KEYDOWN
\ messages to capture keys like Return and F3.
                5 5
                hWnd
                Call ChildWindowFromPoint self SubClass: ComboEdit
                0 0 CB_RESETCONTENT
                GetID: self SendDlgItemMessage: parent drop
                ;M

;Class
\ *G End of ComboControl class

\ *W <a name="ComboListControl"></a>
\ *S ComboListControl class
:Class ComboListControl <Super ComboControl
\ *G Class for select only combo box controls.

:M WindowStyle: ( -- Style )
\ *G Get the window style of the control. The default style is: CBS_DROPDOWNLIST.
                WindowStyle: SUPER CBS_DROPDOWNLIST OR ;M

;Class
\ *G End of ComboListControl class

\ *W <a name="ListControl"></a>
\ *S ListControl class
:Class ListControl <Super CONTROL
\ *G Class for list box controls.

:M WindowStyle: ( -- Style )
\ *G Get the window style of the control. The default style is: WS_VSCROLL,
\ ** LBS_NOTIFY, LBS_NOINTEGRALHEIGHT and WS_TABSTOP.
                WindowStyle: SUPER
                [ WS_VSCROLL LBS_NOTIFY OR LBS_NOINTEGRALHEIGHT OR WS_TABSTOP OR ] literal OR
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent
                z" LISTBOX" Create-Control
                ;M
;Class
\ *G End of ListControlControl class

\ *W <a name="GroupControl"></a>
\ *S GroupControl control class
:Class GroupControl <Super CONTROL
\ *G Class for group controls.

:M WindowStyle: ( -- Style )
\ *G Get the window style of the control. The default style is: BS_GROUPBOX.
                WindowStyle: SUPER BS_GROUPBOX OR ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent z" BUTTON" Create-Control ;M
;Class
\ *G End of GroupControl class

\ *W <a name="StaticControl"></a>
\ *S StaticControl control class
:Class StaticControl <Super CONTROL
\ *G Class for static controls.

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent
                z" STATIC" Create-Control
                ;M
;Class
\ *G End of StaticControl class

\ *W <a name="CheckControl"></a>
\ *S CheckControl control class
:Class CheckControl <Super CONTROL
\ *G Class for check box controls.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: BS_AUTOCHECKBOX,
\ ** and WS_TABSTOP.
                WindowStyle: SUPER
                [ BS_AUTOCHECKBOX WS_TABSTOP OR ] literal OR
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent z" BUTTON" Create-Control ;M

;Class
\ *G End of CheckControl class

\ *W <a name="RadioControl"></a>
\ *S RadioControl control class
:Class RadioControl <Super CONTROL
\ *G Class for radio button controls.

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: BS_AUTORADIOBUTTON,
\ ** and WS_TABSTOP.
                WindowStyle: SUPER
                [ BS_AUTORADIOBUTTON WS_TABSTOP OR ] literal OR
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                TO Parent z" BUTTON" Create-Control ;M

;Class
\ *G End of RadioControl class

\ *W <a name="ButtonControl"></a>
\ *S ButtonControl control class
:Class ButtonControl <Super CONTROL
\ *G Class for push button controls.

int buttonfunc

:M ClassInit:   ( -- )
\ *G Initialise the class.
                ClassInit: super
                ['] noop to buttonfunc
                ;M

:M SetFunc:     ( cfa -- )
\ *G Set the button function. This function is executed when the
\ ** button is pressed with a click with the left mouse button
                to buttonfunc ;M

:M WindowStyle: ( -- style )
\ *G Get the window style of the control. The default style is: BS_PUSHBUTTON,
\ ** and WS_TABSTOP.
                WindowStyle: SUPER
                [ BS_PUSHBUTTON WS_TABSTOP OR ] literal OR
                ;M

:M Start:       ( Parent -- )
\ *G Create the control.
                to Parent z" BUTTON" Create-Control ;M

:M WM_LBUTTONUP ( h m w l -- res )
                hWnd get-mouse-xy hWnd in-button?
                if   buttonfunc execute
                then
                old-wndproc CallWindowProc
                ;M

;Class
\ *G End of ButtonControl class

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Dialog Window Class
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ *W <a name="DialogWindow"></a>
\ *S Dialog Window Class
:CLASS DialogWindow   <Super Window
\ *G Base class for windows that contain controls.

:M ClassInit:   ( -- )
\ *G Initialise the class.
        ClassInit: super
        +dialoglist
        ;M

:M ~:    ( -- )
       -dialoglist ~: super ;M

;Class
\ *G End of DialogWindow class

\ *Z

\s ********* SAMPLE Follows ********* SAMPLE Follows *********
\  ********* SAMPLE Follows ********* SAMPLE Follows *********
\  ********* SAMPLE Follows ********* SAMPLE Follows *********


0 value check1

:OBJECT EditSample <Super DialogWindow

  EditControl Edit_1     \ an edit window
StaticControl Text_1     \ a static text window
ButtonControl Button_1   \ a button
ButtonControl Button_2   \ another button
 CheckControl Check_1    \ a check box
 RadioControl Radio_1    \ a radio button
 RadioControl Radio_2    \ another radio button

: CloseSample   ( -- )
                Close: [ self ] ;

:M ExWindowStyle: ( -- style )
                ExWindowStyle: SUPER
                ;M

:M WindowStyle: ( -- style )
                WindowStyle: SUPER
                [ WS_BORDER WS_OVERLAPPED OR ] literal or
                ;M

:M WindowTitle: ( -- title )
                z" " ;M

:M StartSize:   ( -- width height )
                200 100 ;M

:M StartPos:    ( -- x y )
                3 3 ;M

:M On_Init:     ( -- )
                On_Init: super
                self               Start: Check_1
                4 25 60 20          Move: Check_1
                s" Hello"        SetText: Check_1

                self               Start: Radio_1
                80 25 80 20         Move: Radio_1
                s" Hello2"       SetText: Radio_1
                                GetStyle: Radio_1 \ get the default style
                WS_GROUP   OR
                                SetStyle: Radio_1 \ Start a group

                self               Start: Radio_2
                80 45 120 20        Move: Radio_2
                s" Hello Again"  SetText: Radio_2

                self               Start: Text_1 \ start up static text
                                GetStyle: Text_1 \ get the default style
                [ WS_GROUP SS_CENTER OR WS_BORDER OR ] literal OR \ start a group and centre
                                SetStyle: Text_1 \ and border to style
                4  4 192 20         Move: Text_1 \ position the window
                s" Sample Text"  SetText: Text_1 \ set the window message

                self               Start: Edit_1
                3 72  60 25         Move: Edit_1
                s" 000,00"       SetText: Edit_1

                IDOK               SetID: Button_1
                self               Start: Button_1
                110 72 36 25        Move: Button_1
                s" OK"           SetText: Button_1
                                GetStyle: Button_1
                BS_DEFPUSHBUTTON OR
                                SetStyle: Button_1

                self               Start: Button_2
                150 72 45 25        Move: Button_2
                s" Beep"         SetText: Button_2
                ['] beep         SetFunc: Button_2
                ;M

:M On_Paint:    ( -- )          \ screen redraw procedure
                0 0 width height LTGRAY FillArea: dc
                ;M

:M Close:       ( -- )
                GetText: Edit_1 cr type cr
                Close: SUPER ;M

:M WM_COMMAND  ( hwnd msg wparam lparam -- res )
                over LOWORD ( ID )
                case
                IDOK            of Close: self                          endof
                GetID: Check_1  of GetID: Check_1
                                   IsDlgButtonChecked: self to check1 beep  endof
                endcase
                0 ;M

;OBJECT

: demo          ( -- )
                Start: EditSample ;


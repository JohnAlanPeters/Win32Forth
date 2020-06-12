\ $Id: NewConsole.f,v 1.43 2015/11/06 13:39:03 jos_ven Exp $


\ NewConsole.f - Console window to replace w32fConsole.dll by Rod Oakford
\
\ This console has all the functionality of the old console plus additional features.
\
\ n wrap: cmd   wraps text output from type.  (The command line is not wrapped, just scrolled)
\ 0 (false) - no text wrapping
\ Any positive number wraps the text after column n
\ True (or any negative number) wraps the text after the last visible column
\
\ font SetFont: cmd   sets the font for the console which can be a variable character width font
\ font NewFont
\ s" Courier" SetFaceName: NewFont
\ 20 height: NewFont
\ NewFont SetFont: cmd

\ green blue FGBG!   makes the foreground green and background blue
\ black white FGBG!   normal colours for the console
\ BigCursor: cmd   sets the caret to the average character width
\ SmallCursor: cmd   sets the caret width to 1 pixel
\ 1 SetLeftMargin: cmd   left and right margins can be set
\ 8 SetRightMargin: cmd   would allow the big caret to show at the end of the command line


Needs src\console\CommandWindow.f
Needs src\console\ConsoleStatBar.f

cr .( Loading NewConsole.f : Console main...)

4 proc PostMessage

CommandWindow cmd

INTERNAL
EXTERNAL


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Console Window \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

:Object ConsoleWindow   <Super Window

int WindowState
:M WindowState: ( -- n )   WindowState ;M
int StatusbarHeight

:M ClassInit: ( -- )
        ClassInit: super
        s" Win32Forth" SetClassName: self
        Console-menu to CurrentMenu
        ;M

:M WindowStyle: ( -- style )
        WindowStyle: super
        WS_CLIPCHILDREN or
\        WS_VISIBLE or
        ;M

:M Start: ( -- )   \ overriden to start console hidden
        hWnd
        IF  SetFocus: self
        ELSE
            register-frame-window drop
            create-frame-window to hWnd
            hWnd to _conhndl
        THEN
        ;M

: SetRegValue ( n a1 n1 -- )   2>r  s>d (d.)  2r> s" Settings" RegSetString ;

: GetRegValue ( default a1 n1 - n )
        s" Settings" RegGetString  dup
        IF  number? >r d>s r>
        ELSE  2drop  0 false
        THEN
        IF  nip  ELSE  drop  THEN ;

: SaveWindowSettings ( -- )
        PROGREG-INIT
        StartPos: self   s" WindowTop"    SetRegValue  s" WindowLeft"  SetRegValue
        StartSize: self  s" WindowHeight" SetRegValue  s" WindowWidth" SetRegValue
        ;

:M StartSize: ( -- w h )
        600 s" WindowWidth"  GetRegValue
        400 s" WindowHeight" GetRegValue
        ;M

:M StartPos: ( -- x y )
        0 s" WindowLeft" GetRegValue
        0 s" WindowTop"  GetRegValue
        ;M

:M WindowHasMenu: ( -- f )   true ;M

:M MinSize: ( -- width height )   240  64  ;M

\ :M WindowTitle: ( -- z" )   z" Win32Forth" ;M

:M WindowTitle: ( -- z" )
        s" Win32Forth " pad place
        base @ decimal
        version# ((version)) pad +place
        base !
        pad +NULL pad 1+
        ;M

:M On_SetFocus: ( h m w l -- )   SetFocus: cmd ;M

:M ShowStatusBar: ( -- )   height: ConsoleStatusbar to StatusBarHeight
        SW_SHOW show: ConsoleStatusbar ( true check: hStatusBar )
        0 0  Width  Height StatusbarHeight -  Move: cmd
        ['] Console-Statusbar-interpret is interpret
        ;M

:M HideStatusBar: ( -- )   0 to StatusBarHeight
        SW_HIDE show: ConsoleStatusbar  ( false check: hStatusBar )
        0 0  Width  Height StatusBarHeight -  Move: cmd
        ['] _interpret is interpret
        ;M

also hidden
:M WM_COPYDATA  ( hndl msg wParam lParam -- result )
                \ messages from other applications to be handled by win32forth
                TURNKEYED?                     \ exit if no heads are present
                if 4drop 0 exitm then
                Decodew32fMsg ( hwnd msg wparam lparam -- addr siz w32fmsg w32fAppIDSender )
                dup w32fIDE <> swap w32fWinEd <> and
                if 3drop 0 exitm then
                CASE
                  \ Debugger support from forth side
\in-system-ok     WM_SETBP     OF drop do-set-breakpoint   ( result) ENDOF
\in-system-ok     WM_STEPBP    OF 2drop 0x0D           db-pushkey -1 ENDOF
\in-system-ok     WM_NESTBP    OF 2drop 'N'            db-pushkey -1 ENDOF
\in-system-ok     WM_UNESTBP   OF 2drop 'U'            db-pushkey -1 ENDOF
\in-system-ok     WM_CONTBP    OF 2drop 'C'            db-pushkey -1 ENDOF
\in-system-ok     WM_JUMPBP    OF 2drop 'J'            db-pushkey -1 ENDOF
\in-system-ok     WM_BEGNBP    OF 2drop 'P'            db-pushkey -1 ENDOF
\in-system-ok     WM_HEREBP    OF 2drop 'P' +k_control db-pushkey -1 ENDOF
\in-system-ok     WM_RSTKBP    OF 2drop 'R'            db-pushkey -1 ENDOF
\in-system-ok     WM_DONEBP    OF 2drop 'D'            db-pushkey -1 ENDOF
\in-system-ok     WM_INQUIRE   OF drop do-inquire                 -1 ENDOF
                  \ put the received key in the input stream
\in-system-ok     WM_KEY       OF drop c@ pushkey                 -1 ENDOF
                  \ request to copy text from clipboard and compile it
\in-system-ok     WM_PASTELOAD OF 2drop paste-load                -1 ENDOF
                        DEFAULTOF 2drop                            0 ENDOF
                  ENDCASE \ Paint: cmd \ needs a windows msg to process keys, brute force solution until!
                  0 0 WM_USER hwnd PostMessage drop
                ;M

previous

:M On_Init: ( -- )
        On_Init: super
        ZeroMenu: CurrentMenu
        CS_DBLCLKS GCL_STYLE hWnd Call SetClassLong drop
        COLOR_BTNFACE 1+ GCL_HBRBACKGROUND hWnd Call SetClassLong drop
        101 appinst Call LoadIcon GCL_HICON hWnd Call SetClassLong drop
        self start: ConsoleStatusbar
        Height: ConsoleStatusbar to StatusbarHeight
        StatusbarHeight IF  ShowStatusbar: self  THEN
        self start: cmd
        cls: cmd
        Console-popup SetPopupBar: cmd
        ;M

:M On_Size: ( h m w -- h m w )
        dup to WindowState
        dup SIZE_MINIMIZED <>
        IF
            0 0  Width  Height StatusbarHeight -  Move: cmd
            Redraw: ConsoleStatusbar
        THEN
        ;M

\ :M On_Done: ( -- )
\         WindowState SIZE_RESTORED = IF  SaveWindowSettings  THEN
\         0 to _conhndl
\         ;M

:M WM_CLOSE     ( h m w l -- res )
        WindowState SIZE_RESTORED = IF  SaveWindowSettings  THEN
        0 to _conhndl
        bye 0 ;M

;Object


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Deferred I/O words \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL
in-system

: c_type ( a n -- )
        OverwriteTextAtXY: cmd
        PauseForMessages
        ;

: c_emit ( c -- )
        case
          $7 of beep endof
          $8 of BackSpace: cmd endof
          $A of getxy 1+ gotoxy endof
          $D of getxy swap drop 0 swap gotoxy endof
          sp@ 1 c_type
        endcase
        ;

: c_cr ( -- )    cr: cmd ;
: c_?cr ( n -- )   ?cr: cmd ;
: c_cls ( -- )  cls: cmd ;
: c_getcolrow ( -- col row )   VisibleColRow: cmd ;
: c_getxy ( -- x y )   GetXY: cmd ;
: c_gotoxy ( x y --  )   GoToXY: cmd ;

0 value entered
0 0 2value EnteredString
: c_accept ( a1 n1 -- n2 )
        SetMaxChars: cmd
        Prompt: cmd
        false to entered
        BEGIN
            auto_key
            KeyBufferEmpty: cmd
            IF  call WaitMessage drop
            ELSE  GetKey: cmd  HandleChar: cmd
            THEN
            PauseForMessages  entered  auto_key?
        UNTIL
        EnteredString >r swap r@ move r>
        ;

: AcceptCommand ( a n -- )   to EnteredString  true to entered ;
' AcceptCommand SetAction: cmd

: c_pushkey ( c -- )   PutKey: cmd ;

: c_"pushkeys ( a n -- )    \ push the characters of string a n
        0max 127 min bounds
        ?DO  i c@ c_pushkey
        LOOP ;

: c_key? ( -- f )
        cmd.ClipboardHandle IF  false  exit  THEN   \ need to disable key? during paste because of SLOW
        KeysOff: cmd
        PauseForMessages   \ Winpause
        KeyBufferEmpty: cmd  not
        ;

: c_key ( -- c )   \ keys from WM_KEYDOWN as well
        auto_key
\        1 SetMaxChars: cmd
\        Prompt: cmd
        ShowCaret: cmd
        true SetEditing: cmd
        KeyBufferEmpty: cmd IF  BEGIN  KeysOff: cmd  WaitForMessage  c_key? auto_key? UNTIL  THEN
        GetKey: cmd
        false SetEditing: cmd
        HideCaret: cmd
\        EndPrompt: cmd
        ;

: c_Init-Console ( -- f )   \ start the Console window hidden or show console if already started
\        progreg-init
        KeysOn: cmd
\        z" Win32Forth> " SetPrompt: cmd
        GetHandle: ConsoleWindow 0=   \ false if ConsoleWindow already started
        Start: ConsoleWindow
        ;

: c_Init-Screen ( -- )      \ start the Console window and show it
        c_Init-Console drop
        SW_NORMAL Show: ConsoleWindow
        Update: cmd
        UpdateVScroll: cmd
        UpdateHScroll: cmd
        Update: ConsoleWindow
        SetFocus: ConsoleWindow
        HideCaret: cmd
        ;

: c_FGBG! ( color_object color_object -- )   SetBackground: cmd  SetForeground: cmd ;
: c_FG@ ( -- color_object )   cmd.ForegroundColour ;
: c_BG@ ( -- color_object )   cmd.BackgroundColour ;
: c_&TheScreen ( -- a )   cmd.text ;
: c_CharWH ( -- w h )   CharWH: cmd ;

14 SetTablength: cmd
1 SetLeftMargin: cmd
1 SetRightMargin: cmd   \ so caret fits on end of line
0 SetTopMargin: cmd
0 SetBottomMargin: cmd

Black White c_FGBG!

: c_copy-console   copy: cmd ;
: c_cut-console    SelectAll: cmd  cut: cmd ;
: c_mark-all       SelectAll: cmd ;
: c_paste-load     Paste: cmd ;

: c_getrowoff ( -- n )   FirstVisibleRow: cmd ;
: c_ScrollToView ( -- )   UpdateScrollRange: cmd  AutoScroll: cmd ;

IN-APPLICATION
defer f1key ' noop is f1key
:noname ( n -- )
        Case
            'O' +k_control             of  edit-forth             endof
            'W' +k_control             of  open-web               endof
            'L' +k_control             of  load-forth             endof
            'P' +k_control             of  print-screen           endof
            'D' +k_control             of  ChdirDlg               endof
[DEFINED] replay-macro [IF]
            'M' +k_control +k_shift    of  replay-macro           endof
            'R' +k_control +k_shift    of  CONHNDL repeat-amacro  endof
            'S' +k_control +k_shift    of  start/stop-macro       endof
[THEN]
            k_F1                       of  f1key ( F1-doc )       endof
\            k_F2                       of  F2-help                endof
            ( default )  \ swap drop
        EndCase
        ;   is HandleKeys

((
:noname ( c -- )
        ?shift ?control or
        IF  drop
        ELSE
            Case
\                VK_F1    of  F1-doc       endof
\                VK_F2    of  F2-help      endof
\                VK_F12   of  LoadProject  endof
\                ( default )   \  swap drop
            EndCase
        THEN
        ;   is HandleKeyDown
))

IN-SYSTEM
' menukey-more is LogKeyStrokes


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Hooks the new console in defered i/o and imageman \\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: NewConsole    ( -- ) \ reset all defered words for the console window
              \ ['] NOOP              IS CONSOLE
                ['] c_Init-Console    IS INIT-CONSOLE
                ['] c_Init-Screen     IS INIT-SCREEN
                ['] c_key             IS KEY
                ['] c_key?            IS KEY?
                ['] c_accept          IS ACCEPT
                ['] c_pushkey         IS PUSHKEY
                ['] c_"pushkeys       IS "PUSHKEYS
                ['] c_cls             IS CLS
                ['] c_emit            IS EMIT
                ['] c_type            IS TYPE
                ['] c_cr              IS CR
                ['] c_?cr             IS ?CR
                ['] c_gotoxy          IS GOTOXY
                ['] c_getxy           IS GETXY
                ['] c_FGBG!           IS FGBG!       \ use forgrnd/bckgrnd color_objects
                ['] c_FG@             IS FG@
                ['] c_BG@             IS BG@
                ['] c_CharWH          IS CHARWH
                ['] 2DROP             IS SETCHARWH   \ no ( change the font )
                ['] DROP              IS SET-CURSOR  \ no  big-cursor, norm-cursor
                ['] K_NOOP1           IS GET-CURSOR  \ no
                ['] c_getcolrow       IS GETCOLROW
                ['] c_getrowoff       IS GETROWOFF
                ['] c_&TheScreen      IS &THE-SCREEN
                ['] c_ScrollToView    IS SCROLLTOVIEW
                \ specific to new console :
                ['] c_copy-console    IS copy-console
                ['] c_cut-console     IS cut-console
                ['] c_mark-all        IS mark-all
                ['] c_paste-load      IS paste-load
                ;

\in-system-ok   forth-io-chain chain-add NewConsole

:noname         ( -- )
                NewConsole
                init-console drop
\                unset-except        \ exception handling needs to be set after Console
\                set-except          \ is started (this doesn't clear the exception)
                init-screen
                ; is (ConsoleBoot)

:noname         ( -- )
                NewConsole
                init-console drop
\                unset-except        \ exception handling needs to be set after Console
\                set-except          \ is started (this doesn't clear the exception)
                ; is (ConsoleHiddenBoot)

in-previous

MODULE


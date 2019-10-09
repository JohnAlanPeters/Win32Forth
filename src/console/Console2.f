\ Console2.f   (was Console2New.f)

cr .( Loading Console2.f Console I/O Part 2...)

: forth-io ( -- )   forth-io-chain do-chain ;

1 proc HideCaret
: hide-cursor   ( -- )
                conHndl call HideCaret drop ;

: cursor-off    ( -- ) \ synonym for hide-cursor
                hide-cursor ;

1 proc ShowCaret
: show-cursor   ( -- )
                conHndl call ShowCaret drop ;

: cursor-on     ( -- ) \ synonym for show-cursor
                show-cursor ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
((
in-system

: minimize-console ( -- )
                SW_SHOWMINIMIZED conhndl call ShowWindow drop ;

in-application
))
\ Make console the foreground window. Ignore error which will occur if we are
\ running under Windows95 and we are already the foreground window.
0 proc GetActiveWindow
1 proc SetActiveWindow
1 proc SetForegroundWindow
2 proc GetWindowThreadProcessId
3 proc AttachThreadInput

: (SetWindow) { hWnd proc \ hActiveThreadID hLocalThreadID -- }
                call GetActiveWindow dup hWnd =
                -if  hWnd proc execute
                else swap call GetWindowThreadProcessId to hActiveThreadID
                     0 hWnd call GetWindowThreadProcessId to hLocalThreadID
                     1 hLocalThreadID hActiveThreadID Call AttachThreadInput
                     hWnd proc execute
                     0 hLocalThreadID hActiveThreadID Call AttachThreadInput
                then 3drop ;

: (SetForegroundWindow) ( hwnd -- ) \ Put window as foreground
                                    \ See full doc in method SetForegroundWindow:
                ['] SetForegroundWindow (SetWindow) ;

: (SetActiveWindow) ( hWnd -- ) \ Activate the window.
                                \ See full doc in method SetActiveWindow:
                ['] SetActiveWindow (SetWindow) ;

in-system

: _foreground-console   ( -- )
                conhndl (SetForegroundWindow) ;

: _activate-console   ( -- )
                conhndl (SetActiveWindow) ;

defer foreground-console ( -- )
' _foreground-console is foreground-console

defer activate-console ( -- )
' _activate-console is activate-console

in-application

0 value mousex
0 value mousey
0 value mouseflags

defer auto_key  ' noop is auto_key      \ default to nothing
defer auto_key? ' noop is auto_key?     \ default to nothing

defer menukey-more
        ' noop is menukey-more


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\ Redefined ?WinError to give more debugging information
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: (GetLastError) ( -- n)   GetLastWinErr ;

: (FormatSystemMessage) ( error -- a n)
   GetLastWinErrMsg count ;

4 PROC MessageBox

: (?WinError) ( f)   \ show an error dialog box if f=FALSE/0
   0= IF  (GetLastError) (FormatSystemMessage)
          2DUP  2 - ( to drop CRLF pair)  CR TYPE CR  ( echo to console)
          DROP >R
          MB_OK MB_ICONWARNING OR  Z" Error"
             R> NULL  Call MessageBox drop
    THEN ;


\ TRUE [IF]   \ add more debugging information to ?WinError
\ cdo [IF] is not yet deined (when building setup.exe)

   : DefinedAbort,   \ compiles an ABORT" with the file name and line where defined
        LOADING?
        IF  S" Defined in file: "    TEMP$ PLACE
              LOADFILE COUNT         TEMP$ +PLACE
              S"  -- Line: "         TEMP$ +PLACE
              LOADLINE @ (.)         TEMP$ +PLACE
              POSTPONE (ABORT")
              TEMP$ COUNT ", 0 c, align
        ELSE  POSTPONE DROP
        THEN
        ;

   : ?WinError ( f)
      STATE @ IF  POSTPONE DUP  POSTPONE (?WinError)  POSTPONE 0= DefinedAbort,
            ELSE  (?WinError)
            THEN ; IMMEDIATE

\ [ELSE]   \ just give messagebox as an alert, don't abort

\    : ?WinError ( f)   (?WinError) ;

\ [THEN]

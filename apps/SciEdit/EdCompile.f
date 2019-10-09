\ $Id: EdCompile.f,v 1.5 2007/05/13 07:52:26 dbu_de Exp $

\    File: EdCompile.f
\
\  Author: Dirk Busch (dbu)
\   Email: dirkNOSPAM@win32forth.org
\
\ Created: Sonntag, Juni 27 2004 - dbu
\ Updated: Dienstag, Juni 29 2004 - dbu
\
\ Most of this code was stolen from WinEd.

\ -----------------------------------------------------------------------------
\ A replacement for win32forth-message to get rid of HWND_BRODCAST
\ -----------------------------------------------------------------------------
: GetProcessId { hWnd -- ProcessID }  \ get ProcessId for given window
        here hWnd call GetWindowThreadProcessId drop here @ ;

create Win32ForthClassName ," Win32Forth" \ the window class name of the forth console
create Win32ForthName MAXSTRING allot Win32ForthName off \ the window name of the forth console
0 value hWndForthWindow \ holds the current handle of forth console

2 CallBack: GetForthWindowCallback { hWnd SciEditProcessID \ buff$ -- int }
        MAXSTRING localalloc: buff$

        true \ default return value

        \ get classname
        MAXSTRING buff$ hWnd call GetClassName 0<>
        if   \ is it the window we are lookin for?
             Win32ForthClassName count buff$ over COMPARE 0=
             if   MAXSTRING buff$ hWnd call GetWindowText drop
                  Win32ForthName count buff$ over COMPARE 0=
                  if   \ don't return our own (hidden) console window
                       hWnd GetProcessId SciEditProcessID <>
                       if   hWnd to hWndForthWindow
                            drop false \ stop enum
                       then
                  then
             then
        then ;

: BuildWin32ForthName ( -- )
\ Build the window name of the Forth console window.
\ If a Forth console window is embedded within an turnkey application
\ the name is "Win32Forth".
\ For a stand alone console which is needed here it is "Win32forth <Version>",
\ were <Version> is something like "6.11.09" (see src/extend.f).
        base @ decimal
        S" Win32Forth " Win32ForthName place
        version# ((version)) Win32ForthName +place
        Win32ForthName +NULL
        base !
        ;

: GetForthWindow ( -- ) \ get the handle of the forth console window
        BuildWin32ForthName
        0 to hWndForthWindow
        GetHandle: Frame GetProcessId
        &GetForthWindowCallback
        Call EnumWindows drop ;

: FindForthWindow ( -- flag ) \ check if there is a forth console
        hWndForthWindow call IsWindow 0=
        if   GetForthWindow hWndForthWindow 0<>
        else true
        then ;

: sciedit_win32forth-message ( lParam wParam -- ) \ send message to forth console
        hWndForthWindow call IsWindow 0=
        if   \ if not try to get one
             GetForthWindow
        then

        hWndForthWindow 0<>
        if   \ if we have a valid window handle to the forth console
             \ we can just send the message directly
             WM_WIN32FORTH hWndForthWindow Call SendMessage drop
        else 2drop  \ [rda 1/18/04]
        then ;


\ -----------------------------------------------------------------------------
\ Start the Forth console if needed
\ -----------------------------------------------------------------------------

: WaitForConsole { \ ?deadlook -- } \ wait until console is ready to accept char's
                                    \ return's after 10 seconds even when the console is not ready
        0 to ?deadlook
        begin 100 ms WINPAUSE
              ?deadlook 1+ dup to ?deadlook 10000 =
              ConsoleReady? or
        until ;

: StartUpForth  { \ file$ -- } \ Start forth console

        false to ConsoleReady?

        MAXSTRING LocalAlloc: file$
        &prognam count "path-only" file$ place
                                   file$ ?+\
        s" Win32For.exe"           file$ +place
                                   file$ EXEC-CMD drop

        \ wait untill Forth is loaded
        WaitForConsole ;


\ -----------------------------------------------------------------------------
\ Send keystrokes to the Forth console
\ -----------------------------------------------------------------------------

: "Forth ( a1 n1 -- )   \ send a string to the console
        ConsoleReady?
        if   bounds
             ?DO  I c@ WM_KEY win32forth-message
                  0 ms \ release control to OS for a moment
             LOOP 0x0D WM_KEY win32forth-message \ send CR to execute the string
        else 2drop
        then ;

\ -----------------------------------------------------------------------------
\ Compile the file in the Forth console
\ -----------------------------------------------------------------------------
:noname ( addr n -- )   \ compile a file
        { \ load$ file$ -- }
        MAXSTRING LocalAlloc: load$
        MAXSTRING LocalAlloc: file$

        file$ place

        FindForthWindow
        if   \ true to ConsoleReady?
        else StartUpForth \ if no forth instance is running then start one
        then

        ConsoleReady?
        if   s" foreground-console" "Forth \ make Forth the front application

             s" chdir '" load$ place
             file$ COUNT "path-only" load$ +place
             s" '" load$ +place
             load$ COUNT "Forth            \ Make file directory active

             s" FLOAD '" load$ place
             file$ COUNT load$ +place
             s" '" load$ +place
             load$ COUNT "Forth            \ Compile the source file
        else 2drop beep
        then ; is Compile-File

\ $Id: NoConsole.f,v 1.2 2008/08/19 22:05:20 camilleforth Exp $

\   File: NoConsole.f
\ Author: Dirk Busch      dirk@win32forth.org

\ *D doc
\ *! p-noconsole
\ *T No console
\ *Q Helper words for turnkey applications that don't need the console window and the \i w32fConsole.dll \d.
\ *P To use these words you must load the file \i src/console/NoConsole.f \d first.
\ *S Glossary

cr .( Loading NoConsole...)

anew -NoConsole.f

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\ Turnkey without needing w32fConsole.dll \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application

internal

: K_NOOP0 2DROP 0 ;
: K_NOOP1 0 ;
: K_NOOP2 0 0 ;

: NoConsole     ( -- )
        initialization-chain do-chain
        StopLaunching not               \ if instance allowed to run        [cdo]
        if   default-application        \ then run the users application
        else bye
        then ;

external

: MessageLoop           ( -- )  \ W32F console
\ *G The message loop for the application.
\ ** Use this instead of: \i BEGIN KEY DROP AGAIN \d. \n
\ ** Also needs to be used by tasks that start their own windows.
        { | pMsg -- }
        7 cells LocalAlloc: pMsg
        Begin 0 0 0 pMsg call GetMessage
        While pMsg HandleMessages drop
        Repeat ;

in-system

: NoConsoleIO           ( -- )  \ W32F console
\ *G Setup of the Console I/O for turnkey applications that doesn't need
\ ** the console window.
        \ reset all deferd words for the console window to noop's.
        ['] NOOP    IS INIT-CONSOLE-REG
        ['] K_NOOP1 IS INIT-CONSOLE
        ['] NOOP    IS INIT-SCREEN
        ['] K_NOOP1 IS KEY
        ['] K_NOOP1 IS KEY?
        ['] K_NOOP0 IS ACCEPT
        ['] DROP    IS PUSHKEY
        ['] 2DROP   IS "PUSHKEYS
        ['] K_NOOP1 IS SHIFTMASK
        ['] NOOP    IS CLS
        ['] DROP    IS EMIT
        ['] 2DROP   IS TYPE
        ['] NOOP    IS CR
        ['] DROP    IS ?CR
        ['] NOOP    IS CONSOLE
        ['] 2DROP   IS GOTOXY
        ['] K_NOOP2 IS GETXY
        ['] K_NOOP2 IS GETCOLROW
        ['] K_NOOP1 IS SIZESTATE
        ['] 4DROP   IS MARKCONSOLE
        ['] NOOP    IS CURSORINVIEW
        ['] 2DROP   IS FGBG!
        ['] K_NOOP1 IS FG@
        ['] K_NOOP1 IS BG@
        ['] K_NOOP2 IS CHARWH
        ['] 2DROP   IS SETCHARWH
        ['] 2DROP   IS SETCOLROW
        ['] DROP    IS SET-CURSOR
        ['] K_NOOP1 IS GET-CURSOR
        ['] DROP    IS SETROWOFF
        ['] K_NOOP1 IS GETROWOFF
        ['] K_NOOP2 IS GETMAXCOLROW
        ['] 2DROP   IS SETMAXCOLROW
        ['] K_NOOP1 IS &THE-SCREEN

        \ reset BYE to default
        ['] k_bye is bye

        \ set default-hello for the turnkey application
        ['] NoConsole is default-hello
        ;

: ResetConsoleIO           ( -- )  \ W32F console
\ *G Reset of the Console I/O after saving an application that don't need
\ ** the console window. Done automatically by TURNKEY and APPLICATION.

        \ set all deferd words for the console window.
        ['] NOOP                IS INIT-CONSOLE-REG
        ['] M_INIT-CONSOLE      IS INIT-CONSOLE
        ['] X_INIT-SCREEN       IS INIT-SCREEN
        ['] MENUKEY             IS KEY
        ['] _MKEY?              IS KEY?
        ['] _LACCEPT            IS ACCEPT
        ['] X_PUSHKEY           IS PUSHKEY
        ['] X_"PUSHKEYS         IS "PUSHKEYS
        ['] X_SHIFTMASK         IS SHIFTMASK
        ['] _mcls               IS CLS
        ['] _MEMIT              IS EMIT
        ['] _MTYPE              IS TYPE
        ['] _MCRTAB             IS CR
        ['] _M?CR               IS ?CR
        ['] FORTH-IO            IS CONSOLE
        ['] X_GOTOXY            IS GOTOXY
        ['] X_GETXY             IS GETXY
        ['] X_GETCOLROW         IS GETCOLROW
        ['] X_SIZESTATE         IS SIZESTATE
        ['] X_MARKCONSOLE       IS MARKCONSOLE
        ['] X_CURSORINVIEW      IS CURSORINVIEW
        ['] X_FGBG!             IS FGBG!
        ['] X_FG@               IS FG@
        ['] X_BG@               IS BG@
        ['] X_CHARWH            IS CHARWH
        ['] X_SETCHARWH         IS SETCHARWH
        ['] X_SETCOLROW         IS SETCOLROW
        ['] X_SET-CURSOR        IS SET-CURSOR
        ['] X_GET-CURSOR        IS GET-CURSOR
        ['] X_SETROWOFF         IS SETROWOFF
        ['] X_GETROWOFF         IS GETROWOFF
        ['] X_GETMAXCOLROW      IS GETMAXCOLROW
        ['] X_SETMAXCOLROW      IS SETMAXCOLROW
        ['] X_&THE-SCREEN       IS &THE-SCREEN

        \ reset BYE to default
        ['] k_bye is bye

        \ set default-hello for the saver application
        ['] _default-hello is default-hello
        ;

\ We redefine TURNKEY and APPLICATION to reset the
\ Console I/O after writing the executable. So we can
\ see the error messages.
warning @ checkstack warning off

: turnkey       ( xt -<prognam>- -- )
        ['] turnkey catch ResetConsoleIO throw ;

: application   ( app-mem sys-mem xt -<prognam>- -- )
        ['] application catch ResetConsoleIO throw ;

warning !


\+ VIMAGE        also VIMAGE

: NoConsoleInImage      ( -- )  \ W32F console
\ *G Tell Imageman that we don't need the w32fconsole.dll if possible.
\ In older w32f versions you have to modify Imageman.f to do this.
        \+ CONSOLE-DLL?  false to CONSOLE-DLL?
        ;
\+ VIMAGE        previous

in-application

module

\s

\ *S Example

\ *E : Main  ( -- )
\ **         \ things to do to start the application
\ **         ...
\ **
\ **         \ enter the message loop
\ **         Turnkeyed?
\ **         IF   MessageLoop bye
\ **         THEN ;
\ **
\ ** turnkey? [if]
\ **
\ **         \ Setup the console I/O
\ **         NoConsoleIO
\ **
\ **         \ Tell Imageman that we don't need the w32fconsole.dll.
\ **         NoConsoleInImage
\ **
\ **         \ Create the exe-file
\ **         ' Main turnkey PlayVirginRadio.exe
\ **
\ **         \ add the Application icon to the EXE file
\ **         s" apps\PlayVirginRadio\Virgin.ico" s" PlayVirginRadio.exe" AddAppIcon
\ **
\ **         1 pause-seconds bye
\ ** [else]
\ **         s" apps\PlayVirginRadio\Virgin.ico" s" PlayVirginRadio.exe" AddAppIcon
\ **         Main
\ ** [then]

\ *P For a full working example see \i apps/PlayVirginRadio/PlayVirginRadio.f \d.

\ *P For an example of multi-tasking use see \i demos/MultiHello.f \d.

\ *Z

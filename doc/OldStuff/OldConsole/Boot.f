\ $Id: Boot.f,v 1.1 2008/08/19 04:29:21 camilleforth Exp $

\ finish kernel extension : boot words

cr .( -- BOOT.F ) cr


create config$ ," WIN32FOR.CFG"
create userconfig$ ," WIN32FORUSER.CFG"

\ ........ set the default system access strings ..........
\ -rbs make shell work in other drives
: set-shell
        winver winnt351 >=
        if      s" CMD.EXE "
        else    s" c:\command.com " then
        2dup dos$ place shell$ place
        s" /c " shell$ +place ;

: .mem-free     ( -- )
                app-free 1000 / 1 u,.r ." k bytes free" ;

in-system

\ set title of the console window
\ August 31st, 2003 - 13:24 dbu (SF-ID 778673)
\
\ Note: If the window title for a stand alone Forth console window is changed here
\ the word BuildWin32ForthName in SciEdit, WinEd and the IDE must be changed, too !!!
: (ConsoleTitle) { \ $buff -- }
        256 LocalAlloc: $buff
        S" Win32Forth " $buff place
        base @ decimal
        version# ((version)) $buff +place
        base !
        $buff +NULL $buff 1+
        CONHNDL call SetWindowText drop
;

DEFER ConsoleTitle ' (ConsoleTitle) is ConsoleTitle

: HELLO         { \ doing-app? -- }             \ startup stuff
                only forth also definitions
                action-of default-application ['] bye <> to doing-app?
                init-console                    \ -- f1
                dup                             \ init if we created a console
                IF      \ !!!! HAVE TO DO THE INITIALIZATION CHAIN    !!!!
                        \ !!!! BEFORE WE USE ANY WINDOWS SYSTEM CALLS !!!!
                        \ More precisely : the very first members of the
                        \ initialization-chain actually do the work of
                        \ initializing Windows calls so that we can add in
                        \ this chain subsequent words using Windows calls
                        initialization-chain do-chain
                        ConsoleTitle \ set title of console window
                THEN

                normal-console

                exception@ 0=                   \ -- f1 f2
                doing-app? 0= and               \ if no app, display info
                IF      cls
                        set-shell

                        \ enable messaging thru console only if win32forth itself
                        MyAppID w32fForth = if conhndl EnableW32FMsg then
                THEN                            \ f1 --

                IF      doing-app? 0=           \ if no app, display more info
                                                \ and load config file
                        IF      config$ count "path-file nip nip 0=  \ if found
                                IF      config$ ['] $fload catch ?dup
                                        IF      MESSAGE
                                                RESET-STACKS
                                                QUIT
                                        THEN
                                THEN
                        THEN
                ELSE    exception@
                        IF      CMDLINE DROP OFF     \ reset commandline length
                                .exception
                        ELSE    cr ."  ** Warm Start Performed **"
                        THEN
                THEN
                exception@ 0=                    \ if no exception
                doing-app? and                   \ and have an application to run
                IF      StopLaunching not        \ if instance allowed to run
                        if   default-application \ then run the users application
                        then
                        bye                      \ terminate when it's done
                THEN    ;

\in-system-ok   ' hello is boot

: LoadUserConfig ( -- ) \ load user configuration file
        userconfig$ COUNT "path-file NIP NIP 0=
        IF userconfig$ $FLOAD THEN ;

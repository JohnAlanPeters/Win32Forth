\ $Id: Boot.f,v 1.9 2013/12/09 21:25:16 georgeahubert Exp $

\ finish kernel extension : boot words

cr .( Loading Boot.f : boot Win32Forth... ) cr

in-system

\ ........ set the default system access strings ..........
\ -rbs make shell work in other drives
: set-shell
[ version# ((version)) 0. 2swap >number 3drop 7 < ] [if]  \ For V6.xx.xx suporting older OSs
        winver winnt351 >=
        if      s" CMD.EXE "
        else    s" c:\command.com " then
[else]  s" CMD.EXE" [then]
        2dup dos$ place shell$ place
        s" /c " shell$ +place ;

\ : .mem-free     ( -- )
\                 app-free 1000 / 1 u,.r ." k bytes free" ;

\ : (ConsoleTitle) { \ $buff -- } \ set title of the console window
\         256 LocalAlloc: $buff
\         S" Win32Forth " $buff place
\         base @ decimal
\         version# ((version)) $buff +place
\         base !
\         $buff +NULL $buff 1+
\         CONHNDL call SetWindowText drop
\ ;
\
\ DEFER ConsoleTitle ' (ConsoleTitle) is ConsoleTitle

create config$     ," WIN32FOR.CFG"
create userconfig$ ," WIN32FORUSER.CFG"

: LoadConfigFile { addr -- }
                addr count "path-file nip nip 0= \ search for config file
                if   addr ['] $fload catch \ load it (will display message)
                     if MESSAGE then
                else cr ." File: " addr count type ."  not found"
                then ;

: ForthBoot     ( -- )
                cls
                only forth also definitions
                set-shell
                stack-check-off           \ disable stack depth checking (can be enabled in userconfig if wanted)
                config$ LoadConfigFile
                Start-Interpreter ;

in-previous

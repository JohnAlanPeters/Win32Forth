\ $Id: Shell.f,v 1.13 2014/04/16 17:57:06 georgeahubert Exp $
\
\ SHELL support
\
\ Moved here from UTILS.F and partly rewritten by Dirk Busch
\ Dienstag, März 29 2005

cr .( Loading Shell Words...)

only forth also definitions

IN-APPLICATION


\ ((CreateProcess)) is defined in CreateProcess.f

Require CreateProcess.f

2 proc WaitForInputIdle
2 proc WaitForSingleObject

INTERNAL

: (EXEC-PROCESS-WAIT) { hProcess -- } \ Wait for terminating of a process
        INFINITE hProcess call WaitForInputIdle WAIT_FAILED <>
        if   begin
               winpause \ keep the Win32Forth message loop alive
               1 hProcess call WaitForSingleObject WAIT_OBJECT_0 =
             until
        then ;

: EXEC-PROCESS-WAIT  ( -- ) \ Wait for terminating the process
        ProcInfo @ (EXEC-PROCESS-WAIT) ;

EXTERNAL

: zEXEC-CMD     ( a1 -- f1 ) \ execute a command line
        count ((CreateProcess)) dup 0=
        if   CloseThread
             CloseProcess
        then ;

: zEXEC-CMD-WAIT ( a1 -- f1 ) \ execute a command line, and wait for terminating of the process
        count ((CreateProcess)) dup 0=
        IF   CloseThread               \ close the thread handle
             EXEC-PROCESS-WAIT         \ wait for the process
             CloseProcess              \ and close the process handle
        then ;

: EXEC-CMD      ( a1 -- f1 )
        dup +null zEXEC-CMD ;

: EXEC-CMD-WAIT ( a1 -- f1 )
        dup +null zEXEC-CMD-WAIT ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  SHELL support with interpreted string replacement for selected words
\  %FILENAME  %DIR  %LINE
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL

named-new$ &execbuf
variable &linenum  &linenum off

: execbuf+      ( a1 n1 a2 -- ) \ append to the exec buffer
        &execbuf 2dup c@ + MAXCOUNTED > abort" Too long for EXEC buffer"
        +place ;

EXTERNAL

true value new-prompt?

INTERNAL

: $EXECBUF-PREPARE ( a1 -- ) \ preprocess for file and line parameters
        base @ >r decimal
        &execbuf off            \ pre-zero the buffer
        count
        begin   2dup ascii % scan dup
        while   2dup 2>r nip - execbuf+ 2r>
                over s" %FILENAME" tuck ISTR=
                if      new-prompt?
                        if      cur-file count "path-file
                                if      cr ." File doesn't exist, create it? [Y/N] (N):"
                                        key upc 'Y' <> abort" Aborting"
                                then    execbuf+
                        else    cur-file count execbuf+
                        then    9 /string                    \ remove %FILENAME
                else
                        over s" %DIR" tuck ISTR=
                        if      &prognam count 2dup "to-pathend" nip -
                                execbuf+
                                4 /string                    \ remove %DIR
                        else
                                over s" %LINE" tuck ISTR=
                                if      &linenum @ 0 <# #s #> execbuf+
                                        5 /string            \ remove %LINE
                                else
                                        over 1 execbuf+
                                        1 /string            \ remove one % char
                                then
                        then
                then
        repeat  nip - execbuf+
                r> base ! ;

EXTERNAL

: $EXEC         ( a1 -- f1 )    \ Invoke a DOS command string with
                                \ preprocess for file and line parameters
                                \ f1 = TRUE on error
        $EXECBUF-PREPARE &execbuf EXEC-CMD ;

: $EXEC-WAIT    ( a1 -- f1 )    \ Invoke a DOS command string with
                                \ preprocess for file and line parameters
                                \ and wait for terminating of the process.
                                \ f1 = TRUE on error
        $EXECBUF-PREPARE &execbuf EXEC-CMD-WAIT ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\



create editor$  ," %DIRWinEd.exe '%FILENAME' %LINE"    MAXSTRING allot-to
create browse$  ," %DIRWinEd.exe /B '%FILENAME' %LINE" MAXSTRING allot-to
create shell$   ," CMD /C "                            MAXSTRING allot-to
create dos$     ," CMD"                                MAXSTRING allot-to

: editor"       ( -<string">- ) \ set the editor command string
                ascii " word count editor$ place ;

: browse"       ( -<string">- ) \ set the browser command string
                ascii " word count browse$ place ;

: shell"        ( -<string">- ) \ set the shell command string
                ascii " word count shell$ place ;

: dos"          ( -<string">- ) \ set the dos command string
                ascii " word count dos$ place dos$ +NULL ;



\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  User specifiable string delimiter utility
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-SYSTEM

: ,$            ( -< #text#>- )
                >in @ bl word swap >in ! 1+ c@
                word count here place here c@ 1+ allot 0 c, align ;

: .$            ( -< #text#>- )
                POSTPONE (.") ,$ ; immediate

: s$            ( -< #text#>- )
                ( -- a1 n1 )
                POSTPONE (s") ,$ ; immediate

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: .shell        ( -- )  \ display the editor, browser, shell & dos strings
                cr .$ 'EDITOR" ' editor$ count type .$ '"'
                cr .$ 'BROWSE" ' browse$ count type .$ '"'
                cr .$ 'SHELL" '   shell$ count type .$ '"'
                cr .$ 'DOS" '       dos$ count type .$ '"' ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  10  A utility to allow invoking a DOS shell on a following commandline
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-APPLICATION INTERNAL

create shell-name$ ," SHELL.BAT"  MAXSTRING allot-to
create shell-buf                  MAXSTRING allot

0 value ?shell-pause

EXTERNAL

: $shell        ( a1 -- )
                dup c@
        if      shell-name$ count w/o create-file       \ make the file
                abort" Couldn't create SHELL.BAT"
                >r                                      \ save file handle
                ( a1 ) count r@ write-file drop         \ write commandline
                crlf$  count r@ write-file drop         \ line terminator
                ?shell-pause
          if    s" PAUSE"    r@ write-file drop         \ wait for results
                crlf$  count r@ write-file drop         \ line terminator
          then  r> close-file drop                      \ close the file
                shell$      count shell-buf  place      \ the command
                shell-name$ count shell-buf +place      \ append batch name
                                  shell-buf EXEC-CMD drop \ perform command
        else    drop
                ?shell-pause
                if   dos$ EXEC-CMD drop
                then
        then    ;

: shell         ( -<string>- )
                true to ?shell-pause
                0 word $shell ;

: dos           ( -<string>- )
                false to ?shell-pause
                0 word $shell ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  25  HTML linkage support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

6 proc ShellExecute
: ("ShellExecute) { operation addr cnt hWnd --  errorcode } \ open file using default application
        SW_SHOWNORMAL         \ nShowCmd
        Null                  \ default directory
        Null                  \ parameters
        addr cnt asciiz       \ file name to execute
        operation             \ operation to perform
        hWnd                  \ parent
        Call ShellExecute ;

: "ShellExecute { addr cnt hWnd -- errorcode } \ open file using default application
        z" open" addr cnt hWnd ("ShellExecute) ;

: "Web-Link     { adr len hWnd \ web$ -- }   \ open the Web link supplied, using the web browser
                LMAXSTRING LocalAlloc: web$
                                       web$ off                 \ reset buffer initially
                adr len bl skip -trailing to len to adr         \ remove leading & trailing blanks
                adr len 4 min s" WWW."    caps-compare 0=       \ if www. present
                adr len 5 min s" FILE:"   caps-compare 0= or    \ or file: present
                adr len 5 min s" HTTP:"   caps-compare 0= or    \ or http: present
                adr len 5 min s" NEWS:"   caps-compare 0= or    \ or news: present
                adr len 4 min s" FTP:"    caps-compare 0= or    \ or ftp: present
                adr len 4 min s" FTP."    caps-compare 0= or    \ or ftp. present
                adr len 7 min s" MAILTO:" caps-compare 0= or    \ or mailto: present
                len 0= or                                       \ or NULL string
                IF      adr len         web$  LPLACE            \ then pass through un-modified
                ELSE    s" www."        web$  LPLACE            \ else prepend "www."
                        adr len         web$ +LPLACE            \ append specified string
                        s" .com"        web$ +LPLACE            \ append ".com"
                THEN
                web$ +LNULL                                     \ null terminate string
                web$ @                                          \ if there is any thing there
                IF   web$ lcount hwnd "ShellExecute drop  \ tell Windows we want this link
                ELSE beep
                THEN ;

: Web           ( -<www.???.com>- )     \ open the Web link specified, using the Web browser
                bl word count conhndl "Web-Link ;

: "file-link    ( adr len hWnd -- ) \ open a local file in default browser
                s" file:" temp$ place           \ build string
                >R Prepend<home>\ temp$ +place  \ file:<absolute path>\<file name>.<ext>
                temp$ count r> "web-link ;

MODULE


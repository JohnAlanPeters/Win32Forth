\ $Id: Utils.f,v 1.34 2016/01/03 17:58:53 jos_ven Exp $
\ UTILS.F               A file to hold some utilities   by Tom Zimmer
\ -rbs globalized path init
\ Changes February 14th, 2002 - 1:37 - rls

\ utils.f beta 2.0A 2002/08/31 arm windows ANS file words
\ utils.f beta 2.9G 2002/09/24 arm release for testing
\ utils.f beta 3.3D 2002/10/08 arm Consolidated

cr .( Loading Utility Words...)

only forth also definitions

in-application

: screen-size   ( -- width height )     \ get windows screen size
                SM_CXSCREEN call GetSystemMetrics       \ screen width
                SM_CYSCREEN call GetSystemMetrics ;     \ screen height


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  5   Display the deferred words in the system, and their *current function
\      along with the default function.
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-SYSTEM

: .deferred     ( -- )
                defer-list @
                begin   ?dup
                while   cr ." Deferred: "
                        dup cell - dup body> .NAME
                        23 col ."  does: " @ .NAME
                        45 col ."  defaults to: " dup cell+ @ .NAME
                        @
                        start/stop
                repeat  ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  5a  Display the current file
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: .cur-file     ( -- )
                ." The current file is: " cur-file count type ;

\ synonym .file    .cur-file   - made a colon def [cdo-2008May13]
: .file		\ synonym of .CUR-FILE
                .cur-file ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  5b  Set the current directory relative to the &forthdir
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: idir  ( -<optional_new_directory>- -- )
   &forthdir count "chdir chdir  ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

also hidden

: .reg_WNT\Version ( key$ len -- )  \ W32F      Tools extra    in-system
\ *G Display the string of the specified registry key in
\ ** HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
                WNT\Version GetRegistryEntry 1- dup 0>
                if   type   else   2drop   then ;
previous

: .platform-nt ( -- )         \ W32F      Tools extra    in-system
\ *G Display the Windows-NT platform the system is running on.
                s" ProductName"  .reg_WNT\Version ;

: .platform     ( -- )         \ W32F      Tools extra    in-system
\ *G Display the Windows platform the system is running on.
                winver cr ." Platform: " dup WIN2K <
                if ." Windows " then
                 case
[ version# ((version)) 0. 2swap >number 3drop 7 < ] [if]  \ For V6.xx.xx suporting older OSs
                 WIN95     of ." 95" endof
                 WIN98     of ." 98" endof
                 WINME     of ." ME" endof
                 WINNT351  of ." NT3.51" endof
                 WINNT4    of ." NT4" endof
[then]
                 WIN2008   of ." Windows SERVER 2008" endof
                 WIN2008R2 of ." Windows SERVER 2008 R2" endof
                 WIN2K >= true
                           of .platform-nt endof
                 endcase ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  7   Display the files loaded into the system
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

also hidden

: .loaded       ( -- )
                also files
                screendelay 0 to screendelay
		false to with-tabs?
                _words
                previous to screendelay ;
previous

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  display a Message Box
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-APPLICATION

: MessageBox    ( szText szTitle style hOwnerWindow -- result ) \ W32F
\ *G Display a standard windows message box, with the title sztitle and message sztext,
\ ** where both strings are null terminated. Style is one of the standard window message
\ ** box styles. If hOwnerWindow is null then the active window is used as the owner.
                dup NULL = if drop call GetActiveWindow then \ better use a valid handle
                >r 3reverse r> Call MessageBox ;

: ?MessageBox   ( flag addr len -- ) \ W32F
\ *G If flag is true display the text addr len in a modal information message box.
                asciiz  swap
                if   z" Notice!"
                     [ MB_OK MB_ICONINFORMATION or MB_TASKMODAL or ] literal
                     NULL  MessageBox
                then drop ;

: ?ErrorBox     ( flag addr len -- ) \ W32F
\ *G If flag is true display the text addr len in a modal warning message box. If OK is
\ ** pressed then perform an abort, if cancel is pressed terminate the application.
                asciiz  swap
                if   z" Application Error"
                     [ MB_OKCANCEL MB_ICONWARNING or MB_TASKMODAL or ] literal
                     NULL MessageBox
                     IDCANCEL =
                     if   bye
                     then abort
                else drop
                then ;

: ?TerminateBox ( flag addr len -- ) \ W32F
\ *G If flag is true display the text addr len in a modal stop message box. When OK is
\ ** pressed terminate the application.
                asciiz  swap
                if   z" Error Notice!"
                     [ MB_OK MB_ICONSTOP or MB_TASKMODAL or ] literal
                     NULL MessageBox drop
                     bye
                else drop
                then ;

: ErrorBox      ( addr len -- )      \ W32F
\ *G Display the text addr len in a modal error message box.
                asciiz
                z" Application Error"
                [ MB_TASKMODAL MB_ICONERROR or ] literal
                NULL MessageBox drop ;

: .ErrorBox     ( n - )              \ W32F
\ *G Display the number n in a modal error message box.
                0 (d.) ErrorBox ;

\ [cdo] this has been moved to editor-io.f
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   primitive utilities to support VIEW, BROWSE, EDIT and LOCATE
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL
EXTERNAL

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  9   Handle error returned by window functions
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

defer win-abort ' abort is win-abort

: ?win-error    ( f1 -- )       \ f1=0=failed
\ ?win-error can only be used right after a CALL. It looks at the CALL word,
\ finds the PROC and extracts the name of the function. It's a pretty nasty
\ bit of code! The bit that does it is:
\
\       r@ 2 cells - @ .proc-name
\
\ Fetches the current IP, then goes 2 cells back (the pointer is always a
\ cell ahead at the next word, so 1 cell back is the ?win-error word, 2
\ cells is the CALL). This is the pointer to the CALL CFA in the PROC; then
\ it fetches the PROC address and displays the name. Horrible.
                0= ?win-error-enabled and
                if   \ build string for error message debugging
                     WinErrMsg @ WinErrMsg OFF
                     GetLastWinErr SWAP WinErrMsg !

                     DUP NO_ERROR <>
                     if   false to ?win-error-enabled
\+ debug-io               debug-io
                          cr ." On Function: "
                          r@ 2 cells - @
\+ .proc-name             .proc-name \ Horrible...
\- .proc-name             h.
                          ."  Windows Returned Error: "
                          . temp$ count type

                          tabbing-off
                          forth-io
                          win-abort
\+ restore-io             restore-io
                     else drop
                     then
                then ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: copyfile      ( -<from to>- -- )      \ W32F
\ *G Copy a file to a directory. The from string is made up of the path (either absolute
\ ** or relative) and the file name (with extension). The to string is the path (either
\ ** absolute or relative) only; the filename is taken from the from string.
                { | from$ to$ }
                max-path localAlloc: from$
                max-path localAlloc: to$
                /parse-s$ count from$  place
                /parse-s$ count to$    place
                              to$    ?+\
                from$ count "to-pathend" to$ +place
                from$ +NULL
                to$   +NULL
                cr ." Copying: " from$  count type
                cr ."      To: " to$    count type
                false
                to$    1+
                from$  1+
                Call CopyFile 0=
                abort" The COPY Failed!" ;

in-system


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  11  More primitive utilities to support view, browse and edit
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application

variable cur-line
         cur-line off

-1 value orig-loc

in-system

: $.viewinfo    ( cfa -- line filename )
                get-viewfile 0= abort" Undefined word!"
                ."  loaded from: " over 0<
                if      2drop consfile count type 0 -1
                else    base @ >r decimal
                        dup uppercase count type 15 ?cr
                        ."  at line: "
                        swap dup 1- . swap
                        r> base !
                        dup count cur-file place
                then    ;

: .viewinfo     ( -<name>- line filename )
                bl word anyfind
                if      $.viewinfo
                else    c@ abort" Undefined word!"
                        cur-line @ cur-file
                then    over to orig-loc ;

\ [cdo] this has been moved to editor-io.f
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  12  Highlevel words used to view, browse and edit words and file
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  13  Compiler utilities
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   14  Utility to allow loading a file starting at a specified line number
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


VARIABLE START-LINE  \ Allows you to start including a file at a line number
                     \ other than 1.  Can't think of a serious use for it.
                     \ Not ANS. Dangerious, We are advised - don't use it.

: >LINE         ( n1 -- )     \ move to line n1, 1 based
                1- 0 MAX
                ?DUP
                IF      0 DO  REFILL DROP  LOOP
                THEN ;

: #fload        ( n1 -<name>- )         \ load file "name" from line n1, 1 based
                start-line !            \ set start line
                /parse-s$ $fload ;      \ do the load

: lineload      ( n1 -- )               \ load the current file from line n1
                start-line !
                cur-file $fload ;

\ [cdo] this has been moved to editor-io.f
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   15  Linkage to automatically invoke the editor on a compile error
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  16  A simple error number extension to error handling
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ : ?error        ( f1 n1 -- )    \ abort with error code n1 if f1=true
\ now as ?THROW in kernel; ?error is unused

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  17  ANSI Save and Restore Input Functions
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ In kernel

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  Compile time stack depth checking (Part 2 for Part 1 see Primeutil.f)
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-SYSTEM

\ add stack message increased
THROW_MSGS LINK, -4103 ( WARN_STACK ) , ," stack depth increased"

: _stack-check  ( -- )
                loading? 0=             \ if we are not loading
                state @ or              \ or we are in compile state,
                                        \ then don't check stack depth change
                olddepth 0< or ?exit    \ or if olddepth is below zero
                                        \ or if assembling
                context @ [ ' assembler vcfa>voc ] literal = ?exit
                depth olddepth >        \ if stack depth has increased
                if                      \ then warn of extra item on stack
                        -4103 ( WARN_STACK ) WARNMSG
                        cr ." Stack: " .s cr
                then    depth to olddepth ;

\ If interpretation of files is done in a TURNKEYed application this must be
\ reset to NOOP

\in-system-ok ' _stack-check is stack-check

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  19  Time control words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-APPLICATION

16 constant TIME-LEN

next-user dup @ aligned swap !

time-len newuser TIME-BUF
        \ +0  year
        \ +2  month
        \ +4  day of week
        \ +6  day of month
        \ +8  hour
        \ +10 minute
        \ +12 second
        \ +14 milliseconds

32 newuser date$
32 newuser time$

: get-local-time ( -- )                 \ get the local computer date and time
        time-buf call GetLocalTime drop ;

create compile-version time-len allot   \ a place to save the compile time (global)

get-local-time                          \ save as part of compiled image

time-buf compile-version time-len move  \ move time into buffer

: time&date     ( -- sec min hour day month year )
                get-local-time
                time-buf 12 + w@        \ seconds
                time-buf 10 + w@        \ minutes
                time-buf  8 + w@        \ hours
                time-buf  6 + w@        \ day of month
                time-buf  2 + w@        \ month of year
                time-buf      w@ ;      \ year

: .#"           ( n1 n2 -- a1 n3 )
                >r 0 <# r> 0 ?do # loop #> ;

: >date"        ( time_structure -- )
                >r 31 date$ null \ z" ddddd',' MMMM dd yyyy"
                r> null LOCALE_USER_DEFAULT
                call GetDateFormat date$ swap 1- ;

: .date         ( -- )
\ *G Print date in short format, based on regional setting.
                get-local-time time-buf >date" type ;

: >month,day,year" ( time_structure -- )
                >r 31 date$  z" ddddd',' MMMM dd yyyy"
                r> null LOCALE_USER_DEFAULT
                call GetDateFormat date$ swap 1- ;


: .month,day,year ( -- )
\ *G Print day and date in full.
                get-local-time time-buf >month,day,year" type ;

: >time"        ( time_structure -- )
                >r 31 time$ null
                r> null LOCALE_USER_DEFAULT
                call GetTimeFormat time$ swap 1- ;

: .time         ( -- )
\ *G Print time in 24hr format.
                get-local-time time-buf >time" type ;

: >am/pm"       ( time_structure -- )
                >r 31 time$ z" h':'mmtt"
                r> null LOCALE_USER_DEFAULT
                call GetTimeFormat time$ swap 1- ;

: .am/pm        ( -- )
\ *G Print time in 12hr format.
                get-local-time time-buf >am/pm" type ;

: .cversion     ( -- )
                cr ." Compiled: "
                compile-version dup >month,day,year" type
                             ." , " >am/pm"          type ;

: ms@           ( -- ms )
                get-local-time
                time-buf
                dup   8 + w@     60 *           \ hours
                over 10 + w@ +   60 *           \ minutes
                over 12 + w@ + 1000 *           \ seconds
                swap 14 + w@ + ;                \ milli-seconds

0 value start-time

: time-reset    ( -- )
                ms@ to start-time ;

\ ' time-reset alias timer-reset           \ made a colon def - [cdo-2008May13]
: timer-reset   \ synonym of time-reset
                time-reset ;

: .elapsed      ( -- )
                ms@ start-time -
                ." Elapsed time: "
                [ 24 60 * 60 * 1000 * ] literal mod
                1000 /mod
                  60 /mod
                  60 /mod 2 .#" type ." :"
                          2 .#" type ." :"
                          2 .#" type ." ."
                          3 .#" type ;

: elapse        ( -<commandline>- )
                time-reset interpret cr .elapsed ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

internal

fload builtby.f

external

: .Builtby      ( -- ) \ print the name of the person who built this copy of w32f
		builtby count ?dup
                if   cr ." Built by: " type
		else drop
		then ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  20  Random number generator for Win32Forth
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

3141592 value SEED1
6535897 value SEED2
9323846 value SEED3

: RANDOM        ( n1 -- n2 )    \ W32F  Utils
\ *G Get a pseudo random number between 0 and n1 as n2. n2 has the same sign as n1.
                dup 0= if 1+ then
                SEED1 177 /MOD  2*    SWAP  171 *  SWAP  - DUP  to SEED1
                SEED2 176 /MOD  35 *  SWAP  172 *  SWAP  - DUP  to SEED2
                SEED3 178 /MOD  63 *  SWAP  170 *  SWAP  - DUP  to SEED3
                +  + SWAP  MOD  ;

: RANDOM-INIT   ( -- )          \ W32F  Utils
\ *G Initialize the random number generator from the system clock. This is performed at
\ ** program initialisation.
                get-local-time
                time-buf 3 cells + @ to SEED1
                time-buf 2 cells + @ to SEED2
                time-buf 1 cells + @ to SEED3 ;

INITIALIZATION-CHAIN CHAIN-ADD RANDOM-INIT      \ randomize at boot time


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  21  Delay Time Words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ old Win32s support removed
\ September 17th, 2003 - 10:38 dbu
: _MS           ( u -- )       \ delay u milli-seconds or forever if u=-1.
                dup IF  WinPause  THEN
                Call Sleep drop ;

' _MS IS MS

: SECONDS       ( n1 -- )
                0max 0
                ?do     10 0
                        do      winpause 100 ms
                                key?
                                if      key drop
                                        unloop
                                        unloop
                                        EXIT
                                then
                        loop
                loop    ;

IN-SYSTEM

: pause-seconds ( n1 -- )
                cr ." Delaying: " dup . ." seconds, press a key to HOLD "
                SCROLLTOVIEW
                30 min 1 max 10 * 0
                ?do     100 ms
                        key?
                        if
        cr ." HOLDING,  Space=continue delaying, Enter=cancel pause, ESC=abort"
                                key     dup k_ESC =
                                if      cr ." Aborted" abort
                                then    K_CR = ?leave
                                key     dup k_ESC =
                                if      cr ." Aborted" abort
                                then    K_CR = ?leave
                                cr      ." Press a key to pause "
                        then
                loop    ;

\ synonym ?keypause  start/stop  \ from F-PC      \ made a colon def - [cdo-2008May13]
: ?KeyPause     \ synonym of START/STOP
                start/stop ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  22  File type
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: "ftype        { \ locHdl typ$ -<name>- }   \ type file "name" to the console
                max-path LocalAlloc: typ$
                "open abort" Couldn't open file!"
                to locHdl
                cur-line off
                cr ." Typing file: " open-path$ count type cr
                begin   typ$ dup MAXCOUNTED locHdl read-line
                        abort" Read Error"
                        nuf? 0= and
                while   type cr
                        10 ms
                repeat
                locHdl close-file 3drop ;

: ftype         ( -<filename>- )  \ W32F System Utils
\ *G Type the contents of file -<filename>- at the console. If no extension is supplied
\ ** then the default extension (.f) is applied. Relative paths are relative to the Forth
\ ** search path.
                /parse-s$ count "ftype ;

\ synonym flist ftype             \ made a colon def - [cdo-2008May13]
: flist
\ *G Synonym of FTYPE
               ftype ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  23  An addition to CASE OF ENDOF ENDCASE, for default case without SWAP
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: DefaultOf     ( -- ) \ define a default condition for CASE structure
                \ *** must be last in the series of OF ***
                \ avoids the use of SWAP in default CASE condition
		POSTPONE DUP POSTPONE OF ; IMMEDIATE

IN-APPLICATION

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

EXTERNAL

: make-cursor   ( cursor_constant|z.cur-adr  usingCURfile -- )
\ *G Enables various shapes of the mouse.
\ ** When a *.cur file is used the file must be in the search path
\ ** of the application.
\ ** When you have NT or better you could use resources.f
                create , ,
                does>  dup cell+ @ swap @  \ Runtime: ( - )
			if     dup>r call LoadCursorFromFile dup 0=
				if	r> z" Can not find file:"
					[ MB_TASKMODAL MB_ICONSTOP or ] literal
					NULL MessageBox 2drop abort
				else	r>drop
				then
			else   NULL Call LoadCursor
			then   Call SetCursor drop ;

\ Standard Win32 API Cursors

IDC_APPSTARTING FALSE   make-cursor appstarting-cursor
IDC_ARROW       FALSE   make-cursor arrow-cursor
IDC_CROSS       FALSE   make-cursor cross-cursor
IDC_HELP        FALSE   make-cursor help-cursor
IDC_IBEAM       FALSE   make-cursor ibeam-cursor
IDC_NO          FALSE   make-cursor noway-cursor
IDC_SIZEALL     FALSE   make-cursor sizeall-cursor
IDC_SIZENESW    FALSE   make-cursor sizenesw-cursor
IDC_SIZENS      FALSE   make-cursor sizens-cursor
IDC_SIZENWSE    FALSE   make-cursor sizenwse-cursor
IDC_SIZEWE      FALSE   make-cursor sizewe-cursor
IDC_UPARROW     FALSE   make-cursor uparrow-cursor
IDC_WAIT        FALSE   make-cursor wait-cursor

\ Cursors added from MFC

sys-FLOAD src\res\resforth.h \ load the headerfile with a few constants

here z," HAND.CUR"        TRUE    make-cursor hand-cursor
here z," SPLITV.CUR"      TRUE    make-cursor splitv-cursor
here z," SPLITH.CUR"      TRUE    make-cursor splith-cursor
here z," MAGNIFY.CUR"     TRUE    make-cursor magnify-cursor
here z," HARROW.CUR"      TRUE    make-cursor harrow-cursor


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: 2literal      ( x1 x2 -- )       \ ANSI             Double
\ *G \b Interpretation: \d Interpretation semantics for this word are undefined. \n
\ ** \b Compilation: \d ( x1 x2 -- )
\ ** Append the run-time semantics below to the current definition. \n
\ ** \b Run-time: \d ( -- x1 x2 )
\ ** Place cell pair x1 x2 on the stack.
                swap POSTPONE LITERAL POSTPONE LITERAL ; immediate

: MACRO         ( "name <char> ccc<char>" -- )    \ W32F (Wil Baden)
\ *G Create a definiton, "name and store the text cccc delimited by <char> so that when
\ ** "name is used the code is compiled or executed according to state. \n
\ ** \b Note: \d Because "name uses evaluate then the actual interpretation is sensitive to the
\ ** search order when "name is compiled or interpreted, \b not \d when defined. \n
\ ** Also "name should not be postponed into a word or stored into a deferred word,
\ ** which is called in a turnkeyed application (it causes the application to crash).
                :
                char parse POSTPONE sliteral
                POSTPONE evaluate
                POSTPONE ; immediate ;

in-application

MODULE

\ *Z



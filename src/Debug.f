\ $Id: Debug.f,v 1.25 2013/04/01 12:22:02 jos_ven Exp $
\ Changes February 14th, 2002 - 1:36 rls
\ debug.f beta 3.9K 2002/10/19 arm CONSTANT? to TRUE

cr .( Loading debug.f : Debugger...)

only forth also definitions also hidden

(( [cdo] unused words
0 value page-save
: key-breaker   ( -- )
                noop ;

: L.ID  	( nfa len -- )
                swap dup .id  c@ 31 and 1+ - spaces  ;
))


\ ------------------------------------------------------------------------------
\ defered words and their use  ---  dependencies
\ ------------------------------------------------------------------------------

\ these chains are used to later add new words types to be debugged
new-chain dbg-nest-chain        ( i*x cfa flag --  i*x cfa false | true )
new-chain .word-type-chain      ( cfa flag -- cfa false | true )
new-chain dbg-next-cell         ( ip cfa -- ip' cfa )

\ this word is defered to later hook floating point stack - actually is defined before
defer dbg-fstack        ' f.s  is         dbg-fstack
                        ' noop is-default dbg-fstack

\ theese words are defered to later hook the remote debugger
defer word-watch   ( address -- )         ' drop  is word-watch
defer stack-watch  ( -- )                 ' noop  is stack-watch
defer $watch       ( line filename -- )   ' 2drop is         $watch
                                          ' 2drop is-default $watch

\ these words are defered to later hook special use of debugger, eg lib\fmacro\profiler.f
defer debug-entry       ' noop is debug-entry   \ application init stuff
defer debug-.s          ' noop is debug-.s      \ show stack in current dbg base
defer debug-exit        ' noop is debug-exit    \ application un-init stuff

\ dependencies:
\ .execution-class         is defined in see.f
\ .execution-class-chain   is defined in see.f


\ ------------------------------------------------------------------------------
\ primatives
\ ------------------------------------------------------------------------------

[undefined] debugging? [if]
        0 value debugging?
[then]

CODE +OV?       ( n1 n2 -- f )    \ add two numbers and return true
                sub     ecx, ecx  \ if they would produce arithemtic overflow
                pop     eax
                add     ebx, eax
                jno     short @@1
                sub     ecx, # 1
@@1:            mov     ebx, ecx
                next    c;

32 value max.rstack
 0 value remote-debug?
 0 value in-breakpoint?

0 value start-watch?
0 value watched-cfa

: cfa-watch     ( cfa -- ) \ try to display the source for CFA
                with-source?
                if      dup to watched-cfa
                        dup >name name> ['] [unknown] <>
                        if      dup
                                get-viewfile >r swap
                                dup 0> r> and           \ found and not console
                                if      2dup swap $watch
                                then    2drop
                        then
                then    drop ;

2 #vocabulary bug also bug also definitions


\ ------------------------------------------------------------------------------
\ Numeric printing words that do NOT use PAD !!!
\ ------------------------------------------------------------------------------

: CHR>ASC       ( n -- char )
                dup 9 > 7 and + 48 + ;

: &             ( n1 -- char n2 )
                0 base @ um/mod swap chr>asc swap ;

: &S            ( n1 -- c1 c2 ... 0 )
                BEGIN & dup 0= UNTIL ;

: <&            ( n -- 0 n )
                0 swap ;

: &>            drop ;

: &TYPE         ( 0 c1 c2 ... -- )
                BEGIN ?dup
                WHILE emit
                REPEAT ;

: U%.           ( u -- )
	        <& &s &> &type space ;

: %.            ( n -- )
                dup 0<
                IF      abs ascii - emit
                THEN u%. ;

: 0%.R          ( n -- ) \ display signed right justified except in HEX,
                         \ then display unsigned
                base @  0x10 <>
                if      dup 0<
                        IF      abs ascii - emit
                        THEN
                then    <& &s &> &type ;

: H%.           ( n -- )
                base @ swap hex u%. base ! ;

: %.S           ( ... -- ... )
                ?stack depth .smax @ min dup
                IF   ." [" depth 1- 0%.r ." ] "
                     BEGIN
                       dup pick 0%.r
                       base @ 0x10 =
                       IF  ." h" THEN
                       space
                       1- dup 0=
                     UNTIL
                ELSE ."  empty "
                THEN
                drop ;


\ ------------------------------------------------------------------------------
\ Advance IP
\ ------------------------------------------------------------------------------

2variable ip            \ ip & contents of current breakpoint
variable ip0            \ ip at start of word
variable rtop           \ top of return stack
variable nesting        \ nesting level

0 value ?dbg-cont       \ are we stepping contiuously
0 value 'trace          \ address of the trace function

: patch  ( cfa -- )
        ip @ @ 'trace <>                \ if there is NOT a trace in the target
        if      ip @ @  ip cell+ !      \ then save old word
        then
        ip @ ! ;                        \ patch in trace word


: colon?        ( cfa -- f ) @ docol = ;

: code?         ( cfa -- f ) dup @ swap cell+ = ;

: constant?     ( cfa -- f ) @ docon = ;

: offset?       ( cfa -- f ) @ dooff = ;

: variable?     ( cfa -- f ) @ dovar = ;

: defer?        ( cfa -- f ) @ dodefer = ;

: execute?      ( cfa -- f ) ['] execute = ;

: m1cfa?        ( cfa -- f ) @ m1cfa = ;

: m0cfa?        ( cfa -- f ) @ m0cfa = ;

: unnest?       ( cfa -- f )
                @ dup ['] unnest =
                over  ['] unnestp = or
                swap  ['] unnestm = or ;

: ?JUMP         ( ip f -- ip' ) IF  CELL+ @ CELL- ELSE  2 CELLS+  THEN ;

: <STRING>      ( ip -- ip' )   CELL+ COUNT + 1+ ALIGNED ;

: (EXIT)        ( ip 'ret -- ip' )
        nip nesting @ 0>
        if      @                           \ unnest level
                dup ?name ?dup
                if      ." Unnesting to: " dup .name cfa-watch
                then    -1 nesting +!
        else    drop ip0 @   ( done, reset ip for next time )
                nesting off
        then ;

: <EXIT>        ( ip -- ip' )   rtop (EXIT) ;

: <EXITP>       ( ip -- ip' )   lp @ cell+ (EXIT) ;

: <EXITM>       ( ip -- ip' )   lp @ 2 cells+ (EXIT) ;

: dbg-next  ( -- )
   IP @   DUP @ CASE
     ['] LIT      OF  2 CELLS+                                  ENDOF
     ['] (&OF-LOCAL) OF  2 CELLS+                               ENDOF
     ['] (&OF-VALUE) OF  2 CELLS+                               ENDOF
        &FLIT     OF  CELLS/FLOAT CELLS+ CELL+                  ENDOF
     ['] (IS)     OF  2 CELLS+                                  ENDOF
     ['] COMPILE  OF  2 CELLS+                                  ENDOF
     ['] BRANCH   OF  TRUE ?JUMP                                ENDOF
     ['] _endof   OF  TRUE ?JUMP                                ENDOF
     ['] _again   OF  TRUE ?JUMP                                ENDOF
     ['] _repeat  OF  TRUE ?JUMP                                ENDOF
     ['] leave    of  drop rp@ 5 cells+ @ cell -                ENDOF
     ['] ?leave   of  over
                      if    drop rp@ 5 cells+ @ cell -
                      else  cell+ then                          ENDOF
     ['] ?BRANCH  OF  OVER 0= ?JUMP                             ENDOF
     ['] -?BRANCH OF  OVER 0= ?JUMP                             ENDOF
     ['] _until   OF  OVER 0= ?JUMP                             ENDOF
     ['] _while   OF  OVER 0= ?JUMP                             ENDOF
     ['] (DO)     OF  2 CELLS +                                 ENDOF
     ['] (?DO)    OF  OVER 3 PICK = ?JUMP                       ENDOF
     ['] (LOOP)   OF  1 RTOP @ +OV? NOT ?JUMP                   ENDOF
     ['] (+LOOP)  OF  OVER RTOP @ +OV? NOT ?JUMP                ENDOF
     ['] _OF      OF  OVER 3 PICK <> ?JUMP                      ENDOF
     ['] (S")     OF  <STRING>                                  ENDOF
     ['] (C")     OF  <STRING>                                  ENDOF
     ['] (Z")     OF  <STRING>                                  ENDOF
     ['] (.")     OF  <STRING>                                  ENDOF
     ['] (ABORT") OF  <STRING>                                  ENDOF
     ['] (;CODE)  OF  <EXIT>                                    ENDOF
     ['] (DOES>)  OF  <EXIT>                                    ENDOF
     ['] UNNEST   OF  <EXIT>                                    ENDOF
     ['] UNNESTP  OF  <EXITP>                                   ENDOF
     ['] UNNESTM  OF  <EXITM>                                   ENDOF
  ['] init-locals OF  2 cells+                                  ENDOF
   DUP @ M1CFA =  IF  SWAP CELL+ SWAP ( skip an extra cell )    THEN
                      dbg-next-cell do-chain
                      SWAP CELL+ SWAP
   ENDCASE   IP ! ;


\ ------------------------------------------------------------------------------
\ Trace Commands
\ ------------------------------------------------------------------------------

-1 value nextbreak
 0 value stack-top
 0 value return-top

create tib-save         MAXSTRING allot
create pocket-save      MAXSTRING allot
create here-save        MAXSTRING allot
create watch-buf        MAXSTRING allot
       watch-buf OFF                            \ empty to start

: perform-watch ( -- )
                state @ >r state off
                watch-buf count evaluate
                r> state ! ;

: do-watch      ( -- )
                watch-buf c@ 0= ?exit
                cr ." Watch-[" watch-buf count type ." ]: "
                ['] perform-watch catch drop ;

: run-forth
                here   here-save     MAXSTRING move
                pocket pocket-save   MAXSTRING move
                source tib-save swap MAXSTRING min move \ save SOURCE buffer
                (source) 2@ 2>r >in @ >r                \ save SOURCE and >IN
                begin   cr ." forth>  "
                        query  source nip
                while   ['] interpret catch
                        if      ." <- interpret error!" beep
                        then
                repeat
                r> >in ! 2r> (source) 2!                \ restore SOURCE and >IN
                tib-save source move                    \ restore SOURCE buffer
                pocket-save pocket MAXSTRING move
                here-save   here   MAXSTRING move ;

: dbg-watch     ( -- )
                cr ." Enter a line to interpret after each instruction step is performed:"
                cr watch-buf 1+ MAXCOUNTED accept watch-buf c! ;

0 value emit-save
0 value type-save
0 value cr-save
0 value ?cr-save
0 value key-save
0 value key?-save
0 value cls-save
0 value gotoxy-save
0 value getxy-save
0 value getcolrow-save

0 value tabing?-save
0 value left-margin-save
0 value indent-save
0 value x-save
0 value y-save


: _dbg-nest  ( cfa -- )
        dup>r  false dbg-nest-chain do-chain if r> cfa-watch exit then
        r> colon?                              \ colon definitions
        if      dup cfa-watch >body ip !
                1 nesting +! else
        dup does>?                              \ does> definitions
        if      ." DOES> nesting "
                @ 3 + @ dup                     \ offset to vector to high level code is implementation dependent
                ?name   cfa-watch
                cell- ip !
                1 nesting +! else
        dup defer?                              \ deferred words (Recursive)
        if      ." DEFER nesting " dup
                case    ['] type       of   drop       type-save  endof
                        ['] emit       of   drop       emit-save  endof
                        ['] cr         of   drop         cr-save  endof
                        ['] ?cr        of   drop        ?cr-save  endof
                        ['] key        of   drop        key-save  endof
                        ['] key?       of   drop       key?-save  endof
                        ['] cls        of   drop        cls-save  endof
                        ['] gotoxy     of   drop     gotoxy-save  endof
                        ['] getxy      of   drop      getxy-save  endof
                        ['] getcolrow  of   drop  getcolrow-save  endof
                        swap >body @ swap
                endcase dup .name
                recurse else
        dup execute?                            \ handle execute (Recursive)
        if      ." EXECUTE nesting " over .name
                drop dup recurse else
        dup m0cfa?                              \ methods type zero (Standard method calls)
        if      3 cells+ ip !
                1 nesting +! else
        dup m1cfa?                              \ methods type 1 (Object IVars)
        if      2 cells+ ip !
                1 nesting +! else
        drop ." Can't nest " beep
        then then then then then then ;

: dbg-nest      ( a1 -- )
                ip @ @ _dbg-nest ;

: dbg-unnest    ( -- )  \ not valid inside a loop or if >R has been used !
                rtop @  here u<
                rtop @  app-origin sys-offs + sys-here between or
                if      rtop @  ip !
                        -1 nesting +!
                        rtop @  ?name ?dup
                        if      ." Unnesting to: " dup .name cfa-watch
                        then
                else    ." Can't unnest " beep
                then    ;

: dbg-jump      ( -- )          \ set breakpoint beyond following branch word
                ip @ @
                case    ['] branch   of TRUE    endof
                        ['] _repeat  of TRUE    endof
                        ['] ?branch  of TRUE    endof
                        ['] -?branch of TRUE    endof
                        ['] _until   of TRUE    endof
                        ['] _while   of TRUE    endof
                        ['] (loop)   of TRUE    endof
                        ['] (+loop)  of TRUE    endof
                        ['] _of      of TRUE    endof
                        ['] UNNEST   of TRUE    endof
                        FALSE swap
                endcase
                if      ip @ 2 cells+ to nextbreak
                        nesting off
                        dbg-next
                        0x0D pushkey
                else    beep
                then    ;

: #dbg-rstack   ( a1 a2 -- )
                cr ." RETURN STACK[" 2dup swap - cell / 1 .r ." ]: "
                over max.rstack cells+ umin     \ limit return stack entries
                swap over min
                ?do     i @  ?name ?dup
                        if      i @  here u<
                                if      dup >name nfa-count type
                                        i @
                                        swap >body - cell / 1- ." +" %.
                                else    h%.
                                then
                        else    i @ h%.
                        then    12 ?cr
          cell +loop    cr ;

: dbg-rstack    ( -- )
                rp@ 1 cells + rp0 @ #dbg-rstack ;

: dbg-help      ( -- )
                cr ." ENTER/SPACE-single step"
                cr ." ESC/Q-quit, unbug, abort"
                cr ."  C-continuous step till key"
                cr ."  D-done, run the program"
                cr ."  F-forth commandline"
                cr ."  H-Hex display toggle"
                cr ."  J-Jump over next Word"
                cr ."  N-nest into this definition"
                cr ."  P-proceed to def again"
                cr ." ^P-proceed to this point again"
                cr ."  R-show Return stack"
                cr ."  U-unnest to definition above"
                cr ."  V-Vocabulary search order"
                cr ."  W-watch commands" ;

: .wordtype     ( -- )
                ip @ @ false .word-type-chain do-chain ?exit
                        dup colon?
                if      drop ."    :   " exit
                then    dup execute?
                if      drop             exit
                then    dup code?
                if      drop ." code   " exit
                then    dup variable?
                if      drop ." var    " exit
                then    dup does>?
                if      drop ." does   " exit
                then    dup constant?
                if      drop ." const  " exit
                then    dup offset?
                if      drop ." offset " exit
                then    dup defer?
                if      drop ." defer  " exit
                then    dup  m0cfa?
                        over m1cfa? or
                if      drop ." Meth:  " exit
                then    drop
                7 spaces ;

0 value debug-base

: .s-base       ( -- )
                base @ >r debug-base base ! %.s r> base ! ;

' .s-base is debug-.s

: f.s-debug     ( -- )  \ display the floating point stack while debugging
                fdepth
                IF      fdepth  ." {" 1 .r ." } "
                show-fp-depth fdepth umin dup 1- swap 0
                        DO      10 ?cr
                                dup i - fpick g.
                        LOOP
                        drop
                ELSE    ." Empty fp stack "
                THEN ;

: base-toggle   ( -- )
                debug-base 0x10 =
                if      0x0A to debug-base
                else    0x10 to debug-base
                then    ;

: restore-io    ( -- )
                key-save 0= ?exit
                tabing?-save     to tabing?
                left-margin-save to left-margin
                indent-save      to indent
                key-save action-of key = ?EXIT
                emit-save        is emit
                type-save        is type
                  cr-save        is cr
                 ?cr-save        is ?cr
                 key-save        is key
                key?-save        is key?
                 cls-save        is cls
                gotoxy-save      is gotoxy
                getxy-save       is getxy
                getcolrow-save   is getcolrow
                remote-debug?
                if      x-save y-save gotoxy    \ restore cursor position
                then
                0                to key-save    \ clear key saved cfa/flag
                tabbing-off
                FALSE to in-breakpoint? ;       \ flag for remote debugger

: debug-io      ( -- )
                action-of key key-save = ?EXIT     \ leave already saved
                getxy              to y-save  to x-save
                action-of emit      to   emit-save   \ save current contents
                action-of type      to   type-save
                action-of cr        to     cr-save
                action-of ?cr       to    ?cr-save
                action-of key       to    key-save
                action-of key?      to   key?-save
                action-of cls       to    cls-save
                action-of gotoxy    to gotoxy-save
                action-of getxy     to  getxy-save
                action-of getcolrow to    getcolrow-save
                tabing?             to tabing?-save
                left-margin         to left-margin-save
                indent              to indent-save
                remote-debug? 0=
                IF      \ console debugging
                        unhide-console           \ activate full console
                        normal-console
                        forth-io
\             key-save           ( ['] x_key )     is key     \ [cdo] if forth-io is restored then
\             key?-save          ( ['] x_key?)     is key?    \ keep current action-of keying
\ so : not needed : tests ==> yes, ok
                        16             to left-margin
                        -16            to indent
                        tabing-on
                else    \ remote debugging
\ allow keying in console ???
\ pb: the messages sent from IDE are actually received by Console BUT they are
\     not executed until at least the mouse flies over the console ...
\ looks like messages are received but not decoded until we activate something
\ in the console ( a message loop ?)
                        ['] drop       is emit
                        ['] 2drop      is type
                        ['] noop       is cr
                        ['] drop       is ?cr
             key-save   ( ['] x_key )   is key    \ [cdo] for remote debugging
             key?-save  ( ['] x_key? )  is key?   \ let current key defered ???
                        ['] noop       is cls
                        ['] k_noop2    is getcolrow
                        ['] k_noop2    is getxy
                then    ;

\ -------------------- Trace Breakpoint --------------------

: trace  ( ? -- )
        dup to stack-top
        TRUE to in-breakpoint?          \ flag for remote debugger
        debug-entry
        debug-io
        rp@ to return-top
\ *** Moved WinEd start from here, because we needed to clear the breakpoint
\ *** before executing some kernel words, to prevent recursive breakpoints
        r>
        r@ rtop !
        cell - dup >r

         ip @ <>
        IF      true abort" trace error"
        THEN
        ip 2@ !  ( restore )
\ ***  Start WinEd after restoring breakpoint ---
        start-watch? ?dup               \ bring up WinEd if needed
        IF      cfa-watch
                false to start-watch?
        THEN
\ ***  Start WinEd after restoring breakpoint ---
        getxy drop 25 >         \ if column greater than 25
        IF      first-line
                cr 25 col
        THEN
        debug-.s
        stack-watch
        first-line
        do-watch
        0tab
        remote-debug? 0=
        IF      cr \ [cdo] replaced x_cr by cr (to avoid use of w32fconsole.dll)
        THEN    .wordtype
        nesting @ 0max ?dup
        IF      0 do ." |" loop space
        THEN
        obj-save >r
        ip @ word-watch
        debugging? >r true to debugging?
        ip @ dup  @
\in-system-ok  .execution-class drop
        r> to debugging?
        ip @ @ execute?
        IF      ." [ "
                stack-top .name
                ." ]"
        THEN

        r> to obj-save
        20 nesting @ ?dup if 1+ - then getxy drop max col
        getxy drop 20 >
        if      cr 20 col
        then    ."  --> "
        ?dbg-cont                               \ are we doing continuous steps
        IF      key?                            \ did user press a key
                IF      key drop              \ then discard it
                        false to ?dbg-cont      \ stop continuous
                        key upc               \ and wait for next command
                ELSE    ip @ @
                        dup  ['] UNNEST  =      \ if at UNNEST
                        over ['] UNNESTP = or   \ or at UNNESTP
                        over ['] UNNESTM = or   \ or at UNNESTM
                        nip
                        IF      false to ?dbg-cont \ stop continuous
                                key upc          \ and wait for next command
                        ELSE    0x0D               \ else just do an 'enter'
                        THEN
                THEN
        ELSE    key upc                       \ not continuous, get a key
        THEN
        CASE
          ascii P OF  ip0 @ ip ! nesting off            ENDOF
           ctrl P OF  ip @ to nextbreak nesting off
                      dbg-next 0x0D pushkey             ENDOF
          ascii J OF  dbg-jump                          ENDOF
          ascii C OF  true to ?dbg-cont                 ENDOF   \ continuous
          ascii D OF  ip off  restore-io debug-exit
                                               EXIT     ENDOF
          ascii H OF  base-toggle                       ENDOF
          ascii N OF  dbg-nest                          ENDOF
          ascii U OF  dbg-unnest                        ENDOF
          ascii F OF  run-forth                         ENDOF
          ascii . OF  dbg-fstack                        ENDOF
          ascii R OF  dbg-rstack                        ENDOF
\in-system-ok 'V' OF  ORDER                             ENDOF
          ascii W OF  dbg-watch                         ENDOF
\in-system-ok 'O' OF  cr order                          ENDOF
          ascii Q OF  ip off  ." unbug" restore-io forth-io
                                                abort   ENDOF
               27 OF  ip off  ." unbug" restore-io forth-io
                                                abort   ENDOF
          ascii ? OF  dbg-help                          ENDOF

\       **** other keys just cause debugger step execution ****
                      >r dbg-next ( default )
                      nextbreak -1 <>
                      IF        nextbreak ip !
                                -1 to nextbreak
                      THEN
                      r>
        endcase
        restore-io
        debug-exit
        [ last @ name> ] literal patch ;        \ patch in trace

' trace to 'trace

: tracing ( cfa -- )
                dup ip0 ! ip !
                ['] trace patch
                nesting off ;


\ ------ Added for SEE; replaces TRACE with the traced word ---

[defined] .execution-class-chain [if]

: .debug-trace  ( ip cfa flag -- ip' cfa flag )
                dup ?EXIT                       \ leave if non-zero flag
                over 'trace =                   \ is it a trace?
                if      2drop ." ( TRACE) "    \ print debug
                        ip cell+ @ false        \ let see handle it
                then    ;

.execution-class-chain chain-add .debug-trace

[then]

\ -------------------- Initialize Debugger --------------------

forth definitions

: _.rstack      ( -- )
                rp@ rp0 @ #dbg-rstack ;

' _.rstack is .rstack

: unbug  ( -- ) \ terminates debugging
        ip @
        if      ip 2@ !  ip off
        then    ;

: unbp   ( -- ) \ synonym of UNBUG
                unbug ;

: remote-debug  ( cfa -- flag ) \ set a breakpoint at cfa from remote editor
                                \ return flag : TRUE=success, FALSE=fail
                unbug                       \ clear any existing breakpoint
                dup cfa-watch
                dup to start-watch?
        begin   false to obj-save
                false to ?dbg-cont          \ turn off continuous step
                base @ to debug-base
                dup  colon?
                over does>?  or
                over defer?  or
                0=
                if      drop FALSE EXIT     \ ERROR EXIT !
                then    dup  colon?
                if      >body   TRUE
                else    dup does>?
                        if      TRUE
                        else    >body @ FALSE
                        then
                then
        until   tracing
                TRUE to remote-debug?   \ disable local display of debug info
                TRUE ;

: adebug        ( cfa -- ) \ set a breakpoint at cfa from Forth interpreter
                unbug                   \ clear any existing breakpoint
                FALSE to remote-debug?  \ enable local display of debug info
                dup to start-watch?
        begin   false to obj-save
                false to ?dbg-cont      \ turn off continuous step
                base @ to debug-base
                dup  colon?
                over does>?  or
                over defer?  or
                0=
           if   cr ." Must be a :, DEFER or DOES> definition"
                drop EXIT
           then  dup  colon?
           if   >body
                TRUE
           else dup does>?
                if      ." DOES> nesting "  @ 3 + @ cell- \ addr from does-call, code
                        TRUE
                else
                    ." DEFER nesting "
                        >body @ dup .name FALSE
                then
            then
        until tracing ;

: ndbg          ( - )  \ while debugging, use "F" command (do Forth command)
                       \ and execute this word to display data stack
                ['] .s-base is debug-.s ;

: debug         ( -<name>- ) \ start the debugger to debug the word <name>
                             \ put any parameters needed by <name> before
                ndbg  ' adebug ;

: fdbg          ( - )  \ while debugging, use "F" command (do Forth command)
                       \ and execute this word to display floating stack
                ['] f.s-debug is debug-.s ;

: fdebug        ( -<name>- ) \ same as DEBUG but displays floating data stack
                fdbg ' adebug ;

\ fdbg and ndbg can be used after the F command while debugging.
\ So you can switch between the stacks while debugging
\ see also mDebug for methods

: bp            ( -<name>- ) \ synonym of DEBUG
                debug ;

IN-APPLICATION

: debug-io
                 TURNKEYED? ?EXIT
\IN-SYSTEM-OK    debug-io
                 ;
: restore-io
                 TURNKEYED? ?EXIT
\IN-SYSTEM-OK    restore-io
                 ;

IN-SYSTEM

: dbg           ( -<name>- )                    \ debug a word now
                >in @ debug >in ! ;

: watch         ( -<watch_command_line>- )      \ install a watch commandline
                0 word c@
                if      pocket count watch-buf place
                else    dbg-watch
                then    ;

: ?unbug        ( nfa -- nfa ) \ If word being debugged is being forgotten unbug
                dup ip @ trim? if unbug then ;

forget-chain chain-add ?unbug


: #patchinto    ( a1 n1 -<name1 name2>- ) \ patch a1 into name1 at name2
                >r                        \ at occurance n1
                bl word anyfind 0= abort" Couldn't find the patchinto function"
                bl word anyfind 0= abort" Replacable word isn't defined"
                swap dup 0x200 ['] unnest lscan
                0= abort" Couldn't find end of the function"
                over - rot
                r> 0
                do      dup>r lscan dup
                        0= abort" Couldn't find the replacable word in function"
                        1- swap cell+ swap
                        r>
                loop    2drop cell - ! ;

: patchinto     ( a1 -<name1 name2>- ) \ Patch a1 into the definition name1
                1 #patchinto ;         \ at the first occurance of name2


only forth also definitions

: with-source   ( -- )
                TRUE to with-source? ;

with-source     \ default to using source

: without-source ( -- )
                FALSE to with-source? ;

\S

: test1  dup dup + + ;
: test2  test1 test1 ;
: test3  1 test2 test2 drop ;

variable foo
: test4  foo @ if  foo @ test2 .  then ;

: test5  10 0 do i foo +! loop ;

: wf  ." foo = " foo ? ;

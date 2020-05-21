\ $Id: Primutil.f,v 1.72 2014/08/06 12:50:24 georgeahubert Exp $

\ load extensions
\ Changes February 14th, 2002 - 1:38 - rls

\ primutil.f beta 2.0A 2002/08/31 arm windows memory managagement
\ primutil.f beta 2.9G 2002/09/24 arm release for testing
\ primutil.f beta 2.9G 2002/10/08 arm Consolidated
\ primutil.f beta 4.9C 2003/02/13 arm Added defered CRTAB, conDC now uses Call GetDC from JvdVen
\ primutil.f beta 4.9C 2002/10/24 rbs Added FORGET chain support for procs, libs
\ primutil.f beta 4.9D 2003/02/19 arm Better OS version support
\ primutil.f beta 501D 2003/02/19 gah \in-system-ok modified to reset sys-warning? on error

cr .( Loading Primutil.f : Primitive Utilities...)

DECIMAL                                 \ start everything in decimal

: HOLDS         ( c-addr u -- )       \ 200X core-ext
\ *G Add string c-addr u to pictured numeric output buffer.
                begin ?dup while 1- 2dup + c@ hold repeat drop ;

\ -------------------- Address Conversion -----------------------------------

in-system

: REL>ABS   	( relAddr -- absAddr )
                \ v4 and previous versions : convert relative to absolute address
                \ post v4 : is a noop (win32forth loads at an absolute address)
                ; IMMEDIATE deprecated
: ABS>REL       ( absaddr -- reladdr )
                \ v4 and previous versions : convert absolute to relative address
                \ post v4 : is a noop (win32forth loads at an absolute address)
                ; IMMEDIATE deprecated

in-application

: exception@    &except @    ;  \ exception occured since starting execution?

in-system

: ascii    char          state @ if postpone literal then ; immediate
: alt      char 4096  or state @ if postpone literal then ; immediate
: ctrl     char   31 and state @ if postpone literal then ; immediate

in-application

0 value doClass         \ cfa for classes, initialized in CLASS.F
0 value do|Class        \ cfa for invisible classes, initialized in CLASS.F

: ?isClass      ( cfa -- f ) \ check if cfa point's to a class
                @ dup doCLass =
                swap do|Class = or ;

in-system

\ The following makes sure internal words in classes have their headers
\ placed into system space
:noname          ( voc -- f )  \ true if wordlist is a class
                 voc>vcfa ?isClass ; is class>sys

\ turn almost any def into a deferred word and make it execute 'cfa'
: makedefer     ( cfa -<name>- )
                ' >r dodefer r@ ! r> cell+ ! ;

: breaker       ( -- )  \ just a place to put a breakpoint if needed
                noop ;

\ synonym .. reset-stacks          \ - made a colon def - [cdo-2008May13]
: ..            \ synonym of RESET-STACKS
                reset-stacks ;

\ synonym stop/start start/stop    \ - made a colon def - [cdo-2008May13]
: stop-start    \ synonym of START/STOP
                start/stop ;

defer .rstack            ' noop         is .rstack
defer ResetSrcInfo       ' drop         is ResetSrcInfo
defer save-source        ' noop         is save-source

IN-APPLICATION

defer "message ( addr len -- ) ' 2drop        is "message
defer "top-message       ' 2drop        is "top-message
defer message-off        ' noop         is message-off

FALSE value with-source?

4 PROC DefWindowProc

: _DefaultWindowProc ( hwnd msg wparam lparam -- res )
                4reverse call DefWindowProc ;

defer DefaultWindowProc  ' _DefaultWindowProc is DefaultWindowProc

: _\n->crlf     ( a1 n1 -- )    \ parse "\n" occurances, change to CRLF's
                begin   [char] \ scan dup               \ found a '\' char
                while   over 1+ c@ [char] n =           \ followed by 'n'
                        if      over 13 swap c!         \ replace with CR
                                over 10 swap 1+ c!      \ replace with LF
                        then    1 /string               \ else skip '\' char
                repeat  2drop   ;

' _\n->crlf is \n->crlf                 \ link into kernel deferred word

: -null,        ( -- )
                5 0                     \ remove previous nulls
                do      here 1- c@ ?leave
                        -1 ALLOT
                loop    ;

\ Moved to user area to make asciiz thread safe gah 28jun04
MAXSTRING newuser z-buf

: asciiz        ( addr len -- buff-z )
                z-buf ascii-z ;

: +z,"          ( -<text">- )
                -null, z," ;

: +z",          ( a1 n1 -- )
                -null, z", ;

: not           0= ;

: get-commandline ( -- )        \ initialize TIB from the commandline
                0 to source-id
                cmdline (source) 2!
                >in off ;

in-system

\ changed to fix 'Record:' bug
\ September 16th, 2003 - 10:27 dbu
: cfa-func      ( -<name>- )
                0 constant -cell allot \ header docon compile, ( code-here , )
                hide !csp dodoes-call, ] ;

defer enter-assembler ' noop is enter-assembler
defer exit-assembler  ' noop is exit-assembler

: cfa-code      ( -<name>- )
                code-here constant \ header docon compile, ,
                enter-assembler ;

: cfa-comp,     ( cfa -- )      \ compile or execute a CFA
                state @ if compile, else execute then ;

: .USERSIZE     ( - )           \ Shows what is left in the user-area
                USERSIZE 3 CELLS - NEXT-USER @
                cr ." Next-user at " DUP .
                cr ." Free user space " - . ." bytes" ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       words to set the default function for a deferred word
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-application

: _is-default   ( cfa -- )
                >body [ 2 cells ] literal + ! ;

: _restore_default ( -- )
                @(ip) >body dup 2 cells + @ swap ! ;

in-system

: is-default    ( cfa -<name>- )
\ *G Set the default field of a deferred word.
                state @
                if      POSTPONE @(ip) POSTPONE _is-default
                else    ' _is-default
                then    ; immediate

: restore-default ( -<name>- )
\ *G Reset name to its default function.
                state @
                if      POSTPONE _restore_default
                else    ' >body dup 2 cells + @ swap !
                then    ; immediate

: action-of     ( "<spaces>name" -- xt ) \ 200X   system      Core ext x:deferred
\ *G Return xt that deferred word name is set to. When compiling put into current def.
                ' ?is >BODY
                state @
                if      postpone literal postpone @
                else    @
                then    ; immediate

in-application


: defer@        ( xt1 -- xt2 )           \ 200X               Core ext x:deferred
\ *G xt1 is deferred word. xt2 is current setting.
                ?is >body @ ;

: DEFER!        ( xt2 xt1 -- )           \ 200X               Core ext x:deferred
\ *G xt1 is deferred word. xt2 is new setting.
                ?is >body ! ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Move multiple values to and from return stack
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: N>R  ( i*x +n -- ) ( R: -- j*x +n ) \       "n-to-r"   200X TOOLS EXT
\ *G Interpretation: must be paired with NR> on the same line.
\ ** Execution: Remove n+1 items from the data stack and store them for later retrieval by NR>.
\ ** The return stack may be used to store the data. Until this data has been retrieved by NR>:
\ ** this data will not be overwritten by a subsequent invocation of N>R and
\ ** a program may not access data placed on the return stack before the invocation of
\ ** N>R.

\ *P NOTE: +n MUST not exceed 8191 (or 1023 during callbacks) minus the number of values previously
\ ** placed on the return stack OTHERWISE the user area (or for callbacks the data stack will be
\ ** corrupted probably causing a CRASH.
r> over begin ?dup while >r rot r> swap >r 1- repeat swap >r >r ;

: NR>  ( -- i*x +n ) ( R: j*x +n -- ) \       "n-r-from" 200X TOOLS EXT
\ *G Interpretation: must be paired with N>R on the same line.
\ ** Execution: Retrieve the items previously stored by an invocation of N>R. n is the number of items
\ ** placed on the data stack. It is an ambiguous condition if NR> is used with data not stored by N>R.
r> r> dup begin ?dup while r> swap >r -rot r> 1- repeat swap >r ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: HIWORD        ( n1 -- n2 )
                word-split nip ;

: LOWORD        ( n1 -- n2 )
                word-split drop ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: "HOLD         ( adr len -- )
                dup negate hld +! hld @ swap move ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

cfa-func DoImport ( i*x -- res )
                dup>r cell+ @ S-REVERSE \ reverse the stack arguments
                r> perform ;

in-system

: \IN-SYSTEM-OK ( -<line_to_interpret>- )
\ *G Suppress in-system warnings for the rest of the current line, restoring the previous
\ ** state of the sys-warning? flag afterwards, even if an error occurs.
                sys-warning? >r
                sys-warning-off
                ['] interpret catch
                r> to sys-warning? throw ; immediate

: Suppress-system suppress on ;

: allot-to      ( n1 -- )
\ *G Extend the dictionary space of most recent word compile to length n1.
                last @ name> >body here swap - - dup 0<
                abort" buffer is already too long!" allot ;

: as            ( 'name' -- ) \ make name an alias of call last winproc
                winproc-last @ proc>cfa alias ;

: import:       ( c "name" -- )
\ *G Create a word "name" in the current vocabulary that when it executes reverses the top c items on
\ ** the data stack and then executes the DLL function "name".
\ *P \b NOTE \d this word also executes PROC, which can be aliased with AS that behaves the same as if
\ ** c PROC "name" has been executed.
\in-system-ok   >IN @ >r dup proc r> >IN ! \ make sure proc exists before doing create
                header DoImport compile,
                winproc-last @ proc>cfa , , \ cfa then number of arguments for this proceedure
                ;

: Buffer:       ( defining: +n "name" -- child's runtime: -- a-addr )
\ *G Create a buffer +n bytes long. The address of the buffer is aligned.
                Create allot ;

in-application

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

1 PROC PathRemoveFileSpec    as (call-prfs)
1 PROC PathRemoveExtension   as (call-pre)

: ("path-func") ( a1 n1 xt -- a2 n2 )   \ execute path function
                -rot                    \ save the xt under the string
                over >r                 \ save original address
                MAX-PATH _localalloc    \ allocate space on stack
                ascii-z dup>r           \ make a zstring
                swap execute drop       \ call the function
                r> zcount               \ count the chars
                _localfree
                nip r> swap             \ use original address
                ;

: "path-only"   ( a1 n1 -- a2 n2 )      \ return path, minus final '\'
                ['] (call-prfs) ("path-func")
                ;

: "minus-ext"   ( a1 n1 -- a2 n2 )      \ remove the file extension
                ['] (call-pre) ("path-func")
                ;

: ".ext-only"   ( a1 n1 -- a1 n1 )      \ returns dotted file extension
                2dup "minus-ext" nip /string ;

: endchar?      ( a1 char -- flag )          \ check the end character in a c-string
                swap dup c@ + c@ = ;

: ?-\           ( a1 -- )       \ delete trailing '\' if present
                dup [char] \ endchar?           \ end in '\'?
                if      -1 swap c+!             \ if so, delete it
                else    drop                    \ else discard a1
                then    ;

: ?+\           ( a1 -- )       \ append a '\' if not already present
                dup [char] \ endchar?           \ end in '\'?
                if      drop                    \ discard a1
                else    s" \" rot +place        \ if not, append \
                then    ;

: ?+;           ( a1 -- )       \ append a ';' if not already present
                dup [char] ; endchar?           \ end in ';'?
                if      drop                    \ discard a1
                else    s" ;" rot +place        \ if not, append ;
                then    ;

IN-APPLICATION

: EXEC:         ( n1 -- )       \ execute the n1 item following
                CELLS R> + @ EXECUTE ;

: ROLL          ( n1 n2 .. nk k -- n2 n3 .. nk n1 )
\  Rotate k values on the stack, bringing the deepest to the top.
                DUP>R PICK SP@ DUP CELL+ R> CELLS CELL+ MOVE DROP ;

: CS-PICK       ( dest .. u -- dest )   \ pick both addr and ?pairs value
                2 * 1+ dup>r pick r> pick ;

: CS-ROLL       ( dest -- u .. dest )   \ roll both addr and ?pairs value
                2 * 1+ dup>r roll r> roll ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  Compile time stack depth checking (Part 1 for Part 2 see Utils.f)
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-2 value olddepth

: stack-check-off ( -- )
                -2 to olddepth ;

: stack-check-on ( -- )
                olddepth -2 = if depth to olddepth then ;

: nostack       ( -- )
                olddepth -2 <> if -1 to olddepth then ;

: nostack1      ( -- )
                olddepth -2 <> if depth to olddepth then ;

\ synonym checkstack nostack1          \ made a colon def - [cdo-2008May13]
: checkstack    \ synonym of nostack1
                nostack1 ;

: stack-empty?  ( -- )
                depth abort" The stack should have been empty here!" ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ MSTARSL.F     ANSI extended precision math by Robert Smith
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: TNEGATE   ( t1lo t1mid t1hi -- t2lo t2mid t2hi )
        >r  2dup or dup if drop  dnegate 1  then
        r> +  negate ;

: UT*   ( ulo uhi u -- utlo utmid uthi )
        swap >r dup>r
        um* 0 r> r> um* d+ ;

: MT*   ( lo hi n -- tlo tmid thi )
        dup 0<
        IF      abs over 0<
                IF      >r dabs r> ut*
                ELSE    ut* tnegate
                THEN
        ELSE    over 0<
                IF      >r dabs r> ut* tnegate
                ELSE    ut*
                THEN
        THEN ;

: (UT/) ( utlo utmid uthi n -- d1 n )
        dup>r um/mod -rot r> um/mod
        -rot 0<> negate ;

: UT/   ( utlo utmid uthi n -- d1 )
        (ut/) drop ;

: M*/  ( d1 n1 +n2 -- d2 )
        >r mt* dup 0<
        IF      tnegate r> (ut/) s>d d+ dnegate
        ELSE    r> ut/
        THEN ;

: M+    ( d1 n -- d2 )
        s>d d+ ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: \-            ( "word" -- )
\ *G Interpret the rest of the line if "word" isn't defined.
                defined nip
                if      POSTPONE \
                then    ; immediate

: \+            ( "word" -- )
\ *G Interpret the rest of the line if "word" is defined.
                defined nip 0=
                if      POSTPONE \
                then    ; immediate

IN-APPLICATION

: APP-RESERVE   ( n1 -- )               \ allot some bytes initialized to NULL
                0max app-here over erase app-allot ;

DEFER RESERVE   ' APP-RESERVE IS RESERVE

: SYS-RESERVE   ( n1 -- )               \ allot some bytes initialized to NULL
                0max sys-here over erase sys-allot ;

: C+PLACE       ( c1 a1 -- )    \ append char c1 to the counted string at a1
                dup cincr count + 1- c! ;

\ ,"TEXT" also detect \T embeded in the text and replaces it with a TAB char
\ Note: ,"TEXT" is partly brocken. It only detects and replaces the first \T
\ in the text all other \T's will not be changed.
: ,"TEXT"       ( -<"text">- )  \ parse out quote delimited text and compile
                                \ it at here  NO EXTRA SPACES ARE NEEDED !!!
                source >in @ /string
                [char] " scan 1 /string                 \ skip past first quote
                2dup [char] " scan                      \ upto next quote
                2dup 2>r nip -                          \ parse out the string
                "CLIP" dup>r
                2dup \n->crlf                           \ fix newlines
                2dup [char] \ scan 2dup 2>r nip -       \ leading part of string
                here place                              \ save in BNAME
                2r>
                -IF     over 1+ c@ upc [char] T =
                        IF      9         here c+place
                                2 /string here  +place
                                r> 1- >r
                        ELSE    here +place
                        THEN
                ELSE    2drop
                THEN
                r> 1+ allot
                0 c,                            \ null terminate name
                source nip 2r> 1 /string nip - >in !    \ adjust >IN
                ;

: CONVERT       ( ud1 c-addr1 -- ud2 c-addr2 )   \ ANSI       Core Ext
\ *G ud2 is the result of converting the characters within the text beginning at the
\ ** first character after c-addr1 into digits, using the number in BASE, and adding
\ ** each digit to ud1 after multiplying ud1 by the number in BASE. Conversion continues
\ ** until a character that is not convertible is encountered. c-addr2 is the location
\ ** of the first unconverted character. An ambiguous condition exists if ud2 overflows.
\ *P \b Note: \d This word is obsolescent and is included as a concession to existing
\ ** implementations. Its function is superseded by >NUMBER.
                char+ 64 >number drop ; deprecated

VARIABLE SPAN   ( -- a-addr )                     \ ANSI        Core Ext
\ *G a-addr is the address of a cell containing the count of characters stored by the
\ ** last execution of EXPECT.
\ *P \b Note: \d This word is obsolescent and is included as a concession to existing
\ ** implementations.
deprecated

DPR-WARNING? DPR-WARNING-OFF

: EXPECT        ( a1 n1 -- )            \ accept the text
                accept span ! ; deprecated

to DPR-WARNING?

: UNUSED        ( -- n1 )               \ return unused HERE in BYTES
                app-free nostack1 ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\      2Value words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: 2+!           ( d1 a1 -- )            \ double accumulate
                dup>r 2@ d+ r> 2! ;

\ cfa-func do2value              @ 2@  ;    \ in the kernel
  cfa-func do2value!   2 cells - @ 2!  ;
  cfa-func do2value+!  3 cells - @ 2+! ;

: 2value        ( d1 -<name>- )
\in-system-ok  header  do2value , here 3 cells+ , do2value! , do2value+! , , , ;

\ synonym 2to   to  \ Sets a 2value      \ made a colon def - [cdo-2008May13]
\ synonym 2+to +to                       \ made a colon def - [cdo-2008May13]
IN-SYSTEM
: 2to           ( d <name> -- ) \ store a double in a 2VALUE
                postpone to ; IMMEDIATE
: 2+to          ( d <name> -- ) \ add a double to a 2VALUE
               postpone +to ; IMMEDIATE
IN-APPLICATION

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\      Command line argument words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 0 2value arg"
0 0 2value arg-pos"


: "arg-next"    ( a1 n1 -- a2 n2 )
                bl skip 2dup bl scan nip -
                2dup bl scan 2dup 2>r nip - 2dup 2to arg"
                2r> 2to arg-pos" ;

: arg-1"        ( -- a1 n1 )
                cmdline upper
                cmdline "arg-next" ;

: arg-next"     ( -- a1 n1 )
                arg-pos" "arg-next" ;

: arg-ext"      ( -- a1 n1 )
                arg" "to-pathend" ".ext-only" ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-SYSTEM

\ A word to look through all vocabularies for a matching word to string a1
\ return cfa of nearest definition at or below a1
: ?name         { ?name-val \ ?name-max -- cfa }
                ?name-val aligned cell+ to ?name-val
                appInst to ?name-max    \ don't want any below the origin
                voc-link
                begin   @ ?dup
                while   dup vlink>voc
                        dup voc#threads 0
                        do      dup i cells +
                                begin   @ ?dup
                                while   dup l>name name> ?name-val u<
                                        if      dup l>name name>
                                                ?name-max umax to ?name-max
                                        then
                                repeat
                        loop    drop
                repeat  ?name-max ;

: ?.name        ( cfa -- )      \ try to display the name at CFA
                dup ?name ?dup
                if      .name
                else    dup ." 0x" 1 h.r ."  "
                then    drop ;

: ID.           ( nfa -- )
                NAME> >NAME .ID ;

IN-APPLICATION

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       various number display words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: (.)           ( n1 -- a1 n1 ) \ convert number n1 to an ascii string
                s>d (d.) ;

\ double number display with commas

: (xUD,.)       ( ud commas -- a1 n1 )
                >r
                <#                      \ every 'commas' digits from right
                r@ 0 DO # 2DUP D0= ?LEAVE LOOP
                BEGIN   2DUP D0= 0=     \ while not a double zero
                WHILE   [char] , HOLD
                        r@ 0 DO # 2DUP D0= ?LEAVE LOOP
                REPEAT  #> r> drop ;

: (UD,.)        ( ud -- a1 n1 )
                base @             \ get the base
                dup  10 =          \ if decimal use comma every 3 digits
                swap  8 = or       \ or octal   use comma every 3 digits
                4 + (xUD,.) ;      \ display commas every 3 or 4 digits

: UD,.R         ( ud l -- )        \ right justified, with ','
                >R (UD,.) R> OVER - SPACES TYPE ;

: U,.R          ( n1 n2 -- )       \ display double unsigned, justified in field
                0 SWAP UD,.R ;

: UD.           ( ud -- )          \ display double unsigned
                0 UD,.R ;

: UD.R          ( ud l -- )        \ right justified, WITHOUT ','
                >R 16 (xUD,.) R> OVER - SPACES TYPE ;

: (D.#)         ( d1 n1 -- a1 n1 ) \ display d1 with n1 places behind DP
                >R <#              \ n1=negative will display'.' but no digits
                R> ?DUP            \ if not zero, then display places
                IF      0 MAX 0 ?DO # LOOP [char] . HOLD
                THEN    #S #> ;

: D.R.#         ( d1 n1 n2 -- )    \ print d1 in a field of n1 characters,
                                   \ display with n2 places behind DP
                SWAP >R (D.#) R> OVER - SPACES TYPE ;

: .R.1          ( n1 n2 -- )       \ print n1 right justified in field of n2
                0 SWAP 1 D.R.# ;   \ display with one place behind DP

\ BINARY double number display with commas

: BUD,.R ( ud width -- ) BASE @ >R BINARY  UD,.R R> BASE ! ; deprecated
: BU,.R  ( n1 width -- ) BASE @ >R BINARY   U,.R R> BASE ! ; deprecated
: B.     ( n1 -- )       BASE @ >R BINARY 1 U,.R R> BASE ! ; deprecated

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       TRIM (forget) primitives
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: (trim)        ( addr1 addr2 -- addr1 addr3 )
                begin @ 2dup u> until ;

: trim          ( addr voc -- )
                tuck (trim) nip swap ! ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Checking addresses are in spaces
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: IN-APP-SPACE?   ( addr -- flag )
                APP-ORIGIN APP-HERE WITHIN ;

: IN-SYS-SPACE?   ( addr -- flag )
                SYS-ORIGIN SYS-HERE WITHIN SYS-SIZE AND 0<> ;

: IN-CODE-SPACE?   ( addr -- flag )
                CODE-ORIGIN CODE-HERE WITHIN ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Execution chain words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: .chain        ( chain -- )
                dup @ 0=
                if      drop ." Empty"
                else    begin   @ ?dup
                        while   dup cell+ @
                                dup >name name> ['] [unknown] <>
                                if      >name
                                        dup nfa-count nip 3 + ?cr
                                        getxy drop 24 <
                                        cols       48 > and
                                        if      24 col
                                        then    .id
                                else    drop
                                then    start/stop
                        repeat
                then    ;

: (.chains)     ( link -- )          \ display the contents of chains
                begin   @ ?dup
                while   dup cell+ @
                        cr dup body> .NAME 23 col space .chain
                repeat  cr ;

: .chains       ( -- )
                cr
                ." -- APP chains" chain-link (.chains)
                ." -- SYS chains" sys-chain-link (.chains)
                ;

in-application

\ define some of the chains we need

new-chain initialization-chain  \ chain of things to initialize
new-chain         unload-chain  \ chain of things to de-initialize
new-chain       forth-io-chain  \ chain of things to to to restore forth-io
\ new-chain          ledit-chain  \ line editor function key chain
new-chain    reset-stack-chain  \ chain for stack reset

new-chain            msg-chain  \ chain of forth console Windows' messages

in-system
new-sys-chain      semicolon-chain  \ chain of things to do at end of definition
new-sys-chain         forget-chain  \ chain of types of things to forget
new-sys-chain    post-forget-chain  \ chain of types of things to forget
new-sys-chain    pre-save-image-chain \ chain for things to be done to an image prior to saving

:noname         ( -- )
                semicolon-chain do-chain ; is do-;chain

\ clear all file handle during startup

in-application

variable handles-list

in-system

\ handles can be treated like values, but they are auto zeroed at startup

: handle        ( -<name>- )   \ handles are automatically zeroed during
                ( -- hndl )    \ Win32Forths startup initialization
                0 value here 3 cells -
                >system handles-list link, , system> ;

in-application

:noname         ( -- )         \ chain for cleanup
                unload-chain do-chain ; is unload-forth \ install in kernel word

\ new chain for reset-stack-chain added
\ January 22nd, 2004 - 13:53 dbu
reset-stack-chain chain-add _RESET-STACKS
:noname         ( ?? -- )      \ chain for stack reset
                reset-stack-chain do-chain ; is reset-stacks \ install in kernel word


\ -------------------- Load Standard Libraries --------------------

\ Root kernel library
WinLibrary KERNEL32.DLL
WinLibrary GDI32.DLL                            \ libraries
WinLibrary ADVAPI32.DLL
WinLibrary SHELL32.DLL
WinLibrary USER32.DLL

\ ------------------ HandleMessages MessageLoop  & WINPAUSE ------------------

1 PROC TranslateMessage
1 PROC DispatchMessage
5 proc PeekMessage
4 proc GetMessage
1 proc PostQuitMessage

: HandleMessages { pMsg -- 0 }
\ This is the word which handles the messages sent by windows. The chain
\ MSG-CHAIN can be used to prepend other message handlers, eg DoDialogMsg
\ DoAccelMsg DoMDIMsg. It is used by console in ACCEPT KEY etc. It is
\ also used by MessageLoop when a program is TURNKEYed without console.
\ This word is called by WINPAUSE
		pMsg TRUE msg-chain do-chain nip
                if   pMsg Call TranslateMessage drop
                     pMsg Call DispatchMessage  drop
                then 0 ;


: PauseForMessages { | pMsg -- }
\ synonym of Winpause : this word is used to give control to Windows so that
\ any pending message can be handled.
                7 cells LocalAlloc: pMsg
                BEGIN  0 ms PM_REMOVE 0 0 0 pMsg  Call PeekMessage
                WHILE  pMsg HandleMessages drop
                REPEAT ;

' PauseForMessages is WINPAUSE

: WaitForMessage { | pMsg -- }   \ wait to handle next message only
                7 cells LocalAlloc: pMsg
                0 0 0 pMsg  Call GetMessage
                IF  pMsg HandleMessages
                ELSE 0 Call PostQuitMessage
                THEN drop ;


32 NEWUSER MessageStructure

: MessageLoop ( -- )
\ This word launches a message loop. It will exit only when receiving a
\ WM_QUIT message. Used with programs TURNKEYed without console.
                BEGIN  0 0 0 MessageStructure  Call GetMessage
                WHILE  MessageStructure  HandleMessages drop
                REPEAT
                0 Call PostQuitMessage drop
 ;
\ Note: just in case several MessageLoop are accidently launched, the last
\       line ensures that all of them will exit when WM_QUIT is received.


in-system

\ ------------------ switching defered i/o ------------------

: NoConsoleIO   ( -- )  \ Reset all defered I/O words to noop's.
                ['] NOOP    IS CONSOLE
                ['] K_NOOP1 IS INIT-CONSOLE
                ['] NOOP    IS INIT-SCREEN
                ['] K_NOOP1 IS KEY
                ['] K_NOOP1 IS KEY?
                ['] K_NOOP0 IS ACCEPT
                ['] DROP    IS PUSHKEY
                ['] 2DROP   IS "PUSHKEYS
                ['] NOOP    IS CLS
                ['] DROP    IS EMIT
                ['] 2DROP   IS TYPE
                ['] NOOP    IS CR
                ['] DROP    IS ?CR
                ['] 2DROP   IS GOTOXY
                ['] K_NOOP2 IS GETXY
                ['] 2DROP   IS FGBG!
                ['] K_NOOP1 IS FG@
                ['] K_NOOP1 IS BG@
                ['] 2DROP   IS SETCHARWH
                ['] K_NOOP2 IS CHARWH
                ['] DROP    IS SET-CURSOR
                ['] K_NOOP1 IS GET-CURSOR
                ['] K_NOOP2 IS GETCOLROW
                ['] K_NOOP1 IS GETROWOFF
                ['] K_NOOP1 IS &THE-SCREEN
                ['] NOOP    IS SCROLLTOVIEW
                \ reset BYE to default ( although should have never changed)
                ['] k_bye   IS bye ;

: DosConsole    ( -- ) \ switch to DOS console functions
                ['] _interpret is interpret
                ['] NOOP    IS CONSOLE
                ['] d_Init-Console       IS INIT-CONSOLE
                ['] NOOP    IS INIT-SCREEN
                ['] d_KEY                IS KEY
                ['] d_KEY?               IS KEY?
                ['] d_ACCEPT             IS ACCEPT
                ['] DROP    IS PUSHKEY
                ['] 2DROP   IS "PUSHKEYS
                ['] NOOP    IS CLS
                ['] d_EMIT               IS EMIT
                ['] d_TYPE               IS TYPE
                ['] d_CR                 IS CR
                ['] DROP    IS ?CR
                ['] 2DROP   IS GOTOXY
                ['] K_NOOP2 IS GETXY
                ['] 2DROP   IS FGBG!
                ['] K_NOOP1 IS FG@
                ['] K_NOOP1 IS BG@
                ['] 2DROP   IS SETCHARWH
                ['] K_NOOP2 IS CHARWH
                ['] DROP    IS SET-CURSOR
                ['] K_NOOP1 IS GET-CURSOR
                ['] K_NOOP2 IS GETCOLROW
                ['] K_NOOP1 IS GETROWOFF
                ['] K_NOOP1 IS &THE-SCREEN
                ['] NOOP    IS SCROLLTOVIEW
                \ reset BYE to default ( although should have never changed)
                ['] k_bye   IS bye ;

in-application
\ defered i/o setting for various consoles
    : (NoConsoleBoot)       ( -- )  ( NoConsoleIO ) ;
\ in-system

: (DosConsoleBoot)      ( -- )  ( DosConsole ) init-console drop ;

in-system

defer (ConsoleBoot)         ' DosConsole is (ConsoleBoot)

defer (ConsoleHiddenBoot)   ' DosConsole is (ConsoleHiddenBoot)

defer PresetConsoleIO       ' noop is PresetConsoleIO

pre-save-image-chain chain-add PresetConsoleIO

\ in-system

\ -----------------------------------------------------------------------

\ April 23rd, 1999 - 14:05 tjz
\ not updated like WINCON-NUMBER? to succeed on ANSI versions, because
\ this only needs to detect WM_ constants for OOP.

: IsWinConstant ( str -- str FALSE | val TRUE )
                { \ WinVal -- }
                &of WinVal over
                count swap Call wcFindWin32Constant
                -if     2drop
                        WinVal TRUE
                then    ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ Limited support for the '#define' statment from 'C'
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: #define ( -<name expression>- )
        header
        >in @ >r
        bl word 1+ c@ [char] " =
        r> >in !
        if      dovar compile, /parse-s$ count ",
        else    docon compile, interpret ,
        then    ;


in-application


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Often used
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: STRING:                 \ Allocates strings
  CREATE MAXSTRING ALLOT  \ Compiletime: ( -< name >- ) Runtime: ( - addr$ )
 ;

: ERASE$ ( adr - )   MAXSTRING ERASE ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value MyAppID
0 value NewAppID
0 value RunUnique
0 value MyRunUnique
0 value StopLaunching  \ true if a new instance of me must be stopped

defer ?EnableConsoleMessages
' noop is ?EnableConsoleMessages

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       LONG counted string support
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
((
\ March 2nd, 2000 - 11:14 tjz
You must not store more than 4k beyond where you currently are into the
stack, and since LMAXCOUNTED is passed to LOCALALLOC: a bunch of times in
WinEd, we must limit long counted strings to significantly less than
the 4k limit. So, I am limiting long counted strings to 3k bytes.
))

1024                 CONSTANT LMAXCOUNTED    \ lines can be 1k characters long
LMAXCOUNTED 2 CELLS+ CONSTANT LMAXSTRING
                            \ room for leading cell count and trailing cell null

: "LCLIP"       ( a1 n1 -- a1 n1 )   \ clip a string to between 0 and LINE-MAX
        LMAXCOUNTED MIN 0 MAX ;

: LPLACE        ( addr len dest -- )
        SWAP "LCLIP" SWAP
        2DUP 2>R
        CELL+ SWAP MOVE
        2R> ! ;

: +LPLACE       ( addr len dest -- ) \ append string addr,len to LONG counted
                                     \ string dest
        >R "LCLIP" LMAXCOUNTED R@ @ - MIN R>   \ clip total to LINE-MAX string
        2DUP 2>R
        LCOUNT CHARS + SWAP MOVE
        2R> +! ;

: C+LPLACE    ( c1 a1 -- )    \ append char c1 to the LONG counted string at a1
        1 OVER +! LCOUNT + 1- C! ;

: +LNULL        ( a1 -- )       \ append a NULL just beyond the counted chars
        LCOUNT + 0 SWAP C! ;

in-system

: GET-VIEWFILE  ( cfa -- line# addr flag )    \ find source for word, very inefficent as
                                              \ uses >name, >view@ and >ffa@
                dup >view@ swap >ffa@         \ fetch line #, file name
                over 1 <                      \ view < 1
                over -1 = or                  \ or file = -1
                if drop -1                    \ must be console
                else dup 0=                   \ if it's a zero, it's kernel
                  if drop KERNFILE then
                then  true
                ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

 proc_mask value proc_next \ next procedure value

: newproc       ( -<proc_name> )        \ define a unique procedure key code
                ( -- n1 )               \ return the procedures key code
                proc_next constant
                1 +to proc_next ;

\ As used in Win32Forth, procedures are just constants, automatically
\ generated with incremented values that are used as keys generated by menu
\ operations, that are later detected in a keyboard interpreters CASE
\ statment to invoke a function. They start with 80000 HEX.

newproc IDK_BASEPROC    \ dummy base procedure showing syntax
                        \ procedure key constants should start with IDK_
                        \ and should be defined and used in UPPERCASE

in-application

cell NewUser UserObjectList \ For disposing of User Objects

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Locking for Windows
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

dpr-warning-off

defer (controllock)
defer (controlunlock)
defer (dialoglock)          deprecated
defer (dialogunlock)        deprecated
defer (classnamelock)
defer (classnameunlock)
defer (pointerlock)
defer (pointerunlock)
defer (dynlock)
defer (dynunlock)
defer (gdilock)
defer (gdiunlock)

     ' noop is (controllock)
     ' noop is (controlunlock)
     ' noop is (dialoglock)         \ no longer needed
     ' noop is (dialogunlock)       \ no longer needed
     ' noop is (classnamelock)
     ' noop is (classnameunlock)
     ' noop is (pointerlock)
     ' noop is (pointerunlock)
     ' noop is (dynlock)
     ' noop is (dynunlock)
     ' noop is (gdilock)
     ' noop is (gdiunlock)

dpr-warning-on

\s

\ $Id: SEE.F,v 1.18 2014/07/28 12:37:55 georgeahubert Exp $

\ see.f beta 1.9G 2002/08/29 arm minor modifications, CALL support
\ see.f beta 2.9G 2002/09/24 arm release for testing
\ see.f beta 3.3D 2002/10/08 arm Consolidation

cr .( Loading Decompiler...)

( Decompiler from F83 )

(( A Forth decompiler is a utility program that translates
  executable forth code back into source code.  Normally this is
  impossible, since traditional compilers produce more object
  code than source, but in Forth it is quite easy.  The decompiler
  is almost one to one, failing only to correctly decompile the
  various Forth control stuctures and special compiling words.
  It was written with modifiability in mind, so if you add your
  own special compiling words, it will be easy to change the
  decompiler to include them.  This code is highly implementation
  dependant, and will NOT work on other Forth system.  To invoke
  the decompiler, use the word SEE <name> where <name> is the
  name of a Forth word. ))


only forth also definitions decimal

new-sys-chain .execution-class-chain
new-sys-chain .other-class-chain
new-sys-chain .word-chain

in-application

0 value debugging?

in-system

\ : dummy.float   ( a1 -- a2 )
\                 ." ???" cells/float cells+ ;
\
\ defer .float    ' dummy.float is .float

DEFER (SEE)  ( cfa -- )

INTERNAL        \ internal definitions start here

in-application

: .proc-name    ( cfa -- )
                cfa>proc proc>name dup c@
                1 name-max-chars between        \ if it looks like a count byte
                if      count type space        \ display the name
                else     u.                     \ else display a number
                then    ;

in-system

: (.WORD)         ( IP  cfa -- IP' )
                DUP  app-origin     HERE within
                OVER sys-origin sys-here within or
                over code-origin code-here within or
        IF      DUP>R  @
                CASE   DOVALUE    OF R@                         .NAME   ENDOF
                       DOVALUE!   OF R@ ." TO "       2 CELLS - .NAME   ENDOF
                       DOVALUE+!  OF R@ ." +TO "      3 CELLS - .NAME   ENDOF
\+ DOFVALUE!           DOFVALUE!  OF R@ ." FTO "      2 CELLS - .NAME   ENDOF
\+ DOFVALUE+!          DOFVALUE+! OF R@ ." F+TO "     3 CELLS - .NAME   ENDOF
                       DOLOCAL    OF R@                         .NAME   ENDOF
                       DOLOCAL!   OF R@ ." TO "       2 CELLS - .NAME   ENDOF
                       DOLOCAL+!  OF R@ ." +TO "      3 CELLS - .NAME   ENDOF
                       DO2VALUE!  OF R@ ." 2TO "      2 CELLS - .NAME   ENDOF
                       DO2VALUE+! OF R@ ." 2+TO "     3 CELLS - .NAME   ENDOF
                       (IV@)      OF R@ ." I:"                  .NAME   ENDOF
                       (IV!)      OF R@ ." TO-I: "    2 CELLS - .NAME   ENDOF
                       (IV+!)     OF R@ ." +TO-I: "   3 CELLS - .NAME   ENDOF
                       DOCALL     OF R@ ." CALL "          .proc-name   ENDOF   \ arm
\+ .M0NAME             M0CFA      OF R@ ." M0:"               .M0NAME   ENDOF
\+ .M1NAME             M1CFA      OF R@ ." M1:"               .M1NAME   ENDOF
                       DOOBJ      OF R@ ." O:"                  .NAME   ENDOF
\ bug fix suggested by "beberst@infonie.fr"
                                R@ 2 cells appInst + U>
                                IF      R@ 2 CELLS - @ DOOBJ =
                                ELSE    FALSE
                                THEN
                                IF      ." O:" R@ 2 CELLS - .NAME
                                ELSE    over 2 cells+ R@ =      \ optimized inline code
                                        IF      debugging?
                                                if      ." <Optimized Code>"
                                                else    R@ (see)
                                                then
                                                swap cell+ @ cell- swap
                                        ELSE    r@ false .word-chain do-chain 0=
                                                if      .name
                                                else    drop
                                                then
                                        THEN
                                THEN
                ENDCASE R> DROP
        ELSE   1 u.r  ( ." 0x" 1 h.r ) ."  "
        THEN    CELL+ ;

: .WORD         ( ip -- ip' )
                dup @ (.word) ;

: .BRANCH       ( IP -- IP' )
                .WORD  DUP @ CELL /  dup 0> if ." +" then h.  CELL+   ;

: .STRING       ( IP -- IP' )
                34 emit space
                CELL+
                dup c@ ?line
                COUNT 2DUP TYPE  34 emit space + 1+ aligned ;

: .CALL         ( ip -- ip' )
                .word .word ;

: (.LOCALS)     ( t-1 n -- )
                0 ?do dup i - ." LOCAL" 1 .r space loop drop ;

: .LOCALS       ( IP -- IP' )
                cell+ ." { "
                dup 2 + sw@ negate               \ init locals   ( IP init )
                over sw@ negate                  \ uninit locals ( IP init uninit )
                2dup + 1-
                rot (.locals)                    \ init locals   ( IP uninit total-1 init 0 ... do )
                -if ." | "                       \ if any unit locals ( IP uninit )
                dup 1- swap (.locals)
                else drop
                then ." } "
                CELL+ ;

\ Decompile each type of word                         28Feb84map

: .(;code)      ( ip -- ip' )
                drop ." ;CODE " false ;

: .(does>)      ( ip -- ip' )
                cell+ cell+ ." DOES> " ;

: d_cr          ( -- )
                debugging? 0=
                if      crtab
                then    ;

0 value hi-branch

: branch+ ( ip -- ip' )  \ advance ip by 1 cell and update hi-branch if necessary
        cell+ dup @ hi-branch umax to hi-branch ;

: .end ( ip -- ip'|0 ) \ advance ip by 1 cell, return false if there are no branches
                       \ past this address
        cell+ dup hi-branch u< 0= if ." ;"  drop  0
                                else ." EXIT"  then ;

: .execution-class  ( ip cfa -- ip' )
    false .execution-class-chain do-chain 0=
    if
      case
        ['] lit         of cell+ ." lit "   .word                     endof
        ['] (&of-local) of cell+ ." &OF "   .word                     endof
        ['] (&of-VALUE) of cell+ ." &OF "   .word                     endof
            &flit       of cell+ ." flit "  .float                    endof
        ['] (is)        of cell+ ." (is) "  .word                     endof
        ['] (.")        of ." ."        .string                       endof
        ['] (S")        of ." S"        .string                       endof
        ['] (Z")        of ." Z"        .string                       endof
        ['] (C")        of ." C"        .string                       endof
        ['] (abort")    of ." ABORT"    .string                       endof
        ['] ?branch     of      d_cr ." IF      " +tab  branch+ cell+ endof
        ['] -?branch    of      d_cr ." -IF     " +tab  branch+ cell+ endof
        ['] branch      of -tab d_cr ." ELSE    " +tab  branch+ cell+ endof
        ['] (do)        of      d_cr ." DO      " +tab  branch+ cell+ endof
        ['] (?do)       of      d_cr ." ?DO     " +tab  branch+ cell+ endof
        ['] (loop)      of -tab d_cr ." LOOP    "       cell+   cell+ endof
        ['] (+loop)     of -tab d_cr ." +LOOP   "       cell+   cell+ endof
        ['] _case       of      d_cr ." CASE    " +tab  cell+         endof
        ['] _of         of      d_cr ." OF      " +tab  branch+ cell+ endof
        ['] _endof      of  tab      ." ENDOF   " -tab  d_cr
                                                        branch+ cell+ endof
        ['] _endcase    of -tab d_cr ." ENDCASE "       cell+         endof
        ['] _then       of -tab d_cr ." THEN    "       cell+         endof
        ['] _begin      of      d_cr ." BEGIN   " +tab  cell+         endof
        ['] _while      of -tab d_cr ." WHILE   " +tab  branch+ cell+ endof
        ['] _until      of -tab d_cr ." UNTIL   "       cell+   cell+ endof
        ['] _repeat     of -tab d_cr ." REPEAT  "       cell+   cell+ endof
        ['] _again      of -tab d_cr ." AGAIN   "       cell+   cell+ endof
        ['] compile     of ." COMPILE " cell+ .word                   endof
        ['] unnest      of .end space                                 endof
        ['] unnestp     of .end space                                 endof
        ['] unnestm     of .end ." M "                                endof
        ['] (;code)     of -tab d_cr .(;CODE) tab +tab                endof
        ['] (does>)     of -tab d_cr .(DOES>) tab +tab                endof
        ['] create      of d_cr ." CREATE" cell+ tab +tab             endof
        ['] init-locals of               .locals                      endof
        tuck (.word) swap
      endcase
    else drop
    then
    ;


\ Decompile a : definition                            15Mar83map

: .PFA          ( cfa -- )
                0 to hi-branch
                tabing-on
                0TAB +TAB tab
                BEGIN   14 ?line   DUP @ .EXECUTION-CLASS
                        DUP 0=
                        nuf? or
                UNTIL   DROP
                tabing-off ;

: .IMMEDIATE    ( cfa -- )
                >name n>bfa c@ 128 and
                if      ." IMMEDIATE "
                then    ;

\ Display category of word                            24APR84HHL

: .CONSTANT     ( cfa -- )
                dup >body ?   ." CONSTANT "   .name   ;

\+ fconstant : .FCONSTANT ( cfa -- )
\+ fconstant    dup >body f@ fe.  ." FCONSTANT "   .name   ;

: .OFFSET       ( cfa -- )
                dup >body ?   ." OFFSET " .name ;

: .USER         ( cfa -- )
                dup >body dup . @ . ." USER "   dup .name
                ." Value = " execute ?   ;

: .VARIABLE     ( cfa -- )
                dup >body .   ." VARIABLE "   dup .name
                ." Value = " >body ?   ;

: .VALUE        ( cfa -- )
                dup cell+ ?  ." VALUE "   .name  ;

: .2VALUE       ( cfa -- )
                dup cell+ @ 2@ (d.) type  ." . 2VALUE "   .name  ;

\+ fvalue : .FVALUE ( cfa -- )
                dup cell+ @ f@ fe.  ." FVALUE "   .name  ;

: .CLASS        ( cfa -- )
                ." :CLASS "  .name  ;

: .VOCABULARY   ( cfa -- )  \ use VOCS to see all the vocabularies and lexicons
             \ this word is used internaly by the code for SEE
                dup IN-APP-SPACE? if ." LEXICON " else ." VOCABULARY " then .name  ;

: .:            ( cfa -- )
                ." : "  dup .name 2 spaces  >body .pfa   ;

: .DEFER        ( cfa -- )
                ." DEFER " DUP .NAME   ." IS "  >BODY @ (SEE)  ;

DEFER DISCODE   ' DROP IS DISCODE

: .SYNONYM      ( cfa -- )
                ." SYNONYM " DUP .NAME ." IS " >BODY CELL+ @ (SEE) ;

: .DOES>        ( pfa -- )                    \ nop lea ecx, xxx [edi] ; pick up xxx
                ." DOES> "  @ 3 + @ cell- .pfa   ;  \ see does-call, in kernel; address of DOES>

: .CODE         ( cfa -- )
                ." IS CODE " @ DISCODE ;

: .;CODE        ( cfa -- )
                ." IS ;CODE " @ DISCODE ;

: .OTHER        ( cfa -- )
                .other-class-chain do-chain ?dup
                if      DUP .NAME DUP @ OVER CELL+ = IF .CODE EXIT THEN  \ will need changed for code sect
                        DUP DOES>? IF  .DOES>  EXIT THEN
                        .;CODE
                then    ;

: .OBJECT       ( cfa -- )
                dup >body @ body> \ .name
                >name dup name> ['] [unknown] =
                if drop ." :OBJECT " else id. then
                .name ;

: .Import       ( cfa -- )
                >body dup cell+ @ . ." Import: " @ .proc-name ;

0 value a_value

\ Classify a word based on its CFA                    09SEP83HHL

: .definition-class  ( cfa cfa -- )
    @ case
             docol       of .:           endof
             docon       of .constant    endof
\+ fconstant dofcon      of .fconstant   endof
             dooff       of .offset      endof
             dovar       of .variable    endof
             douser      of .user        endof
             dodefer     of .defer       endof
             dovalue     of .value       endof
             do2value    of .2value      endof
\+ dofvalue  dofvalue    of .fvalue      endof
             doClass     of .class       endof
             do|Class    of .class       endof
             dovoc       of .vocabulary  endof
             doObj       of .object      endof
             doPointer   of .pointer     endof
             doImport    of .import      endof
        swap .other
    endcase ;


\ Top level of the Decompiler SEE                     29Sep83map

: ((SEE))       ( Cfa -- )
                CRTAB DUP DUP .DEFINITION-CLASS  .IMMEDIATE   ;

' ((SEE)) IS (SEE)

EXTERNAL

\ synonym 'see (see) - made a colon def [cdo-2008May13]
: 'SEE          ( cfa -- ) \ see a word given its cfa
                (SEE) ;

: SEE           ( <name> -- ) \ see a word parsed from input stream
                '   (SEE)    ;

MODULE          \ end of the module


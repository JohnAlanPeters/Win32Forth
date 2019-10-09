\ $Id: meta-compiler.f,v 1.9 2012/02/27 15:04:54 georgeahubert Exp $

cr .( Loading META Compiler)

((

ARM: Separated out the meta compiler into phases. This is the COMPILER phase.

This is the heart of the meta compiler. There are files pre and post loaded to
this code that build the environment in which this meta compiler operates. There
are a number of prerequisites right now, specifically the IMAGE words used by
IMAGEMAN that builds the executable files.

arm: Work in progress; update the meta-compiler memory access words

))

\ ======================================================================
\ Define the wordlists that are used in the metacompiler

VOCABULARY META         \ metacompiler implementation
VOCABULARY TARGET       \ target words
VOCABULARY TRANSITION   \ special compiling words
VOCABULARY FORWARD      \ forward references

: >WORDLIST  ( voc-cfa -- wordlist )   VCFA>VOC ;  ( Win32Forth )

' META        >WORDLIST CONSTANT META-WORDLIST          ( *SYSDEP* )
' TARGET      >WORDLIST CONSTANT TARGET-WORDLIST        ( *SYSDEP* )
' FORWARD     >WORDLIST CONSTANT FORWARD-WORDLIST       ( *SYSDEP* )
' TRANSITION  >WORDLIST CONSTANT TRANSITION-WORDLIST    ( *SYSDEP* )
' ASSEMBLER   >WORDLIST CONSTANT ASSEMBLER-WORDLIST     ( *SYSDEP* )

\ We will use the following search orders:
: IN-FORTH        ONLY FORTH ALSO DEFINITIONS  ;
: IN-META         ONLY FORTH ALSO VIMAGE ALSO META ALSO DEFINITIONS ;
: IN-TRANSITION   ONLY FORWARD ALSO TARGET ALSO TRANSITION ;

IN-META

\ ======================================================================
\ Memory Access Words

\ Where building words go: (for example)
\ COMPILE,       into  IMAGE-APPPTR
\        ,       into  IMAGE-APPPTR
\    SYS-,       into  IMAGE-SYSPTR

\ -------------------- Deferred app space words ------------------------

$10000 dup malloc to image-codeptr image-codeptr swap $90 fill \ where code is built
$10000 dup malloc to image-appptr  image-appptr  swap erase \ where target app is built
$10000 dup malloc to image-sysptr  image-sysptr  swap erase \ where target heads are built

image-origin image-csep + image-codeptr - constant tcode-base  \ target data base
image-origin image-asep + image-appptr  - constant tapp-base   \ target dictionary base
image-origin image-ssep + image-sysptr  - constant tsys-base   \ target header base

create tcode-dp image-codeptr , image-codeptr , image-codeptr $10000 + , 0 , ," tcode-dp" \ code
create tapp-dp  image-appptr  , image-appptr  , image-appptr  $10000 + , 0 , ," tapp-dp"  \ app
create tsys-dp  image-sysptr  , image-sysptr  , image-sysptr  $10000 + , 0 , ," tsys-dp"  \ system

: IN-SYS-T? DP TSYS-DP = ;

: >TAPP  ( -- )    TAPP-DP  >DP ;  \ select app dict, save prev dict
: >TSYS  ( -- )    TSYS-DP  >DP ;  \ select sys dict, save prev dict
: >TCODE ( -- )    TCODE-DP >DP ;  \ select code dict, save prev dict

' DP> ALIAS TAPP>
' DP> ALIAS TSYS>
' DP> ALIAS TCODE>

: tapp-there  ( taddr -- addr )    tapp-base -   ;
: tapp-@      ( taddr -- n )       tapp-there @  ;
: tapp-c!     ( char taddr -- )    tapp-there c! ;
: tapp-w!     ( word taddr -- )    tapp-there w! ;
: tapp-!      ( n taddr -- )       tapp-there !  ;
: tapp-here   ( -- taddr )         >tapp     here          tapp> tapp-base + ;
: tapp-allot  ( n -- )             >tapp     allot         tapp> ;
: tapp-c,     ( char -- )          >tapp     c,            tapp> ;
: tapp-w,     ( w -- )             >tapp     w,            tapp> ;
: tapp-,      ( n -- )             >tapp     ,             tapp> ;
: tapp-align                       >tapp     align         tapp> ;
: tapp-s,     ( addr len -- )      0 ?do count tapp-c, loop drop ;

: tsys-there  ( taddr -- addr )    tsys-base -   ;
: tsys-@      ( taddr -- n )       tsys-there @  ;
: tsys-c!     ( char taddr -- )    tsys-there c! ;
: tsys-w!     ( word taddr -- )    tsys-there w! ;
: tsys-!      ( n taddr -- )       tsys-there !  ;
: tsys-here   ( -- taddr )         >tsys     here          tsys> tsys-base + ;
: tsys-allot  ( n -- )             >tsys     allot         tsys> ;
: tsys-c,     ( char -- )          >tsys     c,            tsys> ;
: tsys-w,     ( w -- )             >tsys     w,            tsys> ;
: tsys-,      ( n -- )             >tsys     ,             tsys> ;
: tsys-align                       >tsys     align         tsys> ;
: tsys-s,     ( addr len -- )      0 ?do count tsys-c, loop drop ;

: tcode-there ( taddr -- addr )    tcode-base -   ;
: tcode-c@    ( taddr -- char )    tcode-there c@ ;
: tcode-w@    ( taddr -- word )    tcode-there w@ ;
: tcode-@     ( taddr -- n )       tcode-there @  ;
: tcode-c!    ( char taddr -- )    tcode-there c! ;
: tcode-w!    ( word taddr -- )    tcode-there w! ;
: tcode-!     ( n taddr -- )       tcode-there !  ;
: tcode-here  ( -- taddr )         >tcode    here          tcode> tcode-base + ;
: tcode-allot ( n -- )             >tcode    allot         tcode> ;
: tcode-c,    ( char -- )          >tcode    c,            tcode> ;
: tcode-w,    ( w -- )             >tcode    w,            tcode> ;
: tcode-,     ( n -- )             >tcode    ,             tcode> ;
: tcode-align                      >tcode    align         tcode> ;
: tcode-s,    ( addr len -- )      $90 ?do count tcode-c, loop drop ;

: tany-there  ( taddr -- addr )
              dup tcode-base tcode-here within if tcode-there else
              dup tapp-base  tapp-here  within if tapp-there  else
              dup tsys-base  tsys-here  within if tsys-there  else
              drop 0 then then then ;

: t-@         ( taddr -- n ) tany-there @ ;
: t-!         ( n taddr -- ) tany-there ! ;

\ section still requires work

\ DEFER t-@
\ DEFER t-!
DEFER t-here
DEFER t-allot
DEFER t-c,
DEFER t-w,
DEFER t-,
DEFER t-s,
DEFER t-align

: IN-APPLICATION ( -- )
\                ['] TAPP-@       IS t-@
\                ['] TAPP-!       IS t-!
                ['] TAPP-HERE    IS t-here
                ['] TAPP-ALLOT   IS t-allot
                ['] TAPP-C,      IS t-c,
                ['] TAPP-W,      IS t-w,
                ['] TAPP-,       IS t-,
                ['] TAPP-S,      IS t-s,
                ['] TAPP-ALIGN   IS t-align
                ;

: IN-SYSTEM     ( -- )
\                ['] TSYS-@       IS t-@
\                ['] TSYS-!       IS t-!
                ['] TSYS-HERE    IS t-here
                ['] TSYS-ALLOT   IS t-allot
                ['] TSYS-C,      IS t-c,
                ['] TSYS-W,      IS t-w,
                ['] TSYS-,       IS t-,
                ['] TSYS-S,      IS t-s,
                ['] TSYS-ALIGN   IS t-align
                ;

IN-APPLICATION                                     \ start in-application

\ ======================================================================
\ Modify assembler to place code into target

VARIABLE IN-CODE?
     IN-CODE? OFF    \ we're building in target

' TCODE-HERE  ASSEMBLER ASM-HIDDEN IS CODE-HERE  META
' TCODE-C,    ASSEMBLER ASM-HIDDEN IS CODE-C,    META
' TCODE-W,    ASSEMBLER ASM-HIDDEN IS CODE-W,    META
' TCODE-,     ASSEMBLER ASM-HIDDEN IS CODE-D,    META
' TCODE-C@    ASSEMBLER ASM-HIDDEN IS CODE-C@    META
' TCODE-C!    ASSEMBLER ASM-HIDDEN IS CODE-C!    META
' TCODE-W@    ASSEMBLER ASM-HIDDEN IS CODE-W@    META
' TCODE-W!    ASSEMBLER ASM-HIDDEN IS CODE-W!    META
' TCODE-@     ASSEMBLER ASM-HIDDEN IS CODE-D@    META
' TCODE-!     ASSEMBLER ASM-HIDDEN IS CODE-D!    META
' TCODE-ALIGN ASSEMBLER ASM-HIDDEN IS CODE-ALIGN META

\ ======================================================================
\ Define Meta Branching Constructs

: ?CONDITION  TRUE - ABORT" Conditionals not paired" ;

: ?>MARK      ( -- f addr )   TRUE   t-here   0 t-,   ;
: ?<MARK      ( -- f addr )   TRUE   t-here   ;

: ?>RESOLVE ( f addr -- ) t-here CELL+ SWAP t-! ?CONDITION ;
: ?<RESOLVE ( f addr -- ) t-,                   ?CONDITION ;

\ ======================================================================
\ Meta Compiler Forward Reference Linking

\ Structure of a forward reference (cell offsets from BODY)
\       0       - target address if resolved
\       1       - resolved flag
\       2       - link to previous forward reference


VARIABLE FORWARD-LINK   \ linked list of FORWARD words (for .UNRESOLVED)
0 FORWARD-LINK !

: MAKE-TARGET    ( pfa -- )  @ t-, ;

: LINK-BACKWARDS ( pfa -- ) t-here OVER @ t-, SWAP ! ;

: RESOLVED?      ( pfa -- f ) CELL+ @ ;

: DO-FORWARD     ( -- )
                 DOES>   DUP RESOLVED?
                         IF  MAKE-TARGET  ELSE  LINK-BACKWARDS  THEN ;

: (FORWARD)    ( taddr -- )
        GET-CURRENT >R
        FORWARD-WORDLIST SET-CURRENT
        CREATE
          , ( taddr )
          FALSE , ( resolved flag )
          HERE FORWARD-LINK @ , FORWARD-LINK !
        DO-FORWARD
        R> SET-CURRENT ;

: FORWARD:  ( -- )      \ Explicit forward reference
        0 (FORWARD) ;

: UNDEFINED   ( -- )    \ Undefined words create automatic forward reference
          t-here  (FORWARD)  0 t-, ;

\ ======================================================================
\ Force compilation of target & forward words. We need to reference the
\ special runtime target words like LIT and BRANCH before they are defined,
\ so we store the name of the word and look it up when we need it. Hopefully
\ they will have been defined by then. [TARGET] is for target primatives and
\ [LABEL] is for target assembly labels (runtime of builtin defining words).

: FIND&EXECUTE  ( addr len wordlist -- ? )
        SEARCH-WORDLIST 0= ABORT" Target word not found"  EXECUTE ;

: DEFERRED  ( wordlist -- )
        BL WORD COUNT POSTPONE SLITERAL
        POSTPONE LITERAL
        POSTPONE FIND&EXECUTE ;

: [TARGET]  ( -- )  TARGET-WORDLIST    DEFERRED ; IMMEDIATE
: [LABEL]   ( -- )  ASSEMBLER-WORDLIST DEFERRED ; IMMEDIATE

\ Find the next word in a single wordlist only
: DEFINED-IN  ( wordlist -- xt )
        BL WORD COUNT ROT SEARCH-WORDLIST ?MISSING  ;

: 'T   ( -- xt )   TARGET-WORDLIST  DEFINED-IN ;
: 'F   ( -- xt )   FORWARD-WORDLIST DEFINED-IN ;

: [FORWARD]   ( -- )    'F , ;   IMMEDIATE

\ ======================================================================
\ Create Headers in Target IMAGE-APPPTR. We support only one FORTH-WORDLIST in
\ the kernel.

CREATE FORTH-THREADS  #THREADS CELLS ALLOT
       FORTH-THREADS  #THREADS CELLS ERASE

CREATE PROCS-THREADS  #PTHREADS CELLS ALLOT  \ for procedures
       PROCS-THREADS  #PTHREADS CELLS ERASE

CREATE FILES-THREADS  #FTHREADS CELLS ALLOT  \ for files
       FILES-THREADS  #FTHREADS CELLS ERASE

CREATE HIDDEN-THREADS  #HTHREADS CELLS ALLOT  \ for hidden
       HIDDEN-THREADS  #HTHREADS CELLS ERASE

CREATE ROOT-THREADS  CELL ALLOT  \ for root, nust be 1 cell
       ROOT-THREADS  CELL ERASE

: (THREAD)     ( addr len -- 'thread )      \ get FORTH vocab thread address
                #THREADS "#HASH FORTH-THREADS +  ;
: (PTHREAD)     ( addr len -- 'thread )      \ get PROCS vocab thread address
                #PTHREADS "#HASH PROCS-THREADS +  ;
: (FTHREAD)     ( addr len -- 'thread )      \ get PROCS vocab thread address
                #FTHREADS "#HASH FILES-THREADS +  ;
: (HTHREAD)     ( addr len -- 'thread )      \ get PROCS vocab thread address
                #HTHREADS "#HASH HIDDEN-THREADS +  ;
: (RTHREAD)     ( addr len -- 'thread )      \ get PROCS vocab thread address
                2drop ROOT-THREADS ;

DEFER THREAD

FALSE VALUE IN-HIDDEN?

: VOC-FORTH      ( -- ) ['] (THREAD)  IS THREAD FALSE TO IN-HIDDEN? ;
: VOC-PROCS      ( -- ) ['] (PTHREAD) IS THREAD FALSE TO IN-HIDDEN? ;
: VOC-FILES      ( -- ) ['] (FTHREAD) IS THREAD FALSE TO IN-HIDDEN? ;
: VOC-HIDDEN     ( -- ) ['] (HTHREAD) IS THREAD TRUE  TO IN-HIDDEN? ;
' VOC-HIDDEN ALIAS INTERNAL
' VOC-FORTH  ALIAS EXTERNAL

EXTERNAL                        \ set as threads default

VARIABLE HEADS  HEADS ON
: |   HEADS OFF ;   ( make next word headerless )

VARIABLE LAST-H         \ target address of count byte
0 VALUE  OFA-H          \ target address of OFA
VARIABLE OFAING

TRUE OFAING !

\ -------------------------------------------------------
\ Header structure as of May 2003
\
\       [ link field       ] -4  +0       LFA
\   +-  [ cfa ptr field    ] +0   4       CFA-PTR
\   |   [ byte flag        ]  4   8       BFA
\   |   [ count byte       ]  5   9       NFA
\   |   [ the name letters ]  6  10
\   |   [ alignment bytes  ]  0 to 3 bytes for name alignment
\   |   [ view field       ]  n+0         VFA <- head-fields
\   |   [ file field       ]  n+4         FFA
\   |   [ optimize field   ]  n+8         OFA
\   |
\   v
\       [ cfa  field       ] +0           CFA
\       [ body field       ] +4           PFA
\ -------------------------------------------------------

9  offset  L>NAME   ( lfa -- nfa )
-9 offset  N>LINK   ( nfa -- lfa )
-5 offset  N>CFAPTR ( nfa -- cfa-ptr )
-1 offset  N>BFA    ( nfa -- bfa )
-1 offset  N>BFA    ( nfa -- bfa )

\ FORWARD: <COMPILE,>

: HEADER   ( -- )
        tsys-align
        tcode-align
        tapp-align                                         \ align code space
        BL WORD UPPERCASE COUNT
        HEADS @ IN-HIDDEN? INVERT AND                   \ are we hiding?
        IF
                2dup THREAD DUP @  tsys-here ROT !  tsys-,    \ LFA
                0 tsys-,                                   \ CFA-PTR
                BFA_VFA_PRESENT  tsys-c,                   \ BFA (VFA only)
                tsys-here LAST-H !                         \ remember nfa
                DUP tsys-c, tsys-s,                           \ count byte NFA  name string
                0 tsys-c,
                tsys-align
                LOADLINE @ tsys-,                          \ view field
                IN-CODE? @ IF tcode-here ELSE t-here THEN
                LAST-H @ N>CFAPTR tsys-!                   \ set the CFA-PTR
        ELSE
                2DROP HEADS ON
        THEN  ;

\ ======================================================================
\ Meta Compiler Create Target IMAGE-APPPTR

VARIABLE TARGET-LINK    \ linked list of TARGET words (for .SYMBOLS)
0 TARGET-LINK !

: DO-TARGET  DOES> MAKE-TARGET ;  \ what target words do

: TARGET-DEFINE   ( xt -- )             \ alias support
        >IN @ HEADER >IN !              \ create header in target
        DUP LAST-H @ N>CFAPTR tsys-!       \ point at xt
        TARGET DEFINITIONS              \ add word to TARGET wordlist
        CREATE
          , ( xt )
          HERE TARGET-LINK @ , TARGET-LINK !    \ linked list of target words
        DO-TARGET
        META DEFINITIONS ;

: TARGET-CREATE   ( -- )
        >IN @ HEADER >IN !              \ create header in target
        TARGET DEFINITIONS              \ add word to TARGET wordlist
        CREATE
          IN-CODE? @ IF tcode-here ELSE t-here THEN , ( xt )
          HERE TARGET-LINK @ , TARGET-LINK !    \ linked list of target words
        DO-TARGET
        META DEFINITIONS ;

: RECREATE   ( -- )
        >IN @ TARGET-CREATE >IN ! ;

\ ======================================================================
\ Create target assembler words

[DEFINED] CLEAR-LABELS 0= [IF]
: CLEAR-LABELS ;
: CHECK-LABELS ;
[THEN]

: NO-OFA ( -- )                    \ reset ofa count field
        0 TO OFA-H ;

: HERE-OFA ( -- )                  \ set ofa count field
        tsys-here TO OFA-H                 \ save address of OFA
        tcode-here tsys-,                      \ init OFA with start of definition
        LAST-H @ 1- DUP tsys-@ BFA_OFA_PRESENT OR SWAP tsys-c! \ mark as OFA in BFA
        ;

: INIT-ASSEMBLER  ( -- )        \ prepare for assembly code
        [ ASSEMBLER ] CLEAR-LABELS [ ASM-HIDDEN ] RESET-ASM [ META ]
        ASSEMBLER DEFINITIONS  !CSP ;

: RESOLVE-OFA   ( -- )
        OFAING @
        OFA-H AND
        IF      \ save size of code definition
                        [ ASSEMBLER ] A;
                        [ META ] tcode-here OFA-H tsys-@ - OFA-H tsys-!
        THEN
        0 TO OFA-H ;             \ reset OFA pointer

: CODE-HEAD ( -- )
        IN-CODE? ON
        TARGET-CREATE
        tcode-here CELL+ tcode-,
        INIT-ASSEMBLER ;

: CODE  ( -- )
        CODE-HEAD
        HERE-OFA                   \ init OFA with start of definition
        ;

: NCODE ( -- )                          \ NON inlineable code word
        CODE-HEAD
        NO-OFA
        ;

: CFA-CODE ( -- )
        IN-CODE? ON
\        tcode-align
        INIT-ASSEMBLER
        NO-OFA
        tcode-here CONSTANT
        ;

ALSO ASSEMBLER DEFINITIONS

: LABEL   A;  tcode-here CONSTANT ;

: END-CODE
      A;
      IN-META  CHECK-LABELS
      [ ASM-HIDDEN ]  ?FINISHED ?UNRES  [ ASSEMBLER ]  ?CSP
      IN-CODE? OFF ;

SYNONYM C; END-CODE
SYNONYM ;C END-CODE

PREVIOUS DEFINITIONS

\ ======================================================================
\ Define transition words, which behave like forth immediate words.

: T:   TRANSITION DEFINITIONS  META  :  ;
: T;   POSTPONE ;  META DEFINITIONS ; IMMEDIATE

: [TRANSITION]  TRANSITION-WORDLIST DEFINED-IN COMPILE, ; IMMEDIATE

T: (   POSTPONE (   T;
T: \   POSTPONE \   T;
T: ((  POSTPONE ((  T; \ support (( ))

: t-string,     [CHAR] " PARSE  DUP t-c,  t-s,  0 t-c,  t-align  ;

FORWARD: <(.")>
T: ."   [FORWARD]  <(.")>   t-string,   T;

FORWARD: <(S")>
T: S"    [FORWARD] <(S")>   t-string,   T;

FORWARD: <(C")>
T: C"    [FORWARD] <(C")>   t-string,   T;

FORWARD: <(ABORT")>
T: ABORT"   [FORWARD] <(ABORT")>    t-string,   T;

\ ======================================================================
\ Define target vocabularies (uh, wordlists)

\ -------------------- Vocabulary dictionary structure ----------------------

\       [ cfa field        ] +0           VCFA = vocabulary cfa -> DOES> code
\       [ num voc threads  ] +4           #THREADS
\       [ head create      ] +8           VHEAD
\       [ find entry       ] +12          VFIND
\       [ iterate over     ] +16          VITER
\       [ voc link         ] +20          VLINK
\       [ voc thread 0     ] +24          VOC thread 0 = voc-address
\       [ voc thread 1     ] +28          VOC thread 1
\       [ voc thread 2     ] +32          VOC thread 2
\       [ voc thread ...   ] +n*4+24      VOC thread n

VARIABLE VOC-LINK-T
FORWARD: <VOCABULARY>
FORWARD: <VHEAD>
FORWARD: <VSRCH>

: #VOCABULARY   ( threads -- )
        IN-SYSTEM
        TARGET-CREATE
        [FORWARD] <VOCABULARY>
        DUP t-,
        [FORWARD] <VHEAD>
        [FORWARD] <VSRCH>
        0 t-,     \ <VITER>
        t-here  VOC-LINK-T @ t-,   VOC-LINK-T !
        CELLS t-allot
        IN-APPLICATION
        ;

: VOCABULARY   ( -- )
        #threads #vocabulary ;

: #LEXICON     ( -- )                             \ lexicion vocabulary
        IN-APPLICATION
        TARGET-CREATE
        [FORWARD] <VOCABULARY>
        DUP t-,
        [FORWARD] <VHEAD>
        [FORWARD] <VSRCH>
        0 t-,     \ <VITER>
        t-here  VOC-LINK-T @ t-,   VOC-LINK-T !
        CELLS t-allot
        ;

: LEXICON      ( -- )                             \ lexicion vocabulary
        #pthreads #lexicon ;

: IMMEDIATE   ( -- )
        LAST-H @ 1- DUP  ( N>BFA ) tsys-@ 128 OR  ( Precedence Bit )  SWAP tsys-c! ;

VARIABLE STATE-T

T: [COMPILE]   'T EXECUTE    T;

FORWARD: <(IS)>
T: IS      [FORWARD] <(IS)>    T;
:  IS   'T >BODY @ >body 2DUP t-!  8 + t-! ;
 ( patches both current and default value of deferred word )

\ TO used inside a definition
T: TO   'T >BODY @ ( tcfa )  2 CELLS+ t-,  T;
T: +TO  'T >BODY @ ( tcfa )  3 CELLS+ t-,  T;

T: CALL 'T >BODY @ CELL+ t-, T;                               \ added to support call

\ ======================================================================
\ Display the Target Symbol Table

: _@COL  GETXY DROP ;
FORTH DEFER @COL META ' _@COL FORTH IS @COL META

: TAB   @COL 60 >
        IF  CR  ELSE  10 @COL OVER MOD - SPACES  THEN ;

: .SYMBOLS    ( -- )
        TARGET-LINK
        BEGIN   @ DUP
        WHILE   DUP CELL - ( pfa )
                DUP @ TAB 6 H.R SPACE
                BODY> .NAME  ( *SYSDEP* )
                START/STOP
        REPEAT  DROP ;

\ ======================================================================
\ Meta Compiler Resolve Forward References

0 VALUE #UNRESOLVED

: .UNRESOLVED   ( -- f )
        0 TO #UNRESOLVED
        FORWARD-LINK CR
        BEGIN   @ DUP
        WHILE   DUP 2 CELLS - RESOLVED? 0=
                IF      DUP 2 CELLS - BODY> .NAME  ( *SYSDEP* )
                        1 +TO #UNRESOLVED
                THEN
        REPEAT  DROP
        #UNRESOLVED
        IF      CR ."   *** There were: " #UNRESOLVED . ." words unresolved ***"
        ELSE    CR ."   All words resolved"
        THEN
        DEPTH 0<> IF
          1 TO #UNRESOLVED CR
             ."   *** Stack was not clean on exit ***"
        ELSE ."   Stack clean on exit"
        THEN
        #UNRESOLVED IF 3 0 DO BEEP 300 MS LOOP THEN
        #UNRESOLVED
        ;

: FIND-UNRESOLVED   ( -- cfa f )
        'F    DUP  >BODY RESOLVED?     ;

: RESOLVE   ( taddr cfa -- )
        >BODY   2DUP TRUE OVER CELL+ ! @
        BEGIN   DUP
        WHILE 2DUP
        DUP tapp-here > IF          \ check if in system address for target
          tsys-@   -ROT SWAP tsys-!
        ELSE
          t-@   -ROT SWAP t-!
        THEN
        REPEAT  2DROP  !   ;

: RESOLVES   ( taddr -- )
        FIND-UNRESOLVED
        IF      .NAME ." Already Resolved"   DROP  ( *SYSDEP* )
        ELSE    RESOLVE
        THEN   ;

\ ======================================================================
\ Meta compiler Branching & Looping

T: IF      [TARGET] ?BRANCH  ?>MARK   T;
T: -IF     [TARGET] -?BRANCH ?>MARK   T;
T: THEN    [TARGET] _THEN    ?>RESOLVE    T;
T: ELSE    [TARGET]  BRANCH  ?>MARK   2SWAP ?>RESOLVE   T;

T: BEGIN   [TARGET] _BEGIN   ?<MARK CELL+  T;
T: AGAIN   [TARGET] _AGAIN   ?<RESOLVE   T;
T: UNTIL   [TARGET] _UNTIL   ?<RESOLVE   T;
T: WHILE   [TARGET] _WHILE   ?>MARK  2SWAP  T;
T: REPEAT  [TARGET] _REPEAT  ?<RESOLVE  ?>RESOLVE   T;

T: ?DO     [TARGET] (?DO)    ?>MARK   T;
T: DO      [TARGET] (DO)     ?>MARK   T;
T: LOOP    [TARGET] (LOOP)   2DUP 2 CELLS+ ?<RESOLVE ?>RESOLVE   T;
T: +LOOP   [TARGET] (+LOOP)  2DUP 2 CELLS+ ?<RESOLVE ?>RESOLVE   T;

\ ======================================================================
\ Meta compiler literals

T: LITERAL   ( n -- )   [TARGET] LIT  t-,   T;
T: [CHAR]    ( -- )     CHAR        [TRANSITION] LITERAL   T;
T: [']       ( -- )     'T >BODY @  [TRANSITION] LITERAL   T;

\ ======================================================================
\ Target EQU is like a constant except that if it is used in a definition
\ it will just compile a literal.

: (EQU)  ( n -- )
        CREATE ,  DOES> @ [TRANSITION] LITERAL ;

: EQU   ( n -<name>- )
        TRANSITION DEFINITIONS
        >IN @  OVER (EQU)  >IN !
        META DEFINITIONS
        CONSTANT ;

: HERE:  ( -<name>- )
        t-here EQU ;

\ ======================================================================
\ Meta compiler defining words

ASSEMBLER DEFINITIONS

: [UP]   ( offset -- ) [edx]  ;     \ EDX is user pointer
: [UP],  ( offset -- ) [edx], ;
: TOS    ( -- )        ebx    ;
: TOS,   ( -- )        ebx,   ;
: [TOS]  ( -- )        [ebx]  ;
: [TOS], ( -- )        [ebx], ;

META DEFINITIONS

: ALIAS ( xt -- )
        TARGET-DEFINE
        ;

FORTH VARIABLE PROC-LIST-T META
FORTH VARIABLE LIBS-LIST-T META

: PROC  ( n -- )                                  \ added to support proc
        | RECREATE
        t-here  PROC-LIST-T @ t-,  PROC-LIST-T !
        >IN @ HERE: >IN !
        [LABEL] DOCALL t-,
        [LABEL] DOCALL-MULTI t-,
        0 t-,
        t-c,
        BL PARSE DUP t-c,  t-s,  0 t-c,  t-align
        ;

: WINLIBRARY ( -- )
        | RECREATE                                \ added to support winlibrary
        t-here  LIBS-LIST-T @ t-,  LIBS-LIST-T !
        0 t-,
        BL PARSE 2dup upper DUP t-c,  t-s,  0 t-c,  t-align
        ;

: USER  ( n -- )        \ 960827 bee
        RECREATE   [LABEL] DOUSER t-,
        DUP t-,   CONSTANT   ;

: CREATE  ( -- )
        RECREATE  [LABEL] DOVAR t-,
        t-here CONSTANT  ;

: VARIABLE  ( -- )
        CREATE   0 t-,   ;

: CONSTANT   ( n -- )
        RECREATE   [LABEL] DOCON t-,
        DUP t-,   CONSTANT   ;

: DLL        ( 'name.DLL' <-name-> )  \ usage: DLL "USER32.DLL" USER32
        WINLIBRARY LIBS-LIST-T @ CONSTANT ;

: OFFSET ( n -- )
        TARGET-CREATE [LABEL] DOOFF t-, t-, ;

: VALUE  ( n -- )
        TARGET-CREATE
        [LABEL] DOVALUE   t-,
        t-,
        [LABEL] DOVALUE!  t-,
        [LABEL] DOVALUE+! t-,  ;

: LOCAL  ( n -- )
        TARGET-CREATE
        [LABEL] LOCAL@  t-,
        1+ -4 * t-,
        [LABEL] LOCAL!  t-,
        [LABEL] LOCAL+! t-,  ;

FORTH VARIABLE DEFER-LIST-T META

: DEFER   ( -- )
        TARGET-CREATE   [LABEL] DODEFER t-,
        0 t-,
        t-here  DEFER-LIST-T @ t-,  DEFER-LIST-T !
        0 t-,  ;

: LINK,    ( addr -- )                       \ build link from list head at addr
        t-here OVER t-@ t-, SWAP t-! ;

FORWARD: <(;CODE)>

T: ;CODE   ( -- addr )
        [FORWARD] <(;CODE)> tcode-here t-,
        STATE-T OFF   IN-META
        IN-CODE? ON
        INIT-ASSEMBLER T;

\ ======================================================================
\ Identify numbers (single numbers only)

: meta-number?  ( ^str -- d n )           \ an extensible version of NUMBER
                count temp$ place
                temp$ ['] number catch
                if false else
                  double? abort" Doubles not supported in meta-compiler"
                  [ also hidden ]
                  float?  abort" Floats not supported in metacompiler"
                  [ previous ]
                drop true then ;

\ ======================================================================
\ Meta Compiler Compiling Loop.

\ We need a special version of WORD that will span multiple lines.
\ This will also save >IN so we can rescan the input stream.
FORTH VARIABLE T-IN META

: TOKEN  ( -- addr )
        BEGIN   >IN @ T-IN !
                BL WORD  DUP C@ 0=
        WHILE   DROP REFILL  0= ABORT" end of file in definition"
        REPEAT  UPPERCASE ;

: ]   ( -- )
        STATE-T ON   IN-TRANSITION
        BEGIN   TOKEN FIND \ no locals or class words
                IF      EXECUTE
                ELSE    meta-number?
                        IF      [TRANSITION] LITERAL
                        ELSE    DROP T-IN @ >IN !
                                UNDEFINED ( create forward reference )
                        THEN
                THEN
                STATE-T @ 0=
        UNTIL   ;

T: [   IN-META   STATE-T OFF   T;
T: ;   [TARGET] UNNEST   [TRANSITION] [   T;

\ ======================================================================
\ Interpretive words for Meta

: '    'T >BODY @ ;
: ,           t-, ;
: W,         t-w, ;
: C,         t-c, ;
: HERE     t-here ;
: ALLOT   t-allot ;
: ,"    t-string, ;
: !           t-! ;
: ALIGN   t-align ;
: COLON:   TARGET-CREATE  [LABEL] DOCOL t-,   ]  ;
: |: | COLON:  ;   \ headerless : colon def
: :    COLON:  ;   \ standard colon def

((
*** NOTE From this point on, everything is meta compiled!
))



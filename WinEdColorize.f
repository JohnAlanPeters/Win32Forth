\ Color configuration for WinEd
\ n1 n2 name:  n1 = action  n2 = color  name = blank-delimited string
\ action color name

\ Actions:
\  1 = colorize single word              n1=non-number is a comment
\  2 = same color to end of line
\  3 = same color to )
\  4 = same color to "
\  5 = same color to }
\  6 = same color to ]
\  7 = same color to >
\  8 = color the first word of a pair, the second word is black
\  9 = same color in a pair
\ 10 = start of comment
\ 11 = start of comment

\ Colors:
\  0 black      1 red         2 green      3 yellow
\  4 blue       5 magenta     6 cyan       7 ltgray
\  8 dkgray     9 ltred      10 ltgreen   11 ltyellow
\ 12 ltblue    13 ltmagenta  14 ltcyan    15 gray
\ 16 brown     17 ltgrey     18 dkmagenta

\ act color
9  13   CALL
1  16   ENTRY
1  12   CODE            defining words that come in pairs
1  12   CFA-CODE        green
1  12   CFA-FUNC
1  12   END-CODE        yellow
1  12   C;
9  12   :
9  1    :M              does not color the second word like it should
1  12   :NONAME
1  12   ;
1  12   :M
1  12   ;M
1  12   :CLASS
1  12   ;CLASS          ltyellow
1  12   :OBJECT
1  12   ;OBJECT
1  12   EXIT            unusual control things that should stand out
1  12   ?EXIT
1  12   LEAVE
1  12   UNLOOP
1  12   QUIT
1  12   RECURSE
1  12   IF              control structures
1  12   -IF
1  12   ELSE
1  12   THEN
1  12   BEGIN
1  12   WHILE
1  12   REPEAT
1  12   AGAIN
1  12   UNTIL
1  12   CONTINUE
1  12   DO
1  12   ?DO
1  12   DO-THRU
1  12   LOOP
1  12   +LOOP
1  12   CASE
1  12   OF
1  12   ENDOF
1  12   ENDCASE
1  6    HERE            dictionary and search order
1  6    ORG
1  6    ALLOT
1  6    ALSO
1  6    ONLY
1  6    PREVIOUS
1  6    DEFINITIONS
1  6    IMMEDIATE
1  6    COMPILE-ONLY
1  6    ALIGN
1  6    ENVIRONMENT?
1  6    IN-APPLICATION
1  6    IN-SYSTEM
1  6    MARKER
1  6    ANEW
1  5    VALUE           single defining words
1  5    CONSTANT
1  5    VARIABLE
1  5    2CONSTANT
1  5    2VARIABLE
1  5    USER
1  5    INT
9  3    LOCAL           local variable
1  5    DEFER
1  5    CREATE
1  5    DOES>
1  5    VOCABULARY
5  3    {               locals between { and }
2  2    \
2  2    //
3  2    (
3  2    C(
3  2    .(
4  1    ."              string constants
4  1    S"
4  1    C"
4  1    ABORT"
4  1    Z"
4  1    Z,"
4  1    +Z,"
9  1    H#              number follows, color both
9  1    '
9  1    [']
9  1    [CHAR]
1  1    FALSE           other constants
1  1    TRUE
1  1    BL
9  13   POSTPONE
9  13   [COMPILE]
9  13   TO
9  13   +TO
9  13   IS
1  9    #IF             conditional compilation
1  9    #ELSE
1  9    #THEN
1  9    #ENDIF
1  9    [IF]
1  9    [ELSE]
1  9    [THEN]
9  9    INCLUDE
9  9    FLOAD
9  9    FSAVE
9  9    NEEDS
1  9    [
1  9    ]
9  9    IMAGE-SAVE
9  9    TURNKEY

\ Other ANS CORE

1  4    !
1  4    #
1  4    #>
1  4    #S
1  4    *
1  4    */
1  4    */MOD
1  4    +
1  4    +!
1  4    ,
1  4    -
1  4    .
1  4    /
1  4    /MOD
1  4    0<
1  4    0=
1  4    1+
1  4    1-
1  4    2!
1  4    2*
1  4    2/
1  4    2@
1  4    -ROT
1  4    2ROT
1  4    2DROP
1  4    3DROP
1  4    4DROP
1  4    2DUP
1  4    3DUP
1  4    4DUP
1  4    2OVER
1  4    2SWAP
1  4    <
1  4    <#
1  4    =
1  4    >
1  4    >BODY
1  4    >IN
1  4    >NUMBER
1  4    >R
1  4    R>DROP
1  4    DUP>R
1  4    ?DUP
1  4    @
1  4    ABS
1  4    ABORT
1  4    ACCEPT
1  4    ALIGNED
1  4    AND
1  4    BASE
1  4    C!
1  4    C,
1  4    C@
1  4    CELL+
1  4    CELLS
1  4    CHAR
1  4    CHAR+
1  4    CHARS
1  4    COUNT
1  4    CR
1  4    DECIMAL
1  4    DEPTH
1  4    DROP
1  4    DUP
1  4    EMIT
1  4    EVALUATE
1  4    EXECUTE
1  4    FILL
1  4    FIND
1  4    FM/MOD
1  4    HOLD
1  4    I
1  4    INVERT
1  4    J
1  4    KEY
1  4    LITERAL
1  4    LSHIFT
1  4    M*
1  4    MAX
1  4    MIN
1  4    MOD
1  4    MOVE
1  4    NEGATE
1  4    OR
1  4    OVER
1  4    R>
1  4    R@
1  4    ROT
1  4    RSHIFT
1  4    S>D
1  4    SIGN
1  4    SM/REM
1  4    SOURCE
1  4    SPACE
1  4    SPACES
1  4    STATE
1  4    SWAP
1  4    TYPE
1  4    U.
1  4    U<
1  4    UM*
1  4    UM/MOD
1  4    WORD
1  4    XOR
1  4    3REVERSE
1  4    4REVERSE

\ Other ANS EXT

1  15   #TIB
1  15   .R
1  15   0<>
1  15   0>
1  15   2>R
1  15   2R>
1  15   2R@
1  15   <>
1  15   COMPILE,
1  15   CONVERT
1  15   ERASE
1  15   EXPECT
1  15   HEX
1  15   NIP
1  15   2NIP
1  15   PAD
1  15   PARSE
1  15   PICK
1  15   QUERY
1  15   REFILL
1  15   RESTORE-INPUT
1  15   ROLL
1  15   SAVE-INPUT
1  15   SOURCE-ID
1  15   SPAN
1  15   TIB
1  15   TUCK
1  15   U.R
1  15   U>
1  15   UNUSED
1  15   WITHIN

\ Other ANS Floating Piont

1  11   1/F
1  11   >FLOAT
1  11   F>S
1  11   S>F
1  11   F.
1  11   F+!
1  11   F+
1  11   F-
1  11   F*
1  11   F/
1  11   F^2
1  11   F~
1  11   F@
1  11   D>F
1  11   F>D
1  11   SF@
1  11   DF@
1  11   F!
1  11   SF!
1  11   DF!
1  11   F=
1  11   F<
1  11   F>
1  11   F>=
1  11   F0=
1  11   F0<
1  11   F0>
1  11   F0<>
1  11   F2/
1  11   F2*
1  11   F**
1  11   FTO
1  11   FE.
1  11   FS.
1  11   FEPS
1  11   FINF
1  11   FLN
1  11   FLOG
1  11   FSIN
1  11   FSINH
1  11   FCOS
1  11   FCOSH
1  11   FTAN
1  11   FTANH
1  11   FABS
1  11   FMAX
1  11   FMIN
1  11   FDUP
1  11   FEXP
1  11   FLNP1
1  11   FDROP
1  11   FSWAP
1  11   FOVER
1  11   FEXAM
1  11   FEXPM1
1  11   FNIP
1  11   FROT
1  11   FLOAT+
1  11   FLOATS
1  11   DFLOAT+
1  11   DFLOATS
1  11   FLOOR
1  11   F-ROT
1  11   FPICK 
1  11   FSQRT
1  11   FTUCK
1  11   FASIN
1  11   FALOG
1  11   FASINH
1  11   FACOS
1  11   FACOSH
1  11   FATAN
1  11   FATAN2
1  11   FATANH
1  11   FALIGN
1  11   FALIGNED
1  11   FLITERAL
1  11   DFALIGN
1  11   DFALIGNED
1  11   SFALIGN
1  11   SFALIGNED
1  11   SFLOAT+
1  11   SFLOATS
1  11   F2DUP
1  11   FINIT
1  11   F2DROP
1  11   F2SWAP
1  11   F2NIP
1  11   FROUND
1  11   FDEPTH
1  11   FNEGATE
1  11   FVALUE
1  11   FSINCOS
1  11   REPRESENT
1  11   FVARIABLE
1  11   FCONSTANT
1  11   PRECISION
1  11   SET-PRECISION

\ Other stuff used in Firmware Studio

1  12   LOCO
1  12   ASSEMBLE
1  12   MACRO:
1  12   ;MACRO
1  12   MULTI           for MULTI..REPEAT
1  12   IF_Z            assembler control structures
1  12   IF_NZ
1  12   IF_C
1  12   IF_NC
1  12   IF_EQ
1  12   IF_NE
1  12   WHILE_Z
1  12   WHILE_NZ
1  12   WHILE_C
1  12   WHILE_NC
1  12   WHILE_EQ
1  12   WHILE_NE
1  12   UNTIL_Z
1  12   UNTIL_NZ
1  12   UNTIL_C
1  12   UNTIL_NC
1  12   UNTIL_EQ
1  12   UNTIL_NE
1  12   NEVER           works like 0 IF  \ for processors with SKIP instruction
1  12   NOWAY           works like 0 WHILE
1  12   FOR
1  12   NEXT
1  6    RAM
1  6    ROM
1  6    {{
1  6    }}
1  6    LOW-TOKENS
1  6    MAIN-TOKENS
1  6    TEMP-TOKENS
1  9    >TOKEN#
1  5    ASMBYTE
1  5    ASMWORD
1  5    ASMLONG
1  5    ASMARRAY
1  5    ASMLABEL
9  1    ASMLABEL?
\ 10  2   COMMENT:
\ 11  2   COMMENT;
\ 10  2    ((
\ 11  2    ))


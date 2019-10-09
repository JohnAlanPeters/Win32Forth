( *
  * LANGUAGE    : ANS Forth
  * PROJECT     : Forth Environments
  * DESCRIPTION : Matrix Multiplication
  * CATEGORY    : Benchmark
  * AUTHOR      : Mark Smotherman <mark@cs.clemson.edu>
  * From        : June 12, 2000, Marcel Hendrix
  * Changes     : January 12th, 2009  J.v.d.Ven: Changed 2^x thanks to Elko Tchernev

  * )

\ The MM benchmark from: http://home.iae.nl/users/mhx/mm.fw


NEEDS fsl_util.f

0 [IF] ===========================================================================================
 matrix multiply tests -- C language, version 1.0, May 1993

 compile with -DN=<size>

 I usually run a script file
   time.script 500 >500.times
 where the script file contains
   cc -O -DN=$1 mm.c
   a.out -n             (I suggest at least two runs per method to
   a.out -n             alert you to variations.  Five or ten runs
   a.out -t             each, giving avg. and std dev. of times is
   a.out -t             best.)
     ...

 Contact Mark Smotherman (mark@cs.clemson.edu) for questions, comments,
 and to report results showing wide variations.  E.g., a wide variation
 appeared on an IBM RS/6000 Model 320 with "cc -O -DN=500 mm.c" (xlc compiler):
  500x500 mm - normal algorithm                     utime     230.81 secs
  500x500 mm - normal algorithm                     utime     230.72 secs
  500x500 mm - temporary variable in loop           utime     231.00 secs
  500x500 mm - temporary variable in loop           utime     230.79 secs
  500x500 mm - unrolled inner loop, factor of  8    utime     232.09 secs
  500x500 mm - unrolled inner loop, factor of  8    utime     231.84 secs
  500x500 mm - pointers used to access matrices     utime     230.74 secs
  500x500 mm - pointers used to access matrices     utime     230.45 secs
  500x500 mm - blocking, factor of  32              utime      60.40 secs
  500x500 mm - blocking, factor of  32              utime      60.57 secs
  500x500 mm - interchanged inner loops             utime      27.36 secs
  500x500 mm - interchanged inner loops             utime      27.40 secs
  500x500 mm - 20x20 subarray (from D. Warner)      utime       9.49 secs
  500x500 mm - 20x20 subarray (from D. Warner)      utime       9.50 secs
  500x500 mm - 20x20 subarray (from T. Maeno)       utime       9.10 secs
  500x500 mm - 20x20 subarray (from T. Maeno)       utime       9.05 secs

 The algorithms can also be sensitive to TLB thrashing.  On a 600x600
 test an IBM RS/6000 Model 30 showed variations depending on relative
 location of the matrices.  (The model 30 has 64 TLB entries organized
 as 2-way set associative.)

 600x600 mm - 20x20 subarray (from T. Maeno)       utime      19.12 secs
 600x600 mm - 20x20 subarray (from T. Maeno)       utime      19.23 secs
 600x600 mm - 20x20 subarray (from D. Warner)      utime      18.87 secs
 600x600 mm - 20x20 subarray (from D. Warner)      utime      18.64 secs
 600x600 mm - 20x20 btranspose (Warner/Smotherman) utime      17.70 secs
 600x600 mm - 20x20 btranspose (Warner/Smotherman) utime      17.76 secs

 Changing the declaration to include 10000 dummy entries between the
 b and c matrices (suggested by T. Maeno), i.e.,

 double a[N][N],b[N][N],dummy[10000],c[N][N],d[N][N],bt[N][N];

 600x600 mm - 20x20 subarray (from T. Maeno)       utime      16.41 secs
 600x600 mm - 20x20 subarray (from T. Maeno)       utime      16.40 secs
 600x600 mm - 20x20 subarray (from D. Warner)      utime      16.68 secs
 600x600 mm - 20x20 subarray (from D. Warner)      utime      16.67 secs
 600x600 mm - 20x20 btranspose (Warner/Smotherman) utime      16.97 secs
 600x600 mm - 20x20 btranspose (Warner/Smotherman) utime      16.98 secs

 I hope to add other algorithms (e.g., Strassen-Winograd) in the near future.

P5-166 MHz, 48 MB, NT 4.0
        500x500 mm (aborted - over 6 minutes per benchmark)
CLK 165 MHz
        120x120 mm - normal algorithm                            0.93 MFlops, 176.76 ticks/flop,   3.702 s
        120x120 mm - blocking, factor of 20                      0.55 MFlops, 295.18 ticks/flop,   6.182 s
        120x120 mm - transposed B matrix                         0.87 MFlops, 189.46 ticks/flop,   3.968 s
        120x120 mm - Robert's algorithm                          0.90 MFlops, 181.76 ticks/flop,   3.807 s
        120x120 mm - T. Maeno's algorithm, subarray 20x20        0.45 MFlops, 366.00 ticks/flop,   7.666 s
        120x120 mm - D. Warner's algorithm, subarray 20x20       0.57 MFlops, 288.33 ticks/flop,   6.039 s
CLK 165 MHz
        60x60 mm - normal algorithm                              0.92 MFlops, 178.71 ticks/flop,   0.467 s
        60x60 mm - blocking, factor of 20                        0.56 MFlops, 290.60 ticks/flop,   0.760 s
        60x60 mm - transposed B matrix                           0.80 MFlops, 203.84 ticks/flop,   0.533 s
        60x60 mm - Robert's algorithm                            0.86 MFlops, 191.84 ticks/flop,   0.502 s
        60x60 mm - T. Maeno's algorithm, subarray 20x20          0.44 MFlops, 372.79 ticks/flop,   0.976 s
        60x60 mm - D. Warner's algorithm, subarray 20x20         0.53 MFlops, 307.52 ticks/flop,   0.805 s
========================================================================================================== [THEN]

\ TOOLS ==================================================================================================

0 VALUE [S]
0 VALUE [T]

\ Not portable.
: HTAB  ( n -- ) GETXY NIP AT-XY ;
: DEC.  ( n -- ) BASE @ >R DECIMAL . R> BASE ! ;
: F<>   ( F: r -- ) ( -- bool ) F= 0= ;
: DFLOAT[] ( addr ix -- addr' ) DFLOATS + ;
: DFVARIABLE ( -- ) CREATE 8 ALLOT ;

0 CONSTANT U>D

DEFINED DF@+  NIP 0= [IF] : DF@+  ( addr -- addr' ) ( F: -- r ) DUP DF@ DFLOAT+ ; [THEN]
DEFINED DF!+  NIP 0= [IF] : DF!+  ( addr -- addr' ) ( F: r -- ) DUP DF! DFLOAT+ ; [THEN]
DEFINED DF+!+ NIP 0= [IF] : DF+!+ ( addr -- addr' ) ( F: r -- ) DUP DF@ F+ DF!+ ; [THEN]
DEFINED DF+!  NIP 0= [IF] : DF+!  ( addr -- addr' ) ( F: r -- ) DUP DF@ F+ DF!  ; [THEN]

DEFINED DDOT NIP 0= [IF]
: DDOT ( addr1 inc1 addr2 inc2 count -- ) ( F: -- n )
                SWAP DFLOATS >R  ROT DFLOATS R> LOCALS| inc2 inc1 |
                0e 0 ?DO  SWAP DUP DF@ inc1 +
                          SWAP DUP DF@ inc2 +
                          F* F+
                    LOOP  2DROP ;
[THEN]


DEFINED DAXPY NIP 0= [IF]
: DAXPY ( addr1 inc1 addr2 inc2 count -- ) ( F: a -- )
                SWAP DFLOATS >R  ROT DFLOATS R> LOCALS| inc2 inc1 |
                0 ?DO   FDUP
                        SWAP DUP DF@ F* inc1 +
                        SWAP DUP DF+!   inc2 +
                 LOOP   2DROP FDROP ;
[THEN]


: 2^X   ( x - 2^x )
   dup 0<
    if    0>
    else  dup 31 >= abort" Out of range"
          1 SWAP LSHIFT
    then
 ;

CHAR x CONSTANT 'x'
CHAR n CONSTANT 'n'
CHAR v CONSTANT 'v'
CHAR u CONSTANT 'u'
CHAR p CONSTANT 'p'
CHAR t CONSTANT 't'
CHAR i CONSTANT 'i'
CHAR b CONSTANT 'b'
CHAR m CONSTANT 'm'
CHAR r CONSTANT 'r'
CHAR w CONSTANT 'w'
CHAR s CONSTANT 's'
CHAR . CONSTANT '.'
CHAR , CONSTANT ','
CHAR : CONSTANT ':'

\ =====================================================================================

FALSE VALUE SHHT?
   0  VALUE FLOPS
   0  VALUE t/flops
   0  VALUE msecs
  80  VALUE N

1 DFLOATS CONSTANT DFLOAT1
4 DFLOATS CONSTANT DFLOAT4
8 DFLOATS CONSTANT DFLOAT8

DOUBLE DMATRIX  a{{
DOUBLE DMATRIX  b{{
DOUBLE DMATRIX  c{{
DOUBLE DMATRIX  d{{
DOUBLE DMATRIX bt{{

166 VALUE PROCESSOR-CLOCK
2VARIABLE _ticks_  ( counts clock ticks )

\ uses EDX:EAX
CODE TICKS-GET ( -- d )
        push ebx
        mov ecx , edx
        rdtsc
        push eax
        mov ebx , edx
        mov edx , ecx
        NEXT,
END-CODE

: TICKS-RESET  ( -- ) TICKS-GET _ticks_ 2! ; TICKS-RESET
: TICKS>US ( d -- u ) PROCESSOR-CLOCK UM/MOD NIP ;
: TICKS?     ( -- u ) TICKS-GET _ticks_ 2@  D- ;
: US?       ( -- us ) TICKS?  TICKS>US ;
: CALIBRATE    ( -- ) TICKS-RESET  1000 MS  TICKS? 1000000 UM/MOD NIP  TO PROCESSOR-CLOCK ;

: ?# ( d -- d )   2DUP OR 0= IF  BL HOLD  ELSE  #  ENDIF ;
: .FLOPS ( n -- ) U>D <# BL HOLD # # '.' HOLD # ?# ?# ?# #> TYPE ." MFlops" ;
: .TICKS ( n -- ) U>D <# BL HOLD # # '.' HOLD # ?# ?# BL HOLD ',' HOLD #> TYPE ." ticks/flop" ;
: .SECS  ( n -- ) U>D <# 's' HOLD BL HOLD # # # '.' HOLD # ?# ?# BL HOLD ',' HOLD #> TYPE ;
: INIT-RESULT     S" TICKS-RESET 0 TO [T] BEGIN " EVALUATE ; IMMEDIATE

: (.RES) ( n -- )
        DUP N * N * N * 2* 1 OR  TICKS? ( -- n fl dti )
        3DUP TICKS>US 1 OR DUP >R  100 SWAP */ TO FLOPS
        100 1 M*/ ROT UM/MOD NIP TO t/flops
        R> SWAP 1000 * / TO msecs
        SHHT? IF  EXIT  ENDIF
        FLOPS .FLOPS  t/flops .TICKS msecs .SECS ;

: .RESULT         S" [T] 1+ TO [T] US? 2000000 > UNTIL  [T] (.RES) " EVALUATE ; IMMEDIATE

\ Set coefficients so that result matrix should have row entries equal to (1/2)*n*(n-1)*i in row i
: SET-COEFFICIENTS ( -- )  N 0 ?DO  N 0 ?DO  J S>F FDUP b{{ J I }} DF!  a{{ J I }} DF!  LOOP LOOP ;
: FLUSH-CACHE      ( -- )  N 0 ?DO  N 0 ?DO  0e d{{ J I }} DF!  LOOP LOOP ;

FVARIABLE row_sum
FVARIABLE sum

: CHECK-RESULT ( -- )
        FLOPS 0= IF  SHHT? 0= IF CR ." algorithm aborted" ENDIF EXIT  ENDIF
        0e row_sum F!
        N N 1- * 2/ S>F sum F!
        N 0 ?DO  I S>F sum F@ F* row_sum F!
                 N 0 ?DO c{{ J I }} DF@ row_sum F@ F<> IF  CR ." error in result entry c{{ " J DEC. I DEC. ." }}: " c{{ J I }} DF@ F. ." <> " row_sum F@ F. UNLOOP UNLOOP EXIT  ENDIF
                         a{{ J I }} DF@     J S>F  F<> IF  CR ." error in result entry a{{ " J DEC. I DEC. ." }}: " a{{ J I }} DF@ F. ." <> " J S>F      F. UNLOOP UNLOOP EXIT  ENDIF
                         b{{ J I }} DF@     J S>F  F<> IF  CR ." error in result entry b{{ " J DEC. I DEC. ." }}: " b{{ J I }} DF@ F. ." <> " J S>F      F. UNLOOP UNLOOP EXIT  ENDIF
                    LOOP
           LOOP ;

: NORMAL() ( -- )
        SHHT? 0= IF  CR N 0 .R 'x' EMIT N 0 .R ."  mm - normal algorithm" 54 HTAB ENDIF
        INIT-RESULT
        N 0 ?DO c{{ I 0 }}
                a{{ I 0 }} TO [S]
                b{{ 0 0 }} N DFLOATS BOUNDS
                ?DO  [S] 1  I N  N DDOT DF!+  DFLOAT1 +LOOP
                DROP
           LOOP
        .RESULT ;

: TRANSPOSE() ( -- )
        SHHT? 0= IF  CR N 0 .R 'x' EMIT N 0 .R ."  mm - transposed B matrix" 54 HTAB  ENDIF
        INIT-RESULT
        N 0 ?DO  N 0 ?DO  b{{ J I }} DF@  bt{{ I J }} DF!  LOOP LOOP
        N 0 ?DO  c{{ I 0 }}  N 0 ?DO  a{{ J 0 }} 1  bt{{ I 0 }} 1  N DDOT DF!+  LOOP DROP LOOP
        .RESULT ;

\ from Monica Lam ASPLOS-IV paper
: TILING() ( step -- )
        DUP 4 N 1+ WITHIN 0= IF  SHHT? 0= IF CR ."  mm - blocking step size of " DUP DEC. ." is unreasonable" ENDIF DROP EXIT ENDIF
        SHHT? 0=  IF  CR N 0 .R 'x' EMIT N 0 .R ."  mm - blocking, factor of " DUP DEC. 54 HTAB  ENDIF
        0 0 LOCALS| kk jj step |
        INIT-RESULT
        N 0 ?DO  N 0 ?DO  0e c{{ J I }} DF!  LOOP LOOP
           N 0 ?DO  I TO kk
                       N 0 ?DO  I TO jj
                                N 0 ?DO   a{{ I kk }}
                                          kk step + N MIN
                                          kk ?DO  DF@+  b{{ I jj }} 1  c{{ J jj }} 1
                                                  jj step + N MIN  jj - DAXPY
                                            LOOP  DROP
                                   LOOP
                    step +LOOP
        step +LOOP
        .RESULT ;

\ ********************************************
\ * Contributed by Robert Debath 26 Nov 1995 *
\ * rdebath@cix.compulink.co.uk              *
\ ********************************************
: ROBERT() ( -- )
        SHHT? 0=  IF  CR N 0 .R 'x' EMIT N 0 .R ."  mm - Robert's algorithm" 54 HTAB  ENDIF
        INIT-RESULT
        N 0 ?DO  N 0 ?DO  b{{ J I }} DF@  bt{{ I J }} DF!  LOOP LOOP
        a{{ 0 0 }} TO [S]
        N 0 ?DO   bt{{ 0 0 }}
                   c{{ I 0 }}
                  N 0 ?DO  [S] 1  3 PICK 1  N DDOT  DF!+  SWAP N DFLOAT[] SWAP  LOOP
                  2DROP
                  N DFLOATS [S] + TO [S]
           LOOP
        .RESULT ;


0 [IF] ===========================================================================
 * Matrix Multiply by Dan Warner, Dept. of Mathematics, Clemson University
 *
 *    mmbu2.f multiplies matrices a and b
 *    a and b are n by n matrices
 *    nb is the blocking parameter.
 *    the tuning guide indicates nb = 50 is reasonable for the
 *    ibm model 530 hence 25 should be reasonable for the 320
 *    since the 320 has 32k rather than 64k of cache.
 *    Inner loops unrolled to depth of 2
 *    The loop functions without clean up code at the end only
 *    if the unrolling occurs to a depth k which divides into n
 *    in this case n must be divisible by 2.
 *    The blocking parameter nb must divide into n if the
 *    multiply is to succeed without clean up code at the end.
 *
 * converted to c by Mark Smotherman
 * note that nb must also be divisible by 2 => cannot use 25, so use 20
=========================================================================== [THEN]

DFVARIABLE s10
DFVARIABLE s00
DFVARIABLE s01
DFVARIABLE s11

: WARNER() ( nb -- )
        0 0 0 0 0 LOCALS| 'a 'b ii jj kk nb |
        SHHT? 0= IF  CR N 0 .R 'x' EMIT N 0 .R  ENDIF
        N nb MOD  N 2 MOD OR IF SHHT? 0= IF ."  mm - Warner's algorithm, the matrix size " N DEC. ." must be divisible both by the block size " nb DEC. ." and 2." ENDIF EXIT ENDIF
        nb 2 MOD IF  SHHT? 0= IF ."  mm - block size for Warner method must be evenly divisible by 2" ENDIF EXIT ENDIF
        SHHT? 0= IF  ."  mm - D. Warner's algorithm, subarray " nb 0 .R 'x' EMIT nb 0 .R SPACE  54 HTAB  ENDIF
        INIT-RESULT
         N 0 ?DO  I TO ii
                  N 0 ?DO I TO jj
                          nb ii + ii ?DO  nb jj + jj ?DO  0e c{{ J I }} DF!  LOOP  LOOP
                          N 0 ?DO  I TO kk
                                   nb ii + ii ?DO
                                   nb jj + jj ?DO c{{ J     I    }} DUP DF@+ s00 DF!
                                                                    DUP DF@  s01 DF!
                                                  c{{ J 1+  I    }} DUP DF@+ s10 DF!
                                                                    DUP DF@  s11 DF!
                                                  a{{ J    kk }} TO 'a
                                                  b{{ kk    I }} TO 'b
                                                  nb kk + kk ?DO  'a             DUP DF@  'b DF@+ F* s00 DF+!
                                                                                SWAP DF@     DF@  F* s01 DF+!
                                                                  'a N DFLOAT[] DUP  DF@  'b DF@+ F* s10 DF+!
                                                                                SWAP DF@     DF@  F* s11 DF+!
                                                                  DFLOAT1   'a + TO 'a
                                                                  N DFLOATS 'b + TO 'b
                                                            LOOP
                                                  s11 DF@ DF!
                                                  s10 DF@ DF!
                                                  s01 DF@ DF!
                                                  s00 DF@ DF!
                                          2 +LOOP
                                          2 +LOOP
                         nb +LOOP
                 nb +LOOP
        nb +LOOP
        .RESULT ;

0 [IF] ===========================================================================
Matrix Multiply tuned for SS-10/30;
 *                      Maeno Toshinori
 *                      Tokyo Institute of Technology
 *
 * Using gcc-2.4.1 (-O2), this program ends in 12 seconds on SS-10/30.
 *
 * in original algorithm - sub-area for cache tiling
 * #define      L       20
 * #define      L2      20
 * three 20x20 matrices reside in cache; two may be enough
=========================================================================== [THEN]

DFVARIABLE t0
DFVARIABLE t1
DFVARIABLE t2
DFVARIABLE t3
DFVARIABLE t4
DFVARIABLE t5
DFVARIABLE t6
DFVARIABLE t7

: MAENO() ( nb -- )
        0 0 0 0 LOCALS| it kt i2 kk lparm |
        SHHT? 0= IF  CR N 0 .R 'x' EMIT N 0 .R  ENDIF
        N lparm MOD  N 4 MOD OR IF SHHT? 0= IF ."  mm - Maeno's algorithm, the matrix size " N DEC. ." must be divisible both by the block size " lparm DEC. ." and 4." ENDIF EXIT ENDIF
        lparm 4 MOD IF  SHHT? 0= IF ."  mm - block size for Maeno's method must be evenly divisible by 4" ENDIF EXIT  ENDIF
        SHHT? 0= IF  ."  mm - T. Maeno's algorithm, subarray " lparm 0 .R 'x' EMIT lparm 0 .R SPACE  54 HTAB  ENDIF
        INIT-RESULT
        N 0 ?DO N 0 ?DO  0e c{{ J I }} DF!  LOOP LOOP
            N 0 ?DO I TO i2  N 0 ?DO  I TO kk
                                      i2 lparm + TO it
                                      kk lparm + TO kt
                                      N 0 ?DO  it i2 ?DO
                                                          0e t0 DF!  0e t1 DF!  0e t2 DF!  0e t3 DF!
                                                          0e t4 DF!  0e t5 DF!  0e t6 DF!  0e t7 DF!
                                                          kt  kk ?DO    a{{ J    I }} DF@
                                                                        FDUP b{{ I K }} DUP DF@+ F* t0 DF+!
                                                                        FDUP                DF@+ F* t1 DF+!
                                                                        FDUP                DF@+ F* t2 DF+!
                                                                                            DF@  F* t3 DF+!
                                                                        a{{ J 1+ I }} DF@
                                                                        FDUP                DF@+ F* t4 DF+!
                                                                        FDUP                DF@+ F* t5 DF+!
                                                                        FDUP                DF@+ F* t6 DF+!
                                                                                            DF@  F* t7 DF+!
                                                                LOOP
                                                          t0 DF@ c{{ I    J }}  DF+!+
                                                          t1 DF@                DF+!+
                                                          t2 DF@                DF+!+
                                                          t3 DF@                DF+!
                                                          t4 DF@ c{{ I 1+ J }}  DF+!+
                                                          t5 DF@                DF+!+
                                                          t6 DF@                DF+!+
                                                          t7 DF@                DF+!
                                                 2 +LOOP
                                      4 +LOOP
                         lparm +LOOP
        lparm +LOOP
        .RESULT ;

: MM ( char n -- )
        DEPTH 0= ABORT" no algorithm chosen"
        DEPTH 2 < IF 0 ENDIF LOCALS| ur |
        &  a{{ N N }}malloc
        &  b{{ N N }}malloc
        & bt{{ N N }}malloc
        &  c{{ N N }}malloc
        &  d{{ N N }}malloc
        SET-COEFFICIENTS
        FLUSH-CACHE
        CASE
         'n' OF NORMAL()    ENDOF
         't' OF TRANSPOSE() ENDOF
         'b' OF ur TILING() ENDOF
         'r' OF ROBERT()    ENDOF
         'm' OF ur MAENO()  ENDOF
         'w' OF ur WARNER() ENDOF
                CR ." `" DUP EMIT ." ' is an invalid algorithm"
        ENDCASE
        CHECK-RESULT
        &  d{{ }}free
        &  c{{ }}free
        & bt{{ }}free
        &  b{{ }}free
        &  a{{ }}free ;

: ALL-TESTS ( -- )
        CR ." CLK " CALIBRATE PROCESSOR-CLOCK DEC. ." MHz"
                                         'n'    mm
        EKEY? IF  EKEY DROP EXIT  ELSE   'b' 20 mm  't'    mm    ENDIF
        EKEY? IF  EKEY DROP EXIT  ELSE   'r'    mm               ENDIF
        EKEY? IF  EKEY DROP EXIT  ELSE   'm' 20 mm  'w' 20 mm    ENDIF ;

: NEXT-N ( -- )
        N 1200 1000 */ TO N
         17 1 DO  N  I 2^x DUP  9 10 */ SWAP  11 10 */
                  WITHIN IF  I 2^x TO N LEAVE  ENDIF
            LOOP ;

: MEGAFLOPS ( sel -- )
        DEPTH 0= ABORT" no algorithm chosen"
        DEPTH 2 < IF 0 ENDIF
        0 0 SHHT? N LOCALS| old-N silence? flp ix ur algo |
        TRUE TO SHHT?
        CR ." Algorithm = '" algo EMIT [CHAR] ' EMIT  ur IF ." , parameter is " ur 0 .R ENDIF
        ." , clock = " CALIBRATE PROCESSOR-CLOCK DEC. ." MHz"
        32 TO N
         17 0 DO CR ." testing data size " N 3 .R  ."  x " N 3 .R ':' EMIT
                 algo ur mm
                 FLOPS flp > IF  FLOPS TO flp  N TO ix  ENDIF
                 FLOPS .FLOPS
                 NEXT-N  0 TO FLOPS
                 EKEY? IF  EKEY DROP LEAVE  ENDIF
            LOOP
        ix IF  CR CR ." Maximum: " flp .FLOPS ."  at N = " ix DEC.  ENDIF
        silence? TO SHHT?  old-N TO N ;

: .ABOUT
        CR ." -------------------------- Double-precision benchmark --------------------------"
        CR ." Try: 'n'    mm  -- normal"
        CR ."      'b'  n mm  -- using blocking by n, 4 < n < " N DEC.
        CR ."      't'    mm  -- with transposed b matrix"
        CR ."      'r'    mm  -- using Robert's algorithm"
        CR ."      'm'  n mm  -- using Maeno's algorithm with blocking factor n"
        CR ."      'w'  n mm  -- using Warner's algorithm with blocking factor n"
        CR
        CR ." ALL-TESTS       -- test all algorithms"
        CR ." ( x ) MEGAFLOPS -- find optimum size for this machine, algorithm 'x'" ;

                .ABOUT

        CR .( Compile time = ) US? 1000 / DEC. .( ms, assuming clockspeed = ) PROCESSOR-CLOCK DEC. .( MHz.)


all-tests

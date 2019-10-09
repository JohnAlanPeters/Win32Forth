\ ANS Forth Complex Arithmetic Lexicon

\ ---------------------------------------------------
\     (c) Copyright 1998  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

\ Environmental dependences:
\       1. requires FLOAT and FLOAT EXT wordsets
\       2. assumes separate floating point stack
\       3. does not construct a separate complex number stack

\ Complex numbers x+iy are stored on the fp stack as ( f: -- x y).
\ Angles are in radians.
\ Polar representation measures angle from the positive x-axis.

\ All Standard words are in uppercase, non-Standard words in lowercase,
\ as a convenience to the user.

MARKER -complex

\ ---------------------------------------- LOAD, STORE
: z@  DUP  F@  FLOAT+  F@ ;     ( adr --  f: -- z)
: z!  DUP  FLOAT+  F!  F! ;     ( adr --  f: z --)
\ ------------------------------------ END LOAD, STORE

\ non-Standard fp words I have found useful



[undefined] s>f       [IF]  : s>f     S>D  D>F  ;     [THEN]
[undefined] f-rot     [IF]  : f-rot    FROT  FROT  ;  [THEN]
[undefined] fnip      [IF]  : fnip   FSWAP  FDROP  ;  [THEN]
[undefined] ftuck     [IF]  : ftuck    FSWAP  FOVER ; [THEN]
[undefined] 1/f       [IF]  : 1/f   F1.0  FSWAP  F/ ; [THEN]
[undefined] f^2       [IF]  : f^2   FDUP  F*  ;       [THEN]
[undefined] fpi       [IF]  3.1415926535897932385E0  FCONSTANT  fpi  [THEN]
[undefined] f0.0      [IF]  0.0E0  FCONSTANT  f0.0   [THEN]
[undefined] f1.0      [IF]  1.0E0  FCONSTANT  f1.0   [THEN]



\ --------------------------------- MANIPULATE FPSTACK
: z.   FSWAP  FS. ."  + i " FS. ;  ( f: x y --)     \ emit complex #
: z=0  f0.0 f0.0 ;                 ( f: -- 0 0)
: z=1  f1.0 f0.0 ;                 ( f: -- 1 0)
: z=i  z=1 FSWAP ;                 ( f: -- 0 1)
: zdrop  FDROP FDROP ;             ( f: x y --)
: zdup   FOVER FOVER ;             ( f: x y -- x y x y)

\ hidden temporary storage for stuff from fpstack
FALIGN  HERE  VALUE noname   2 FLOATS  ALLOT     \ ALLOT z variable

: zswap    ( f: x y u v -- u v x y)
    [ noname ] LITERAL  F!  f-rot
    [ noname ] LITERAL  F@  f-rot  ;

: zover     ( f: x y u v -- x y u v x y )
    FROT    [ noname FLOAT+ ]  LITERAL  F!   ( f: -- x u v)
    FROT FDUP   [ noname    ]  LITERAL  F!   ( f: -- u v x)
    f-rot   [ noname FLOAT+ ]  LITERAL  F@   ( f: -- x u v y)
    f-rot   [ noname        ]  LITERAL  z@   ( f: -- x y u v x y)
;

: real    STATE @  IF   POSTPONE   FDROP   ELSE   FDROP   THEN  ; IMMEDIATE
: imag    STATE @  IF   POSTPONE   fnip    ELSE   fnip    THEN  ; IMMEDIATE
: conjg   STATE @  IF   POSTPONE   FNEGATE ELSE   FNEGATE THEN  ; IMMEDIATE


: znip     zswap  zdrop ;
: ztuck    zswap  zover ;

: z*f      ( f: x y a -- x*a y*a)
    FROT  FOVER  F*  f-rot  F*  ;

: z/f      ( f: x y a -- x/a y/a)
    1/f   z*f  ;

: z*    ( f: x y u v -- x*u-y*v  x*v+y*u)
\ uses the algorithm
\       (x+iy)*(u+iv) = [(x+y)*u - y*(u+v)] + i[(x+y)*u + x*(v-u)]
\       requiring 3 multiplications and 5 additions
  
        zdup F+                         ( f: x y u v u+v)
        [ noname ] LITERAL  F!          ( f: x y u v)
        FOVER F-                        ( f: x y u v-u)
        [ noname FLOAT+ ] LITERAL F!    ( f: x y u)
        FROT FDUP                       ( f: y u x x)
        [ noname FLOAT+ ] LITERAL F@    ( f: y u x x v-u)
        F*
        [ noname FLOAT+ ] LITERAL F!    ( f: y u x)
        FROT FDUP                       ( f: u x y y)
        [ noname ] LITERAL F@           ( f: u x y y u+v)
        F*
        [ noname ] LITERAL F!           ( f: u x y)
        F+  F* FDUP                     ( f: u*[x+y] u*[x+y])
        [ noname ] LITERAL F@ F-        ( f: u*[x+y] x*u-y*v)
        FSWAP
        [ noname FLOAT+ ] LITERAL F@    ( f: x*u-y*v u*[x+y] x*[v-u])
        F+ ;                            ( f: x*u-y*v x*v+y*u)

: z+   FROT F+  f-rot F+ FSWAP ;  ( f: a b x y -- a+x b+y)

: znegate  FSWAP FNEGATE FSWAP FNEGATE ;

: z-  znegate  z+ ;

: |z|^2   f^2  FSWAP  f^2  F+  ;

\ writing |z| and 1/z as shown reduces overflow probability
: |z|   ( f: x y -- |z|)
    FABS  FSWAP  FABS
    zdup  FMAX  f-rot  FMIN     ( f: max min)
    FOVER  F/  f^2  1e0  F+  FSQRT  F*  ;

: 1/z   fnegate  zdup  |z|  1/f  FDUP  [ noname ] LITERAL F!
        z*f  [ noname ] LITERAL  F@  z*f  ;

: z/    1/z  z* ;
: z2/   F2/  FSWAP  F2/  FSWAP  ;
: z2*   F2*  FSWAP  F2*  FSWAP  ;

: arg   ( f: x y -- arg[x+iy] )
        FDUP  F0<  FSWAP    ( : -- y<0  f: -- y x)
        FATAN2
        IF  fpi F2*  F+  THEN ;
\ tested September 27th, 1998 - 21:15

: >polar  ( f: x+iy -- r phi )  zdup  |z|  f-rot  arg  ;
: polar>  ( f: r phi -- x+iy )  FSINCOS FROT  z*f   FSWAP  ;

: i*      FNEGATE FSWAP ;  ( f: x+iy -- -y+ix)
: (-i)*   FSWAP FNEGATE ;  ( f: x+iy -- y-ix)

: zln   >polar   FSWAP  FDUP  F0=  ABORT" Can't take ZLN of 0"  FLN   FSWAP ;

: zexp   ( f: z -- exp[z] )   FSINCOS  FSWAP FROT  FEXP  z*f ;

: z^2   zdup  z*  ;
: z^3   zdup  z^2  z* ;
: z^4   z^2  z^2  ;

: z^n      ( n --  f: z -- z^n )    \ raise z to integer power
       z=1   zswap
       DUP  50 < IF
         BEGIN   DUP  0>  WHILE
                 DUP  1 AND   IF ztuck  z*  zswap THEN z^2
                 2/
         REPEAT  zdrop  DROP
       ELSE   zln  S>F  z*f  zexp  THEN  ;

: z^   ( f:  x y u v --  [x+iy]^[u+iv] )  zswap zln  z* zexp  ;

: zsqrt   ( f: x y -- a b )     \ (a+ib)^2 = x+iy
     zdup                               ( f: -- z z)
     |z|^2                              ( f: -- z |z|^2 )
     FDUP  F0=   IF   FDROP EXIT  THEN  ( f: -- z=0 )
     FSQRT FROT  FROT  F0<              ( f: -- |z| x )  ( -- sgn[y])
     ftuck                              ( f: -- x |z| x )
     F-  F2/                            ( f: -- x [|z|-x]/2 )
     ftuck  F+                          ( f: -- [|z|-x]/2 [|z|+x]/2 )
     FSQRT  IF  FNEGATE  THEN           ( f: -- [|z|-x]/2  a )
     FSWAP  FSQRT   ;                   ( f: -- a b)
\ tested September 16th, 1999 - 13:49

\ Complex trigonometric functions
: zcosh    ( f: z -- cosh[z] )  zexp   zdup   1/z   z+  z2/  ;
: zsinh    ( f: z -- sinh[z] )  zexp   zdup   1/z   z-  z2/  ;
: ztanh    zexp  z^2    i*   zdup   f1.0 F-   zswap   f1.0 F+   z/  ;
: zcoth    ztanh  1/z ;
: zcos     ( f: z -- cos[z] )   i*    zcosh  ;
: zsin     ( f: z -- sin[z] )   i*    zsinh  (-i)* ;
: ztan     ( f: z -- tan[z] )   i*    ztanh  (-i)* ;

\ Complex inverse trigonometric functions
\   -- after Abramowitz & Stegun, p. 80-81

\ the following is a primitive ANS-compatible data hiding mechanism

: compile!  ( xt -- )   COMPILE,  ;  IMMEDIATE

:noname ( A|B)   ( f: x y n -- a)   FROT  F+  |z|  F2/   ; TO noname

: alpha.beta  ( f: x y -- alpha beta)
        zdup  f1.0          [ noname ] COMPILE!
        f-rot f1.0 FNEGATE  [ noname ] COMPILE!
        zdup  F+  f-rot  F-  ;

' NOOP  TO noname      \ forget hidden xt


\ Note: the following functions have not yet been fully tested. Use
\       with caution!   September 17th, 1999 - 18:14

: zasin   alpha.beta   FASIN  FSWAP  FDUP  f^2 f1.0 F-  FSQRT  F+  FLN ;
: zacos   alpha.beta   FACOS  FSWAP  FDUP  f^2 f1.0 F-
          FSQRT  F+  FLN  FNEGATE ;
: zatan   zdup  FOVER  |z|^2  FNEGATE f1.0 F+  F/ F2*  FATAN  F2/  f-rot
          FSWAP  f^2  FOVER  f1.0 F+ f^2  ( f: -- re y x^2 [y+1]^2 )
          F+  FDUP  FROT  F2*  F-  F/  FLN  F2/ F2/ ;
: zasinh  i*   zasin  (-i)* ;
: zacosh  zacos  i*   ;
: zatanh  i*   zatan  (-i)* ;


\ ------------------------------------------ for use with ftran2xx.f
: zvariable   CREATE   2 FLOATS  ALLOT  ;

: cmplx   ( f: x 0 y 0 -- x y)  FDROP  FNIP  ;


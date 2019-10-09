FALSE [IF]

Vectoring package: use for

    1. passing function xt's as arguments;
    2. deferred definitions (instead of DEFER...IS)

Usage:  v: dummy
        : )test   ( xt --)  defines  dummy  dummy  ;
        3 4 use( * )test  .  12  ok

\ ---------------------------------------------------
\     (c) Copyright 2001  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

This is an ANS Forth program requiring the
    CORE wordset

[THEN]

: use(      '       \ state-smart ' for syntactic sugar
    STATE @  IF  POSTPONE LITERAL  THEN  ;  IMMEDIATE

' NOOP  CONSTANT  'noop
: v:   CREATE  'noop  ,  DOES> @  EXECUTE  ;   \ create dummy def'n

: defines    ' >BODY     STATE @
             IF   POSTPONE  LITERAL    POSTPONE  !
             ELSE   !   THEN  ;  IMMEDIATE


FALSE [IF]

Code to create state machines from tabular representations

\ ---------------------------------------------------
\     (c) Copyright 2001  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

This is an ANS Forth program requiring the
    CORE


[THEN]

: ||   ' ,  ' ,  ;            \ add two xt's to data field
: wide   0  ;                 \ aesthetic, initial state = 0
: fsm:   ( width state --)    \ define fsm
    CREATE  , ( state) ,  ( width in double-cells)  ;

: ;fsm   DOES>                ( x col# adr -- x' )
         DUP >R  2@           ( x col# width state)
         *  +                 ( x col#+width*state )
         2*  2 +  CELLS       ( x relative_offset )
         R@  +                ( x adr[action] )
         DUP >R               ( x adr[action] )
         @  EXECUTE           ( x' )
         R> CELL+             ( x' adr[update] )
         @  EXECUTE           ( x' state')
         R> !   ;             ( x' )  \ update state

\ set fsm's state, as in:  0 >state fsm-name
: >state   POSTPONE defines  ; IMMEDIATE   ( state "fsm-name" --)

\ query current state, as in:  state: fsm-name
: state: ( "fsm-name" -- state)
    ' >BODY                     \ get dfa
    POSTPONE LITERAL  POSTPONE @   ;   IMMEDIATE

0 CONSTANT >0   3 CONSTANT >3   6 CONSTANT >6    \ these indicate state
1 CONSTANT >1   4 CONSTANT >4   7 CONSTANT >7    \ transitions in tabular
2 CONSTANT >2   5 CONSTANT >5                    \ representations
\ end fsm code

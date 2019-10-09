Anew -NumberAlloc.f \ Allocates numbers without the use of C, or ,

hidden definitions

defer <depth>
: save-(f)depth ( depth|fdepth - ) is <depth> create <depth> , ;

: ;fill  ( numbers|floats... 'comma size -- )
    locals| size 'comma |
    <depth>  here 1 cells - tuck @ - dup 1 < abort" Empty stack"
    dup size * >r swap ! here r@ allot
    dup r> + size dup negate to size -
        do   i 'comma execute size  +loop
    does>  lcount ;

also forth definitions

: numbers:  \ compiletime: ( "name" - ) runtime: ( - Adr #items )
\ *G Creates an allocated space for numbers.
\ ** The first cell contains the number of items.
\ ** In runtime the created definition will return the adress
\ ** of the first item and the number of used items. Eg:
\ **  numbers: &test1 8 0 13 ;bytes    &test1 dump
\ **  numbers: &test2 8 0 -1 ;ints     &test2 cells dump
     ['] depth  save-(f)depth ;  \ map: n...

: ;bytes  ( numbers... -- )
\ *G Terminates a started definition of numbers: and fills
\ ** the allocated space with 1 byte of each number.
     ['] c! 1        ;fill ;

: ;ints   ( numbers... -- )
\ *G Terminates a started definition of numbers: and fills
\ ** the allocated space with 32-bits numbers.
     [']  ! 1 cells  ;fill ;
\s

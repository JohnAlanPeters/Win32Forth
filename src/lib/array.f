\ $Id: array.f,v 1.1 2004/12/21 00:19:10 alex_mcdonald Exp $

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Array words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: byte-array    ( n1 -<name>- )         \ compile time
                ( -- a1 )               \ runtime
                create 1+ reserve ;

: word-array    ( n1 -<name>- )         \ compile time
                ( -- a1 )               \ runtime
                create 1+ 2* reserve ;

: long-array    ( n1 -<name>- )         \ compile time
                ( -- a1 )               \ runtime
                create 1+ cells reserve ;

: double-array  ( n1 -<name>- )         \ compile time
                ( -- a1 )               \ runtime
                create 1+ 2* cells reserve ;

: #byte-array   ( n1 -<name>- )         \ compile time          8-bits
                ( n1 -- byte )          \ runtime
                create 1+ reserve
                does> + c@ ;

: ^#byte-array  ( a1 -<name>- )         \ compile time          8-bits
                ( n1 -- byte )          \ runtime
                create ,
                does> @ + c@ ;

: #word-array   ( n1 -<name>- )         \ compile time          16-bits
                ( n1 -- word )          \ runtime
                create 1+ 2* reserve
                does> swap 2* + w@ ;

: ^#word-array  ( n1 -<name>- )         \ compile time          16-bits
                ( n1 -- word )          \ runtime
                create ,
                does> @ swap 2* + w@ ;

: #long-array   ( n1 -<name>- )         \ compile time          32-bits
                ( n1 -- long )          \ runtime
                create 1+ cells reserve
                does> swap cells+ @ ;

: ^#long-array  ( a1 -<name>- )         \ compile time          32-bits
                ( n1 -- long )          \ runtime
                create ,
                does> @ swap cells+ @ ;

: #double-array ( n1 -<name>- )         \ compile time          2 x 32-bits
                ( n1 -- long )          \ runtime
                create 1+ 2* cells reserve
                does> swap 2* cells+ 2@ ;

: ^#double-array ( a1 -<name>- )        \ compile time          2 x 32-bits
                ( n1 -- long )          \ runtime
                create ,
                does> @ swap 2* cells+ 2@ ;

in-system

: b#->          ( n1 n2 -<name>- )      \ store byte n1 into element n2
                                        \ of byte array
                ' >body state @
                if      POSTPONE literal
                        POSTPONE +
                        POSTPONE c!
                else    + c!
                then    ; immediate

: b#+>          ( n1 n2 -<name>- )      \ store byte n1 into element n2
                                        \ of byte array
                ' >body state @
                if      POSTPONE literal
                        POSTPONE +
                        POSTPONE c+!
                else    + c+!
                then    ; immediate

: w#->          ( n1 n2 -<name>- )      \ store word n1 into element n2
                                        \ of word array
                ' >body state @
                if      POSTPONE 2*
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE w!
                else    swap 2* + w!
                then    ; immediate

: w#+>          ( n1 n2 -<name>- )      \ store word n1 into element n2
                                        \ of word array
                ' >body state @
                if      POSTPONE 2*
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE w+!
                else    swap 2* + w+!
                then    ; immediate

: l#->          ( n1 n2 -<name>- )      \ store long n1 into element n2
                                        \ of long array
                ' >body state @
                if      POSTPONE cells
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE !
                else    swap cells+ !
                then    ; immediate

: l#+>          ( n1 n2 -<name>- )      \ store long n1 into element n2
                                        \ of long array
                ' >body state @
                if      POSTPONE cells
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE +!
                else    swap cells+ +!
                then    ; immediate

: d#->          ( n1 n2 -<name>- )      \ store long n1 into element n2
                                        \ of double array
                ' >body state @
                if      POSTPONE 2*
                        POSTPONE cells
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE 2!
                else    swap 2* cells+ 2!
                then    ; immediate

: d#+>          ( n1 n2 -<name>- )      \ store long n1 into element n2
                                        \ of double array
                ' >body state @
                if      POSTPONE 2*
                        POSTPONE cells
                        POSTPONE literal
                        POSTPONE +
                        POSTPONE 2+!
                else    swap 2* cells+ 2+!
                then    ; immediate

in-application

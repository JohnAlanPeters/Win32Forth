anew wilsort
\ ----------------------------------------------------------
\ Wil Baden's sorter
\  Set PRECEDES for different datatypes or sort order.
DEFER PRECEDES  ' < IS PRECEDES

\  For sorting character strings in increasing order:
: SPRECEDES         ( addr addr -- flag )  >R COUNT R> COUNT COMPARE 0< ;
: IPRECEDES         ( addr addr -- flag )  < ;
  ' SPRECEDES IS PRECEDES
internal
: EXCHANGE          ( addr_1 addr_2 -- )
    DUP @ >R  OVER @ SWAP !  R> SWAP ! ;
\ : -CELL ( -- n )  -1 CELLS ;
\ : CELL-  ( addr -- addr' )  1 CELLS - ;

: PARTITION         ( lo hi -- lo_1 hi_1 lo_2 hi_2 )
    2DUP OVER - 2/  -CELL AND +  @ >R  ( R: median)
    2DUP BEGIN      ( lo_1 hi_2 lo_2 hi_1)
         SWAP BEGIN  DUP @ R@   PRECEDES WHILE  CELL+  REPEAT
         SWAP BEGIN  R@ OVER @  PRECEDES WHILE  CELL-  REPEAT
         2DUP > NOT IF  2DUP EXCHANGE  >R CELL+ R> CELL-  THEN
    2DUP > UNTIL    ( lo_1 hi_2 lo_2 hi_1)
    R>DROP SWAP ROT ( lo_1 hi_1 lo_2 hi_2)
    ;

: QSORT             ( lo hi -- )
    PARTITION                ( lo_1 hi_1 lo_2 hi_2)
    2OVER 2OVER  - +         ( . . . . lo_1 hi_1+lo_2-hi_2)
        < IF  2SWAP  THEN    ( lo_1 hi_1 lo_2 hi_2)
    2DUP < IF  RECURSE  ELSE  2DROP  THEN
    2DUP < IF  RECURSE  ELSE  2DROP  THEN ;
external
: SORT              ( addr n -- )
    DUP 2 < IF  2DROP  EXIT THEN
    1- CELLS OVER + ( addr addr+{n-1}cells) QSORT ( ) ;
module
\ ----------------------------------------------------------
\s
\ quickie tests:

here ," nine"  here ," fout" here ," three" here ," seven" here ," zero"
here ," eight" here ," two"  here ," six"   here ," one"   here ," five"
create str-table , , , , , , , , , , \ table of counted strings

: str_dump 10 0 do i cells STR-TABLE + @ count type space loop ;
cr str_dump .( -> ) ' SPRECEDES IS PRECEDES STR-TABLE 10 sort cr str_dump

CREATE INT-TABLE
9 , 4 , 3 , 7 , 0 , 8 , 2 , 6 , 1 , 5 ,

: int_dump 10 0 do i cells INT-TABLE + @ . loop ;
cr int_dump .( -> ) ' IPRECEDES IS PRECEDES INT-TABLE 10 sort int_dump



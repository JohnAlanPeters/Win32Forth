\ $Id: 2ARRAY.F,v 1.1 2006/09/16 10:52:04 georgeahubert Exp $

\ G.Hubert Friday, September 15 2006
\ Based on the code in Doug Hoffman's Class11

anew -2array.f

needs var11.f

:class 2array ( size -- ) <super object  4 <indexed
 var #ofRows
 var #ofCols
 var elemSize
 var stride

:m classinit:
 4 put: elemSize \ a 32 bit integer
 colDim @ put: #ofCols
 rowDim @ put: #ofRows
 get: #ofCols get: elemSize * put: stride
 ;m

:m check:  ( row# col# -- )
 get: #ofCols 1 -  > swap
 get: #ofRows 1 -  > or abort" 2array indice(s) out of bounds." ;m

:m elemAddr:  { row# col# -- addr }
\ locals| col# row# |
 row# col# check: self
 idxbase
 get: stride  row# * +
 get: elemSize col# * +
 ;m


:m to: ( n row# col# -- )
  elemAddr: self !
 ;m


:m at: ( row# col# -- n )
 elemAddr: self @ ;m

:m clearall: ( -- )
 get: #ofRows 0 ?DO
  get: #ofCols 0 ?DO
   0 j i elemAddr: self !
      LOOP
     LOOP ;m

:m print: ( -- )
 get: #ofRows 0 ?DO
  get: #ofCols 0 ?DO
   cr j . i .
   j i at: self .
      LOOP
     LOOP ;m

;class


0 [if]


*** EXAMPLE USE


5 5 dimension 2array a

33 0 6 to: a  \ should error

12 0 0 to: a

33 0 1 to: a

12345678 1 0 to: a

0 0 at: a .
12

0 1 at: a .
33

1 0 at: a .
12345678
print: a

[then]

\ $Id: 2ARRAYGEN.F,v 1.1 2006/09/16 10:52:04 georgeahubert Exp $

\ 2ARRAYGEN.F for Win32Forth V6.11.09 or higher
\ G.Hubert Sunday, July 23 2006
\ Based on the ANSI Neon Model Class of Doug Hoffman

\ *P A 2arraygen is a dynamically-allocated 2-dimensional array, intended to be
\ ** used for keeping text strings.  The strings are not objects.  Each string
\ ** has a maximum length that it will accept.

\ *P Note that after instantiation we must first send maxsize new: because memory
\ ** from the heap is allocated.  Maxsize is the maximum number of chars we can
\ ** have in each element.  We specify for each array.  Limited to 255.

anew -2arraygen.f

needs var11

:class 2arrayGen <super object

 var #ofRows
 var #ofCols
 var elemSize
 var stride
 ptr arrayData


:m classinit:
 colDim @ put: #ofCols
 rowDim @ put: #ofRows
;m

:m maxsize:  ( -- n )  \ maximum number of characters for a cell
 get: elemSize 1- ;m

:m init:  ( maxSize -- )
 1+ put: elemSize  \ must allow room for count byte
 ;m


:m release:
 release: arrayData ;m

:m check:  ( row# col# -- )
 get: #ofCols 1 -  > swap
 get: #ofRows 1 -  > or abort" 2arrayGen indices out of bounds." ;m

:m elemAddr:  { row# col# -- addr }
\ locals| col# row# |
 row# col# check: self
 get: arrayData
 get: stride  row# * +
 get: elemSize col# * +
 ;m

:m to: { addr len row# col# | dest -- }
\ 0 locals| dest col# row# len addr |
 len  maxSize: self  min to len
 row# col# elemAddr: self to dest
 addr ( src) dest 1+ len cmove
 len dest c!
 ;m

:m at: ( row# col# -- addr len )
 elemAddr: self dup 1+ swap c@ ;m

:m clearall:
 get: #ofRows 0 ?DO
  get: #ofCols 0 ?DO
   0 j i elemAddr: self c!
      LOOP
     LOOP ;m

:m new: ( maxSize -- ) \ establish max element size and allot memory
 init: self
 get: #ofCols get: elemSize * put: stride
 get: #ofCols get: #ofRows *
 get: elemSize *
 new: arrayData

 clearall: self ;m

:m print:
 cr
 get: #ofRows 0 ?DO
  get: #ofCols 0 ?DO
    j i at: self type 2 spaces
      LOOP
      cr
     LOOP ;m
;class

0 [if]

*** EXAMPLE USE


2arrayGen gg
6 new: gg

s" teststring" 0 0 to: gg

s" test2" 0 1 to: gg
s" test3" 1 0 to: gg

print: gg

release: gg
[then]


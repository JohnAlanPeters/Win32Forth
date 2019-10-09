\ $Id: ORDERED-COL.F,v 1.2 2007/02/21 09:57:32 georgeahubert Exp $

\ Win32Forth version, 3 July 2006 G.Hubert for V6.11.10 or later
\ based on Doug Hoffman's version for the ANSI Neon Model OOF

Forth Definitions
decimal

anew -ordered-col.f

needs ext_classes\array11.f

 \ 06/19/05 dbh  code lifted from Mops

:class ORDERED-COL  <super array \ cell <indexed
 var SIZE    \ # elements in list

:m SIZE: \ ( -- cursize )  Returns #elements currently in list
  get: size  ;m

:m CLEAR:
 clear: size    ;m

:m ADD:  \ ( val -- )  add value to end of list
 get: size  limit  >=  abort" Ordered-col full"
 get: size  to: [ self ]  1 +: size  ;m

:m LAST:  \ ( -- val )  Returns contents of end of list
 get: size dup 0= abort" Empty ordered-col"
 1-  at: self  ;m


\ Removes the element at index
:m REMOVE:  ( indx  -- ) { | cnt wid addr }
 >r    \ indx to r
 get: size  r@ -  1-  to cnt  dup
     0<  abort" Can't remove: ordered-col"
 width: self to wid
 r>  ^elem: self  to addr
\ locals| addr wid cnt |
 1 -: size
 cnt  0= IF exitm THEN
 addr wid +  addr  cnt wid *  move  ;m

\ Finds a value in a collection.
:m INDEXOF:  { val | wid addr  -- indx T  | -- F }
 width: self  to wid   idxbase to addr
\ locals| addr wid val |
 false  get: size  0
 ?DO
  addr @ \ getelem: super
  val =  IF  drop  i  true  LEAVE  THEN
  wid addr + to addr
 LOOP  ;m

:m first?: ( -- elem t | f )
  size: self 1 < IF false exitm THEN
  clear: current
  0 at: self true ;m

:m next?:  ( -- ^obj t | f )
  1 +: current get: current dup size: self <
  IF at: self true
  ELSE drop false
  THEN ;m

;class



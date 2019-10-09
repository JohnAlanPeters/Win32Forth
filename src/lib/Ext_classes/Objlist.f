\ $Id: Objlist.f,v 1.1 2007/02/21 09:57:32 georgeahubert Exp $

\ a dynamically expandable list of objects
:class objList <super sequence
 ptr list
 var current

\ :m ListSize: ( -- n )
\    size: list ;m

:m valid?: ( idx0 -- t/f )
 nil?: list IF false exitm THEN
 size: list cell /  \ idx0 idxmax+1
 < ;m

:m ^elem: ( idx -- addr )
 cell * get: list + ;m

:m at: ( idx -- ^obj )
 ^elem: self @ ;m

:m add: ( ^class -- ^obj )
 >body DUP ?isClass 0= ABORT" Not a class" (heapobj) dup
 nil?: list
 IF cell new: list get: list !  \ ^obj
 ELSE
  size: list dup cell + resize: list  \ ^obj ^obj size
  get: list + !
 THEN ;m

 :m first?: ( -- ^obj t | f )
  nil?: list IF false exitm THEN
  clear: current
  0 at: self true ;m

 :m next?:  ( -- ^obj t | f )
  1 +: current get: current dup valid?: self
  IF at: self true
  ELSE drop false
  THEN ;m

 :m release:
  BEGIN
    each: self
  WHILE
    <release
  REPEAT
  clear: list clear: current clear: each_started?
   ;m

 :m print:
   BEGIN
     each: self
   WHILE
     cr print: **
   REPEAT ;m

  :m size: ( -- n ) \ number of objects in list
    size: list cell / ;m


;class


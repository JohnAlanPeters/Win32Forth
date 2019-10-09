\ $Id: ARRAY11.F,v 1.2 2007/02/21 09:57:32 georgeahubert Exp $

\ Classes for indexed objects
\ Version 1.2, 4 Feb 1997
\ Andrew McKewan
\ mckewan@austin.finnigan.com
\ Win32Forth version, 3 July 2006 G.Hubert (Requires V6.11.10 or later)

\ *P These classes are for one-dimensional arrays. The size of the array is passed to the
\ ** array when it is created, either at compile-time or at run-time for arrays created
\ ** with NEW>. For IVARS the size is passed when the IVAR is declared.

anew -array11.f

needs ext_classes\sequence.f

\ *S Glossary

in-system

:Class IndexedObj  ( #elems -- ) <Super Sequence
\ *G This is the base class for all indexed objects. It provides the
\ ** primitives that are common to all indexed objects.
CELL <Indexed

in-previous

:M IxAddr: ( -- addr )
\ *G Leave addr of 0th indexed element.
          idxBase   ;M

:M Limit: ( -- limit )
\ *G Leave max #elements for array.
          limit   ;M

:M Width: ( -- len )
\ *G Leave width of indexed elements.
          #width  ;M

:M ^Elem: ( index -- addr )
\ *G Return the address of an indexed element.
          ?idx  ^elem    ;M

:M Clear: ( -- )
\ *G Indexed Clear: erases indexed area
          idxBase  #width limit * ERASE  ;M

;Class
\ *G End of class


:Class Array  ( #elems -- ) <Super IndexedObj
\ *G A standard one-dimensional array of #elems elements. The elements are referenced
\ ** by a 0 based index.

var current

:M  At:   ( index -- n )
\ *G Fetch the element at index.
          ?idx  At4  ;M

:M  To:   ( n Index -- )
\ *G Put n into the element at index.
          ?idx  To4  ;M

:M  +To:  ( n index -- )
\ *G Add n to the element at index.
          ?idx  ++4  ;M

:M Fill:  ( n -- )
\ *G Fill all the elements of the array with n.
          limit 0 DO  DUP I To4  LOOP DROP  ;M

:m first?: ( -- elem t | f )
\ *G Return first element and true.
  clear: current
  0 at: self true ;m

:m next?:  ( -- ^obj t | f )
\ *G Return next obj and true if there is a next object; false otherwise.
  1 +: current get: current dup limit <
  IF at: self true
  ELSE drop false
  THEN ;m

:m print:
\ *G Print all elements.
   BEGIN
    each: self
   WHILE cr .
   REPEAT ;m

:m apply: ( xt -- )
\ *G Apply xt to each element and store the result in the element. xt should have the
\ ** stack effect ( n1 -- n2 ).
     >r
    BEGIN
      each: self
    WHILE
      r@ ( elem xt ) execute
        get: current to: self
    REPEAT r> drop ;m

;Class
\ *G End of Class.

:Class X-Array  ( #elems -- ) <Super Array
\ *G Create an array of execution vectors; i.e. a jump table.

:M Exec:  ( index -- )
\ *G Execute the cfa at Index.
          ?idx  At4  DUP 0= ABORT" Null xt"  EXECUTE  ;M

:M ClassInit: ( -- )
\ *G Initialise the class. The elements are set to perform noop.
          ['] NOOP Fill: self  ;M

;Class
\ *G End of Class.

:Class ByteArray ( #elems -- )  <Super IndexedObj
\ *G Array of bytes.
         1 <Indexed

:M  At:   ( index -- n )
\ *G Fetch the element at index.
          ?idx  At1  ;M
:M  To:   ( n Index -- )
\ *G Put n into the element at index.
          ?idx  To1  ;M
:M  +To:  ( n index -- )
\ *G Add n to the element at index.
          ?idx  ++1  ;M

:M Fill:  ( n -- )
\ *G Fill all the elements of the array with n.
          idxBase limit ROT FILL  ;M

;Class
\ *G End of Class.

\ *Z



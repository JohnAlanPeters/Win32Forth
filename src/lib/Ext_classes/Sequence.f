\ $Id: Sequence.f,v 1.1 2007/02/21 09:57:32 georgeahubert Exp $

\ Originally written by Doug Hoffman
\ Ported to W32F Monday, February 19 2007 by George Hubert

anew -sequence.f

needs ext_classes\var11.f

in-system

:class SEQUENCE <super object
\ *G SEQUENCE is a generic superclass for classes which have multiple items which
\ ** frequently need to be looked at in sequence.  At present the main function of
\ ** Sequence is to implement the EACH: method, which makes it very simple to
\ ** deal with each element.  The usage is

\ *E  BEGIN  each: <obj>  WHILE  <do something to the element>  REPEAT

\ *P Sequence can be a superclass for any class which implements the
\ ** FIRST?: and NEXT?: methods.  The actual implementation details are quite
\ ** irrelevant, as long as these methods are supported.

in-previous

 bool each_started?

:m first?: false ;m

:m next?: false ;m

:m EACH:  \ ( -- (varies) T  |  -- F )
 get: each_started?
 IF \ Subsequent time in:
  next?: [ self ]
  IF  true  ELSE  clear: each_started?  false  THEN
 ELSE \ First time in:
  first?: [ self ]  0= IF 0 exitm THEN
  set: each_started?
  true  \ Yes, we've got the 1st element
 THEN
;m

:m UNEACH: \ Use to terminate an EACH: loop before the end.
 clear: each_started?
;m

  :m apply: ( xt -- )
     >r
    BEGIN
      each: self
    WHILE
      r@ ( elem xt ) execute
    REPEAT r> drop ;m

;class



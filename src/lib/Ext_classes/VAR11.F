\ $Id: VAR11.F,v 1.1 2006/09/16 10:52:04 georgeahubert Exp $

\ Basic object variables
\ Ported to W32F Wednesday, June 14 2006 George Hubert for V6.11.09 or later
\ Based on Version 1.1, 6 Jan 2006  Doug Hoffman
\ Andrew McKewan
\ mckewan@austin.finnigan.com


\ ======================================================================
\ Define the basic cell-sized variable class. This is a generic superclass
\ that defines the basic access operators.

anew -var11.f

:Class CellObj  <Super Object <NoClassPointer

 CELL bytes Data

[undefined] M@ [if]

: M@   ( -- n )   Data @ ;
: M!   ( n -- )   Data ! ;

[then]

 :M  Get:   ( -- n )   M@   ;M  \ just for testing
 :M  Put:   ( n -- )   M!   ;M  \ ditto

 :M  Clear:   0 M!  ;M
 :M  Print:   M@ .  ;M

 \ ( ^obj -- )  copies data from another CellObj
 :M ->:   @ M!  ;M

;Class


\ ======================================================================
\ Var is for integer data

:Class Var   <Super CellObj <NoClassPointer

 :M  +:  ( n -- )         ^base +!  ;M
 :M  -: ( n -- )  NEGATE ^base +!  ;M

 :M  *:  ( n -- )  M@  *       M!   ;M
 :M  /:  ( n -- )  M@  SWAP /  M!   ;M
 :M  Negate:   M@  NEGATE  M!   ;M

;Class


\ ======================================================================
\ Bool is for storing booleans. It always returns TRUE or FALSE.

:Class Bool   <Super CellObj <NoClassPointer

 :M Put:  ( f -- )   0= 0= M!  ;M

 :M Get: get: super ;M
 :M Set:      TRUE  M!  ;M
 :M Invert:   M@ 0= M!  ;M

 :M Print:  M@ IF ." true " ELSE ." false " THEN  ;M
;Class


\ ======================================================================
\ ExecVec stores an execution token.

:Class ExecVec   <Super CellObj <NoClassPointer

 \ Execute xt stored in variable
 :M Exec:  ( -- )   M@ EXECUTE  ;M

 \ Initialize to do nothing
 :M Clear:      ['] NOOP M!  ;M
 :M ClassInit:  Clear: self  ;M

;Class

\ ======================================================================
\ Ptr stores a pointer to dynamically-allocated memory. We also keep track
\ of the current size of the memory block.

:Class Ptr   <Super CellObj <NoClassPointer

 Var size \ current size

 : ?MEMERR  ( ior -- )   abort" Memory error !" ;

 :M Size:  ( -- n )  \ get current size
  Get: size  ;M

 :M Release:  ( -- )   \ release current memory
  M@ IF  M@ FREE ?MEMERR  0 M!  THEN   Clear: size  ;M

 :M New:  ( len -- )  \ create a new memory block
  Release: self  DUP ALLOCATE ?MEMERR  M!  Put: size  ;M

 :M Resize:  ( len -- )  \ resize memory block
  M@ OVER RESIZE ?MEMERR  M!  Put: size  ;M

 :M Nil?:  ( -- f )  \ true if no memory has been allocated
  M@ 0=  ;M

;Class

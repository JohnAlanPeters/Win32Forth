\ $Id: Struct200x.f,v 1.2 2013/11/15 19:35:03 georgeahubert Exp $ \

\ --------------------------- Change Block -------------------------------
\
\
\ ------------------------- End Change Block -----------------------------
\


\ RfD: Structures - Version 4
\ 6 February 2007, Stephen Pelc

\ ------------------------------------------------------------------------

in-system

: begin-structure     ( -- addr 0 )
             create here 0 0 ,
             does> ( -- size ) @ ;

: end-structure       ( addr n -- )
             swap ! ;                \ set size

(( : +field     ( n1 n2 "name" -- n3 ) \ ANSI version
             create over , +
             does> ( addr -- addr+n1 ) @ + ; ))

: +field     ( n1 n2 "name" -- n3 )   field+ ;    \ Optimised code version

: field:     ( n1 <"name"> -- n2 ) ( addr -- 'addr )  aligned cell +field ;
: cfield:    ( n1 <"name"> -- n2 ) ( addr -- 'addr )  1 chars +field ;
: bfield:    ( n1 <"name"> -- n2 ) ( addr -- 'addr )  1 +field ;
: wfield:    ( n1 <"name"> -- n2 ) ( addr -- 'addr )  2 +field ;
: lfield:    ( n1 <"name"> -- n2 ) ( addr -- 'addr )  4 +field ;
: xfield:    ( n1 <"name"> -- n2 ) ( addr -- 'addr )  8 +field ;


[defined] environment [if]

get-current also environment definitions

      : X:STRUCTURES ;
previous set-current [then]

in-previous


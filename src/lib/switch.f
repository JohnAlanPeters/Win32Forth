\ $Id: switch.f,v 1.8 2013/11/20 12:28:36 georgeahubert Exp $
\ G.hubert February 16th, 2003 - 21:40

\ Adapted from original ANSI code (by Rick Van Norman)
\ Originally  ported from Aztec Forth (by Thomas Worthington) by George Hubert

\ Change Log
\ gah 17feb03 added code to forget switches
\ gah 23feb03 improved version of switcher
\ gah 1mar03  code version of switcher
\ gah 2mar03 moved [+SWITCH RUNS RUN: to system
\ gah 3mar03 SWITCHER replaced by (SWITCH)
\ gah 3mar03 better factored version with ;CODE defined later
\ gah 3mar03 moved [SWITCH :SWITCH to system
\ gah 3mar03 added DOSWITCH for compiler security
\ gah 4mar03 moved DOSWITCH to system
\ gah 6mar03 added nostack and checkstack suggested by rbs
\ gah 6mar03
\ gah 9mar03 moved SWITCH-LINK to system space
\ gah 13mar03 added SWITCH:
\ gah 31mar03 added dbg-nest-switch for debugging
\ gah 30apr03 minor spelling corrections
\ gah 04jun03 minor bug fixes
\ gah 22nov03 changed DOSWITCH and (SWITCH) to use cfa-code and header to work
\             correctly with code space in V6.08 while still working with earlier versions

\ See Switches.txt for information about switches

\ *! p-switch W32F switch
\ *T Using Switches

\ *P Switches are a cross between chains and case structures. Like chains they can be defined where they need to be
\ ** compiled and extended by later code. Like case structures they perform different operations depending on the
\ ** value on the top of the stack. Unlike CASE the comparators are stored as a single cell so cannot be a
\ ** non-constant value. Also they pass the input value to a default case if no match is found in the linked cases,
\ ** whereas with CASE one has to add code to handle a default case. For more information on switches see
\ ** Forth Dimensions Volume 20 Issue 3 (Page 19 onwards).

\ *S STRUCTURE OF A SWITCH

\ *E HEADER OF SWITCH                      SWITCH CELL
\ **  | DOSWITCH      CFA of SWITCH
\ **  | SWITCH LINK   First case/null ---> SWITCH LINK Next case/null --->
\ **  | XT            Default              COMPARATOR  Value to match
\ **  | SWITCHES LINK Next switch/null __  XT          Word to run if matched
\ **  V                                  |
\ **                                     V

\ *S GLOSSARY


Only Forth also definitions decimal \ gah 14mar03 Make sure of search order

anew -switch.f

internal

in-system

VARIABLE SWITCH-LINK \ For forgetting
SWITCH-LINK OFF

\ in-application

cfa-code DOSWITCH
                   lea     ecx, 4 [eax]        \ PFA to ECX, n already in TOS
                   mov     eax, 4 [ecx]   \ Save default xt in eax
@@1:               mov     ecx, [ecx]     \ Get next link
                   or      ecx, ecx            \ Test for Null
                   je      short @@2           \ If Null execute default xt
                   cmp     ebx, 4 [ecx]   \ Compare with match value
                   jne     short @@1           \ If no match go to next case
                   mov     eax, 8 [ecx]   \ xt of matching case
                   pop ebx                     \ Drop match value
@@2:               exec                        \ arm use exec macro

end-code

\ in-system \ gah 4mar03 move DOSWITCH :SWITCH [SWITCH to system space
          \ gah 22nov03 DOSWITCH moved to application space & (SWITCH) moved to system space

: (SWITCH) header doswitch , ;

0 VALUE CURRENT-SWITCH \ gah 9mar03 Address of switch currently being
                       \ defined or null if not defining switch

external

: :SWITCH ( xt "name" -- head )  \              FORTH            SYSTEM
\ *G Define a switch "name" that executes the procedure whose xt is on the stack ( with the input argument on top
\ ** of the stack ) if no matching condition has been added to the switch and open it for adding conditions.
  NOSTACK
  (SWITCH) HERE 0 , SWAP ,
  switch-link link,       \ gah 17feb03 for forgetting
  dup to current-switch ;  \ gah 9mar03 for security

: [SWITCH ( "name" "default" -- head )   \    FORTH            SYSTEM
\ *G Define a new switch "name" whose default action is "default" and open
\ ** it for adding conditions.
  nostack                 \ rbs
  (switch)  HERE 0 ,  ' ,
  switch-link link,       \ gah 17feb03 for forgetting
  dup to current-switch    \ gah 9mar03 for security
   ;

 \ gah 13mar03
: SWITCH: ( "name" "<code to perform> ;" -- head )     \   FORTH            SYSTEM
\ *G Define a new switch "name" whose default action is the following inline
\ ** forth code (up to the terminating ;). The forth words must call the switch
\ ** "name" as a recursive call with "name" to perform recursion, since
\ ** RECURSE merely runs the inline code again.
  nostack (switch) here 0 ,
  dup to current-switch
  here 0 ,
  switch-link link,
  :noname swap ! 2 cells csp +! ;


\ gah 3mar03 move <SWITCH to system space
\ gah 2mar03 move [+SWITCH SWITCH] RUNS RUN: to system space
\ gah 23mar03 eliminated <SWITCH

: [+SWITCH ( "name" -- head )    \              FORTH            SYSTEM
\ *G Open existing SWITCH "name" for additional conditions.
  nostack                      \ rbs turn off stack checking
  ' dup @ doswitch = 0=        \ gah 3mar03 added test for valid switch
   ABORT" is not a switch as expected by [+SWITCH !"
   >BODY  dup to current-switch ;

internal

: SWITCH-OPEN   ( -- )
\ Error if switch not open for additional conditions.
     current-switch 0= abort" No switch is open !" ;

: NOT-LINK ( head n -- head n )
\ Error if not link.
     over current-switch <> abort" Not valid switch link !" ;

: RUN-ERROR   ( -- )
\ Check for errors.
     switch-open not-link ;

external

: SWITCH] ( head -- ) \                           FORTH            SYSTEM
\ *G Close SWITCH structure. An error occurs if head is not the head of the currently open switch.
  switch-open
  dup current-switch <> abort" Not trying to close valid switch !"
  CHECKSTACK                     \ rbs turn on stack checking
  0 to current-switch DROP ;

: RUNS ( head n -<word>- -- head ) \              FORTH            SYSTEM
\ *G Add a condition to the currently open switch structure that runs -<word>- if the value n is passed to the
\ ** switch. An error occurs if head is not the head of the currently open switch, or no switch is open.
  run-error
  ' 3reverse dup link, -rot , , ;

: RUN: ( head n -<words ;>- -- head ) \           FORTH            SYSTEM
\ *G Add a condition to the currently open switch structure that runs the following forth words up to ; if the
\ ** value n is passed to the switch. An error occurs if head is not the head of the currently open switch, or no
\ ** switch is open.
  run-error
  over link, , here cell allot
  :noname swap ! 2 cells csp +! ;

internal

: trim-switches   ( nfa -- nfa )
\ trim down the switch linked list.
        switch-link
        begin   @ ?dup
        while   2dup -2 cells+ full-trim
        repeat  dup switch-link full-trim ;

\in-system-ok forget-chain chain-add trim-switches

defined unknown? nip 0= [IF]

: UNKNOWN?  ( xt -- f )
\ Return true if xt is an unnamed definition.
          >NAME NAME> ['] [UNKNOWN] = ;

[THEN]

: .CONDITION  ( link -- )
\ Print out a condition.
     dup cell+ @ . cell+ Cell+ @ dup unknown?
     if ." RUN:" >body .pfa
     else ." RUNS " .name
     then cr ;

: .CONDITIONS  ( link -- )
\ Print out all conditions.
     cr begin ?dup While
     dup .condition @ repeat ;

: .DEFAULT ( xt f -- )
\ Print default.
     if >body .pfa else .name then ;

: (.SWITCH) ( xt -- )
\ Print Switch.
     dup 2 cells + @ dup unknown? tuck 2>r if ." SWITCH: " else ." [SWITCH " then
     dup .name space 2r> .default >body @ .conditions ." SWITCH]" cr ;

: _.SWITCH  ( xt -- xt|0)
\ Used by SEE.
     -if dup @ doswitch = if (.switch) 0 then then ;

\in-system-ok .other-class-chain chain-add _.switch

external

: .SWITCH ( xt -- ) \                             FORTH            SYSTEM
\ *G Print out all the conditions defined for this switch.Using SEE -< name >- on a switch has the same effect.
\ ** Conditions are listed default first followed by the others with in the order they are found i.e. the later
\ ** they are defined the earlier they are in the list.
    dup @ doswitch <> abort" expects the xt of a SWITCH"
    cr (.switch) ;

: .SWITCHES \                                     FORTH            SYSTEM
\ *G Print out all the defined switches.The more recently a switch has been defined the earlier it comes in the
\ ** list.
    cr switch-link begin @ ?dup while
    dup -3 cells + .switch repeat ;

internal also bug

: DBG-NEST-SWITCH  ( xt false | true -- xt false | true )
\ Nest into switch when debugging.
   dup ?exit                                       \ exit if already dealt with
   over @ doswitch = if drop ." SWITCH nesting "   \ is this a switch
   cell+ dup cell+ @ -rot                          \ save default under n
   begin @ ?dup while                              \ more conditions ?
   2dup cell+ @ = until                            \ does this match ?
   rot drop cell+ cell+ @ \ drop default and get matching function preserving n
   else swap then                                  \ put default on top
   dup .name _dbg-nest        \ print name and nest into function if possible
   true then ;                \ return true if we dealt with xt

previous

\in-system-ok dbg-nest-chain chain-add dbg-nest-switch

: .WORD-TYPE-SWITCH  ( xt false | true -- xt false | true )
\ Print this is a switch.
    dup ?exit
    over @ doswitch = if
    2drop ." Switch "
    true then ;

\in-system-ok .word-type-chain chain-add .word-type-switch

module

in-application

\ *S SOME EXAMPLES OF SWITCHES

\ *E SWITCH: FACTORIAL   ( n -- factorial )
\ **           dup 1- factorial * ;      \ Recursive call n <> 1 and n <> 0
\ **           0 runs 1                  \ Base conditions:Note 1 is a constant
\ **           1 runs 1
\ **           switch]
\ ** An implimentation of the classic recursive FACTORIAL function using SWITCH: that is about 15% faster than
\ ** the standard recursive version, while only taking 16 cells ( the same as the standard version ).
\ **
\ **
\ ** [SWITCH FOO-ERROR throw SWITCH]
\ ** : (FOO) -<Some code>- ;
\ ** : FOO ['] (foo) catch foo-error ;
\ ** An extensible error handler. Initially any errors are simply thrown to the previous CATCH but adding extra
\ ** conditions means they are caught and handled by FOO, since 0 THROW drops the 0 and carries on. You can even
\ ** add a success condition e.g.
\ **
\ ** [+SWITCH FOO-ERROR 0 run: ." Hip, Hip, Hoorah I've done it" ; SWITCH]
\ **
\ ** if you want.
\ **
\ *W <hr>Document : dexh-switch.f -- 2008/05/16 -- georgeahubert

\ *Z

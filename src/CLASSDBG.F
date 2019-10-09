\ $Id: CLASSDBG.F,v 1.11 2013/02/14 20:05:47 georgeahubert Exp $

\ *D doc
\ *! p-classdbg W32F classdbg
\ *T Class Debugging Words
\ *P Win32Forth contains some miscellaneous words to help with developing Classes and Objects.

cr .( Loading Object Debugging...)

internal

also classes

: .method       ( mlink -- mlink )
                dup cell+ @ unhash
                type 14 #tab space 14 ?cr ;

: _methods      ( class_body -- )
                MFA #mlists 0 do
                dup i cells+
                begin   @ ?dup
                while   .method
                repeat
                loop drop ;

: ?.match       ( n lfa -- n )
                link> dup @ docon = if
                  2dup execute = if
                    >name id. 20 #tab space 20 ?cr else
                    drop then else
                  drop then ;

: #matches      ( n -- )
                cr hash-wid voc#threads 0 do
                  ['] ?.match hash-wid i cells+ do-link loop
                drop ;

: "matches      ( addr len -- )
                2dup upper method-hash #matches ;

previous

external

also classes

\ *S Glossary

: cmethods      ( 'class' -- )          \ W32F      Class debug
\ *G Print out all the methods of a class.
                { \ superlist -- }
                cr ." New Methods :-" cr
                ' >body dup
                sfa @ swap
                #mlists 0 do 2dup
                mfa i cells+ swap mfa i cells+ @ to superlist
                begin   @ dup superlist <>
                while   .method
                repeat  drop
                loop    drop
                cr ." Inherited Methods :-" cr
                 _methods ;

: methods       ( object-address -- )    \ W32F      Class debug
\ *G Print out all the methods of an object.
                depth 0=
                if      ' execute
                then
                cr obj>class _methods ;

: ivars         ( object-address -- )    \ W32F      Class debug
\ *G Print out all the object IVARs of an object.
                depth 0=
                if      ' execute
                then
                cr obj>class IFA
                begin   @ ?dup
                while   dup cell+ @ unhash
                        type 10 #tab ."  (" dup 3 cells+ @ 1 .r ." )"
                        10 #tab space 20 ?cr
                repeat ;


: matches   ( -"name"- )                 \ W32F      Class debug
\ *G Print out all the method selectors and IVAR names that have the same hash value as
\ ** -"name"- will be assigned. If -"name"- is already in use as a selector or an IVAR name
\ ** then it will appear in the list.
            bl word count "matches ;

previous

INTERNAL

0 value theClass

: .obj          ( nfa -- )
                dup name> dup @ doobj =
                if      >body @ theClass =
                        if      nfa-count type cr
                        else    drop
                        then
                else    2drop
                then    ;

EXTERNAL

also classes

: objects       ( 'class' -- )     \ W32F       Class debug
\ *G Display all of the instances of 'class'.
                ' >body to theClass
                ['] .obj on-allwords ;

previous

MODULE

also classes also hidden also bug

\ GetMethod and [GetMethod] have been moved to Class.f

: msee          ( -<method object>- )       \ W32F      Class debug
\ *G Display the source code of the method. Either a Class or Object can be supplied.
                GetMethod cr ." :M " dup .m0name 2 spaces
                dup  2 cells+ @ if
                cell+ .locals                   \ display locals if present
                else 3 cells+ then              \ step to the PFA
                .pfa ;                          \ decompile the definition

: mdebug        ( -<method object>- )         \ W32F      Class debug
\ *G Set debugging of the method. An Object must be supplied (Classes aren't allowed).
\ ** NOTE the method will be debugged for all objects that respond to it.
                unbug
                false to ?dbg-cont              \ turn off continuous step
                base @ to debug-base
                GetMethod
                obj-save 0= abort" Must specify an Object, not a Class!"
                3 cells+ tracing ;

: mdbg          ( -<method object>- )         \ W32F       Class debug
\ *G Set debugging of the method and then execute it.
\ ** An Object must be supplied (Classes aren't allowed).
\ ** NOTE the method will be debugged for all objects that respond to it.
                >in @ mdebug >in ! ;

previous previous previous

\ *Z

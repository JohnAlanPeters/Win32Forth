\ $Id: POINTER.F,v 1.11 2008/06/19 19:50:54 georgeahubert Exp $

\ POINTER.F     External memory allocation and management   by Tom Zimmer

cr .( Loading Memory Pointer...)

\ BODY          +0             +4      +8              |    +12 ( removed)
\               [ phy_pointer ][ link ][ size_bytes ]  | [ ptr->link ]

in-application

internal

VARIABLE PHEAD  PHEAD OFF

:NONAME         ( LINK --  )                     \ POINTERS-INIT
                CELL- OFF                        \ clear the pointer
                ; : POINTERS-INIT ( -- )         \ clear each pointer in turn
                    LITERAL [ !CSP ]             \ make sure CSP is adjusted
                    PHEAD DO-LINK ;              \ from noname above

initialization-chain chain-add pointers-init

cfa-func DoPointer  ( -- address )                  \ it's location
                dup @ if @ exit then                  \ ok, straight fetch
                dup (pointerlock)
                @ if (pointerunlock) @ exit then  \ another task won the race
                dup 2 cells+ @ allocate 0=
                if     dup off                 \ set first cell to zeros
                       tuck swap ! (pointerunlock) exit
                then   (pointerunlock) 1-
                       abort" Failed to allocate POINTER" ;

in-system

: TRIM-POINTERS ( a1 -- a1 )
                PHEAD
                BEGIN   @ ?DUP
                WHILE   2DUP TRIM?
                        IF      DUP CELL- @ ?DUP
                                IF      RELEASE
                                THEN
                        THEN
                REPEAT  DUP PHEAD FULL-TRIM ;

forget-chain chain-add trim-pointers

: (.Pointer)    ( pfa -- )
                dup 2 cells+ @ 10 U,.R ."  bytes at: "
                @ ?DUP
                IF      13 H.R
                ELSE    ." <unallocated>"
                THEN     ;

: .Pointer      ( cfa -- )
                ." POINTER " dup .name >body (.Pointer) ;

external

:NONAME         ( link -- )                      \ .POINTERS
                cr CELL-  dup>r (.Pointer) ."  for: " R> body> .NAME
                ; : .POINTERS ( -- )
                    LITERAL [ !CSP ]             \ make sure CSP is adjusted
                    PHEAD DO-LINK ;              \ from noname above

internal

: (IsPointer?)   ( plink -- plink )     \ check for valid pointer structure
                 DUP @ Dopointer <>
                 IF      DUP CR h.
                         .name
                         ." is NOT a valid POINTER structure!"
                         ABORT
                 THEN    ;

in-application

: IsPointer?    ( cfa -- cfa )                    \ check for valid pointer structure
\in-system-ok     TURNKEYED? ?EXIT (IsPointer?) ; \ no point if this is turnkeyed

external

: %UnPointer    ( cfa -- )      \ deallocate pointer given the cfa
                IsPointer? >BODY DUP @ 0<>                  \ only if non-zero (added missing 0<> February 6th, 2004 - 18:35 dbu)
                IF      DUP @ release            \ release the memory
                        off                      \ clear the memory pointer
                ELSE DROP
                THEN ;

: >POINTER      ( cfa -- ptr )      \ move to ptr
                IsPointer? >BODY 2 cells+ ;

: %SizeOf!      ( bytes cfa -- )    \ set the size of pointer "cfa"
                >POINTER ! ;

: %SizeOf@      ( cfa -- bytes )    \ get the size of pointer "cfa"
                >POINTER @ ;

: (ResizePointer)  ( size size pointer -- f )
                dup>r 2 cells+ !                \ first, adjust the size of the desired pointer
                r@ @ 0=
                IF      r>drop                  \ if it isn't allocated yet, just leave
                        drop FALSE              \ things went just fine.
                        EXIT                    \ April 15th, 1999 - 10:51 tjz corrected
                THEN
                r@ @ (pointerlock) realloc 0=
                if      r> ! FALSE
                else    drop r>drop TRUE
                then    (pointerunlock) ;

in-system

: ResizePointer ( size -<Pointer>- flag )       \ return FALSE if all went ok
                ' STATE @
                IF      postpone dup  POSTPONE LITERAL
                        POSTPONE (ResizePointer)
                ELSE    over swap (ResizePointer)
                THEN    ; IMMEDIATE

: Pointer       ( bytes -<name>- )              \ make a pointer "name"
                >APPLICATION                    \ always in app space
                128 max                         \ at least 160 bytes
                header DoPointer compile, 0 ,   \ initialize to unallocated
                PHEAD link,                     \ link into chain
                ,                               \ lay in size in bytes
                APPLICATION> ;                  \ back to where we came from

: UnPointer>    ( name -- )     \ deallocate a pointer name following
                ' STATE @
                IF      POSTPONE LITERAL
                        POSTPONE %UNPOINTER
                ELSE    %UNPOINTER
                THEN    ; IMMEDIATE

: SizeOf!>      ( bytes | name -- ) \ set size of the following pointer
                ' STATE @
                IF      POSTPONE LITERAL
                        POSTPONE %SIZEOF!
                ELSE    %SIZEOF!
                THEN    ; IMMEDIATE

: SizeOf@>      ( -<name>- bytes )  \ get size of the following pointer
                ' STATE @
                IF      POSTPONE LITERAL
                        POSTPONE %SIZEOF@
                ELSE    %SIZEOF@
                THEN    ; IMMEDIATE

: named-new$    ( -<name>- )            \ a semi-static buffer of MAXSTRING length
                MAXSTRING Pointer ;

in-application

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\               Dynamic String Support Words
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

\ *P The dynamic string buffer is allocated when it is first used, and automatically
\ ** released when the program terminates.

32768 constant max-dyn-string
\ *G Gives the size of the dynamic string buffer.
\ Increased to 32768 for improved multi-tasking performance.

max-dyn-string Pointer dyn-ptr  ( -- addr )
\ *G Gives the address of the dynamic string buffer.

0 value dyn-offset                      \ top of the dynamic string buffer

: DynAlloc      ( n -- addr )
\ *G Allocate n bytes from the dynamic string buffer and return the address. If n exceeds 2048 then the size
\ ** is limited to 2048 bytes.
                dup
                max-dyn-string 16 / >    \ limit one string to 1/16 of total
                abort" Can't allocate a dynamic string this large"
                (dynlock) dyn-offset over + max-dyn-string >=
                if      0 to dyn-offset
                then    dyn-ptr dyn-offset + swap +to dyn-offset (dynunlock) ;

: _new$         ( -- addr )
\ *G Allocate MAXSTRING bytes from the dynamic string buffer and return the address. Used as the normal action
\ ** of NEW$ except during the early stages of initialisation, when NEW$ is a static buffer.
                MAXSTRING DynAlloc ;

: init-new$     ( -- )
\ *G Set new$ to perform _new$. This is performed as part of the initialisation chain, so is not normally
\ ** needed in an application.
                ['] _new$ is new$ ;

init-new$

initialization-chain chain-add init-new$

module

\ *Z


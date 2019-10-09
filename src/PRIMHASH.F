\ $Id: PRIMHASH.F,v 1.11 2013/11/06 21:56:29 georgeahubert Exp $
\ PRIMHASH.F    primitive hash functions
\ primhash.f 11/02/2003 22:33:59 arm Moved primitives from the kernel

cr .( Loading Primitive Hash...)

7 #vocabulary classes

sys-here ' classes >body -                    \ voc-pfa-size
          2 dup                               \ for #mlists below
          4 + cells sys-reserve               \ extra for a class
          swap constant voc-pfa-size

also classes get-current swap definitions

constant #mlists \ Number of method lists; must be a non-zero power of 2.

set-current previous

\ ---------------- 32-bit Hash Function for Objects ----------------

CODE METHOD-HASH ( addr len -- hash-val )
                pop     eax                     \ eax = address
                test    ebx, ebx                \ ebx=0?
                jz      short @@4               \ yes, bail out
                mov     ecx, ebx                \ ecx = count, ebx=result(includes count)
@@1:            rol     ebx, # 7
                xor     bl, 0 [eax]             \ add in next    c; byte
                add     eax, # 1
                sub     ecx, # 1
                jnz     short @@1
@@3:            test    ebx, ebx                \ make sure it's negative
                js      short @@2
@@4:            not     ebx
@@2:            next    c;

\ -------------------- Method/Ivar Search --------------------

CODE ((FINDM))  ( SelID addr -- 0cfa t | f )
                pop     eax                     \ selector id
                mov     ecx, eax
                and     ecx, # also classes #mlists 1- cells previous
                add     ebx, ecx
@@1:            mov     ebx, 0 [ebx]            \ follow link
                test    ebx, ebx                \ end of list?
                je      short @@2
                cmp     eax, 4 [ebx]            \ selectors match?
                jne     short @@1
                add     ebx, # 8                \ method cfa
                push    ebx
                mov     ebx, # -1               \ and true flag
@@2:            next    c;

CODE ((FINDV))  ( SelID addr -- 'ivar t | f )
                pop     eax                     \ selector id
@@1:            mov     ebx, 0 [ebx]            \ follow link
                test    ebx, ebx                \ end of list?
                je      short @@2
                cmp     eax, 4 [ebx]            \ selectors match?
                jne     short @@1
                add     ebx, # 8                \ ivar structure
                push    ebx
                mov     ebx, # -1               \ and true flag
@@2:            next    c;

\ -------------------- Runtime for Methods --------------------
\ m0cfa is executed when the object address is on the stack
\ m1cfa is executed when the ivar offset is compile in-line

CFA-CODE M0CFA
                mov     -4 [ebp], esi
                mov     ecx, OP [UP]
                mov     -8 [ebp], ecx
                mov     ecx, LP [UP]
                mov     -12 [ebp], ecx
                sub     ebp, # 12
                mov     OP [UP], ebx            \ get object address
                mov     LP [UP], ebp            \ LP = ebp
                pop     ebx
                lea     esi, 8 [eax]            \ get new ip (skip m1cfa)
                mov     ecx, 8 [eax]            \ get locals count
                test    ecx, ecx
                jnz     MOVE-LOCALS             \ we need to set up locals
                mov     eax, 4 [esi]            \ optimised next
                add     esi, # 8
                exec    c;

CFA-CODE M1CFA
                mov     ecx, 0 [esi]            \ get inline offset
                add     esi, # 4                \ esi past offset
                mov     -4 [ebp], esi
                mov     esi, OP [UP]
                mov     -8 [ebp], esi
                mov     esi, LP [UP]
                mov     -12 [ebp], esi
                sub     ebp, # 12
                add     OP [UP], ecx            \ add offset to object address
                mov     LP [UP], ebp            \ LP = ebp
                lea     esi, 4 [eax]            \ get new ip (skip m1cfa)
                mov     ecx, 4 [eax]            \ get locals count
                test    ecx, ecx
                jnz     MOVE-LOCALS             \ we need to set up locals
                mov     eax, 4 [esi]            \ optimised next
                add     esi, # 8
                exec    c;

\ end of method definition


\ EXITM was lost in Version 6.07.00
\ readded here for compatiblity September 8th, 2003 - 12:53 dbu

NCODE UNNESTM   ( -- )
                mov     ebp, LP [UP]
                xchg    esp, ebp
                pop     LP [UP]                   \ restore local pointer
                pop     OP [UP]                   \ restore object pointer
                pop     esi                       \ restore ip
                xchg    esp, ebp
                next    c;

\ in-system
\
\ : EXITM         ( -- ) \ exit a method definition
\                 ?comp postpone unnestm ; immediate
\
\
\
\ in-application

synonym exitm   exit
synonym ?exitm ?exit

\ -------------------- Runtime for Objects --------------------

CFA-CODE DOOBJ
                push    ebx
                lea     ebx, 8 [eax]
                next    c;

\ return the base of the current object

CODE ^BASE      ( -- addr )
                push    ebx
                mov     ebx, OP [UP]
                next    c;


\ -------------------- Runtime for Instance Variables --------------------

\ These are the "non-object" instance variables.  They have the same
\ names and syntax as the regular Forth versions.  They are defined in
\ the META vocabulary and will be found when inside a class definition.
\ The Offset from OP stored at cfa+15
\ bytes runtime

CFA-CODE (&IV)
                push    ebx
                mov     ebx, 4 [eax]            \ get ivar offset
                add     ebx, OP [UP]            \ add to base of current object
                next    c;


\ single byte (8bit) instance variables

CFA-CODE (IVC@)
                push    ebx
                mov     eax, 4 [eax]            \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                movzx   ebx, byte ptr 0 [eax]   \ fetch value
                next    c;

CFA-CODE (IVC!)
                mov     eax, -4 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     0 [eax], bl             \ store value
                pop     ebx
                next    c;

CFA-CODE (IVC+!)
                mov     eax, -8 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                add     0 [eax], bl             \ add value
                pop     ebx
                next    c;


\ word number (16bit) instance variables

CFA-CODE (IVW@)
                push    ebx
                mov     eax, 4 [eax]            \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                movzx   ebx, word ptr 0 [eax]   \ fetch WORD value
                next    c;

CFA-CODE (IVW!)
                mov     eax, -4 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     0 [eax], bx             \ store WORD value
                pop     ebx
                next    c;

CFA-CODE (IVW+!)
                mov     eax, -8 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                add     0 [eax], bx             \ add WORD value
                pop     ebx
                next    c;


\ single number (32bit) instance variables

CFA-CODE (IV@)
                push    ebx
                mov     eax, 4 [eax]            \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     ebx, 0 [eax]            \ fetch value
                next    c;

CFA-CODE (IV!)
                mov     eax, -4 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     0 [eax], ebx            \ store value
                pop     ebx
                next    c;

CFA-CODE (IV+!)
                mov     eax, -8 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                add     0 [eax], ebx            \ add value
                pop     ebx
                next    c;

\ double number (64bit) instance variable

CFA-CODE (IVD@)
                push    ebx
                mov     eax, 4 [eax]            \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     ecx, 4 [eax]            \ fetch value at cell +
                mov     ebx, 0 [eax]            \ fetch value
                push    ecx
                next    c;

CFA-CODE (IVD!)
                mov     eax, -4 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                mov     0 [eax], ebx            \ store value
                pop     ebx
                mov     4 [eax], ebx            \ store value
                pop     ebx
                next    c;

CFA-CODE (IVD+!)
                mov     eax, -8 [eax]           \ get ivar offset
                add     eax, OP [UP]            \ add to base of current object
                pop     ecx
                add     4 [eax], ecx            \ add low part first
                adc     0 [eax], ebx            \ add high part with carry
                pop     ebx
                next    c;


\ -------------------- Object pointer --------------------

: OP@  OP @ ;   \ to allow UP to be kept in the EDX register
: OP!  OP ! ;

\ -------------------- Find Name for Hashed Value --------------------

79 #vocabulary hashed

' hashed vcfa>voc constant hash-wid

: (unhash)  ( hash-val -- addr len flag )
        hash-wid dup voc#threads cells+ hash-wid  ( hash-wid end to hash-wid )
        do      i
                begin   @ ?dup
                while   ( hash-val link-field )
                        2dup link> >body @ =
                        if      nip ( discard hash value )
                                l>name
				dup LATEST-NFA ! \ save nfa for other use (Sonntag, März 13 2005 dbu)
				count ( addr len )
                                true unloop exit
                        then
                repeat
        cell +loop
        drop S" Unknown" false ;

: unhash    ( hash-val -- addr len )
        (unhash) drop ;

: ?unhash   ( hash-val -- f1 )
        (unhash) nip nip ;

IN-SYSTEM

defer clash ( hash-val -- )

' drop is clash

: add-hash  ( addr len hash-val -- )
        >r 2dup hash-wid search-wordlist
        if
                r> 4drop  ( already found )
        else
                r@ -rot hash-wid swap-current >r
                ['] Constant execute-parsing
                r> set-current
                r> clash
        then ;

0 value obj-save

: .M0NAME       ( a1 -- )
                [ 1 cells ] literal - @ unhash type space ;

also classes

: .M1NAME       ( a1 a2 -- a3 )
                [ 2 cells ] literal - @ unhash type
                cell+   ( a1 becomes a3 )       \ skip next cell also
                dup @ ?dup
        if      obj-save
                if      obj-save cell - @           \ should use obj>CLASS, not yet there
                        voc-pfa-size #mlists cells+ +        \ should use IFA,       not yet there
                        begin   @ 2dup 3 cells+ @ u< 0=
                                start/stop
                        until   nip dup
                        if      cell+ @ unhash space type
                        else    drop ." ???"
                        then    space
                else    drop ." NULL "
                then
        else    ."  self "
        then    ;

previous

IN-APPLICATION



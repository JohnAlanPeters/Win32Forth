\ *! gdiTools
\ *T GdiTools -- Helper words for the GDI class library
\ *Q Version 1.0
\ ** This GDI class library was written and placed in the Public Domain
\ ** in 2005 by Dirk Busch
\ *S Glossary

cr .( Loading GDI class library - Tools...)

internal
external

in-application

[undefined] S-REVERSE [IF] \ from toolset.f
CODE S-REVERSE ( n[k]..2 1 0 k -- 0 1 2..n[k] ) \ w32f
\ *G Reverse n items on stack   \n
\ ** Usage: 1 2 3 4 5 5 S_REVERSE ==> 5 4 3 2 1
         lea     ecx, -4 [esp]     \ ecx points 4 under top of stack
         lea     ebx, 4 [ecx] [ebx*4] \ ebx points 4 over stack
\ bump pointers, if they overlap, stop
@@1:     sub     ebx, # 4          \ adjust top
         add     ecx, # 4          \ adjust bottom
         cmp     ecx, ebx          \ compare
         jae     short @@2         \ ecx passing ebx, so exit
\ rotate a pair
\ xor a,b xor b,a xor a,b swaps a and b
         mov     eax, 0 [ebx]      \ bottom to eax
         xor     0 [ecx], eax      \ exchange top and eax
         xor     eax,  0 [ecx]
         xor     0 [ecx], eax
         mov     0 [ebx], eax      \ eax to bottom
         jmp     short @@1         \ next pair
@@2:     pop     ebx               \ tos
         next    c;
[then]

[undefined] 3reverse [if]
: 3reverse ( n1 n2 n3 -- n3 n2 n1 ) \ w32f
\ *G Reverse 3 items on stack
        3 S-REVERSE ;
[then]

[undefined] 4reverse [if]
: 4reverse ( n1 n2 n3 n4 -- n4 n3 n2 n1 ) \ w32f
\ *G Reverse 4 items on stack
        4 S-REVERSE ;
[then]

[undefined] 5reverse [if]
: 5reverse ( n1 n2 n3 n4 n5 -- n5 n4 n3 n2 n1 ) \ w32f
\ *G Reverse 5 items on stack
        5 S-REVERSE ;
[then]

[undefined] 6reverse [if]
: 6reverse ( n1 n2 n3 n4 n5 n6 -- n6 n5 n4 n3 n2 n1 ) \ w32f
\ *G Reverse 6 items on stack
        6 S-REVERSE ;
[then]

[undefined] 8reverse [if]
: 8reverse ( n1 n2 n3 n4 n5 n6 n7 n8 -- n8 n7 n6 n5 n4 n3 n2 n1 ) \ w32f
\ *G Reverse 8 items on stack
        8 S-REVERSE ;
[then]

module

\ *Z

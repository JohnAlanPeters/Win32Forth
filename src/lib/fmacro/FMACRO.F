\ needs src\old\optimize.f \ load the optimizer here when you would like to see its effect.

anew fmacro.f \ January 17th, 2012  by J.v.d.Ven

((

fmacro.f is an extension for Win32Forth to speed it a bit up.
It is done by translating Forth like statements into code.

You might see the biggest gain when recursive code is used.

There seems to exist a strange puzzeling "memory" effect.
When we understand and use it we could gain 25% of speed.

Here is my case when fmacro.f is used.

Conditions:
A P400 using Win32forth Version: 6.09.04 Build: 156 under XP:

Results of the tests when optimize.f IS loaded:

Test1 normal:...................................Elapsed time: 00:00:04.516
Test2 with the optimizer :......................Elapsed time: 00:00:04.467
Test3 using the macro code:.....................Elapsed time: 00:00:01.172
Test4 using the macro code bypassing the stack:.Elapsed time: 00:00:01.071

When optimize.f is NOT loaded I get:

Test3 using the macro code:.....................Elapsed time: 00:00:01.011
Test4 using the macro code bypassing the stack:.Elapsed time: 00:00:00.851

The "memory" effect is almost gone under Windows 7 with an iCore7.
Under Windows 7 using Win32forth Version: 6.15.00 Build: 40 when optimize.f IS loaded::
Test1 normal:...................................Elapsed time: 00:00:00.203
Test2 with the optimizer :......................Elapsed time: 00:00:00.188
Test3 using the macro code:.....................Elapsed time: 00:00:00.124
Test4 using the macro code bypassing the stack:.Elapsed time: 00:00:00.113

When optimize.f is NOT loaded I get:
Test3 using the macro code:.....................Elapsed time: 00:00:00.119
Test4 using the macro code bypassing the stack:.Elapsed time: 00:00:00.106


The floating point part uses the hardware stack of the CPU
The size of the hardware floating point stack is limited to 8 floats.
There are no warnings when an error condition occurs.

There is some coding overhead for literals and variables.
Eg:

In forth you would write:

variable aa  2 aa !
: test1   ( - aa*2)      aa @ 2 * ;

When you would like to use code you must use ADDR and ASS-LIT
so the new code would be:

code test2 ( - aa*2)
                 aa ADDR@    2 ASS-LIT  *
        next,
        end-code

test1 decompiles as follows:
  see test1
  : TEST1         AA @ lit "0x2" * ;

test2 decompiles as follows:
  see test2
TEST2 IS CODE
  ( $404150 53 )              push    ebx
  ( $404151 8B1DE8A44400 )    mov     ebx, $44A4E8 ( AA+$0 )
  ( $404157 53 )              push    ebx
  ( $404158 C7C302000000 )    mov     ebx, # $2
  ( $40415E 58 )              pop     eax
  ( $40415F 83ED04 )          sub     ebp, # $4
  ( $404162 895500 )          mov     $0 ( $400000+$FFBFFFFC ) [ebp] edx
  ( $404165 F7E3 )            mul     ebx
  ( $404167 8BD8 )            mov     ebx, eax
  ( $404169 8B5500 )          mov     edx, $0 ( $400000+$FFBFFFFC ) [ebp]
  ( $40416C 83C504 )          add     ebp, # $4

The coding overhead is a small disadvantage.
Bypassing the interpreter by using code is the advantage.

Do not use this pack when you are just starting to use Forth.
It is fast but hard to debug.
As soon as you are used to Forth you might like it since it
is possible to translate Forth like statements into code which might be
2 till 5 times faster than high level Win32Forth depending on your code and
your PC.

Variables and fvariables of Forth can be used.
They are faster in this pack than value or fvalue.

Only words that I needed are done.
Do not use labels in macro's. They might generate unpredictable code.

Updates:
========

March 10th, 2003. A version in which the following words
were temporary added:  <cmp[  ]<cmp       +addr[  ]tos!

March 17th, 2003 - 15:25
Now it is possible to bypass the stack in a better way.
Bypassing the stack reduced the size of the code and may speed up your program.
The syntax is more Forth-like thanks to a few dirty tricks in the assembler.

Removed: <cmp[  ]<cmp  +addr[  ]tos!
Added:    addr@+ addr@< faddr@  faddr! f2* f< f2drop fsqr
Changed:  ass-lit and some stack notations.

Now it is possible to bypass the stack as follows:

variable t1

code test
        t1 addr@+
     next,
     end-code

It decompiles as follows:

see test
TEST IS CODE
  ( $40417C 031DF0A44400 )    add     ebx, $44A4F0 ( T1+$0 )

In high level forth you would need:
: test  ( n - t1+n )  t1 @ + ;

NOTES:
1. Words like  @ ! F! and F@ can be used when there is an address on the stack.
2. Words like:  addr@+ addr@< faddr@  faddr!  are used during COMPILE-time.
   They put an address in your code that will be used in runtime.
3. The word ADDR enables you to get an address on the stack in runtime when not in the user-area.


March 22nd, 2003
Added: carry? f0> if then do loop leave execute_exit begin while repeat
       and high level faddr@ faddr!

April 5th, 2003 added:  nip sm/rem  f>d f>s faddr@+ faddr@- faddr@* faddr@/
The new floating point instructions make test4 about 5% faster when b/float=8.

April 12th, 2003 Added: ftan -rot

April 21st, 2003 Added: dup>r removed a bug from faddr@/

May 12th, 2003 Changed to free register ECX: rot -rot * sm/rem fs>hw loop
               Also changed swap.
               Swap took 8 bytes now it takes only 4 bytes at the same speed.
               Added: ass-lit+ up>r r>up 32align and 2 local variables A and B
               The 2 local variables are using the registers ECX and EDX and
               are able to perform the following:
               a>nos  a@  a!  dup_a!  a@+  a>r  r>a  @to_a+
               b>nos  b@  b!  dup_b!  b@+  b>r  r>b  @to_b+
               Do not use fs>hw after variable B is used since it uses EDX
               See sieve.f and mm_fw_fm.f for an example.
               Now Sieve is 5.3 times faster then 'standard' high level Win32Forth code.
               The new words can also be simulated in high level Forth.
               That means you can use the words in high level Forth.
               Debug it and then change it into assembler by
               replacing the : by CODE and the ; by NEXT, END-CODE

May 17th, 2003 Added: push_eax, pop_eax, push_ebx and pop_ebx to avoid a sequence like:
               pop ebx  push ebx

December 9th, 2004  Added: r_nos_c!,  r_nos_!, b_nos_c!, b_nos_!, a_nos_c! and a_nos_!
                          to avoid using the parameter stack.
December 27th, 2004 Removed a bug from  begin while repeat
May 20th, 2009      Removed a bug from - added:  swap- and j
December 14th, 2011 Made the user-area accessible and adapted it for Win32Forth version 6.14
                    the user-area is handled by EDX so you should not use the local B
                    when you are using the user-area.
December 18th, 2011 addr@+ addr@< faddr@  faddr! are now also able to use the user-area
January  17th, 2012 Bugfix in FLD_extended|double_[edx] and FSTP_extended|double_[edx]
November 1st,  2015 Removed EDI

))


defined  code-c, nip  not  [IF]
synonym code-c, c,
synonym code-w, w,
synonym code-,  ,
synonym code-here here
synonym cdp dp
[then]


SYS-WARNING-OFF


: qalign                code-here -11 and 12 + code-here - allot ;
: 32align               code-here -31 and 32 + code-here - allot ;

DUP-WARNING-OFF

: fvariable     ( -<name>- )                    \ compile time
                ( -- a1 )                       \ runtime
                qalign            \ There is a positive effect when fvariables are at a qword
                create B/FLOAT allot ;  \ Uses 4 bytes in runtime

DUP-WARNING-ON

0e      fvariable fzero         fzero f!
0       variable _zero          _zero !
0       constant                zero

: user?  ( adr - adr flag )  dup rp0 dup usersize + between  ;


also assembler definitions

        fvariable ftrash

' loop alias loop_   \ use loop_ for the orignal assembler code

in-system


0 value FLD_extended|double
0 value FSTP_extended|double
0 value FLD_extended|double_[edx]
0 value FSTP_extended|double_[edx]

B/FLOAT 10 =
[IF]    $2DDB to FLD_extended|double       $3DDB to FSTP_extended|double
        $AADB to FLD_extended|double_[edx] $BADB to FSTP_extended|double_[edx]
[ELSE]  $05DD to FLD_extended|double       $1DDD to FSTP_extended|double
        $82DD to FLD_extended|double_[edx] $9ADD to FSTP_extended|double_[edx]

[THEN]


: a;; postpone a; postpone ; ; immediate

\ The macros that can be used in code are:

0 value poped_ebx
0 value opt_pop_adr

: push_ebx       \ push ebx only when it is needed.
    [ also forth ]
    code-here 1- poped_ebx =  cdp @ opt_pop_adr > and
         if      -1 cdp +!    \ avoid a sequence like:  pop ebx  push ebx
         else    $53 code-c,  \ previous instruction was not pop ebx so push ebx
         then
    [ previous ]
 ;

0 value poped_eax

: push_eax \  also sets poped_eax
  push    eax
  code-here to poped_eax
 ;

: pop_eax       \ push eax only when it is needed.
    [ also forth ]
    code-here 1- poped_eax =
         if      -1 cdp +!  \ avoids a sequence like:  push eax  pop eax
         else    $58 code-c,    \ previous instruction was not push eax so pop eax
         then
    [ previous ]
 ;

: drop   ( n -- )               pop     ebx   code-here to poped_ebx  a;;
: 2drop  ( n -- )               drop    drop a;;
: dup    ( n -- n n )           push    ebx  a;; \ do not use: push_ebx
: nip    ( n1 n2 -- n2 )        pop_eax      a;;

: a>nos  ( n -- n l )           push    ecx  a;;
: dup_a! ( n -- n )             mov     ecx, ebx a;;
: a@+    ( n -- n+a )           add ebx, ecx a;;

\ : r@a+a! ( r: r - r ) ( a: a - r+a) add    ecx, 0 CELLS [ebp] a;;


: a@     (   -- n )             push_ebx
                                mov     ebx, ecx
                               a;;

: a!     ( n -- )               mov ecx, ebx
                                drop
                               a;;
: a>r    ( Returnstack: - up )
                                sub     ebp, # 4
                                mov     0 [ebp], ecx
                               a;;

: r>a    ( Returnstack: up -- )
                                mov     ecx, 0 [ebp]
                                add     ebp, # 4
                               a;;

\ Save and restore local variable B when you use it.

: b>nos  ( n -- n l )           push    edx  a;;
: dup_b! ( n -- n )             mov     edx, ebx  a;;
: b@+    ( n -- n+b )           add ebx, edx a;;

: b@     (   -- n )             push_ebx
                                mov     ebx, edx
                               a;;

: b!     ( n -- )               mov edx, ebx
                                drop
                               a;;

: b>r    ( Returnstack: - up )
                                sub     ebp, # 4
                                mov     0 [ebp], edx
                               a;;

: r>b    ( Returnstack: up --  )
                                mov     edx, 0 [ebp]
                                add     ebp, # 4
                               a;;

: over   ( n1 n2 -- n1 n2 n1 )
                    dup  mov  ebx, 4 [esp]
                   a;;

\ mov is faster then xchg

: swap  ( n1 n2 -- n2 n1 )   \ Took 8 bytes now 4 bytes BM: new: 155.4E-3 sec  old: 159.9E-3
                    pop_eax  \ BM: means tested 10.000.000 times in a loop on a P400.
                    push ebx
                    mov  ebx, eax
                   a;;

: rot   ( n1 n2 n3 -- n2 n3 n1 )  \ BM: new: 194.5E-3 sec  old: 210.7E-3 sec
                    pop_eax
                    push ebx
                    mov  ebx, 4 [esp]
                    mov  4 [esp], eax
                   a;;


: -rot  ( n1 n2 n3 -- n3 n1 n2 )  \ BM: new: 200.8E-3 sec  old: 249.7E-3
                    mov  eax, 4 [esp]
                    mov  4 [esp], ebx
                    pop  ebx
                    push_eax
                a;;

: 2dup  ( n1 n2 -- n1 n2 n1 n2 )
                   mov     eax, 0 [esp]
                   push    ebx
                   push_eax
                  a;;

: +     ( n1 n2 -- n3 )
                   pop_eax
                   add     ebx, eax
                  a;;

: swap- ( n1 n2 -- n3 )
                  pop_eax
                  sub     ebx, eax
                 a;;

: -     ( n1 n2 -- n3 )
                 pop_eax
                 sub     eax, ebx
                 mov     ebx, eax
                 a;;

: up>r           ( Returnstack: - up )
                 sub     ebp, # 4
                 mov     0 [ebp], edx
                a;;

: r>up         ( Returnstack: up --  )
                 mov     edx, 0 [ebp]
                 add     ebp, # 4
                a;;

: *     ( n1 n2 -- n3 ) \ BM: new: 277.0E-3 sec  old: 292.3E-3
                  pop_eax
                  up>r
                  mul     ebx
                  mov     ebx, eax
                  r>up
                 a;;

: lshift     ( u1 n -- u2 )  \ shift u1 left by n bits (multiply)
                mov     ecx, ebx
                pop     ebx
                shl     ebx, cl
                a;;

: rshift     ( u1 n -- u2 )  \ shift u1 right by n bits (divide)
                mov     ecx, ebx
                pop     ebx
                shr     ebx, cl
                a;;

: sm/rem ( d n2 -- rem quot ) \ BM: new:  1.216E0 sec  old: 966.3E-3
                 up>r
                 pop     edx
                 pop     eax
                 idiv    ebx
                 push    edx
                 mov     ebx, eax
                 r>up
                a;;

: @     ( a1 -- n1 )
                 mov     ebx, [ebx]
                 a;;

: c@    ( a1 -- c1 )
                 movzx   ebx, byte ptr 0 [ebx]
                 a;;

: c!    ( c1 a1 -- )
                 pop_eax
                 mov     0 [ebx], al
                 drop
                a;;
: r_nos_c!     ( a1 -- )  ( r: n1 - n1)
		mov     eax, 0 [ebp]
                mov     0 [ebx], al
		drop
                a;;

: r_nos_!     ( a1 -- )  ( r: n1 - n1)
		mov     eax, 0 [ebp]
                mov     0 [ebx], eax
		drop
                a;;

: b_nos_c!     ( a1 -- )
                mov     0 [ebx], dl
		drop
                a;;

: b_nos_!     ( a1 -- )
                mov     0 [ebx], edx
		drop
                a;;

: a_nos_c!     ( a1 -- )
                mov     0 [ebx], cl
		drop
                a;;

: a_nos_!     ( a1 -- )
                mov     0 [ebx], ecx
		drop
                a;;

: !       ( a1 -- )  ( r: n1 - n1)
                pop     [ebx]
                pop     ebx
                a;;

: carry? ( n - flag )
                 mov     ebx, # 0
                 sbb     ebx, ebx
                a;;

: cells+     ( a1 n1 -- a1+n1*cell )
                 lea     ebx, 0 [ebx*4]
                 pop     eax
                 add     ebx, eax
                a;;

: cell-      ( a1 -- a1-cell )
                 sub     ebx, # cell
                a;;

: 2cells-    ( a1 -- a1-2cells )
                 sub     ebx, # 8
                a;;

: 2r>        ( -- n1 n2 )
                  push_ebx
                  mov     ebx, 0 CELLS [ebp]
                  mov     eax, 1 CELLS [ebp]
                  add     ebp, # 8
                  push_eax
                a;;

: >r         ( n1 -- )
                 sub     ebp, # 4
                 mov     0 [ebp], ebx
                 drop
                a;;

: r>         ( -- n1 )
                 push_ebx
                 mov     ebx, 0 [ebp]
                 add     ebp, # 4
                a;;

: r>drop         ( -- n1 )
                 add     ebp, # 4
                a;;

: r@         ( -- n1 )       \ get a copy of the top of the return stack
                 push_ebx a;
                 mov     ebx, 0 [ebp]
                a;;

: dup>r      ( n1 -- n1 )    \ push a copy of n1 onto the return stack
                sub     ebp, # 4
                mov     0 [ebp], ebx
                a;;

: 2>r        ( n1 n2 -- )
                 pop_eax
                 sub     ebp, # 8
                 mov     1 CELLS [ebp], eax
                 mov     0 CELLS [ebp], ebx
                 drop
                a;;

: 2@         ( a1 -- d1 )
                push    4 [ebx]
                mov     ebx, 0 [ebx]
                a;;

: ass-lit    ( <lit> - ) [ also forth ]
                          push_ebx
                          $C7 code-c, $C3 code-c,  code-,
                          [ previous ] a;;

: ass-lit+   ( <lit> - ) [ also forth ] $81 code-c, $C3 code-c,  code-, [ previous ] a;;


: user!        \ Compiletime:  ( name-user -  )  ( n -- )
                [ also forth ] $89 code-c, $9A code-c, TCB -  code-, $5B code-c, [ previous ]
                    a;;

: user@        \ Compiletime:  ( name-user -  )  ( - n )
                [ also forth ] $53 code-c, $8B code-c, $9A code-c,  TCB -  code-, [ previous ]
                    a;;


: fuser!       \ Compiletime:  ( name-fuser -  ) Runtime: ( fhw: r --  )
                [ also forth ] FSTP_extended|double_[edx]  code-w,  TCB -  code-,  [ previous ]
                    a;;

: fuser@       \ Compiletime: ( name-fuser - ) Runtime: ( fhw: -- r  )
                [ also forth ] FLD_extended|double_[edx] code-w, TCB - code-,  [ previous ]
                a;;


: f@         ( addr -- )  ( fhw: -- r )
                 fld   FSIZE DATASTACK_MEMORY
                 drop
                a;;

: f!         ( addr -- )  ( fhw: r -- )
                 fstp    FSIZE DATASTACK_MEMORY
                 drop
                a;;

: df@        ( addr -- )  ( fhw: -- r )
                 fld     double DATASTACK_MEMORY
                 drop
                a;;

: df!        ( addr -- )  ( fhw: r -- )
                 fstp    double DATASTACK_MEMORY
                 drop
                a;;

: d>f         ( d -- )  ( hw: -- r )
                 xchg    ebx, 0 [esp]
                 push    ebx
                 fild    qword 0 [esp]
                 add     esp, # 8
                 drop
                a;;

: s>f         ( n -- )  ( hw: -- r )
                 push ebx
                 shl     ebx, 1
                 sbb     ebx, ebx
                 d>f
                a;;

: f>d          ( hw: -- r ) (  -- d )
                push ebx
                sub     esp, # 8
                fistp   qword 0 [esp]
                pop     ebx
                xchg    ebx, 0 [esp]
                a;;

: f>s          ( hw: -- r ) (  -- n )
                push ebx
                sub     esp, # 4
                fistp   dword 0 [esp]
                drop
                a;;

: (faddr!      \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: r --  )
                [ also forth ] FSTP_extended|double code-w,  code-,  [ previous ]
                a;;

: faddr!  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF   fuser!
         ELSE (faddr!
         THEN  a;;

: fdup          ( hw: r -- r r )              fld st(0)         a;;
: fover         ( hw: r1 r2 -- r1 r2 r1 )     fld st(1)         a;;
: f2dup         ( hw: r1 r2 -- r1 r2 r1 r2 )  fover fover       a;;
: fswap         ( hw: r1 r2 -- r2 r1 )        fxch              a;;
: frot          ( hw: r1 r2 r3 -- f3 r2 r1 )  fxch st(2)        a;;
: fdrop         ( hw: r --  )                 ftrash faddr!     a;;
: f2drop        ( hw: r r --  )               fdrop fdrop       a;;
: f+            ( hw: r1 r2 -- r3 )           fadd              a;;
: f-            ( hw: r1 r2 -- r3 )           fsub              a;;
: f/            ( hw: r1 r2 -- r3 )           fdiv              a;;
: f*            ( hw: r1 r2 -- r3 )           fmul              a;;
: fnegate       ( hw: r1 -- r3 )              fchs              a;;
: fsqr          ( hw: r1 -- r2 )              fabs fsqrt        a;;


: fs>hw       ( fs: r1 -- ) ( fhw: -- r1 )  \ NOTE: uses EDX which might be in use as a local variable
                 mov     eax,   FSP_MEMORY
                 sub     eax, # B/FLOAT
                 fld     FSIZE floatstack [eax] [up]
                 mov     FSP_MEMORY , eax
                a;;

(( 6.09
  3C0C 8B8278010000             mov     eax, 178 ( _THEN : 0x0 ) [edx]
  3C12 DD043B                   fld     double [ebx] [edi]
  3C15 898280010000             mov     180 ( _THEN : 0x8 ) [edx] eax
  3C1B 53                       push    ebx
  3C1C 83EC04                   sub     esp, # 4
  3C1F DB1C24                   fistp   dword [esp]
  3C22 5B                       pop     ebx

4.2
         3C2AC 8B8270010000     mov     eax , 170 [edx]
         3C2B2 DD043B           fld     double [ebx] [edi]
         3C2B5 898278010000     mov     178 [edx] , eax
         3C2BB 53               push    ebx
         3C2BC 83EC04           sub     esp , # 4
         3C2BF DB1C24           fistp   dword [esp]
         3C2C2 5B               pop     ebx

))

: (faddr@      \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: -- addrf@ )
                 [ also forth ] FLD_extended|double  code-w,   code-,  [ previous ]
                 a;;

: faddr@  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF   fuser@
         ELSE (faddr@
         THEN  a;;

: (faddr@+ \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: -- ftos+addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $05DC code-w,  code-, [ previous ]
        [ELSE]  faddr@ f+
        [THEN]  a;;

: fuser@+ \ Compiletime: ( name-fuser - ) Runtime: ( fhw: -- ftos+addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $82DC code-w,  tcb - code-, [ previous ]
        [ELSE]  faddr@ f+
        [THEN]  a;;


: faddr@+  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF    fuser@+
         ELSE (faddr@+
         THEN  a;;


: (faddr@- \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: -- ftos-addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $AFDC code-w,  code-, [ previous ]
        [ELSE]  faddr@ f-
        [THEN]  a;;


: fuser@- \ Compiletime: ( name-fuser - ) Runtime: ( fhw: -- ftos+addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $AADC code-w,  tcb - code-, [ previous ]
        [ELSE]  faddr@ f-
        [THEN]  a;;


: faddr@-  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF   fuser@-
         ELSE (faddr@-
         THEN  a;;

: (faddr@/ \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: -- ftos/addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $3DDC code-w,  code-, [ previous ]
        [ELSE]  faddr@ f/
        [THEN]  a;;

: fuser@/ \ Compiletime: ( name-fuser - ) Runtime: ( fhw: -- ftos/addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $BADC code-w,  tcb - code-, [ previous ]
        [ELSE]  faddr@ f/
        [THEN]  a;;



: faddr@/  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF   fuser@/
         ELSE (faddr@/
         THEN  a;;

: (faddr@* \ Compiletime: ( name-fvariable|addr - ) Runtime: ( fhw: -- ftos-addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $0DDC code-w,  code-, [ previous ]
        [ELSE]  faddr@ f*
        [THEN]  a;;


: fuser@* \ Compiletime: ( name-fuser - ) Runtime: ( fhw: -- ftos-addrf@ )
        [ B/FLOAT 8 = ]
        [IF]    [ also forth ] $8ADC code-w,  tcb - code-, [ previous ]
        [ELSE]  faddr@ f*
        [THEN]  a;;


: faddr@*  \ Compiletime: ( name-fuser|addr - ) Runtime: ( fhw: -- addrf@ )
         user?
         IF   fuser@*
         ELSE (faddr@*
         THEN  a;;

: c0c3?          ( -- flag )   ( hw: -- )
                 push ebx
                 fstsw   ax
                 mov     ebx, eax
                 and     ebx, # 0x4100
 a;;

: fcomppx     ( -- flag )   ( hw: r1 r2 -- )
                 fcompp
                 c0c3?
                ;

: f>          ( -- f )  ( Fhw: r1 f2-- )
                 fswap
                 fcomppx
                 sub     ebx, # 1
                 sbb     ebx, ebx
                a;;

: f<          ( -- f )  ( Fhw: r1 f2 -- )
                 fcomppx
                 sub     ebx, # 1
                 sbb     ebx, ebx
                a;;

: f0>         ( -- f )  ( F: r -- )
                 fzero faddr@ f>
                 a;;

\ Already defined are:
\  fsin    ( fhw: r1 -- r3 )
\  fcos    ( fhw: r1 -- r3 )
\  fabs    ( fhw: r1 -- r3 )

: ftan          ( fhw: r1 -- r2 )
                fsincos f/
  ;


: addr ( <name-addr> - adr )
                push_ebx
                mov ebx, #
 ;

: addr@+ ( n name-addr - n+value )
   user?
   if   [ also forth ] $03 code-c, $9A code-c,  TCB -  code-, [ previous ]
   else [ also forth ] $03 code-c, $1D code-c,  code-, [ previous ]
   then
 a;;

: @to_a+ ( n - ) \ In A will be n+a
   [ also forth ] $03 code-c, $0D code-c,  code-, [ previous ]
 a;;

: @to_b+ ( n - ) \ In B will be n+a
   [ also forth ] $03 code-c, $15 code-c,  code-, [ previous ]
 a;;

: addr@ ( name-addr - value )
   user?
   if    [ also forth ] $53 code-c, $8B code-c, $9A code-c,  TCB -  code-, [ previous ]
   else  [ also forth ] $53 code-c, $8B code-c, $1D code-c,  code-, [ previous ]
   then
 a;;

: addr! ( name-addr - value )
   user?
   if   [ also forth ] $89 code-c, $9A code-c, TCB - code-, $5B code-c, [ previous ]
   else [ also forth ] $89 code-c, $1D code-c,  code-, $5B code-c, [ previous ]
   then
 a;;

: addr@<        ( addr -- flag )
     user?
     if    [ also forth ]  $3B code-c, $9A code-c,  TCB - code-, $C7 code-c, $C3 code-c, 0  code-, $1B code-c, $DB code-c, [ previous ]
     else  [ also forth ]  $3B code-c, $1D code-c,  code-, $C7 code-c, $C3 code-c, 0  code-, $1B code-c, $DB code-c, [ previous ]
     then
 a;;

: 0=    ( n1 -- f1 )    \ return true if n1 equals zero
                 sub     ebx, # 1
                 sbb     ebx, ebx
 a;;

: if    \ compiletime: ( - adr-to-jmp-part1 )
   0=  drop
   [ also forth ] $0f code-c, $85 code-c, code-here -1  code-, [ previous ]
 a;;

: else  \ compiletime: ( adr-to-jmp-part1 - adr-to-jmp-part2 )
   [ also forth ] code-here over - 1+ ( $5 + cell- ) swap ! $e9 code-c, code-here -1  code-,  [ previous ]
    a;;

: then  \ compiletime: ( adr-to-jmp-part -  )
   [ also forth ] code-here over - cell- swap !
		  code-here to opt_pop_adr
   [ previous ]
 a;;

: do    \ compiletime: ( - adr-after do ) ( fs: - leave-flag|adr )
        pop     eax
        sub     ebp, # 8
        mov     0 CELLS [ebp], ebx
        mov     1 CELLS [ebp], eax
        pop     ebx \  drop is not allowed here.
        a;
       [ also forth ] 0.0e code-here   [ previous ]
 ;

: 1+    ( n - n+1 )     inc ebx         a;;
: i     ( - i )         r@              a;;
: j     ( - j )
                 push_ebx a;
                 mov     ebx, 2 CELLS [ebp]
                a;;

DUP-WARNING-OFF

: leave \ compiletime: ( - ) ( fs: - leave-flag|adr )
       [ also forth ] $e9 code-c, fdrop  code-here s>f  -1  code-, [ previous ]
 a;;

: loop  \ compiletime: ( adr-after -  ) ( fs: leave-flag|adr - )
    [ also forth ]       $FF code-c, $45 code-c, $00 code-c,   \ inc dword ptr  0 [ebp]  \ inc index
                         $8B code-c, $45 code-c, $04 code-c,   \ mov  eax, 4 [ebp]
                         $3B code-c, $45 code-c, $00 code-c,   \ cmp eax, 0 [ebp]
                         $0f code-c, $85 code-c, code-here -  cell-  code-,
                         f>s dup 0<>
                                if      code-here over - 4 - swap  !  \ jmp address for leave
                                else    drop
                                then
                         [ previous ]
      add     ebp, # 8 \ endloop
      code-here to opt_pop_adr
 a;;

DUP-WARNING-ON

: begin  \ compiletime: ( - adr-at-begin )
	[ also forth ] code-here
	dup to opt_pop_adr
	[ previous ]
 ;

: while \ compiletime: ( adr-at-begin - put-adr-after-repeat adr-at-begin )
       0=  drop
       [ also forth ] $0F code-c, $85  code-c, code-here -1  code-, swap
	code-here to opt_pop_adr
       [ previous ]
 a;;

: repeat \ compiletime: ( put-adr-after-repeat adr-at-begin -  )
   [ also forth ] $e9 code-c, code-here - cell-  code-, \  jmp near @@1  E9 D0FFFFFF
                  code-here over - cell- swap !
   [ previous ]
 a;;

: f2*           ( n1 -- n2 )     fdup f+        a;;
: 1/            ( hw: x - 1/x )  fld1 fswap f/  a;;
: zero          ( -- 0 )         0 ass-lit      a;;
: one           ( -- 1 )         1 ass-lit      a;;
: 2*            ( n1 -- n2 )     dup +          a;;

: dfloats       ( addr1 -- addr2 )    8 ass-lit * a;;
: dfloat+       ( addr1 -- addr2 )    8 ass-lit + a;;


: <     ( n1 n2 -- f1 )
                 pop_eax
                 cmp     eax, ebx
                 carry?
                a;;

: >     ( n1 n2 -- f1 )
                 pop_eax
                 cmp     ebx, eax
                 carry?
                a;;

: =          ( n1 n2 -- f1 )
                 pop_eax
                 sub     ebx, eax
                 sub     ebx, # 1
                 sbb     ebx, ebx
                a;;

: <>         ( n1 n2 -- f1 )
                 pop_eax
                 sub     eax, ebx
                 neg     eax
                 sbb     ebx, ebx
                a;;

: 0<>        ( n1 -- f1 )    \ return true if n1 is not equal to zero
                sub     eax, eax
                sub     eax, ebx
                neg     eax
                sbb     ebx, ebx
                a;;

: execute_exit  ( xt -- )
                 mov     eax, ebx
                 drop
                 exec
                a;;




\ Use:  variable t1    code x1  t1 addr@<    next,  end-code

: pick-a-color
   push ebx
   0<>
        if      0 ass-lit  16777216  ass-lit sm/rem drop
        then    PC_NOCOLLAPSE ass-lit +
  a;;

in-application  SYS-WARNING-ON  \ End of added macro's

only forth also definitions

code df@>hw     ( addr -- )  ( hw: -- r )
                fld   double DATASTACK_MEMORY
                drop
   next,
   end-code

\ For high level compatibility

: fs>hw         ( -- )                  ; immediate
: ass-lit       ( -- )                  ; immediate
: ass-lit+      ( -- )            +     ;
: addr          ( -- )                  ; immediate
: addr@         ( - addr@ )       @     ;
: addr!         ( addr - )        !     ;
: addr@+        ( addr - addr@+ ) @ +   ;
: addr@<        ( addr - f )      @ <   ;
: faddr@        ( - faddr@ )      f@    ;
: faddr!        ( n - )           f!    ;
: faddr@+       ( - faddr@ ) ( f: -- ftos+addrf@ ) f@ f+ ;
: faddr@-       ( - faddr@ ) ( f: -- ftos+addrf@ ) f@ f- ;
: faddr@*       ( - faddr@ ) ( f: -- ftos+addrf@ ) f@ f* ;
: faddr@/       ( - faddr@ ) ( f: -- ftos+addrf@ ) f@ f/ ;
\IN-SYSTEM-OK  : execute_exit  ( xt - ) postpone execute postpone exit  ; immediate

cell newuser loc_a       cell newuser loc_b

: a>nos    ( n -- n a )            loc_a @ swap        	;
: a@       (   -- l )              loc_a @             	;
: a!       ( n -- )                loc_a !             	;
: a_nos_c! ( a - )  		   a@ swap c!  		;
: a_nos_!  ( a - )  		   a@ swap !  		;
: dup_a!   ( n -- n )              dup a!              	;
: a@+      ( n -- n+a )            a@ +                	;
: a>r      ( Returnstack:  -- a )  s" a@ >r" EVALUATE  	; IMMEDIATE
: r>a      ( Returnstack: a --  )  s" r> a!" EVALUATE  	; IMMEDIATE
: r_nos_c! ( Returnstack: n --  ) ( a - ) s" r@ swap c!" EVALUATE  ; IMMEDIATE
: r_nos_!  ( Returnstack: n --  ) ( a - ) s" r@ swap  !" EVALUATE  ; IMMEDIATE
: @to_a+      ( addr - )                 @ loc_a +!     ;
: b>nos     ( n -- n b )            loc_b @ swap        ;
: b@        (   -- l )              loc_b @             ;
: b_nos_c!  ( a - )  		    b@ swap c!  	;
: b_nos_!   ( a - )  		    b@ swap  !  	;
: b!        ( n -- )                loc_b !             ;
: dup_b!    ( n -- n )              dup b!              ;
: b@+       ( n -- n+b )            b@ +                ;
: b>r       ( Returnstack:  -- b )  s" b@ >r"  EVALUATE ; IMMEDIATE
: r>b       ( Returnstack: b --  )  s" r> b!"  EVALUATE ; IMMEDIATE
: @to_b+    ( a - )                 @ loc_b +!          ;
\ : r@a+a!    ( r: - r: ) ( a - r+a)  s" r@ a@ + a!"   EVALUATE ; IMMEDIATE



 ((  >>> Disable or delete this line to run the following BM test section


\ needs profiler.f

  B/FLOAT newuser t1
\ fvariable t1
fvariable t2
fvariable t3

\ 99 t1 !
20001e t1 f!



code BM
      s>f t1 faddr!
\     t1  faddr@
\     t1 faddr!
   next,   end-code

see t1
 see bm

: x11   20001 bm  t1 f@ f. ;

 cr   x11  .s
   abort

\s

\ ))

\s \    Disable or delete this line to run the following tests

fvariable aa fvariable bb fvariable cc

defined  opt[ nip [IF]

opt[
: test2
    ." Test2 with the optimizer :......................" time-reset 10000000 0
        do aa f@ bb f@ f+ cc f@ f* aa f@ f- bb f!
        loop
    .elapsed ;
]opt

[then]

: test1
   ." Test1 normal:..................................." time-reset 10000000 0
        do aa f@ bb f@ f+ cc f@ f* aa f@ f- bb f!
        loop
   .elapsed ;


code _test3    \ Costs about 87 bytes >>>
   do   addr aa f@    addr bb f@ f+   addr cc f@ f*   addr aa f@  f- addr bb  f!
   loop
   next,
   end-code

code _test4   \ Costs only about 56 bytes
 do
    aa faddr@    bb faddr@+  cc faddr@*   aa faddr@- bb   faddr!
 loop
   next,
   end-code


: test3
   1.1e aa f!
   .2e bb f!
   .23e cc f!
   ." Test3 using the macro code:....................." time-reset  20000000 0
     _test3 \   bb f@ f.
   .elapsed  ;

: test4
   1.1e aa f!
   .2e bb f!
   .23e cc f!
   ." Test4 using the macro code bypassing the stack:." time-reset 20000000 0
     _test4 \ bb f@ f.
   .elapsed ;

defined  opt[ nip  [IF]
 cr test1  cr test2
[THEN]
 cr test3  cr test4
\s


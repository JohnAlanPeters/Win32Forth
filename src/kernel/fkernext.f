\ $Id: fkernext.f,v 1.2 2005/08/16 00:01:05 alex_mcdonald Exp $
\
\ fkernext.f beta 3.1A 2002/09/25 arm Performance enhancements
\ fkernext.f beta 3.3D 08/10/2002 arm Consolidation
\ fkernext.f beta 4.0A 18/11/2002 arm Tidy up of macros

((

   Code moved out of ASMWIN32.F and FKERNEL.F so that definitions of NEXT and
   EXEC are next to each other for ease of edit. 
   
   There are two definitions, one for use in ASMWIN32.F, that builds NEXT and EXEC
   as macro: for use in assembled code; and one for META.F that builds NEXT and EXEC
   as macro definition for use in CODE and NCODE sections of FKERNEL.F.

   Fixed Loadpoint
   ---------------

     Fixed EXEC is
                        jmp     [eax]

     Fixed NEXT is
                        mov     eax, 0 [esi]
                        add     esi, # 4
                        jmp     [eax]
                        
     Fixed does NOT use EDI, as ORIGIN (or @ORIGIN @) of non-zero means that this
     has been built to load at that, AND ONLY THAT, address. It's much faster (25-30%)
     but cannot be moved in memory, and must be loaded at a specific address.
     
   EXE vs DLL
   ----------

   EXE files are loaded at specific addresses, and do not require relocation sections. Under
   all opsys except NT, this address is 0x00400000 (NT 0x00010000).
   
   DLLs require relocatability. Win32Forth doesn't yet build relocation sections for addresses
   so it's not possible to build them right now, as the loadpoint can be anywhere.

))

macro: exec ( assemble code to execute the cfa in eax )
                ( -- )
                /set-prefix >r
                jmp     [eax]
                r> reset-syntax
endm

macro: next ( assemble the code to do a next )
                ( -- )
                /set-prefix >r
                a; resolve-ofa          \ resolve the optimizer field address
                mov     eax, 0 [esi]
                add     esi, # 4 
                jmp     [eax]
                r> reset-syntax
endm

macro: br-next ( assemble the code to do a branch to next )
                ( -- )
                /set-prefix >r
                a; resolve-ofa          \ resolve the optimizer field address
                mov     esi, 0 [esi]
                mov     eax, -4 [esi]
                jmp     [eax]
                r> reset-syntax
endm

[undefined] META [IF] \ in ASMWIN32.F
\ is meta vocab undefined?

        cr .( Loading NEXT/EXEC ASM Support)

        macro: fcall ( a macro to assemble a call to callf )
               xchg    esp, ebp
               mov     eax, # '                \ set eax to word
               call    callf                   \ and call forth
               xchg    esp, ebp
        endm



[ELSE] \ in META.F

        cr .( Loading META NEXT/EXEC ASM Support)

        macro: fcall    ( a macro to assemble a call to callf )
               xchg    esp, ebp
               mov     eax, # '                \ set eax to word
               s" call    callf a;" evaluate
               xchg    esp, ebp
        endm
                 
[THEN] \ end of META.F



\ $Id: ASMWIN32.F,v 1.7 2013/11/15 19:35:02 georgeahubert Exp $

\ ASMWIN32.F      486ASM/Win32Forth Interface File

\ ASMWIN32.F beta 3.1A 2002/09/25 arm performance enhancements
\ ASMWIN32.F beta 3.3D 2002/10/08 Consolidation
\ arm 02/01/2005 21:28:34 factor macro[ ]macro to reduce postpone word count
\ arm 09/05/2005 20:16:11 incorrect override of data-, to code section removed

cr .( Loading 486ASM/Win32Forth Interface File...)

\ WARNING!!  THIS FILE IS A SUBSTANTIALLY MODIFIED VERSON OF THE FILE
\ OF THE SAME NAME THAT WAS DISTRIBUTED WITH JIM SCHNEIDER'S 486ASM
\ ASSEMBLER.  IF YOU UPDATE YOUR 486ASM SOURCE FILE WITH A MORE CURRENT
\ COPY IF JIM'S ASSEMBLER, BE SURE NOT TO UPDATE THIS FILE FROM HIS
\ 486ASM.ZIP ARCHIVE. August 2nd, 1996 Tom Zimmer

( FORTH for Windows 95 and NT specific macros )
( These macros are derived from code in Andrew McKewan and Tom Zimmer's )
( FORTH for Windows 95 and NT.  This file is public domain )
( This software is distributed as is, with no warranty whatsoever )
( This file version 1.1, first distributed with 486asm, version 1.1 )

also assembler also asm-hidden

: code-header   ( -- )
                header _header-ofa
                code-HERE CFAPTR! ;

forth ' code-c,     asm-hidden is code-c,     ( x -- )
forth ' code-w,     asm-hidden is code-w,     ( x -- )
forth ' code-,      asm-hidden is code-d,     ( x -- )
forth ' code-here   asm-hidden is code-here   ( -- a )
forth ' code-align  asm-hidden is code-align  ( -- )
forth ' code-header asm-hidden is code-header ( -- )

: resolve-ofa   ( -- )          \ resolve OFA to contain code length in bytes
                ofa-last code-d@
                if a;              \ save size of code definition
                  code-here ofa-last code-d@ - ofa-last code-d!
                then
                ;

: _opt-code     ( -<name>- )    \ redefine to resolve code length in bytes
                code-align
                _code
                code-here ofa-last code-d! \ init OFA with start of definition
                ;

' _opt-code is code

: _code>        ( -- ) \ create the ;code part of a low level defining word
        ?csp !csp postpone (;code)
        [ also forth ] code-align code-here , [ previous ]
        postpone [ init-asm ;

' _code> is ;code

warning @ warning off nostack1

: subr: sys-warning? >r sys-warning-off subr: r> to sys-warning? ;

warning !

defer ncode

: _nopt-code    code 0 ofa-last code-d! ;        \ zero the OFA

' _nopt-code is ncode           \ unoptimisable code

previous previous

FLOAD SRC\KERNEL\FKERNEXT.F     \ load exec/next words

macro: next,    ( -- )          \ an alias name for next
                next
                endm

macro: ptr      ( -- )          \ does nothing in this assembler
                endm

macro: c;       ( -- )          \ alias for ;c and end-code
                end-code
                endm

macro: [up]     ( n1 -- )       \ calculate offset for [edx]
                TCB - [edx]
                endm

macro: [up],    ( n1 -- )       \ calculate offset for [edx]
                TCB - [edx],
                endm

\ Top of stack macros

macro: TOS      ( -- )  EBX   endm
macro: [TOS]    ( -- ) [EBX]  endm
macro: TOS,     ( -- )  EBX,  endm
macro: [TOS],   ( -- ) [EBX], endm

macro: WinCall  ( "Proc" )
\ *G A macro: to call a windows procedure. The arguments must be pushed onto the system stack
\ ** beforehand and the return value is in eax. For calls with a C convention rather than
\ ** standard call the stack must be cleaned up.
              mov -4 [ebp], edx
              xor edx, edx
              call 0 Proc winproc-last @ proc>ep [edx]
              mov edx, -4 [ebp]
endm


also assembler also asm-hidden current @ also forth definitions nostack1

: (macro[) a; enter-macro ;
: (]macro) leave-macro a; ;

: macro[ ( create a macro in the assembler vocabulary )
        save-current also assembler definitions
        postpone (macro[) ; immediate

: ]macro ( end a macro definition )
        postpone (]macro)
        previous restore-current ; immediate

current ! previous previous previous

\ Everything below this line was added to support Tom Zimmer
\ It was diked out of 486asm.f and put here because it could make it
\ difficult to load the assembler as a cross assembler
\ 12/21/94 09:45 tjz added for Win32Forth
also assembler current @ definitions also asm-hidden nostack1

: _enter-assembler      ( -- )
               hide !csp init-asm ( code-here ofa-last code-d! ) ;

' _enter-assembler is enter-assembler

: _exit-assembler       ( -- )
                semicolon-chain do-chain ;

' _exit-assembler is exit-assembler

current ! previous previous


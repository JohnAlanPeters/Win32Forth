\ $Id: EXCEPTIO.F,v 1.11 2013/11/15 19:35:03 georgeahubert Exp $

\ EXCEPTIO.F            Exception Support               by Tom Zimmer
\
\ exceptio.f beta 4.0A 23/11/2002 arm Heavily modified, see notes
\ exceptio.f beta 4.0B 06/02/2003 arm Don't attempt recovery on EXCEPTION_GUARD_PAGE
\ exceptio.f beta 4.0C 21/02/2003 arm Try to allocate memory on write access violation

cr .( Loading Windows Exception...)

((

Exception Handling V4.0C
------------------------

    Exception handling now uses a process wide exception handler to trap all OS generated errors
    in Win32Forth. The sequence of events is as follows:

    1. Exception handler set by call to SET-EXCEPT
       SET-EXCEPT points to a callbnack IN-EXCEPT that does most of the work.

    2. Code executes, hits some error
       IN-EXCEPT gets called with 1 parameter. This points to two words:

          DWORD Exception Record
          DWORD Context Record

       The first is a "machine independent" record of the error, the second a copy of the machine
       state on entry.

    3. If the execption is GUARD_PAGE, then we just retry after incrementing a counter

    4. If the exception is ACCESS_VIOLATION, and this is a write error (not read!) then
       an attempt is made to VirtualAllocate the page that is faulting.

    5. If the attempt is succesful, retry at the point of failure. Otherwise, call HANDLE-EXCEPT

    6. HANDLE-EXCEPT saves both the exception and context records in a dynamic buffer,
       and points to them.

    7. Calls .EXCEPTION to print out the exception information

    8. Calls RECOVER-EXCEPT to attempt a recovery.
       RECOVER-EXCEPT emulates an "9998 THROW".

    9. Returns to OS to undertake the recovery.

Trapping Memory Write Errors
----------------------------

    This code supports RESERVEing memory using VirtualAlloc, without COMMITting it first.

    First, reserve a range of a process's virtual address space. Reserving address space
    does not allocate any physical storage, but it prevents other allocation operations
    from using the specified range. Reserving pages prevents needless consumption of
    physical storage, while allowing a process to reserve a range of its address space
    into which a dynamic data structure can grow. Reserved but uncommitted memory will
    cause ACCESS VIOLATIONS if it is addressed.

    Once the memory is then committed, it is backed by swap pages and is mapped into the
    virtual address space. Now it can be used (written and read).

    The support provided here allows storage be reserved only. If a block
    of storage is reserved, and it is then written to, the exception handler traps the
    error and automatically commits the memory and retries the failing instruction.

    For instance:

      PAGE_NOACCESS MEM_RESERVE 0x400000 0 CALL VirtualAlloc CONSTANT LARGEAREA

    This reserves but does not consume memory resources.

      10 LARGEAREA 0x4000 + !

    This causes an exception, the memory is COMMITed as PAGE_EXECUTE_READWRITE. Only the page
    (4K) at LARGEAREA 0x4000 + requires swap and memory resources.


Catching Errors
---------------

    The use of THROW makes it easy to catch system errors in code. For instance:

    : x -4 @ ; \ will cause an access exception
    : y ['] x catch if ." Error" else ." OK" then ;

    If you don't do a CATCH, then the last CATCH executed will be run.

    Here's some sample output:

      0 @ \ fetch from absolute zero

      EXCEPTION 0xC0000005 ACCESS_VIOLATION
      Version: 6.09.02
      Registers:
       Eax:         0040147C
       Ebx: TOS     00000000 top of stack
       Ecx:         0013748A
       Edx: USER    00127FB0 user area
       Edi:         00000000
       Esi: IP      0040F4C8 Forth ip
       Esp: SP@     00126F80 stack ptr
       Ebp: RP@     0012FF90 rstack ptr
       Eip: PC      00401480 machine ip
      Access addr:  00000000 READ violation
      Backtracking: CONSOLE-STATUSBAR-INTERPRET+0 QUERY-INTERPRET+2 CATCH+14 [UNKNOWN]+-1048578
      Data stack:   0 0 0 0
      Primitive     @  loaded from: SRC\FKERNEL.F at line: 488
      Invoking word CONSOLE-STATUSBAR-INTERPRET  loaded from: ...SRC\CONSOLE\CONSOLESTATBAR.F at line: 92
      fails at word _INTERPRET  loaded from: SRC\FKERNEL.F at line: 4238

    For TURNKEYed applications, only the registers are shown.

User Words
----------

    .EXCEPTION                  Show the results of the last exception executed
    .EXCEPTION-CODE             Show just the exception code
    CLEAR-EXCEPTION             Clear the exception
    UNSET-EXCEPTION             Suspend exception processing, will return to OS on error
    SHOW-EXCEPTION ON | OFF     Turn the output from an exception on or off (on is default)
    RECOVER-EXCEPTION ON | OFF  Recover from exception. ON is default, OFF will return to OS
    EXCEPT-IO                   Defered word to redirect error io.

))

only forth also definitions

IN-APPLICATION

1  CONSTANT EXCEPTION_EXECUTE_HANDLER    \ no longer in wincon.dll, now macros in
0  CONSTANT EXCEPTION_CONTINUE_SEARCH    \ windows
-1 CONSTANT EXCEPTION_CONTINUE_EXECUTION

9998  CONSTANT   THROW_WINEXCEPT           \ " Windows exception trapped"
THROW_MSGS LINK, THROW_WINEXCEPT          , ," Windows exception trapped"

DEFER EXCEPT-IO                                     \ where print exception goes

INTERNAL

: (except-io) ;                                     \ basic forth io

' (except-io) is EXCEPT-IO

0       nostack1                                    \ exception record
        cell  field+ ExceptionCode
        cell  field+ ExceptionFlags
        cell  field+ ExceptionRecord
        cell  field+ ExceptionAddress
        cell  field+ ExceptionNumParms
        cell  field+ ExceptionParms
        14 cells+ constant ExceptionRecLen

0       nostack1                                    \ context record
        cell  + \ field+ ContextFlags
        cell  + \ field+ Dr0
        cell  + \ field+ Dr1
        cell  + \ field+ Dr2
        cell  + \ field+ Dr3
        cell  + \ field+ Dr6
        cell  + \ field+ Dr7
        0     + \ field+ FloatSaveArea
        cell  + \ field+ FloatControl
        cell  + \ field+ FloatStatus
        cell  + \ field+ FloatTag
        cell  + \ field+ FloatErrorOffset
        cell  + \ field+ FloatErrorSelector
        cell  + \ field+ FloatDataOffset
        80    + \ field+ FloatDataSelector
        cell  + \ field+ FloatRegisterArea
        cell  + \ field+ FloatCr0NpxState
        cell  + \ field+ SegGs
        cell  + \ field+ SegFs
        cell  + \ field+ SegEs
        cell  + \ field+ SegDs
        cell  field+ Edi
        cell  field+ Esi
        cell  field+ Ebx
        cell  field+ Edx
        cell  field+ Ecx
        cell  field+ Eax
        cell  field+ Ebp
        cell  field+ Eip
        cell  + \ field+ SegCs
        cell  + \ field+ EFlags
        cell  field+ Esp
        cell  + \ field+ SegSs
            constant ContextRecLen

0       nostack1                                    \ our save area
        ExceptionRecLen field+ ExceptRecOffset
        ContextRecLen   field+ ContextRecOffset
        cell            field+ UPSaveOffset
        cell            field+ EBP@SaveOffset
        cell            field+ ExceptHandler
        5 cells         field+ RP@STACKSaveOffset
        4 cells         field+ SP@STACKSaveOffset
            constant ExceptBufflen

: except-buffer ( -- a1 )                     \ return the address of the
                &exrec @ ExceptRecOffset ;    \ exception handlers exception buffer

: context-buffer ( -- a1 )                    \ return the address of the
                &exrec @ ContextRecOffset ;   \ exception handlers context buffer

: UPSave-buffer ( -- a1 )                    \ return the address of the
                &exrec @ UPSaveOffset ;      \ save area for UP

: ebp@save-buffer ( -- a1 )                   \ return the address of the
                &exrec @ EBP@SaveOffset ;     \ save area for ebp@

cell NewUser (?exceptioning)

: ?exceptioning ( -- f )
                (?exceptioning) @ ;           \ detect recursive call to handler

1 PROC SetUnhandledExceptionFilter

EXTERNAL

cell NewUser show-exception                   \ show exception?

cell NewUser recover-exception                \ recover from exception?

: Init-Except-Users ( -- )
                (?exceptioning) off show-exception on recover-exception on ;

Init-Except-Users

initialization-chain chain-add Init-Except-Users

: .exception-code ( -- )                      \ get the last exception
    cr ." EXCEPTION " exception@ dup ." 0x" h.8 ."  "
    case
      EXCEPTION_ACCESS_VIOLATION          of ." ACCESS_VIOLATION"         endof
      EXCEPTION_INT_DIVIDE_BY_ZERO        of ." INT_DIVIDE_BY_ZERO"       endof
      EXCEPTION_FLT_DIVIDE_BY_ZERO        of ." FLT_DIVIDE_BY_ZERO"       endof
      EXCEPTION_FLT_STACK_CHECK           of ." FLT_STACK_CHECK"          endof
      EXCEPTION_FLT_INEXACT_RESULT        of ." FLT_INEXACT_RESULT"       endof
      EXCEPTION_FLT_UNDERFLOW             of ." FLT_UNDERFLOW"            endof
      EXCEPTION_FLT_DENORMAL_OPERAND      of ." FLT_DENORMAL_OPERAND"     endof
      EXCEPTION_FLT_INVALID_OPERATION     of ." FLT_INVALID_OPERATION"    endof
      EXCEPTION_FLT_OVERFLOW              of ." FLT_OVERFLOW"             endof
      EXCEPTION_ILLEGAL_INSTRUCTION       of ." ILLEGAL_INSTRUCTION"      endof
      EXCEPTION_DATATYPE_MISALIGNMENT     of ." DATATYPE_MISALIGNMENT"    endof
\     EXCEPTION_GUARD_PAGE                of ." GUARD_PAGE"               endof
      EXCEPTION_BREAKPOINT                of ." BREAKPOINT (INT 3)"       endof
\     EXCEPTION_SINGLE_STEP               of ." SINGLE_STEP"              endof
\     EXCEPTION_NONCONTINUABLE            of ." NONCONTINUABLE"           endof
      EXCEPTION_PRIV_INSTRUCTION          of ." PRIV_INSTRUCTION"         endof
\     EXCEPTION_IN_PAGE_ERROR             of ." IN_PAGE_ERROR"            endof
\     EXCEPTION_STACK_OVERFLOW            of ." STACK_OVERFLOW"           endof
\     EXCEPTION_INVALID_DISPOSITION       of ." INVALID_DISPOSITION"      endof
\     EXCEPTION_ARRAY_BOUNDS_EXCEEDED     of ." ARRAY_BOUNDS_EXCEEDED"    endof
\     EXCEPTION_NONCONTINUABLE_EXCEPTION  of ." NONCONTINUABLE_EXCEPTION" endof
      EXCEPTION_INT_OVERFLOW              of ." INT_OVERFLOW"             endof
      EXCEPTION_INVALID_HANDLE            of ." INVALID_HANDLE"           endof
    endcase
    ;

: clear-exception ( -- )                     \ clear any previous exception
                &except off ;

INTERNAL

IN-SYSTEM

: .exname       ( addr -- )         \ only available in non-turnkeyed apps
                ?name dup .NAME
                $.viewinfo drop
                drop ;

: except-rstack ( a1 -- )
                cr ." Backtracking: "
                dup 4 cells+ swap
                ?do     i @ ?name ?dup
                        if      i @ here u<
                                if      dup >name nfa-count type
                                        i @
                                        swap >body - cell / 1- ." +" h.
                                else    h.
                                then
                        else    i @ h.
                        then    12 ?cr
                cell +loop  ;

IN-APPLICATION

: except-sstack ( a1 -- )                    \ print off the return stack
                cr ." Data stack:   "
                dup 3 cells+
                ?do i @ h.
                -cell +loop  ;

: .exregs       ( n -- )
                @ 14 col h.8  ;

: except-presskey ( -- )
                main? if cr ." Press any key to exit..." wait then ; \ Only wait for main (console) task.

EXTERNAL

: .exception    ( -- )                               \ print exception info
                exception@ 0=
        if      cr ." * No exception has occurred *"
        else    forth-io
                cr .exception-code
                .version
                context-buffer

                cr ." Registers:"
                cr ."  Eax:"       dup Eax .exregs
                cr ."  Ebx: TOS"   dup Ebx .exregs ."  top of stack"
                cr ."  Ecx:"       dup Ecx .exregs
                cr ."  Edx: USER"  dup Edx .exregs ."  user area"
                cr ."  Edi:"       dup Edi .exregs
                cr ."  Esi: IP"    dup Esi .exregs ."  Forth ip"
                cr ."  Esp: SP@"   dup Esp .exregs ."  stack ptr"
                cr ."  Ebp: RP@"   dup Ebp .exregs ."  rstack ptr"
                cr ."  Eip: PC"    dup Eip .exregs ."  machine ip"

                EXCEPTION_ACCESS_VIOLATION exception@ =
                if
                   cr ." Access addr:"
                   except-buffer exceptionparms cell+ .exregs
                   except-buffer exceptionparms @
                   0= if ."  READ" else ."  WRITE" then ."  violation"
                then

                TURNKEYED? IF DROP EXIT THEN

\IN-SYSTEM-OK   &exrec @ RP@STACKSaveOffset except-rstack
                &exrec @ SP@STACKSaveOffset except-sstack

\IN-SYSTEM-OK   cr ." Primitive     " dup Eip  @  .exname
\IN-SYSTEM-OK   cr ." Invoking word " ebp@save-buffer @   .exname
\IN-SYSTEM-OK   cr ." fails at word " dup Esi  @  .exname

                cr drop

        then    ;

INTERNAL

: RECOVER-EXCEPT ( con-ptr -- n )                     \ recovery handler, modify registers for retry
                ['] THROW dup>r  over eax !           \ get address of throw
                r> @             over eip !           \ point at docol
                THROW_WINEXCEPT  over ebx !           \ exception to top of stack for throw
                UP@ over edx !                        \ restore UP from Thread Local Storage
                drop EXCEPTION_CONTINUE_EXECUTION  ;  \ attempt recovery

: HANDLE-EXCEPT ( ex-ptr -- ropt )                    \ Error routine called by OS, save & setup
            except-io
            ?exceptioning                             \ catch errors on error routine
            if      cr ." Recursive Exception" except-presskey
                    EXCEPTION_CONTINUE_SEARCH
                    exit                              \ terminate exception
            then
            (?exceptioning) on
            dup @ dup>r @                             \ get the exception code
            &except !                                 \ save exception for later
            r>                                        \ fetch exception record
            except-buffer ExceptionRecLen move        \ save it
            dup cell+ @ dup>r                         \ fetch context record
            context-buffer ContextRecLen move         \ save the context record
            context-buffer ebp @ dup>r                \ get ebp from new context stack
            &exrec @ RP@STACKSaveOffset 4 cells move  \ move rstack
            context-buffer esp @                      \ get ebp from new context stack
            &exrec @ SP@STACKSaveOffset 4 cells move  \ move stack
            r> @ EBP@Save-Buffer !                    \ save what ebp points at
            show-exception @ if .exception then       \ call exception print
            recover-exception @ if
              r> recover-except >r                    \ attempt recovery
            else
              r>drop EXCEPTION_CONTINUE_SEARCH >r     \ no recovery
            then
            (?exceptioning) off                       \ no longer exceptioning
            show-exception @ if except-presskey then  \ wait if we're showing...
            r>                                        \ recover? from recovery option
            ;

1 callback &IN-EXCEPT HANDLE-EXCEPT

EXTERNAL

: Allocate-Except-Buffer  ( -- )
             ExceptBufflen malloc &exrec ! ;          \ get a buffer for the context

: Release-Except-Buffer   ( -- )
             &exrec @ ?dup if ( release ) free drop &exrec off then ;

: SET-EXCEPT ( -- )                                   \ set exception routine handler
             Allocate-Except-Buffer
             &IN-EXCEPT call SetUnhandledExceptionFilter
             &exrec @ ExceptHandler !                 \ save exception handler
             up@ &exrec @ UPSaveOffset !              \ save UP for recovery
             ;

: UNSET-EXCEPT ( prev-except-addr -- )                \ unset exception routine
             &exrec @ ?dup if ExceptHandler @         \ get old exception handler
             call SetUnhandledExceptionFilter drop
             Release-Except-Buffer then ;             \ clear execution record address

INTERNAL

set-except

initialization-chain chain-add set-except
unload-chain chain-add unset-except

MODULE

only forth also definitions

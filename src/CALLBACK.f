\ $Id: CALLBACK.f,v 1.20 2014/08/06 12:30:30 georgeahubert Exp $

\ CALLBACK.F    Windows Callback support                by Tom Zimmer
\ arm 21/12/2004 21:21:09 Callback support -- moved out of kernel
\ arm 15/08/2005 20:01:54 n callback -- n is now max of 19 args

\ *D doc
\ *! p-callback
\ *T Windows Callback support

\ *P The Windows operating system DLLs often needs application defined callbacks to be
\ ** supplied for certain jobs. Since it is written in C then it assumes the callback only
\ ** needs a single stack to work with, so Win32Forth must wrap a Forth word to allocate a
\ ** second stack and transfer the input arguments to it. It also sets up other registers
\ ** for Forth, including the USER pointer for the calling Task (Versions of Win32Forth prior
\ ** to V6.06.xx always used the CONUSER pointer for this so callbacks were restricted to the
\ ** main (console) task only). It is important to remember a normal xt will not work as a callback.

\ *P Win32Forth now supports assynchronous callbacks (since V6.16.xx) as used in the multi media (Winmm)
\ ** API. Since these create a new thread Win32Forth creates a USER area the first time it runs and leaves
\ ** space for it subsequently. NOTE versions up to V6.04.xx could run assynchronous callbacks, but since
\ ** they shared the main tasks USER area they had restrictions on use of LOCALs USER variables etc. These
\ ** restrictions no longer apply.

\ *S Glossary

cr .( Loading Windows Callback...)

IN-APPLICATION

\ CALLBACK-RETURN and CALLBACK-BEGIN restore and save regs, set up EBP and ESP
\ BUILD-CALLBACK uses ECX as parm count, ret count on stack -- __CDECL sets to zero

NCODE CALLBACK-RETURN                           \ w32f intern
\ General return code, restores all but ecx!
                code-here cell+ code-,          \ make an ITC
                mov     eax, ebx                \ return value
                mov     esp, ebp
                pop     SP0 [UP]
                pop     esi
                pop     edi
                pop     ebx
                pop     ebp
                pop     ecx                     \ count
                lea     ecx, 1234 [ecx] [ecx*2] \ calculate jump offset (4 byte lea version!)
  a; code-here cell-                            \ point at the offset in lea
                jmp     ecx                     \ back to caller
  a; code-here swap !                           \ correct the lea calculation
                ret     nop nop                 \ 3 bytes long ret
                ret     1 cells
                ret     2 cells
                ret     3 cells
                ret     4 cells
                ret     5 cells
                ret     6 cells
                ret     7 cells
                ret     8 cells
                ret     9 cells
                ret     10 cells
                ret     11 cells
                ret     12 cells
                ret     13 cells
                ret     14 cells
                ret     15 cells
                ret     16 cells
                ret     17 cells
                ret     18 cells
                ret     19 cells
                c;

CFA-CODE CALLBACK-BEGIN                         \ w32f intern
\ General start code, don't disturb EAX!
                push    ebp                     \ save regs, return count is already on the stack
                push    ebx
                push    edi
                push    esi
                xor     edi, edi                \ edi is constant 0
                mov     edx, fs: 0x14           \ edx is now ptr TIB pvArbitrary
                test    edx, edx                \ test for async callback
                jnz L$1
                push    # 0
                mov     ebp, esp
                sub     esp, # 4096 32 -        \ room for return stack (Not RSTACKSIZE, please!)
                and     esp, # -16              \ align to 16 byte boundary
                sub     esp, # USERSIZE
                mov     edx, esp
                mov     fs: 0x14 , edx
                sub     esp, # 32
                mov     SP0 [UP]  , esp         \ reset SP0
                and     useroffs negate [edx] , # Assync-task
                jmp L$2
L$1:            push    SP0 [UP]                \ save sp0 on stack
                mov     ebp, esp
                sub     esp, # 4096 32 -        \ room for return stack (Not RSTACKSIZE, please!)
                and     esp, # -16              \ align to 16 byte boundary
                mov     SP0 [UP]  , esp         \ reset SP0
                mov     ebx, useroffs negate [edx]
                and     ebx, # Assync-Task
                test    ebx, # Assync-Task
                jz L$2
                sub     esp, # USERSIZE 32 +
L$2:            lea     ebx, 7 19 - cells [ebp] [ecx*4] \ adjust ebx
                neg     ecx                     \ negate ecx
                lea     ecx, 1234 [ecx] [ecx*2] \ calculate jump offset (4 byte lea version!)




  a; code-here cell-                            \ point at the offset (the 1234) in lea
                jmp     ecx                     \ and leap...
  a; code-here 19 3 * + swap !                  \ correct the lea calculation
                push ( 0 cells) [ebx] nop       \ 19 callback, nop for short from
                push    1 cells [ebx]           \ all entries 3 bytes
                push    2 cells [ebx]
                push    3 cells [ebx]
                push    4 cells [ebx]
                push    5 cells [ebx]           \ 2 callback
                push    6 cells [ebx]
                push    7 cells [ebx]
                push    8 cells [ebx]
                push    9 cells [ebx]
                push    10 cells [ebx]
                push    11 cells [ebx]
                push    12 cells [ebx]
                push    13 cells [ebx]
                push    14 cells [ebx]
                push    15 cells [ebx]
                push    16 cells [ebx]
                push    17 cells [ebx]          \ 2 callback
                push    18 cells [ebx]          \ 1 callback
                pop     ebx                     \ 0 callback -- recover ebx

                mov     esi, # ' callback-return
                exec    c;                      \ go for it

IN-SYSTEM

variable __CDECLV 0 __CDECLV !                  \ for __cdecl type callbacks

: __STDCALL     ( -- )                          \ w32f sys
\ *G Turn on stdcall type callback (the default).
                ; IMMEDIATE

: __CDECL       ( -- )                          \ w32f sys
\ *G Turn on __cdecl type callback for the next callback only.
                __CDECLV ON ;

: BUILD-CALLBACK ( n1 -- a1 a2 )                \ w32f sys
\ Define a callback procedure.
                dup 20 0 within abort" Argument value too large for callback."
                >r                              \ generated via macro[ ]macro
                code-here                       \ func address (a1)
                macro[   mov  eax, # 1234       \ mov eax, # cfa to execute
                         mov  ecx, # r@         \ mov ecx, # args
                         push                   \ push something
                  __cdeclv @ if
                    __cdeclv off                \ turn off cdecl
                              # 0               \ if __cdecl, push # 0
                  else
                              ecx               \ else push # args
                  then   jmp  callback-begin
                ]macro
                r>drop dup 2 +                  \ cfa address (a2)
                ;

: CALLBACK      ( n "name" "function" -- )        \ w32f sys
\ *G Define a callback with "name" that has n arguments.
\ ** "name" will return the address of the callback at runtime.
\ *P Note that a maximum of 19 arguments is supported by Win32Forth.
                BUILD-CALLBACK >R CONSTANT ' R> ! ;

: CALLBACK:     ( n "name" -- )               \ w32f sys
\ *G Define a callback function that has n arguments.
\ *P CALLBACK: creates TWO definitions! The first has the name you specify,
\ ** and the second has the same name, prefixed with a '&' meaning 'address of'
\ ** This second definition is the one which returns the address of the callback,
\ ** and must be passed to Windows.
\ *P Note that a maximum of 19 arguments is supported by Win32Forth.
                BUILD-CALLBACK >R                     \ the callback structure has a header
                MAXSTRING _LOCALALLOC >R              \ use a dynamic string buffer
                S" &"      R@  PLACE
                >IN @ BL WORD COUNT R@ +PLACE
                >IN !                                 \ get a copy of next word in input stream
                R> COUNT ['] constant execute-parsing \ make a constant starting with '&'
                _LOCALFREE
                :                                     \ build the colon definitions starting structure
                HERE CELL- R> !                       \ patch callback structure
                ;

IN-APPLICATION

\ *************************************************************************
\ *S An example of how to use a callback
\ *************************************************************************

\ *P The "EnumFonts" windows call requires an application callback that will be
\ ** called repeatedly to process each font in the system. We are just
\ ** displaying the fonts, so we just look at the "dwType" to decide how to
\ ** display each font.

4 PROC EnumFonts \ must be in-application for WinEd !!!

IN-SYSTEM

\ *+

4 CallBack: FontFunc { lplf lptm dwType lpData -- int }
\ The callback function for EnumFonts() used by .FONTS to dump
\ all installed fonts to the console window.
\ This callback as specified by "EnumFonts" passes four (4) parameters to
\ the callback procedure, so we must say "4 CallBack: FontFunc" to define
\ a callback that accepts four parameters.
                cr
                dwType
                dup TRUETYPE_FONTTYPE and
                IF      ."     "
                ELSE    ." Non-"
                THEN    ." TrueType "
                dup RASTER_FONTTYPE and
                IF      ." Raster "
                ELSE    ." Vector "
                THEN
                DEVICE_FONTTYPE and
                IF      ." Device "
                ELSE    ." GDI    "
                THEN
                lplf 28 + LF_FACESIZE 2dup 0 scan nip - type
                cr 5 spaces
                lplf dup @ 4 .r                 \ height
                4 + dup @ 4 .r                  \ width
                4 + dup @ 6 .r.1                \ escapement angle
                4 + dup @ 6 .r.1                \ orientation angle
                4 + dup @ 4 .r                  \ weight
                4 + dup c@ 1 and 2 .r           \ italics
                1 + dup c@ 1 and 2 .r           \ underline
                1 + dup c@ 1 and 2 .r           \ strike-out
                1 + dup c@ 4 .r                 \ character set
                1 + dup c@ 2 .r                 \ output precision
                1 + dup c@ 4 .r                 \ clip precision
                1 + dup c@ 2 .r                 \ output quality
                1 +     c@ 4 h.r                \ family and pitch
                1 ;  \ return "1=success" flag to windows

: .fonts        ( -- )          \ w32f sys
\ *G Dump all installed Fonts to the console window.
\ The callback name is passed to windows as shown.
                cr 5 spaces
                ."   ht wide  esc  ornt wt  I U S set p  cp q  fp"
                0
                &FontFunc \ here it goes...
                0 conDC Call EnumFonts drop ;

\ *-

IN-APPLICATION

\ *W <hr>Document : Dexh-HelpDexH.htm -- 2007/06/27 -- win32forth team

\ *Z


\ $Id: meta-fkernel.f,v 1.12 2013/11/15 19:35:04 georgeahubert Exp $

\ Win32 Forth Metacompiler
\ Andrew McKewan, November 1995
\ Many thanks to Henry Laxen & Michael Perry for F83
\ for version changes, see version.f

cr .( Loading META FKERNEL Wrapper)

((
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*NOTICE**NOTICE**NOTICE**NOTICE**NOTICE**NOTICE**NOTICE**NOTICE**NOTICE*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

August 27th, 1996 - 13:44 tjz

NOTICE: Rather than modifying this file, to change the Forth dictionary
        available memory, use the NEW commandline method as follows;

        WIN32FOR.EXE FLOAD META.F SETSIZE BYE

        The above commandline, including the RESIZE parameter, will
        cause you to be prompted for the size of the application and
        system dictionaries you want in the new kernel.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
))

\ SYS-WARNING-OFF         \ don't warn about use of system words

ONLY FORTH ALSO DEFINITIONS ALSO VIMAGE

WARNING OFF
SYS-WARNING-OFF

: SETSIZE ;      \ must be findable, but doesn't do anything

KERN-VER $FLOAD      \ GET KERNEL VERSION
KERN-DLG $FLOAD      \ load new save dialog

331 CONSTANT #THREADS                        \ # of threads in FORTH-WORDLIST
 17 CONSTANT #PTHREADS                       \ # of threads in PROCS lexicon
  1 CONSTANT #FTHREADS                       \ # of threads in FILES lexicon
 31 CONSTANT #HTHREADS                       \ # of threads in HIDDEN lexicon

1256000 0x1000 naligned constant MINAPPMEM  \ minimum size of kernel application dictionary
  40960 0x1000 naligned constant MINCODEMEM \ minimum size of kernel code dictionary
1024000 0x1000 naligned constant MINSYSMEM  \ minimum size of kernel system dictionary

APP-SIZE  MINAPPMEM  max 0x1000 naligned TO IMAGE-ASIZE  \ size of kernel application dictionary
CODE-SIZE MINCODEMEM max 0x1000 naligned TO IMAGE-CSIZE  \ size of kernel data dictionary
SYS-SIZE  MINSYSMEM  max 0x1000 naligned TO IMAGE-SSIZE  \ size of kernel system dictionary


: PROMPT-SIZE   ( -<"SETSIZE">- )  \ if SETSIZE follows on commandline
                                   \ open the "Win32Forth Meta Compiler" dialog
                CMDLINE S" SETSIZE" CAPS-SEARCH NIP NIP
                IF
                        MINCODEMEM SetDefCodeMem: META-DIALOG
                        MINAPPMEM  SetDefAppMem: META-DIALOG
                        MINSYSMEM  SetDefSysMem: META-DIALOG

                        IMAGE-CSIZE SetCodeMem: META-DIALOG
                        IMAGE-ASIZE SetAppMem: META-DIALOG
                        IMAGE-SSIZE SetSysMem: META-DIALOG

                        CONHNDL START: META-DIALOG
                        IF      GETAPPMEM: META-DIALOG MINAPPMEM MAX
                                0x1000 naligned TO IMAGE-ASIZE
                                GETSYSMEM: META-DIALOG MINSYSMEM MAX
                                0x1000 naligned TO IMAGE-SSIZE
                                GETCODEMEM: META-DIALOG MINCODEMEM MAX
                                0x1000 naligned TO IMAGE-CSIZE
                        else    bye \ canceled by user
                        THEN
                THEN    ;

PROMPT-SIZE

0                         STD-HEADLEN + TO IMAGE-CSEP \ separations
IMAGE-CSIZE               STD-HEADLEN + TO IMAGE-ASEP
IMAGE-ASIZE IMAGE-CSIZE + STD-HEADLEN + TO IMAGE-SSEP

CR
CR .( Build information ) .month,day,year .(  ) .time
CR .(   Directory:    ) CURRENT-DIR$ COUNT TYPE
CR .(   Source:       ) KERN-SRC  COUNT TYPE
CR .(   NEXT macros:  ) KERN-NEXT COUNT TYPE
CR .(   Version from: ) KERN-VER  COUNT TYPE
CR .(   Version:      ) #version# ((version)) type
   .(  Build: ) #build# .
CR .(   Build Image:  ) KERN-NAME COUNT TYPE
   .(  Type: ) Z" GUI CUI DLL " EXETYPE 1- CELLS+ 4 TYPE
CR CR .( Compiling... ) time-reset

((
*** NOTE From this point on, everything is meta compiled!
))

KERN-CMP $FLOAD               \ load the compiler

KERN-NEXT $FLOAD              \ load kernel extension for NEXT, EXEC code

NOSTACK

\ ======================= COMPILED CODE =============================

KERN-SRC  $FLOAD              \ load the kernel source

\ ===================== END COMPILED CODE ===========================

\ NOTE: We're still in compile mode, only runtime after this

\ Resolve metacompiler forward references
' (.")          RESOLVES <(.")>
' (S")          RESOLVES <(S")>
' (C")          RESOLVES <(C")>
' (ABORT")      RESOLVES <(ABORT")>
' (IS)          RESOLVES <(IS)>
' (;CODE)       RESOLVES <(;CODE)>
' "HEADER       RESOLVES <VHEAD>  \ use VHEAD to build the header in std vocab
' (SEARCH-WID)  RESOLVES <VSRCH>  \ use VSRCH to search the header
ASSEMBLER DOVOC META RESOLVES <VOCABULARY>
\ ' COMPILE, RESOLVES <COMPILE,>  \ work in progress

\ Initialize variables
DEFER-LIST-T @ DEFER-LIST tsys-!                  \ correct links from meta to target
PROC-LIST-T @ WINPROC-LINK t-!
LIBS-LIST-T @ WINLIB-LINK t-!
VOC-LINK-T @ VOC-LINK t-!

' FILES 6 CELLS+                                \ correct the vocabs
  FILES-THREADS SWAP tsys-there #FTHREADS CELLS MOVE \ move the threads
\ ' PROCS 6 CELLS+                                \ correct the vocabs
\   PROCS-THREADS SWAP tsys-there #PTHREADS CELLS MOVE \ move the threads
' HIDDEN 6 CELLS+                                \ correct the vocabs
  HIDDEN-THREADS SWAP tsys-there #HTHREADS CELLS MOVE \ move the threads
' ROOT 6 CELLS+                                \ correct the vocabs
  ROOT-THREADS   SWAP tsys-there           CELL MOVE \ move the threads
' FORTH 6 CELLS+                                \ correct the vocabs
  FORTH-THREADS OVER tsys-there #THREADS CELLS MOVE \ move the threads
  DUP CURRENT t-!                              \ set current & context
  DUP CONTEXT t-!
      CONTEXT CELL+ t-!
'T LOCALS 6 CELLS+ OFF  \ clean the locals vocab

\ Calculate lengths of sections to write
tapp-here IMAGE-ORIGIN IMAGE-ASEP + - TO IMAGE-AACTUAL
tsys-here IMAGE-ORIGIN IMAGE-SSEP + - TO IMAGE-SACTUAL
tcode-here IMAGE-ORIGIN IMAGE-CSEP + - TO IMAGE-CACTUAL

\  CELL OFFSET  FUNCTION
\  ---- ------  --------
\   0     0     Current pointer to area
\   1     4     Address of the area (origin)
\   2     8     Highest address of area (origin + length)
tapp-here ADP t-!                                 \ init the data pointers
tsys-here SDP t-!
tcode-here CDP t-!

IMAGE-ORIGIN IMAGE-ASEP + ADP CELL+ t-!
IMAGE-ORIGIN IMAGE-SSEP + SDP CELL+ t-!
IMAGE-ORIGIN IMAGE-CSEP + CDP CELL+ t-!

IMAGE-ORIGIN IMAGE-ASEP + IMAGE-ASIZE + ADP 2 CELLS+ t-!
IMAGE-ORIGIN IMAGE-SSEP + IMAGE-SSIZE + SDP 2 CELLS+ t-!
IMAGE-ORIGIN IMAGE-CSEP + IMAGE-CSIZE + CDP 2 CELLS+ t-!

EXEM IMAGE-ORIGIN - TO IMAGE-ENTRY          \ entry point

IMAGE-CSIZE ' CODE-SIZE >BODY t-!   \ initialise the constants in the kernel
IMAGE-CSEP  ' CODE-OFFS >BODY t-!
IMAGE-ASIZE ' APP-SIZE  >BODY t-!
IMAGE-ASEP  ' APP-OFFS  >BODY t-!
IMAGE-SSIZE ' SYS-SIZE  >BODY t-!
IMAGE-SSEP  ' SYS-OFFS  >BODY t-!
IMAGE-ENTRY ' IMG-ENTRY >BODY t-!


\ Make sure words all resolved
.UNRESOLVED [IF] CR C" *** Errors in compile" ABORT!
            [ELSE]
              cr .( Compilation complete)
              cr IMAGE-STATS
              IMAGE-SAVE [IF]
                KERN-NAME COUNT STD-IMG2EXE
              [THEN]
            cr .elapsed cr
            [THEN]


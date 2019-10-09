\ $Id: Accel.f,v 1.6 2008/09/02 06:46:26 camilleforth Exp $

\ ---------------------------------------------------------------------------
\ ACCEL.F
\ Windows Accelerator Table support for Win32Forth
\
\ Written by Dirk Busch (dbu)
\            eMail: dirkNO@SPAMwin32forth.org
\                       ^^ ^^^^ remove this
\
\ Version 1.0 May 17th, 2003 - 21:30
\ Version 1.1 May 22nd, 2003 - 17:54
\ Version 1.2 (for Win32Forth 6.07.07 and later) August 30th, 2003 dbu
\ Version 1.3 (for Win32Forth 6.09.12 and later) Samstag, September 11 2004
\ ---------------------------------------------------------------------------

cr .( Windows Accelerator Table support...)


\ ---------------------------------------------------------------------------
\ helper words
\ ---------------------------------------------------------------------------


\ ---------------------------------------------------------------------------
\ Debug support
\ ---------------------------------------------------------------------------

in-system

0 value Debug-Accelerator-Table-Support

: Dump-Accelerator-Key-Table { addr -- }
        cr ." Accelerator-Key-Table:"
        addr cell+ addr @ 0
        do
                dup i 10 * +
                cr
                dup        8 h.R SPACE
                dup     c@ 2 h.R SPACE
                dup 2 + w@ 4 h.R SPACE
                dup 4 + w@ 4 h.R SPACE
                    6 +  @ >NAME .ID
        loop    drop cr
;

: Dump-Windows-Accelerator-Key-Table ( addr count -- )
        cr ." Windows-Accelerator-Key-Table:"
        over swap 0
        do
                dup i 6 * +
                cr
                dup        8 h.R SPACE
                dup     c@ 2 h.R SPACE
                dup 2 + w@ 4 h.R SPACE
                    4 + w@ 4 h.R SPACE
        loop    2drop cr
;

in-application

0 value ACCEL-HNDL
variable ACCEL-PTR

\ ---------------------------------------------------------------------------
\ compiling accelerator table into dictionary
\ ---------------------------------------------------------------------------
1 constant FVIRTKEY \ yet another missing Windows constant

: ACCELTABLE ( -- <-name-> )
        CREATE HERE 0 ,  NOSTACK1 ;

: ACCELENTRY { flags key-code cmd-id xt -- }
        flags FVIRTKEY or FNOINVERT or c, 0 c,
        key-code w, cmd-id w, xt , ;

: ACCELEND ( -- )
        HERE OVER - 10 ( table entry length ) / SWAP ! ;

\ ---------------------------------------------------------------------------
\ Create and destroy  Windows Accelerator Table
\ ---------------------------------------------------------------------------
: Destroy-Accelerator-Table ( -- ) \ destroy's the Windows Accelerator Table
        ACCEL-HNDL 0<>
        if ACCEL-HNDL call DestroyAcceleratorTable drop then
        0 to ACCEL-HNDL
        ACCEL-PTR OFF
;

: Create-Accelerator-Table { addr \ addr2 -- } \ takes the Accelerator-Key-Table and builds a Windows Accelerator Table

        Destroy-Accelerator-Table

\ debug stuff ------
                Turnkeyed? 0=
\IN-SYSTEM-OK   if   Debug-Accelerator-Table-Support
\IN-SYSTEM-OK        if   addr Dump-Accelerator-Key-Table
\IN-SYSTEM-OK   then
                then
\ ------------------

        addr ACCEL-PTR !

        \ Copy the Accelerator-Key-Table to a buffer
        addr @ 6 * MALLOC to addr2
        addr cell+ addr2                ( addr' addr2 )
        addr @ 0                        ( addr' addr2 do loop )
        do                              ( addr' addr2 )
                2dup 6 cmove
                swap 10 + swap 6 +
        loop    2drop

\ debug stuff ------
                Turnkeyed? 0=
\IN-SYSTEM-OK   if   Debug-Accelerator-Table-Support
\IN-SYSTEM-OK        if   addr2 addr @ Dump-Windows-Accelerator-Key-Table
\IN-SYSTEM-OK        then
                then
\ ------------------

        \ Create the Accelerator Table from the global memory handle
        addr @ addr2                ( count addr2 )
        call CreateAcceleratorTable ( hAccelTable )

        \ free buffer
        addr2 RELEASE

        dup to ACCEL-HNDL
        0= if Destroy-Accelerator-Table then
;


\ ---------------------------------------------------------------------------
\ handle accelerator key
\ ---------------------------------------------------------------------------
: Get-Accelerator-Table-Entry { addr cmd-id \ table-offset -- table-offset >= 0 }
        -1 to table-offset
        addr cell+ \ move to first table entry
        addr @ 0
        do      i 10 * 4 + \ addr' offset
                over + w@  \ addr' cmd-id'
                cmd-id =   \ addr' flag
                if i to table-offset leave then
        loop    drop table-offset
;

: Is-Accelerator-Key ( addr cmd-id -- flag )
        Get-Accelerator-Table-Entry 0 >=
;

: Get-Accelerator-Key-CFA { addr cmd-id -- cfa }
        addr cmd-id Get-Accelerator-Table-Entry
        10 * 6 + addr cell+ + @
;

: Handle-Key-Table ( cmd-id -- true | false )
        ACCEL-PTR @ swap
        2dup Is-Accelerator-Key
        if
                Get-Accelerator-Key-CFA
                execute true
        else
                2drop false
        then
;

DEFER ACCEL-KEY ' NOOP IS ACCEL-KEY \ Handler for key entries

: DoAccelMsg    { pMsg flag -- pMsg f | pMsg FALSE }
                pMsg
                ACCEL-HNDL
                pMsg @ \ get the message's HWND
                Call TranslateAccelerator 0= to flag
\                 if  pMsg Call TranslateMessage drop
\                     pMsg Call DispatchMessage  drop
\                then
		pMsg flag ;

msg-chain chain-add DoAccelMsg


\ ---------------------------------------------------------------------------
\s How to use:
\ ---------------------------------------------------------------------------

\ 1 to Debug-Accelerator-Table-Support \ turn debug-support on

\ 1. define the Word's to be executed by an accelerator key
: handle-alt-a         ( -- ) ;
: handle-ctrl-b        ( -- ) beep ;
: handle-alt-ctrl-c    ( -- ) ;
: handle-alt-ctrl-r    ( -- ) ;

\ 2. Define the accelerator key table
ACCELTABLE Accelerator-Key-Table
\       Flags             (Virt-)Key-Code  Command-ID  CFA
        FALT              'A'              4711        ' handle-alt-a       ACCELENTRY
        FCONTROL          'B'              4712        ' handle-ctrl-b      ACCELENTRY
        FALT FCONTROL or  'C'              4713        ' handle-alt-ctrl-c  ACCELENTRY
        FALT FCONTROL or  'R'              4714        ' handle-alt-ctrl-r  ACCELENTRY
ACCELEND \ mark the end of table

\ 3. init Accelerator Table the support
\ Best place to do is in WM_CREATE-Message-Handler
Accelerator-Key-Table Create-Accelerator-Table

\ 4. let w32f processes the windows message with our own function
msg-chain chain-add DoAccelMsg

\ 5. later deinit the Accelerator Table support
\ Best place to do is in WM_DESTROY-Message-Handler
Destroy-Accelerator-Table

\ see AcceleratorTableDemo for a working demo


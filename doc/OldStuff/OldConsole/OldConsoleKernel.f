\ OldConsoleKernel.f


\ This file contains the old console as it was in fkernel.f before it
\ was replaced by the DOS console


\ -------------------- Console I/O ------------------------------------------

(( [cdo] dos console
WinLibrary W32FCONSOLE.DLL
3 PROC c_initconsole
3 PROC k_initkeyboard
0 PROC k_key
0 PROC k_keyq
2 PROC k_accept
1 PROC k_fpushkey
2 PROC c_type
1 PROC c_emit
0 PROC c_cr
0 PROC c_cls
1 PROC c_qcr
2 PROC c_gotoxy
0 PROC c_getxy
4 PROC c_mark
0 PROC c_getcolrow
0 PROC c_sizestate

VARIABLE &CB-MSG    \ callback addresses
VARIABLE &CB-WINMSG
VARIABLE &CB-BYE

: x_KEY         ( -- key )
                Call k_key ;

: x_KEY?        ( -- f )
                Call k_keyq ;

: x_ACCEPT      ( addr len -- n )
                SWAP Call k_accept ;

: x_INIT-CONSOLE ( -- f1 )      \ initialize the Forth console window
                                \ and the keyboard I/O
                                \ f1=false if already inited
                _conHndl >R

                \ initialize the console registry
                INIT-CONSOLE-REG

                \ initialize the console window
                &CB-BYE &CB-WINMSG appInst Call c_initconsole
                DUP to _conHndl \ save window handle
                0= THROW

                \ initialize the keyboard I/O
                &CB-BYE &CB-MSG _conHndl Call k_initkeyboard 0= THROW

                R> _conHndl - ;

WinLibrary USER32.DLL
2 PROC ShowWindow

: x_INIT-SCREEN ( -- )          \ init the screen
                INIT-CONSOLE DROP
                1 ( SW_NORMAL ) _conHndl call ShowWindow DROP ;

: x_EMIT        ( char -- )
                Call c_emit drop ;

: x_TYPE        ( addr len -- )
                SWAP Call c_type drop ;

: x_CR          ( -- )
                Call c_cr drop ;

: x_CLS         ( -- )
                Call c_cls drop ;

\ ?CR checks if there is room for at least n chars in the current
\ row of the console window. If not it emits CR and LF to move the
\ cursor to the beginnig of the next row.
: x_?CR         ( n -- )
                Call c_qcr drop ;

: x_SIZESTATE   ( -- state )    \ state of the display
                Call c_sizestate ;

: x_GOTOXY      ( x y -- )
                SWAP Call c_gotoxy drop ;

: x_GETXY       ( -- x y )
                Call c_getxy WORD-SPLIT ;

: x_GETCOLROW   ( -- cols rows )
                Call c_getcolrow WORD-SPLIT ;

: x_MARKCONSOLE ( startline startcol endline endcol -- )
                Call c_mark DROP ;

' x_INIT-CONSOLE is INIT-CONSOLE
' x_INIT-SCREEN  is INIT-SCREEN

' x_KEY          is KEY
' x_KEY?         is KEY?
' x_ACCEPT       is ACCEPT

' x_TYPE         is TYPE
' x_EMIT         is EMIT
' x_CR           is CR
' x_CLS          is CLS
' x_?CR          is ?CR
' x_SIZESTATE    is SIZESTATE
' x_GOTOXY       is GOTOXY
' x_GETXY        is GETXY
' x_GETCOLROW    is GETCOLROW
' x_MARKCONSOLE  is MARKCONSOLE

))


\ -------------------- Deferred I/O  Part II --------------------------------

(( [cdo] dos console
-1 VALUE STDOUT
-1 VALUE STDERR
-1 VALUE STDIN

1 PROC GetStdHandle
0 PROC AllocConsole
0 PROC FreeConsole
: _DOSCONSOLE   ( fl -- )                        \ true = open, false = close
                if call AllocConsole drop
                  STD_OUTPUT_HANDLE Call GetStdHandle to STDOUT
                  STD_INPUT_HANDLE  Call GetStdHandle to STDIN
                  STD_ERROR_HANDLE  Call GetStdHandle to STDERR
                else call FreeConsole drop
                then ;
))

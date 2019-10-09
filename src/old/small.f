\ $Id: small.f,v 1.3 2005/05/17 22:25:26 alex_mcdonald Exp $
\ extend the kernel

cr .( -- META SMALL.F ) cr
sys-FLOAD src\comment.f
    FLOAD src\console\console.f  \ Console I/O extracted from Primutil.f
    FLOAD src\primutil.f         \ primitive utilities
    FLOAD src\console\console2.f \ more Terminal I/O
\ sys-FLOAD src\nforget.f
sys-FLOAD src\dthread.f     \ display threads
sys-FLOAD src\order.f       \ vocabulary support
sys-FLOAD src\module.f      \ scoping support for modules
    FLOAD src\paths.f       \ multi path support words
sys-fload src\imageman.f    \ fsave, application & turnkey words

0 proc MessageBox

: ?MessageBox   { flag adr len \ message$ -- }
                MAXSTRING localAlloc: message$
                flag
                if      adr len message$ place
                        message$ +NULL
                        MB_OK MB_ICONINFORMATION or MB_TASKMODAL or
                        z" Notice!"
                        message$ 1+
                        NULL call MessageBox drop
                then    ;

: SMALL true s" Message from SMALL.EXE" ?MessageBox  init-console normal-console
." There are a number of messages we could sed" cr
key  ;

0 0 ' small application small


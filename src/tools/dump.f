\ $Id: dump.f,v 1.1 2005/08/29 15:56:28 dbu_de Exp $

\ DUMP.f
\ Moved here from fkernel.f
\ Sonntag, August 28 2005 dbu

cr .( Loading HEX dump utility)

anew -dump.f

INTERNAL
EXTERNAL

IN-APPLICATION

: +NO-WRAP      ( a1 n1 -- a2 ) \ add n1 to a1, limit to address 0xFFFFFFFF
                                \ don't allow wrap around to address zero
                0 TUCK D+ -1 0 DMIN DROP ;

IN-SYSTEM

DEFER DUMPC@ ' C@ IS DUMPC@ \ added as seen in Version 3.5 fkernel.f for
                            \ cf32 port (Samstag, August 13 2005 dbu)

: DUMP  ( adr len -- )  ( hex byte format with ascii )
           OVER +NO-WRAP DUP ROT
           ?DO   CR I 8 h.R ."  | "
                 I 16 +NO-WRAP OVER UMIN I
                 2dup
                 DO      I DUMPC@ H.2 space I J 7 + = IF SPACE THEN
                 LOOP    2DUP -  16 OVER - 3 *  SWAP 8 < -  SPACES ." |"
                 DO      I DUMPC@ EMIT.
                 LOOP    ." |" NUF? ?LEAVE
                 SCREENDELAY MS          \ slow down output
        16 +LOOP DROP    ;

IN-APPLICATION

MODULE

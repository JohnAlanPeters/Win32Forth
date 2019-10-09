\ Joinstr.f       Joins any number of counted strings in fwd order
\ Based on Rainbow Sally's Code

anew -joinstr.f

Internal

variable join$base

External

: join$(
    join$base @ sp@ join$base !
    // links and saves old sp
    ;

: )join$    { \ tmp$ alo ahi -- }
    sp@ to alo join$base @ to ahi
        ahi alo - 7 and     \ must be multiples of 8
        abort" Join$ requires counted strings"
    new$ dup off to tmp$

    alo ahi -2 cells+
    do
        i cell+ @ i @
        ( addr len ) dup 0 255 between not abort" Bad String Len in JOIN$()"
        ( addr len ) tmp$ +place
    -2 cells +loop
    join$base @ sp!  // reset old stack pointer
    join$base !      // restore old join$base
    tmp$ dup +null ;
Module
\s
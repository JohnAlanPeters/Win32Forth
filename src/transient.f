\ $Id: transient.f,v 1.2 2008/05/15 04:28:27 camilleforth Exp $

\ author: alex mcdonald 07/02/2005 23:25:51
\ public domain
\ requires version 6.11 or better
\
\ transient memory support
\
\ reserves 1Mb of virtual space; allocations of real memory
\ are performed by the kernel when an exception is detected.
\ the variable exc-count is incremented each time a page is
\ written to for the first time.
\
\ use .mem or .free to see the amount of space free
\
\ programs that compile to the transient area can't be saved;
\ currently, there's no check performed by turnkey, fsave or
\ application that checks if a transient area has been used.
\


1024 1024 * constant TDPSIZE

PAGE_NOACCESS MEM_RESERVE TDPSIZE 0 VirtualAlloc nostack1 \ reserve memory

\  CELL OFFSET  FUNCTION
\  ---- ------  --------
\   0     0     Current pointer to area
\   1     4     Address of the area (origin)
\   2     8     Highest address of area (origin + length)
\   4    16     Link of all the xDP areas; set in DP-LINK
\   5    20     Counted name of the area
\

in-system                                        \ may not matter

CREATE TDP  DUP ,
            DUP ,
            TDPSIZE + ,
            DP-LINK LINK, ," ^TRANS"             \ transient
: IN-TRANS       ( -- ) TDP TO DP ;              \ set the correct pointer
: >TRANS         ( -- ) TDP >DP ;                \ select trans space
\ ' DP> ALIAS TRANS>      \ made a colon def - [cdo-2008May13]
: TRANS>         \ back to previous DP  (synonym of DP>)
                 ( -- ) 2R> >R TO DP ;
: TRANS-ORIGIN   ( -- a1 ) TDP CELL+ @ ;

in-application


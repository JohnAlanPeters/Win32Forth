\ $Id: Winlib.f,v 1.6 2013/05/17 21:33:47 jos_ven Exp $

\ winlib.f beta 1.9F 2002/08/13 arm major modifications
\ winlib.f beta 2.0A 07/09/2002 22:14:48 arm minor cosmetic
\ winlib.f beta 2.9G 2002/09/24 arm release for testing
\ winlib.f beta 3.3D 2002/10/08 arm Consolidation
\ winlib.f beta 4.9D 2002/10/08 arm OS support removed to PRIMUTIL.F

cr .( Loading Windows API Library...)


INTERNAL                        \ non-user definitions start here

\ init the pdp area; see the structure PDP in the kernel
 APP-HERE DUP DUP 0xC300 DUP APP-ALLOT + PDP 2 CELLS+ ! PDP CELL+ ! PDP !


\ ---------------------- Debugging/Info routines ----------------------

IN-SYSTEM

0 value winproc-count                      \ number of procs
0 value winproc-found                      \ that we found

: (.libs)       ( lib-addr -- )
                dup H.8                         \ address
                tab dup lib>handle @ dup 0<>
                if h.8
                else drop ." -noload-"
                then
                tab lib>name count type
                cr
                ;

: (.procs)      ( addr len proc-addr --  addr len )
                3dup proc>name count temp$ place temp$
                uppercase count 2swap search
                >r 2drop r>
                if
                  dup H.8 tab                       \ address
                  dup proc>name count type 40 col
                  dup proc>pcnt c@ dup 0x80 and         \ 0x80 = unknown # parms
                  if ." -" drop else 0x0F and . then 45 col \ mask out high order bits
                  dup proc>ep @
                  over proc>ep @ DOCALL-MULTI =
                  if drop tab
                  else h.8
                  then                            \ ep
                  dup dup proc>lib @
                  case 0 of drop endof
                      ['] proc-error of ." -error!-" drop endof
                      55 col lib>name count type
                  endcase
                  cr
                  1 +to winproc-found
                then
                drop
                1 +to winproc-count
                ;

EXTERNAL

: .libs         ( -- )
                tab-size >r
                10 to tab-size
                cr
                ." Location  Handle    Name" cr
                ." --------  --------  -----------" cr
                ['] (.libs) winlib-link do-link
                r> to tab-size ;

: .procs        ( <optional name> -- )
                { \ str$ }
                MAXSTRING LocalAlloc: str$
                0 to winproc-count
                0 to winproc-found
                cr
                tab-size >r
                10 to tab-size
                ." Location  ProcName" 40 col ." Prm  ProcEP    LibName"  cr
                ." --------  --------" 40 col ." ---  --------  --------" cr
                bl word count str$ place str$ uppercase count \ get optional name
                ['] (.procs) winproc-link do-link
                2drop
                ." Displayed " winproc-found . ." of "
                winproc-count . ." procedures defined" cr
                r> to tab-size
                ;

\ ------------------------------- Memory Management functions ------------------------
\
\ Malloc data structure in dynamically allocated memory
\ beta 2.0A 06/09/2002 21:54:51 arm major modifications

\ [malloc_next][heapaddress][mem_type][extra-cell][allocated_memory][4 extra_cells]
\                                                 |
\                                                 * returns this address on allocate *
\                                                 this is the "address"
\ Changes:
\   All memory calls are now to Windows heap functions
\   Length field has been discarded
\   Heap address is included
\   Currently, only the process heap is used. Only
\     ALLOCATE and REALLOC need to be modified to work against
\     another heap.
\   mem_type is currently unused, will be for pe header
\ see functions in kernel
\ NOTE: Since Windows guarantees alignment to a double cell the offset from link to address should
\       be an even no. of cells.

INTERNAL

: (tot-malloc)  ( n link-addr -- n' )           \ add in a single entry's byte count
                mHeapSize malloc-adjlen - + ;   \ get, adjust, increment

: (.mallocs)    ( link-addr -- )                \ display one line
                dup h.8 ."   " dup link>mem h.8
                dup mHeapSize malloc-adjlen - 13 space u,.r
                ."   " link>haddr @ h.8 cr ;

: tot-malloc    ( -- n )                        \ count allocated bytes
                (memlock)
                0                               \ run thru malloc chain
                ['] (tot-malloc) malloc-link do-link
                (memunlock) ;

\  Each set of pointers to a data ("dictionary") space is a structure.
\  These structures MUST RESIDE IN THE APPLICATION SPACE if they are linked
\
\  CELL OFFSET  FUNCTION
\  ---- ------  --------
\   0     0     Current pointer to area
\   1     4     Address of the area (origin)
\   2     8     Highest address of area (origin + length)
\   4    16     Link of all the xDP areas; set in DP-LINK
\   5    20     Counted name of the area

: (.free)       ( link -- )
                { link \ addr tot used -- }
                cr
                link cell+ count type tab
                link [ 2 cells ] literal - @ to addr
                link [ 1 cells ] literal - @ addr - to tot
                link [ 3 cells ] literal - @ addr - to used
                addr 8 h.r ." h " tot 10 u,.r used 10 u,.r tot used - 10 u,.r
                ;

EXTERNAL

: .mallocs      ( -- )                          \ display all dynamically allocated buffers
                cr
                ." Link-Addr Rel-Addr         Bytes  HeapAddr  Type" cr
                s" --------- --------      --------  --------  ----" 2dup type cr
                (memlock)
                ['] (.mallocs) malloc-link do-link
                (memunlock)
                type cr ." Total allocated   " tot-malloc 10 u,.r cr ;

: .free         ( -- )  \ Display the amount of used and available program memory
                base @ decimal
                cr ." Section Address        Total      Used      Free"
                cr ." ------- ---------  --------- --------- ---------"
                ['] (.free) DP-LINK DO-LINK
                cr ." * areas are inline"
                cr ." Malloc/Pointer:   " tot-malloc  10 u,.r
                base ! ;

\ synonym .mem .free               \ made a colon def - [cdo-2008May13]
: .mem          \ synonym of .free
                .free ;

: used          ( -- )  \ Display the mount of memory used by the following command line
                sys-free >r code-free >r app-free >r
                interpret
                cr
                r> app-free - ." APP mem: " dup 1 u,.r
                r> code-free - ." , CODE mem: "     dup 1 u,.r
                r> sys-free - ." , SYS mem: "     dup 1 u,.r
                + + ."  Total: " 1 u,.r ;

\ --------------------------- End Memory Management functions ------------------------

IN-APPLICATION

MODULE          \ finishup the module


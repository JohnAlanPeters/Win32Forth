\ $Id: BLOCK.F,v 1.10 2014/05/03 22:29:27 jos_ven Exp $

\       Tom's Forth virtual block system.       by Tom Zimmer

cr .( Loading BLOCK...)

\ *D doc
\ *! p-block W32F block
\ *T Using the Block Wordset

\ *P Win32Forth implements a virtual block system, based on the ANSI standard Block
\ ** and Block extension wordsets. \n
\ ** The block words are not loaded by default and have to be included. The file
\ ** BLOCK.F is in the lib folder (some older versions of W32F placed it in the extras
\ ** folder). \n
\ ** The constants B/BUF, and #BUFFERS control the block size, and the number of
\ ** buffers the system uses.  These are defaulted to 1024 byte blocks, and
\ ** 8 buffers.  A true LRU (least recently used) buffer allocation mechanism
\ ** is used, implemented as a bubble up buffer stack.  The least recently used
\ ** buffer is always on the bottom of the stack.  As buffers are used or
\ ** re-used, they are bubbled immediately up to the top of the stack, destined
\ ** to settle to the bottom of the stack if the same record is not accessed
\ ** again. \n Blocks are stored in a blockfile (normally with the .blk extension,
\ ** although some forths use .fb) which is set by the words set-blockfile,
\ ** open-blockfile or create-blockfile and closed by close-blockfile. Only one
\ ** blockfile is active at any one time, open-blockfile and create-blockfile
\ ** automatically close the current one prior to setting themselves as the current
\ ** blockfile. \n
\ ** \b NOTE \d set-blockfile does not close the current blockfile.

\ *P A sample block file BANNER.BLK has been included for your examination. \n
\ ** type the following commands after loading BLOCK.F \n
\ ** \n
\ **         OPEN-BLOCKFILE DEMOS\BANNER.BLK
\ **         1 7 THRU
\ ** \n
\ ** This will load and run a simple demo. \n
\ ** \n
\ ** Type DEMO again to run it again after it has been loaded.

only forth also definitions

IN-APPLICATION

\ needs 486asm.f                        \ load assembler if needed

\ *S Glossary

        1024 constant b/buf                    \ W32F         Block extra
\ *G Length of each block.
          64 constant c/l                      \ W32F         Block extra
\ *G Number of characters per line.
           8 constant #buffers                 \ W32F         Block extra
\ *G Number of block buffers.
          -1    value blockhandle              \ W32F         Block extra
\ *G The handle of the current block file, or -1 if no current block file.

variable blk        ( -- a-addr )              \ ANSI         Block
\ *G a-addr is the address of a cell containing zero or the number of the mass-storage
\ ** block being interpreted. If BLK contains zero, the input source is not a block
\ ** and can be identified by SOURCE-ID, if SOURCE-ID is available. An ambiguous
\ ** condition exists if a program directly alters the contents of BLK.
variable scr        ( -- a-addr )              \ ANSI         Block ext
\ *G a-addr is the address of a cell containing the block number of the block most
\ ** recently listed.

INTERNAL                                \ internal definitions

variable cur_buffer#                    \ current buffer # of current block
         cur_buffer# off

#buffers cells constant buflen

variable rec_array b/buf #buffers  * allot      \ an array of blocks
variable rec#s            buflen     allot      \ block # array
variable rec#updt         buflen     allot      \ Update flags
variable rec#use          buflen     allot      \ block bubbleup stack
variable rec#fil          buflen     allot      \ hcb for each block

                                        \ n1 = buffer number
                                        \ a1 = address of buffer
: buf#>bufaddr  ( n1 --- a1 )         \ Calculate address a1 of buffer n1.
        b/buf * rec_array + ;

                                        \ n1 = buffer number
                                        \ a1 = buffer address
: >rec#s        ( n1 --- a1 )           \ return the buffer n1's record addr
        rec#s +cells ;

                                        \ n1 = buffer number
                                        \ a1 = buffer address
: >rec#updt     ( n1 --- a1 )           \ return the buffer n1's update addr
        rec#updt +cells ;

                                        \ n1 = buffer number
                                        \ a1 = buffer address
: >rec#fil      ( n1 --- a1 )           \ return the buffer n1's file addr
        rec#fil +cells ;

: chkfil        ( n1 --- n1 f1 )        \ verify file in bufer n1 is current
        dup dup 8 =
        if      drop false exit
        else    >rec#fil @ blockhandle =
        then    ;

: bubbleup      ( n1 --- )              \ move buffer # n1 to end of list
        >r rec#use #buffers r@ lscan dup 0=
        abort" Buffer# number not in buffer list"
        1- cells >r dup cell+ swap r> move  \ move list down except first
        r> rec#use buflen + cell - ! ;      \ stuff first at end of list.

                                        \ n1 = block we are looking for
                                        \ n2 = buffer #
                                        \ f1 = do we have it?, true if we do
: ?gotrec       ( n1 --- <n2> f1 )      \ Do we have block n1 in memory?
        rec#s #buffers rot lscan nip
        #buffers swap - ( tos is buffer # with matching block #)
        chkfil
        if      true
        else    drop false
        then    ;
                                        \ n1 = block to positon to
: pos_block    ( n1 --- )               \ Set file pointer to block pos n1
        0max b/buf * 0 blockhandle reposition-file drop ;

                                        \ a1 = destination address of read
                                        \ n1 = block number to read
: read_block    ( a1 n1 --- )           \ read block n1 to address a1
        pos_block
        b/buf blockhandle read-file swap b/buf <> or
        abort" Error reading block" ;

                                        \ n1 = buffer number
                                        \ n2 = block number to write
: write_block  ( n1 n2 --- )            \ write block n1 to disk
        pos_block
        dup buf#>bufaddr
        b/buf rot >rec#fil @ write-file
        abort" Error writing block, probably out of disk space." ;

EXTERNAL        \ externally available definitions

                                \ u = block #
                                \ a-addr = bufadr
: save-buffers      ( -- )                     \ ANSI         Block
\ *G Transfer the contents of each updated block buffer to mass storage.
\ ** Mark all buffers as unmodified.
        #buffers 0                              \ through all the buffers
        do      rec#use @ >r                    \ find a buffer
                r@ bubbleup                     \ bump to highest priority
                r@ cur_buffer# !                \ set current buffer var
                r@ >rec#updt dup @              \ check update flag
                if      off                     \ clear update flag
                        r@ dup >rec#s @         \ get block #
                        write_block             \ write it
                else    drop                    \ discard, already cleared
                then    r>drop
        loop    ;

: buffer            ( u -- a-addr )            \ ANSI         Block
\ *G a-addr is the address of the first character of the block buffer assigned to block u.
\ ** The contents of the block are unspecified. An ambiguous condition exists if u is not
\ ** an available block number. \n
\ ** If block u is already in a block buffer, a-addr is the address of that block buffer. \n
\ ** If block u is not already in memory and there is an unassigned buffer, a-addr is the
\ ** address of that block buffer. \n
\ ** If block u is not already in memory and there are no unassigned block buffers,
\ ** unassign a block buffer. If the block in that buffer has been UPDATEd, transfer
\ ** the block to mass storage. a-addr is the address of that block buffer.
\ ** At the conclusion of the operation, the block buffer pointed to by a-addr is
\ ** the current block buffer and is assigned to u.
        dup ?gotrec                     \ check if already present
        if      >r drop                 \ buffer already assigned, save it
        else
                rec#use @ >r                 \ assign LRU buffer
                r@ >rec#updt dup @           \ check update flag
                if      off                  \ clear update flag
                        r@ dup >rec#s @      \ get block #
                        write_block          \ write it
                else    drop                 \ discard, already cleared
                then
                r@ >rec#s   !        \ set block #
                blockhandle r@ >rec#fil !    \ set the file hcb
        then
        r@ bubbleup                     \ bump to highest priority
        r@ cur_buffer# !                \ set current buffer var
        r> buf#>bufaddr ;               \ calc buffer addr

: empty-buffers     ( -- )                     \ ANSI         Block ext
\ *G Unassign all block buffers. Do not transfer the contents of any updated
\ ** block buffer to mass storage.
        rec_array b/buf #buffers * erase
        rec#s    buflen -1 fill
        rec#updt buflen erase
        rec#fil  buflen erase
        rec#use  #buffers 0
        do      i over ! cell+     \ initialize the bubbleup stack
        loop
        drop ;

: flush             ( -- )                     \ ANSI         Block
\ *G Perform the function of SAVE-BUFFERS, then unassign all block buffers.
        save-buffers
        empty-buffers ;

: update            ( -- )                     \ ANSI         Block
\ *G Mark the current block buffer as modified. An ambiguous condition exists if there
\ ** is no current block buffer. \n
\ ** Update does not write the block to the disc.
        cur_buffer# @ >rec#updt on ;

                                       \ u = block # to get
                                       \ a-addr is address of block # u
: block             ( u -- a-addr )            \ ANSI         Block
\ *G a-addr is the address of the first character of the block buffer assigned to
\ ** mass-storage block u. An ambiguous condition exists if u is not an available
\ ** block number. \n
\ ** If block u is already in a block buffer, a-addr is the address of that block buffer.  \n
\ ** If block u is not already in memory and there is an unassigned block buffer,
\ ** transfer block u from mass storage to an unassigned block buffer. a-addr is
\ ** the address of that block buffer. \n
\ ** If block u is not already in memory and there are no unassigned block buffers, unassign
\ ** a block buffer. If the block in that buffer has been UPDATEd, transfer the block to
\ ** mass storage and transfer block u from mass storage into that buffer. a-addr is the
\ ** address of that block buffer. \n
\ ** At the conclusion of the operation, the block buffer pointed to by a-addr is the
\ ** current block buffer and is assigned to u.
        dup ?gotrec
        if      nip dup >r buf#>bufaddr
                r@ cur_buffer# ! r> bubbleup
        else    blockhandle 0< abort" No file open"
                dup buffer dup rot read_block
        then    ;

: list              ( u -- )                   \ ANSI         Block ext
\ *G Display block u in the console in a 16 line format. Store u in SCR. \n
\ ** An error occurs if u is greater than the number of blocks in the current blockfile.
        dup scr !
        block b/buf bounds
        do      cr i c/l type
        c/l +loop    ;

: wipe              ( u -- )                   \ W32F         Block extra
\ *G Erase the specified block to blanks.
        buffer b/buf blank update ;

: set-blockfile     ( fileid -- )              \ W32F         Block extra
\ *G Make fileid the current blockfile.
        to blockhandle ;

\ ----------------------------------------------------------------
\ The following words add capabities for dealing with blocks.
\ See the documentation for what they do.
\ ----------------------------------------------------------------

warning off

: evaluate      ( a1 n1 -- )
        blk off evaluate ;

: save-input    ( -- xxx 8 )
        save-input
        blk @ swap 1+ ;

: restore-input ( xxx 8 -- f1 )
        swap blk ! 1-
        restore-input >r
        blk @ 0>
        if      blk @ block b/buf (source) 2! \ force back to block
        then    r> ;

: refill        ( -- f1 )
        blk @ 0=
        if      refill
        else    >in off
                blockhandle to source-id \ ?loading on
                1 blk tuck +! @ block b/buf (source) 2! true
        then    ;

: \     ( -- )
        blk @ 0=
        if      postpone \
        else    >in @ c/l / 1+ c/l * >in !
        then    ; immediate

warning on

: blkmessage    ( n1 -- )
        blk @ 0>
        if      base @ >r
                cr ." Error: " pocket count type space
                dup -2 =
                if      drop msg @ count type
                else    ." Error # " .
                then
                cr ." Block: " blk @ .
                ." at Line: " >in @ c/l / .
                cr blk @ block >in @ c/l / c/l * + c/l type
                blk off   \ reset BLK cause noone else does!!!
                r> base !
        else    _message
        then    ;

' blkmessage is message

\ ----------------------------------------------------------------
\ -------- End of extended capabilities --------------------------
\ ----------------------------------------------------------------

: load              ( i*x u -- j*x )           \ ANSI         Block
\ *G Save the current input-source specification. Store u in BLK (thus making block
\ ** u the input source and setting the input buffer to encompass its contents), set
\ ** >IN to zero, and interpret. When the parse area is exhausted, restore the prior
\ ** input source specification. Other stack effects are due to the words LOADed.
\ ** An ambiguous condition exists if u is zero or is not a valid block number.
        { loadblk \ incntr outcntr -- }
        save-input dup 1+ dup to incntr
                              to outcntr
        begin  >r -1 +to incntr  incntr  0= until
        loadblk blk !
        >in off
        blockhandle to source-id \ ?loading on
        blk @ block b/buf (source) 2!
        interpret
        begin  r> -1 +to outcntr outcntr 0= until
        restore-input drop ;

: thru              ( i*x u1 u2 -- j*x )       \ ANSI         Block ext
\ *G LOAD the mass storage blocks numbered u1 through u2 in sequence. Other stack
\ ** effects are due to the words LOADed.
        1+ swap
        ?do     i load
        loop    ;

: close-blockfile   ( -- )                     \ W32F         Block extra
\ *G Close the current blockfile, flushing any updated buffers. Set the current blockfile
\ ** to no file.
        blockhandle -1 <>
        if      flush
                blockhandle      \ Roderick Mcban - February 11th, 2002
                close-file drop
        then    -1 to blockhandle ;

: open-blockfile    ( "<spaces>'filename'" )   \ W32F         Block extra
\ *G Close the current blockfile. Open the file and make it the current block file.
        close-blockfile
        /parse-word count r/w open-file abort" Failed to open Block File"
        set-blockfile
        empty-buffers ;

: create-blockfile  ( u "<spaces>'filename'" ) \ W32F         Block extra
\ *G Close the current blockfile. Create a file of u blocks long, initialise the
\ ** blocks to blanks and make it the current blockfile.
        close-blockfile
        /parse-word count r/w create-file
        abort" Failed to create Block File"
        set-blockfile
        dup b/buf m* blockhandle resize-file
        abort" Unable to create a file of that size"
        empty-buffers
        0
        do      i wipe
        loop
        flush ;

: #blocks           ( -- u )                   \ W32F         Block extra
\ *G u is the number of blocks in the current blockfile.
        blockhandle file-size drop b/buf um/mod nip ;

: List-All          ( -- )                     \ W32F         Block extra
\ *G To list all blocks in the current blockfile.
   #blocks 0 do   cr i dup ." \ Block # " . list   loop  ;

\ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
\ initialization of the block system
\ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

empty-buffers           \ Initialize the virtual memory arrays interpretively

INTERNAL        \ another internal definitions

: virtual-init  ( --- ) \ and during the system startup initialization
        -1 to blockhandle
        empty-buffers ;

initialization-chain chain-add virtual-init

MODULE          \ end of the module

get-current checkstack also environment definitions

true constant BLOCK
true constant BLOCK-EXT

previous set-current

\ *Z

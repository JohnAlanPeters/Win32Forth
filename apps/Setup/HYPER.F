\ $Id: HYPER.F,v 1.5 2015/12/30 11:41:49 jos_ven Exp $
(( HYPER.F      Build an index of hyper text links      by Tom Zimmer

 Samstag, September 11 2004 dbu
	moved the build of the index files into the setup.

 January 7th, 2004 - 10:25 dbu
        added RBS's patch witch will allow backslashes in WinEd hyperlinks.

 July 5th, 2003 - 7:55 dbu
        Changed for WinEd Version 2.20

 September 12th, 2003 - 10:22 dbu
        Changed to write absolute path's into the ndx-files

 ??.??.?? rbs
        globalization

 10/19/95 17:04 tjz
        Got the hypertext compiler to work on Win32Forth

 10/3/95 tjz
        Started the conversion of Win32Forth. Stripped out all the TCOM
        specific code.

 09/20/95 15:35 tjz     version 2.4
        Modified "write.onename" to always write the names in uppercase.

 03/03/94 13:59 tjz     version 2.3
        Updated to include new features for help, searching and
        displaying indexes.  You can also specify the name of the index
        file to search or build.

))

anew -hyper.f
needs sub_dirs.f

cr .( Loading Hyper...)

\ Runtime allocated MAXSTRING length buffers
   named-new$ index-word-buf
   named-new$ exclude-buf
   named-new$ base-path
   named-new$ input-line-buf
   named-new$ index-line-buf

\ -rbs
0 value &WINED.CFG
0 value &WINED.NDX
create &WINED.CFG1 maxstring allot
create &WINED.NDX1 maxstring allot

\ init now...
&WINED.CFG1 to &WINED.CFG
&WINED.NDX1 to &WINED.NDX
S" HYPER.CFG" PREPEND<HOME>\ &WINED.CFG PLACE
S" HYPER.NDX" PREPEND<HOME>\ &WINED.NDX PLACE
\ <------rbs

  0 value input-line#
  0 value index-hndl
  0 value after-col
  0 value before-col
  0 value stop-char
  0 value fstime?
  0 value ?global
  0 value ?keeppath
  0 value search-param
  0 value eof?

2variable thisline

: make-index    ( -- f1 )       \ make the index file, return TRUE if succeeded
                &WINED.NDX count r/w create-file 0=
                IF        to index-hndl TRUE
                ELSE    DROP
                        0 to index-hndl FALSE
                THEN    ;

: flush-index   ( -- )
                index-line-buf count index-hndl write-file drop
                index-line-buf off ;

: "index        ( a1 n1 -- )
                index-line-buf +place ;

: reset-index   ( -- )
                index-line-buf off ;

: close-index   ( -- )
                crlf$ count "index
                flush-index
                index-hndl close-file drop
                0 to index-hndl ;

create TAB_String 1 c, k_TAB c, 0 c, ALIGN

\ changed to write absolute paths
\ September 12th, 2003 - 10:17 dbu
: write.filename ( -- )
                fstime? ?EXIT           \ put filename in index file
                TAB_String count "index \ filename lines start with a TAB
                name-buf count prepend<home>\ \ write absolute paths
                ?global ?keeppath or 0= if "to-pathend" then "index
                crlf$ count "index
                flush-index
                TRUE to fstime? ;

: write.onename ( a1 n1 -- )    \ add string to index if shorter than 32 chars
                dup 32 <
                if      write.filename
                        2dup upper              \ always upper case entries
                        "index                  \ write to file
                        input-line#             \ line where found,
                        0 <# crlf$ count "hold  \ end line with CRLF
                        #S                      \ preceeded by the number
                        bl hold #>              \ preceeded by a blank
                        "index                  \ write it too.
                        flush-index
                else    2drop                   \ else discard string
                then    ;

: skip_1word    ( a1 n1 -- a2 n2 )              \ skip one word through string
                begin   2dup bl scan            \ find a blank
                        bl skip                 \ and skip it
                        dup                     \ any text left
                while   2nip
                repeat  2drop  ;                \ if any text left, then

: ?word.ending  ( -- )  \ find a word ending with char in index-word-buf
                thisline 2@ over c@ bl =        \ mustn't start with a blank
        if      2drop
        else    bl skip                         \ skip leading spaces
                2dup index-word-buf 1+ c@ scan dup   \ did we find delimit char
                if      over 1+ c@ dup bl =     \ does a blank follow char? if so
                                                \ October 7th, 1999 - 9:29
                                                \ suggested by Michael Steen
                        swap k_CR = or          \ or followed by CR
                                                \ then ok, else not
                   if   nip -                   \ parse word before
                        skip_1word dup          \ if any text left, then
                        if      write.onename   \ write name to index
                        else    2drop
                        then
                   else 2drop 2drop
                   then
                else    2drop 2drop             \ discard if not found
                then

        then ;

: +word         ( a1 n1 -- a2 n2 a3 n3 )
                bl skip 2dup bl scan 2dup 2>r nip - 2r> 2swap ;

: -word         ( a1 n1 -- a2 n2 a3 n3 )
                -trailing 2dup swap over + 1- swap bl -scan 2dup 2>r nip /string
                2r> bl -skip swap over - 1 + swap 2swap ;

: char-strip    ( a1 n1 c1 -- a1 n1 )
                >r 2dup r> scan dup                     \ found strip char?
                if      over dup  1- c@ bl =            \ a bl before char
                             swap 1+ c@ bl = and        \ a bl after char
                        if      nip -                   \ then strip following
                        else    2drop                   \ else don't strip
                        then
                else    2drop
                then    ;

: ?word.after   ( -- )          \ find occurances of index-word-buf string and put word
                                \ following string in index file with line number.
                thisline 2@ dup>r 3 /string             \ don't look at first 3 chars
                stop-char char-strip                    \ stop at stop char
                '('       char-strip                    \ and stop at left paren
                '{'       char-strip                    \ and stop at left brace
                r> 3 >=                                 \ if then were present, then
                if      3 + swap 3 - swap               \ restore first three chars
                then
                begin   index-word-buf count search     \ while found
                while   over 1- dup c@ bl =             \ preceed with BL
                        swap input-line-buf = or >r     \ or at line start
                        index-word-buf c@ /string       \ skip search string + leadin
                        bl skip dup r> and              \ skip those blanks
                                                        \ must have text left
                        if                              \ it anything left
                                2dup                    \ -- addr & len of string
                                                        \ then get word following
                                2dup bl scan nip -      \ addr and len of name
                                write.onename           \ and write one index name
                        then
                repeat  2drop ;

: ?word.begin   ( -- )          \ find occurances of index-word-buf string and put word
                                \ at start of line in index file with line number.
                thisline 2@ index-word-buf count search
                nip nip                         \ discard remainder of string
                if      thisline 2@
                        search-param 0          \ count of words to ship
                        ?do     +word 2drop     \ skip a word
                        loop    +word           \ pick up next word
                        2nip
                        write.onename           \ and write one index name
                then ;

: ?word.stline  ( -- )  \ find occurance of index-word-buf string at line start
                        \ put following string in index file.
                thisline 2@ 2dup bl scan nip - dup
                if      index-word-buf count rot max compare 0=
                        if      thisline 2@ bl scan             \ find a blank
                                bl skip dup                     \ skip those blanks
                                if                              \ if anything left
                                        2dup bl scan nip -      \ word following
                                        write.onename           \ write 1 index name
                                else    2drop
                                then
                        then
                else    2drop
                then ;

: ?word.before  ( -- )          \ find occurances of index-word-buf string and put the
                                \ second word before it in index file with line number.
                thisline 2@ index-word-buf count search
                if      nip thisline 2@ rot -   \ a1,n1 of line text before index word
                        search-param 0
                        ?do     -word 2drop     \ find last word in line and discard it
                        loop    -word           \ find the word before it
                        2nip                    \ discard leading remainder of line
                        write.onename           \ and write one index name
                else    2drop
                then ;

: ?word.terminate ( -- )        \ stop scanning file if this string is found
                thisline 2@ index-word-buf count search
                nip nip
                if      true to eof?    \ mark file as completed
                then    ;

: search.word   ( n1 -- )
                0max 5 min exec:
                ?word.after             \ 0
                ?word.ending            \ 1
                ?word.begin             \ 2
                ?word.stline            \ 3
                ?word.before            \ 4
                ?word.terminate         \ 5     stop scanning the file if this is found
                ;
defined byte-array nip not [IF]

 : byte-array    ( n1 -<name>- )         \ compile time
                ( -- a1 )               \ runtime
                create 1+ here over allot swap erase ;
[THEN]

 64             constant   b/tbl
 64             constant   maxtbl
  0             value      tblcnt
b/tbl maxtbl *  byte-array wtbl

: search.words  ( -- )
                wtbl b/tbl maxtbl * bounds
                do      i 2 + c@ 0= ?leave
                        i 2 + count index-word-buf place
                        i 1+  c@ to search-param
                        i     c@ search.word
                        eof? ?leave                     \ stop if end of file flag set
         b/tbl +loop    ;

: iline-read    ( -- )          \ index line read, with tab expand
                                                        \ read a line from file
                input-line-buf 1+ MAXCOUNTED search-hndl read-line
                drop 0=
                if      TRUE to eof?
                then
                input-line-buf c!
                input-line-buf count upper
                1 +to input-line#
                input-line-buf count                    \ through whole line
                begin   0x09 scan dup                   \ look for next tab char
                while   over bl swap c!                 \ change tab to blank
                repeat  2drop ;

: next-cmd$     ( a1 n1 -- f1 )         \ find next matching string line
                                        \ f1 = true if match
                begin   2dup dup>r
                        iline-read
                        input-line-buf count bl skip 2dup    \ skip leading spcs
                        bl scan nip -                   \ parse first word
                        r> max compare 0=               \ compare strings match
                        input-line-buf 1+ c@ ';' =      \ test for file stop
                        if      true or                 \ say we are done
                                input-line-buf off      \ clear buffer
                        then    eof? or
                until   2drop input-line-buf c@ ;       \ true if matched

: find-cmd$     ( a1 n1 -- f1 )         \ find a line starting with string
                                        \ a1,n1. f1 = true if matched
                0.0 search-hndl reposition-file drop
                FALSE to eof?
                next-cmd$ ;

: after-cmd     ( -- a1 n1 )            \ return a1,n1 string after command
                input-line-buf count
                bl skip bl scan         \ past first word
                bl skip ;               \ and past any following spaces

: read_stopper  ( -- )                  \ STOPAT \
                s" STOPAT" find-cmd$
                if      after-cmd       \ -- a1 n1
                        if      c@ to stop-char
                        else    drop
                        then
                then    ;

: read_before   ( -- )                  \ BEFORE 64
                s" BEFORE" find-cmd$
                if      after-cmd       \ -- a1 n1
                        number?         \ -- d1 f1
                        if      over 250 min to before-col
                        then    2drop
                then    ;

: read_after    ( -- )                  \ AFTER 35
                s" AFTER" find-cmd$
                if      after-cmd       \ -- a1 n1
                        number?         \ -- d1 f1
                        2drop 240 min to after-col
                then    ;

: 1word         ( a1 n1 -- a2 n2 a3 n3 )        \ parse out a word
                bl skip 2dup bl scan 2dup 2>r nip - 2r> 2swap ;

: read_dirs     ( -- )          \ SPECS *.SEQ;*.TXT;*.ASM
                s" DIRS" find-cmd$
                if      after-cmd
                        2dup bl scan nip -              \ get line upto a blank
                        "CLIP" search-path place           \ move in the directory list
                        search-path count + 1- c@ ';' =    \ remove any trailing ';' chars
                        if      search-path c@ 1- 0max search-path c!
                        then
                        search-path c@ 0=
                        if      base-path count search-path place    \ else use current path
                        then
                        search-path c@ 0=
                        if      current-dir$ count search-path place \ else use current directory
                        then
                then    ;

: read_specs    ( -- )          \ SPECS *.SEQ;*.TXT;*.ASM
                s" SPECS" find-cmd$
                if      after-cmd
                        2dup bl scan nip -              \ get line upto a blank
                        "CLIP" mask-ptr place           \ move in file search mask
                        mask-ptr count + 1- c@ ';' =    \ remove any trailing ';' chars
                        if      mask-ptr c@ 1- 0max mask-ptr c!
                        then
                        mask-ptr c@ 0=                  \ if not default file mask
                        if      s" *."        mask-ptr  place
                                defext$ count mask-ptr +place   \ default file extension
                        then
                then    ;

 : read_exclude  ( -- )        \ EXCLUDE file1;file2;file3;file4 ; comment
                 s" EXCLUDE" find-cmd$
                 exclude-buf c@ 128 < and               \ and not full
                 if      after-cmd
                         2dup bl scan nip -             \ get line upto a blank
                         -trailing                      \ remove trailing blanks
                         exclude-buf +place
                 then
                 exclude-buf count upper ;

: exclude-file? { \ nadr nlen -- f1 }   \ return TRUE if this file is to be excluded
                name-buf count upper
                name-buf count "to-pathend" to nlen to nadr
                FALSE
                exclude-buf count
                begin   dup
                while   2dup ';' scan 2dup 2>r nip -
                        nadr nlen compare 0= or
                        2r> 1 /string
                repeat  2drop ;

: get1cmd       ( -- )
                after-cmd                               \ -- a1 n1
                over c@ '0' - 0 max 9 min               \ type 0 to 9
                tblcnt b/tbl * wtbl + c!                \ set search type

                '"' scan 1 /string                      \ skip to search for " char
                2dup 1 /string                          \ allow " to follow as legal
                '"' scan bl scan 2dup 2>r nip - 1- 0max \ get " delim 0x
                b/tbl 2 - min                           \ limit to avail
                tblcnt b/tbl * wtbl + 2 + place         \ move 0x into buf
                2r> bl skip
                if      c@ dup '0' '9' between                  \ if a valid parameter
                        if      '0' - 0 max 9 min               \ then use it
                        else    drop 0                          \ else discard and use zero
                        then    tblcnt b/tbl * wtbl + 1+ c!     \ set search parameter
                else    drop
                then    1 +to tblcnt ;

: read_cmds     ( -- )                  \ TYPE 0 "CONSTANT " 0
                s" TYPE" find-cmd$
                if      get1cmd
                        begin   s" TYPE" next-cmd$
                                tblcnt maxtbl < and
                        while   get1cmd
                        repeat
                then    ;

: read_keeppath  ( -- )                  \ KEEPPATH ON  or  KEEPPATH OFF
                s" KEEPPATH" find-cmd$
                if      after-cmd
                        drop 1+ c@ upc 'N' =    \ second letter is N of "oN"
                        to ?keeppath
                then    ;

: cfg-open?     ( -- f1 )       \ open the configuration file
                &WINED.CFG count r/o open-file     \ init filename
                0=
                if        to search-hndl
                        TRUE
                else    drop
                        0 to search-hndl
                        FALSE
                then    ;               \ f1=TRUE on successful open

: cfg-init      ( -- )
                0 to after-col                  \ start looking at 0
                250 to before-col               \ look up to char 250
                '\' to stop-char                \ stop character=\
                FALSE to tblcnt                 \ command count=0
                wtbl b/tbl maxtbl * erase       \ initialize table
                FALSE to ?global                \ no global searching
                FALSE to eof?                   \ initially not end of file
                exclude-buf off                 \ clear exclude list
                s" *."        mask-ptr  place
                defext$ count mask-ptr +place   \ default to default file extension
                &forthdir count base-path place
                search-path count base-path +place ;

: read-config   ( -- )          \ read the hypertext word table for
                                \ building the index file.
                cfg-init
                cfg-open?
                if      read_dirs               \ read the directory list
                        read_specs              \ read file spec masks
                        read_after              \ read where to start in line
                        read_before             \ read before limit length
                        read_stopper            \ read stop char
                        read_cmds               \ read compiler commands
                        read_exclude            \ excluded file list
                        read_keeppath           \ should path be in index
                        search-hndl close-file drop
                else    0 wtbl c!               \ type is zero
                         s" �" wtbl 1+ place    \ string is "�"
                then    ;

: build-index-message { index$ -- }
                s" Building HyperText Index...\n\nPath: " index$  place
                search-path count                         index$ +place
                s" \nMask: "                              index$ +place
                mask-ptr count                            index$ +place
                s" \nFile: "                              index$ +place
                name-buf count                            index$ +place
                s"   line: "                              index$ +place
                input-line# 0 (d.)                        index$ +place
                s" \n\nPress ESC to abort\n"              index$ +place ;

: .indexing     { \ index$ -- }
[defined] MessageText: [if]
                MAXSTRING localAlloc: index$
                index$ build-index-message
                index$ count MessageText: msg-window
                Refresh: msg-window
                key?
                if      key K_ESC = to search-aborted?
                then
[then]		;

: .indexing-start { \ index$ -- }
                MAXSTRING localAlloc: index$
                index$ build-index-message
                index$ count "top-message
                false to search-aborted? ;

: index-1line   ( -- f1 )
                input-line-buf count
                before-col min after-col /string

\ February 13th, 2003
\ rbs ->
                stop-char '\' =
                \ use Forth syntax (i.e., needs bl delimiters)
                if  \ if first on the line len = 0
                    over c@ stop-char =
                    if    drop 0 tuck
                    else  \ look for bl delimiters
                          2dup s"  \ " search
                          if   nip - tuck
                          else 2drop tuck
                          then
                     then
                else \ use asm, C, etc.
                     2dup
                     stop-char scan
                     nip - tuck
                then ( len adr len )
\ <- rbs
                thisline 2!

                0>
                input-line-buf 1+ c@
                dup  stop-char <>
                swap '('       <> and and
                if   search.words
                then ;

: index-1file   ( -- )
                exclude-file? ?exit
                0 to input-line#
                .indexing
                0.0 search-hndl reposition-file drop
                FALSE to eof?
                FALSE to fstime?
                begin   iline-read              \ read a line
                        eof? 0=                 \ while not end of file
                        search-aborted? 0= and  \ and user doesn't want to abort
                while   index-1line             \ index the line
                        input-line# 127 and 0=
                        if      .indexing
                        then
                repeat  .indexing ;

: build-index   ( --- )

		current-dir$ \ save current directory
		&forthdir 1+ $current-dir! drop \ set current directory

                .indexing-start
                read-config
                make-index
                if      ['] index-1file is process-1file  \ setup processor
                        reset-index                       \ clear output buf
                        do-files-process                  \ process all files
                        close-index
                then    message-off
                base-path count search-path place
                search-aborted?
                if      s" User Aborted Index Compile\n" "message
                        FALSE to search-aborted?
                else    s" Index Compile Complete\n" "message
                then    1 seconds message-off

		$current-dir! ; \ restore current directory

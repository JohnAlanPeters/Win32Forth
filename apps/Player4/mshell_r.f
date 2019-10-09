anew mshell_rel.f        \ March 5th, 2006  for Win32Forth Version: 6.11.07

\ A flexible shellsort.

\ Notes when mapped files are used:
\ 1.The database and the pointers must be mapped.
\ 2.Minimum file size of the database must be 1 byte.
\ 3.When the database is resized, the database has to be re-mapped.

\ Characteristics:
\ This version uses relative as pointers. So there is no need
\ to generate the same pointers again when they are saved in a file.
\ Multiple keys can be used and sorted in one go.
\ The number of keys is only limited by the unused size of the stack.
\ Each key can be sorted in an ascending or descending way.
\ A key may contain a byte, word, cell, float or a string.
\ The sort is case-insensitive for stings.
\ Easy to expand to sort doubles etc.

needs w_search.f    \ Included in Win32Forth Version: 6.11.07

\ :INLINE was posted in comp.lang.forth by Marcel Hendrix about September 9th, 2001

: next_char ( -- char ) \ next-char was used in float.f
        source >in @ <= if  drop -1 exit  endif
        >in @ chars + c@  ;

: skip-line ( -- )
        begin  next_char -1 <>
        while  1 >in +!
        repeat ;

: @+            ( adr -- adr n ) dup cell+ swap @ ;

\ Embedded linebreaks are allowed. Maximum length is 4096 characters.
\ Not allowed: EXIT LOCALS| DLOCALS| FLOCALS| , DOES> R> DROP etc.
\ It needs a space as the first character on each line

: multi-line ( quote "ccc<quote>" tmp-buffer -- str len )
        0 locals| ch buff quote |
        buff off
        begin
          next_char to ch
          ch '\' = if  skip-line  -1 to ch          endif
          ch -1  = if  bl to ch refill  else  true  endif
        while
          ch quote <>
        while
          ch  buff @+ +  c!  1 buff +!  1 >in +!
          buff @ 4096 >=
        until then then
        buff @+  refill drop ;


: :inline ( ccc; -- )
        create  immediate
                ';'
                4096 cell+ chars malloc dup>r
                multi-line  ( addr u tmp-buffer )
                dup , here cell+ ,
                here over allot  swap move
                r> release
        does>   2@ evaluate ;

    23 value record-size
   112 value #records
     0 value aptrs  \ an array of cells containing pointers to records
     0 value records-pointer

:inline n>aptr   ( n -- a )    aptrs +cells                 ;
:inline r>record ( n -- a )    records-pointer ( CHARS) +   ;
:inline record>r ( a -- n )    records-pointer ( CHARS) -   ;
:inline n>record ( n -- a )    n>aptr @ r>record            ;
\ :inline n>key    ( n -- a )  n>record >key                ;
:inline records  ( n -- ra )   record-size *                ;
:inline >record  ( n -- a )    records r>record             ;
:inline xchange  ( a1 a2 -- )  dup>r @ over @ r> ! swap !   ;
:inline &key-len ( key - &key-len )    cell+                ;
:inline >key     ( ra - key-start )    by @ +               ;
:inline key-len  ( ra - cnt )          by &key-len @        ;

:inline <>=      ( n1 n2 - -1|0|1 )
    2dup = if  2drop 0  else <  if 1 else  true  then  then ;

:inline f<>=      ( f1 f2 - -1|0|1 )
    f2dup f= if  f2drop 0  else f<  if 1 else  true  then  then ;

: cmp-bytes  ( cand1 cand2 by - n )  locals| by |  >key c@ swap >key c@ <>=  ;
: cmp-words  ( cand1 cand2 by - n )  locals| by |  >key w@ swap >key w@ <>=  ;
: cmp-cells  ( cand1 cand2 by - n )  locals| by |  >key @  swap >key @  <>=  ;
: cmp-floats ( cand1 cand2 by - n )  locals| by |  >key f@      >key f@ f<>= ;

: cmp$     ( cand1 cand2 by - n )
   locals| by |  swap >key swap >key key-len tuck compareia ;

: mod-cell    ( n adr offset - ) >r swap r> cells+ ! ;
: Ascending   ( key - key ) dup  0 2 mod-cell ;
: Descending  ( key - key ) dup -1 2 mod-cell ;
: $sort       ( key - )     ['] cmp$       3 mod-cell ;
: byte-sort   ( key - )     ['] cmp-bytes  3 mod-cell ;
: word-sort   ( key - )     ['] cmp-words  3 mod-cell ;
: bin-sort    ( key - )     ['] cmp-cells  3 mod-cell ;
: float-sort  ( key - )     ['] cmp-floats 3 mod-cell ;

:inline Descending? ( key - )      2 cells+ @ ;

\ Ascending and cmp$ are default in key:
: key: \ Compiletime: ( start len -< name >- )  Runtime: ( - adr-key )
   create swap , , 0 , ['] cmp$ ,
 ;

:inline by[ ( R: -  #stack )                   depth >r   ;
:inline ]by ( - #stack-inc) ( R: #stack - )    depth r> - ;

: CmpBy  ( cand1 cand2  ByStackTop #keys - f )
   true   locals| flag #keys  ByStackTop cand2 cand1 |
   #keys 0
        do   cand1 cand2  ByStackTop i cells+ @ dup 3 cells+ @ execute
             dup 0=
                if    drop
                else   ByStackTop i cells+ @ Descending?
                        if    0<
                        else  0>
                        then
                      to flag leave             \ 0=exch
                then

        loop
   flag
 ;

: xdrop ( nx..n1 #n - )    locals| #n |    sp@ #n cells+ sp!  ;

: mshell-rel  ( keyx..key1 #keys aptrs #records -- )
    sp@ 3 cells+ 3 roll   locals| #keys by |
    dup 2 <
      if    2drop
      else  1  begin  3 * 1+ 2dup 1+ u< until  \ gap*3
            begin  3 / dup
            while  2dup - >r dup cells r> 0
                      do  dup 4 pick dup i cells +
                            do  dup i + dup @ r>record
                                i tuck @ r>record  by #keys CmpBy
                                    if    2drop  leave
                                    then
                                xchange dup negate
                            +loop  drop
                       loop  drop
           repeat  2drop drop
      then
    #keys xdrop
  ;

\ : check-keys  ( -- )
\    space #records 1-
\    0 do  i n>key i 1+ n>key  key-len tuck compareia 0>
\      if ." UN" leave then loop ." sorted " ;

: create-file-ptrs ( name -- )
   count r/w create-file abort" Can't create index file."  close-file throw
 ;

: open-file-ptrs ( name -- hndl )
   count r/w open-file abort" Can't open index file."
 ;

: extend-file ( size hndl - )
    dup>r file-size drop d>s +
    s>d r@ resize-file abort" Can't extend file."
    r> close-file  drop
 ;

: add-ptrs ( #start #end - )
   dup to #records swap
      do  i records aptrs i cells + !
      loop
 ;

: build-ptrs ( #records -- ) 0 swap  add-ptrs ;

: #RecordsInDatabase ( record-size m_hndl - #records )  >hfileLength @ swap / ;

: CreateIndexFile ( counted$ #records - f )
   cells
   over create-file-ptrs
   swap open-file-ptrs
   extend-file
 ;

\s

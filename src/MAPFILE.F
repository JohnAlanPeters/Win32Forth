\ $Id: MAPFILE.F,v 1.9 2008/06/16 03:35:15 camilleforth Exp $
\ MAPFILE.F             File Memory Mapping             by Tom Zimmer
\ arm 02/01/2005 21:42:24 DOMAP , instead of DOMAP COMPILE,

cr .( Loading File Memory Mapping...)

IN-APPLICATION

CFA-CODE DOMAP  ( -- a1 )               \ runtime for CREATE and VARIABLE
                push    ebx
                lea     ebx, 4 [eax]
                next    c;

: map-handle    ( -<name>- )    \ define a data structure to hold a mapped file
                HEADER DOMAP ,
                -1 ,                    \ hfile
                -1 ,                    \ hfileMapping
                 0 ,                    \ hfileAddress
                 0 ,                    \ hfileLength
                 0 ,                    \ hfileMaxLength
                 0 c, max-path 1- allot \ hfileName
                 ;


: map-field+    ( n1 n2 -<name>- n3 )
                ( a1 -- a2 )
                CREATE over + swap , nostack1
                DOES>   over body> @ domap <>
                        abort" Must be a MAP-HANDLE!"
                        @ + ;

0   cell map-field+ >hfile
    cell map-field+ >hfileMapping
    cell map-field+ >hfileAddress
    cell map-field+ >hfileLength
    cell map-field+ >hfileMaxLength
max-path map-field+ >hfileName
drop

6 proc CreateFileMapping
5 proc MapViewOfFile
2 proc FlushViewOfFile
1 proc UnmapViewOfFile
1 proc CloseHandle
3 proc OpenFileMapping

: create-file-map ( map-handle -- )
                dup >hfile @ -1 = abort" File must first be OPENED!"
                >r                      \               the file handle
                0                       \ *MapName      no name is specified
                r@ >hfileMaxLength @    \ MaxSizeLow    default or specified low size
                0                       \ MaxSizeHi     zero high part
                PAGE_READWRITE          \ fdwProtect    a read and writable file
                0                       \ psa           no security
                r@ >hfile @             \               the file handle
                Call CreateFileMapping r> >hfileMapping ! ;

: map-name      ( a1 n1 map-handle -- )
                >r 127 min r> >hfileName dup 128 erase place ;

: map-view-file ( map-handle -- )
                dup >hfileMapping @ -1 =
                abort" File must first be OPENED and MAPPED!"
                >r
                0                       \ amount of file to map=all of it
                0 0                     \ starting address of file
                FILE_MAP_WRITE
                r@ >hfileMapping @
                call MapViewOfFile ?dup 0=
                IF      Call GetLastError
                        cr ." Map-View Error: " . abort
                ELSE    r@ >hfileAddress !
                THEN    r>drop ;

: flush-view-file ( map-handle -- f1 )  \ flush the file to disk
                dup  >hfileLength  @
                swap >hfileAddress @
                Call FlushViewOfFile 0= ;

: unmap-view-file ( map-handle -- f1 )
                >hfileAddress @
                Call UnmapViewOfFile 0= ;

: close-map-file ( map-handle -- f1 )
                dup >hfile @ -1 =
                IF       drop 0
                ELSE       dup  unmap-view-file >r
                           dup  >hfileMapping @ call CloseHandle 0= >r
                        -1 over >hfileMapping !
                           dup  >hfile        @ call CloseHandle 0= >r
                        -1 swap >hfile        !
                        r> r> or r> or
                THEN    ;

: open-map-file ( a1 n1 map-handle -- f1 )
                >r
                r@ close-map-file drop
                r@ map-name
                r@ >hfileName count r/w open-file
                -IF     nip
                ELSE    swap    r@ >hfile !
                                r@ >hfile @ file-size 2drop
                                r@ >hfileLength !
                                r@ create-file-map
                                r@ map-view-file
                THEN    r>drop ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Shared memory functions
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: close-share   ( memory_pointer handle -- )
                call CloseHandle drop
                Call UnmapViewOfFile drop ;

0 value i-was-first

: open-share    ( z"name" length -- memory_pointer handle )
                FALSE to i-was-first
                over
                FALSE
                FILE_MAP_WRITE
                call OpenFileMapping ?dup 0=
                IF
                                           \ *MapName   no name is specified
                                           \ MaxSizeLow shared memory size
                        dup to i-was-first \ save size as a flag
                        0                  \ MaxSizeHi  zero high part
                        PAGE_READWRITE     \ fdwProtect a read and writable file
                        0                  \ psa        no security
                        -1                 \            the file handle
                        Call CreateFileMapping
                ELSE    nip nip
                THEN
                -IF      >r
                        0                  \ amount of file to map=all of it
                        0 0                \ starting offset into file
                        FILE_MAP_WRITE
                        r@ call MapViewOfFile ?dup 0=
                        IF      r> Call CloseHandle drop
                                0 FALSE
                        ELSE                \ -- mapped_address
                                i-was-first \ if first, erase buffer
                                IF      dup i-was-first erase
                                THEN
                                r>         \ -- mapped_address file_handle
                        THEN
                ELSE    drop 0 FALSE       \ failed, return failure flag
                THEN    ;

\S

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       simple memory file mapping example
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

map-handle ahndl

: mapfile       ( -<name>- a1 n1 )      \ map file name into memory
                /parse-word count ahndl open-map-file
                abort" Failed to open and map the file!"
                ahndl >hfileAddress @
                ahndl >hfileLength  @ ;

: unmapfile     ( -- )                  \ unmap and close the file
                ahndl close-map-file drop ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       shared memory example
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

0 value share-hndl
0 value share-ptr

: share         ( -- )
                z" SharedFile" 4096 open-share ?dup 0=
                abort" Failed to open shared memory"
                to share-hndl
                to share-ptr ;

: unshare       ( -- )
                share-ptr share-hndl close-share
                0 to share-ptr
                0 to share-hndl ;

: .share        ( -- )
                share-ptr 0= abort" Nothing shared!"
                share-ptr 40 dump ;

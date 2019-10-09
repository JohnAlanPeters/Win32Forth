\ $Id: SUB_DIRS.F,v 1.10 2011/09/09 11:16:09 jos_ven Exp $
anew -sub_dirs.f

\ For scanning and processing files of 1 directory or a whole tree.
\ Extracted from WinView and changed by J.v.d.Ven.

\ May 31st, 2003 Now it uses one big heap so that it does not have
\ to re-allocate memory again.
\ Now sdir will also need a flag on the stack for handling of subdirectorys

\ July 4th, 2003 - 17:28 Changed for use in WinEd 2.21.00 - dbu

\ September 9th, 2011 Added sub_dir_access.
\ Using FILE_READ_ATTRIBUTES in it is faster and can be used when you do not need to open a file.
\ R/O is needed for the IDE or WinEd

IN-APPLICATION

INTERNAL \ Hide a number of words

create mask-buf here  max-path + ," *.f" 0 , here - allot

EXTERNAL

mask-buf value mask-ptr
create name-buf MAXSTRING allot
TRUE  value sub-dirs?
FALSE value search-aborted?
    0 value search-hndl     \ handle of file we are searching
TRUE  value open-file?      \ do we want the file opened?

defer process-1file   ' noop is process-1file   \ holds function for processing a file

INTERNAL

2variable mask-source
R/O value sub_dir_access

: next-mask"    ( -- a1 n1 )            \ get the next path from dir list
                mask-source 2@ 2dup ';' scan  2dup 1 /string mask-source 2!
                nip - ;

: first-mask"   ( -- a1 n1 )            \ get the first forth directory path
                mask-ptr count mask-source 2!
                next-mask" ;

\ changed for use in WinEd - July 5th, 2003 - 8:58 dbu
: process-afile ( adrd adr len -- )     \ search this file for find string
        name-buf  place                 \ lay in directory
        11 cells+                       \ adrz
        zcount                          \ adrz slen -- adr len
        name-buf +place                 \ append filename
        open-file?
        if      name-buf count sub_dir_access open-file 0=     \ open the file
                IF      to search-hndl              \ store file handle
                        process-1file               \ process it
                        search-hndl close-file drop \ close file
                        0 to search-hndl
                ELSE    drop
                THEN
        else    process-1file                       \ simply process file
        then    ;

create buf max-path allot

\ changed for use in WinEd - July 5th, 2003 - 8:58 dbu
: "process-mask-directory { adr1 len1 adr2 len2  -- }
                len1
                IF      adr2 len2 buf  place
                        adr1 len1 buf +place
                        buf count find-first-file 0=
                        IF      adr2 len2 process-afile
                                BEGIN   find-next-file 0=      \ file level
                                        search-aborted? 0= and
                                WHILE   adr2 len2 process-afile
                                REPEAT  drop
                                find-close drop \ 0= abort" err"
                        ELSE    drop
                        THEN \ find-close drop \ 0= abort" err"
                THEN

                ;

variable _hdl-dir                       \ hold the find directory handle

2 PROC FindFirstFile
2 PROC FindNextFile
: next-sub-dir"      ( -- sub-dir sub-len )     \ "first-sub-dir" must be called first
        BEGIN   _win32-find-data                                \ lpffd - _WIN32_FIND_DIR
                _hdl-dir @                                      \ hFindFile
                call FindNextFile                               \ ior -
                IF      _win32-find-data @                      \ file_attributes
                        FILE_ATTRIBUTE_DIRECTORY and            \ is the dir bit set
                        IF      _win32-find-data 11 cells+      \ adrz
                                zcount                          \ -- adr len
                                2dup s" ."  compare 0= >r
                                2dup s" .." compare 0=  r> or   \ ignore either '.' or '..'
                        ELSE    0 0 TRUE                        \ try again
                        THEN
                ELSE    0 0 false
                THEN
        WHILE   2drop
        REPEAT  ;

: "first-sub-dir"    { adr len -- sub-adr sub-len }
        adr len asciiz                          \ adrz -
        _win32-find-data                        \ lpffd - _WIN32_FIND_DIR
        swap                                    \ lpszSourceFile
        call FindFirstFile                      \ a search handle if O.K.
                                                \ else INVALID_HANDLE_VALUE
        _hdl-dir !                              \ store to the search handle
        _hdl-dir @ -1 <>                        \ adrd ior = 0 = success
        IF      _win32-find-data @              \ file_attributes
                FILE_ATTRIBUTE_DIRECTORY and    \ is the dir bit set
                IF      _win32-find-data 11 cells+
                        zcount                  \ -- adr len
                        2dup s" ."  compare 0= >r
                        2dup s" .." compare 0=  r> or   \ ignore either '.' or '..'
                        IF      2drop                   \ discard adr,len
                                next-sub-dir"           \ find a sub directory
                        THEN                            \ we found a directory
                ELSE    next-sub-dir"                   \ find a sub directory
                THEN
        ELSE    0 0
        THEN    ;

: sub-dir-close ( -- ior )      \ close the _hdl-dir handle
        _hdl-dir @ call FindClose 0= ;          \ ior - 0 = success

0 value mHndl
0 value #mHndl
0 value HeapBuffer

: new-buffer ( - adr )    HeapBuffer #mHndl max-path * +  ;

: "process-directory { adr len  \ buf1 buf2 -- }
                len
                if
\ cr adr len type ." <-process dir"
                    \ allocate two buffers in case we need are nesting dirs
                    new-buffer
                    dup to buf1 max-path + to buf2  \ init the buffer pointers
                    1 +to #mHndl
                        adr len     buf1 place          \ save the name
                                    buf1 ?+\            \ must end in '\'
                        first-mask" buf1 count "process-mask-directory
                        BEGIN       next-mask" dup
                                    search-aborted? 0= and
                        WHILE       buf1 count "process-mask-directory
                        REPEAT      2drop
                        sub-dirs?                       \ processing sub directories?
                        IF      buf1 count buf2  place
                                s" *"      buf2 +place
                                buf2 count "first-sub-dir" ?dup
                                IF
\ cr 2dup type ."   <======= first subdir"
                                        buf1 count buf2  place          \ init to parent
                                                   buf2 +place          \ append sub dir
                                                   buf2 ?+\             \ add '\' if needed
                                        _hdl-dir @ >r                   \ save before recursing
                                        buf2 count  RECURSE             \ recursively repeat
                                        r> _hdl-dir !                   \ restore from recursion
                                        BEGIN   next-sub-dir" dup
                                                search-aborted? 0= and
                                        WHILE
\ cr 2dup type ."  <---- next subdir"
                                                buf1 count buf2 place   \ init to parent
                                                buf2 +place             \ append sub dir
                                                buf2 ?+\                \ add '\' if needed
                                                _hdl-dir @ >r           \ save before recursing
                                                buf2 count  RECURSE     \ recursively repeat
                                                r> _hdl-dir !           \ restore from recursion
                                        REPEAT  2drop
                                        sub-dir-close drop              \ close dir find
                                ELSE    drop
                                THEN
                        THEN
                      -1 +to #mHndl
\ cr #mHndl .
                THEN    ;

Path: sdir-path

EXTERNAL


: (do-files-process ( path -- )
      >r false to search-aborted?
      r@ first-path" "process-directory
                BEGIN   r@ next-path" dup
                        search-aborted? 0= and
                WHILE   "process-directory
                REPEAT  2drop r>drop
                ;

: do-files-process ( -- )  \ In the Forth-part
        search-path   (do-files-process
        ;

INTERNAL

3 PROC HeapCreate
3 PROC HeapAlloc
: init-heap-buffer
   0 to #mHndl
   0 [ 260 260 * 2 * ] literal dup>r HEAP_GENERATE_EXCEPTIONS  call HeapCreate to mHndl
   r>  HEAP_GENERATE_EXCEPTIONS mHndl call HeapAlloc to HeapBuffer
 ;

init-heap-buffer
initialization-chain chain-add init-heap-buffer

1 PROC HeapDestroy
: delete-heap ( - )
    mHndl call HeapDestroy ?win-error
 ;

UNLOAD-CHAIN chain-add delete-heap

: list-file  ( -- )   cr name-buf count type  ;

\ Tell sdir what to do for each file
' list-file is process-1file

EXTERNAL

: sdir ( path count file-spec count flag-subdir - )
        to sub-dirs?
        mask-buf place    mask-buf +NULL
        sdir-path place   sdir-path +NULL
        sdir-path (do-files-process
        true to open-file?      \ always default
;

MODULE

\s


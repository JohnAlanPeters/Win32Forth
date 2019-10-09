\ $Id: ANSFILE.F,v 1.12 2010/02/04 21:18:43 georgeahubert Exp $

\ *D doc
\ *! p-ansfile W32F ansfile
\ *T File and directory searching words.

\ *P These words are extensions to the ANSI file words for finding files.
\ The ANSI words are defined in the kernel.
\
\ The words defined in this file follow the draft proposed AMERICAN
\ NATIONAL Standard for Information System - Programing Language - Forth
\ - June 30, 1993
\
\ ** If ior = 0, operation is O.K.; Otherwse, it is a failure.


\ ansfile.f beta 2.0A 2002/08/31 arm windows ANS file words
\ ansfile.f beta 2.9G 2002/09/24 arm release for testing
\ ansfile.f beta 3.3D 2002/10/08 arm Consolidation
\ made thread-safe Saturday, August 07 2004 - 0:15 gah

cr .( Loading ANSI File Wordset...)

only forth also definitions

5 PROC GetDiskFreeSpace
2 PROC FindFirstFile
2 PROC FindNextFile
1 PROC FindClose
3 PROC FileTimeToDosDateTime
4 PROC GetFileTime
2 PROC FileTimeToSystemTime

\ *S Glossary

cell newuser _hdl-search ( -- addr )
\ *G Variable holding handle.
         _hdl-search off

cell newuser #files                     \ number of files found
cell newuser total-file-bytes           \ total bytes in files found

11 cells max-path + 14 + nostack1
newuser _win32-find-data                \ struct FindFileFirst or
                                        \ FindNextFile Functions
\   0 ,                                 \ dwFile Attributees
\   0 , 0 ,                             \ ftCreationTime - FILETIME -
\                                       \ (struct) dwLowDateTime
\                                       \          dwHighDateTime
\   0 , 0 ,                             \ ftLastAccessTime - FILETIME
\   0 , 0 ,                             \ ftLastWriteTime - FILETIME
\   0 ,                                 \ nFileSizeHigh
\   0 ,                                 \ nFileSizeLowh
\   0 ,                                 \ dwReserved0
\   0 ,                                 \ dwReserved1
\   MAX-PATH allot                      \ cFileName[MAX_PATH]
\   14 allot                            \ cAlternateFileName[14]

2 newuser ptr-DOS-date                  \ ptr to 16 bit DOS date
2 newuser ptr-DOS-time                  \ ptr to 16 bit DOS time

16 Constant sizeof(_systemTime)
0  newuser _systemtime
\ *G Structure FileTimeToSystemTime
\ ** function; this struc is same as time-buf in kernel.tom
2  newuser wYear
2  newuser wMonth
2  newuser wDayOfWeek
2  newuser wDay
2  newuser wHour
2  newuser wMinute
2  newuser wSecond
2  newuser wMilliseconds

\ ------------------------------------------------------------------------
\       Some case insensitive version of search and compare
\ ------------------------------------------------------------------------

\ enhanced caps-search for source string > 255 bytes
\ search for t-adr,t-len within string s-adr,s-len. f1=true if string was found
: CAPS-SEARCH  ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
\ *G Search the string specified by c-addr1 u1 for the string specified by c-addr2 u2,
\ ** using a case-insensitive search. \n
\ ** If flag is true, a match was found at c-addr3 with u3 characters remaining. \n
\ ** If flag is false there was no match and c-addr3 is c-addr1 and u3 is u1.
        { s-adr s-len t-adr t-len \ t-buf t-str -- adr len flag }
        MAXSTRING localalloc: t-str
        s-len cell+ ALLOCATE 0=
        IF      to t-buf                    \ make a buffer big enough for s-adr
                t-adr t-len t-str place
                t-str count upper
                s-adr t-buf s-len move
                t-buf s-len upper
                t-buf s-len t-str count search
                IF      nip                     \ discard found address
                        s-len swap -            \ offset where string was found
                        s-adr s-len rot /string
                                      \ location of found string in original buf
                        TRUE
                ELSE    2drop
                        s-adr s-len FALSE
                THEN
                t-buf FREE drop
        ELSE    s-adr s-len FALSE             \ failed, couldn't allocate buffer
        THEN    ;

\ COMPARE compares two strings, ignoring case. The return value is:
\
\        0 = string1 = string2
\       -1 = string1 < string2
\        1 = string1 > string2
: CAPS-COMPARE  { sa1 sn1 sa2 sn2 \ st1 st2 -- f1 }
                MAXSTRING LocalAlloc: st1
                MAXSTRING LocalAlloc: st2
                sa1 sn1 st1 place  st1 count upper
                sa2 sn2 st2 place  st2 count upper
                st1 count st2 count compare ;


: get-fspace { zroot \ clus freclus b/sec s/clus -- as bs cs ds }
\ *G Get a drive's free space, cluster and sector information
\ ** "zroot" is the root directory spec zString for the desired drive in the
\ ** format z" x:\", where x can be a, b, c, d or e etc...
        &of clus                             \ lpClusters - bs
        &of freclus                          \ lpFreeClusters - as
        &of b/sec                            \ loBytesPerSector - ds
        &of s/clus                           \ lpSectorsPerCluster - cs
        zroot                                   \ lpszRootPathName
        call GetDiskFreeSpace
        if      freclus  clus                   \ as bs -
                s/clus  b/sec                   \ as bs cs ds -
        else    0 0 0 0                         \ 0 0 0 0 - for failure
        then    ;


: find-first-file ( addr1 len1 -- addr2 ior )
\ *G addr1 len1 is a string that specifies a valid directory or path
\ ** and filename, which can contain wildcard characters (* and ?).
\ ** This string must not exceed MAX_PATH characters.
\ ** addr2 is the address of the _win32-find-data structure.
\ ** ior is 0 for success in which case _hdl-search contains a valid handle.
\ *P Find-First-File searches a directory for a file whose name matches the
\ ** specified filename. Find-First-File examines subdirectory names as well as filenames.
\ *P Find-First-File opens a search handle and returns information about the first
\ ** file whose name matches the specified pattern. Once the search handle is established, you
\ ** can use Find-Next-File to search for other files that match the same pattern.
\ ** When the search handle is no longer needed, close it by using Find-Close.
\ ** Find-First-File searches for files by name only; it cannot be used for attribute-based
\ ** searches.
   max-path malloc dup>r
   ascii-z                                   \ adrz -
   _win32-find-data                          \ lpffd - _WIN32_FIND_DATA
   swap                                      \ lpszSourceFile
   call FindFirstFile                        \ a search handle(hdl if O.K.
                                             \ else INVALID_HANDLE_VALUE)
   _hdl-search !                             \ store to the search handle
   _win32-find-data                          \ adrd -
   _hdl-search @ -1 =                        \ adrd ior - 0 = success
   r> release ;                              \ free buff

: find-next-file ( -- addr ior )
\ *G Find-first-file word must be called
\ ** before this word can be called due to the fact that _hdl-search is needed
   _win32-find-data                          \ lpffd - _WIN32_FIND_DATA
   _hdl-search @                             \ hFindFile
   call FindNextFile                         \ ior -
   _win32-find-data                          \ ior adrd -
   swap 0= ;                                 \ adrd ior - 0 = success

: find-close ( -- ior )
\ *G Close the _hdl-search handle.
   _hdl-search @
   call FindClose 0= ;                       \ ior - 0 = success

internal


: (DOSTime)               ( n -- )
   ptr-DOS-time ptr-DOS-date rot                 \ ptr's to 16 bit DOS time & date
   _win32-find-data swap cells+
   call FileTimeToDosDateTime drop ;

external

: get-DOS-create-datetime ( -- ;convert 64 bit file time to MS_DOS )
\ *G Date and time values of creation. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word.
   1 (DOSTime) ;

: get-DOS-access-datetime ( -- ;convert 64 bit file time to MS_DOS )
\ *G date and time values of last access. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word.
   3 (DOSTime) ;

: get-DOS-write-datetime ( -- ;convert 64 bit file time to MS_DOS )
\ *G Date and time values of last write. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word.
   5 (DOSTime) ;

: get-file-size ( -- size )  \ W32F               Files Extra
\ *G Size of the last found file. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word.
   _win32-find-data 8 cells+ @ ;

: get-file-name ( -- adr; address for file name )
\ *G get the name of the last found file. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word.
   _win32-find-data 11 cells+ ;

: dir-attribute?  ( - flag )
\ *G Returns true when a file is a directory. \n
\ ** You need to call find-first-file or find-next-file word in the current task
\ ** before using this word. \n
\ ** Can be used in combination with ForAllFileNames
        _win32-find-data @ FILE_ATTRIBUTE_DIRECTORY and ;

2 cells newuser file-time-buf
\ *G 2Variable to hold the FILETIME structure, which is a little endian (i.e. reversed order)
\ ** 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601.

: get-file-modified ( fileid -- system-time )
        >r
        file-time-buf 2 cells erase     \ pre-clear buffer
        file-time-buf                   \ address of where to put the file's
                                        \ last written time and date
        0                               \ last access time not needed
        0                               \ creation time not needed
        r> call GetFileTime drop

        _systemtime                     \ where to put results
        file-time-buf                   \ file time/date to convert
        call FileTimeToSystemTime drop
        _systemtime ;

: filetime-to-systemtime ( cell# -- ; convert file time to system time )
\ need to call find-first-file or find-next-file word
\ before using this word
\ cell# is offset in number of cells to _win32-find-data
\ 1 for creation time; 3 for access time; and 5 for write time
\ normaly 5 should be used
   >r                                   \ cell# -> rstack
   _systemtime                          \ struct FileTimeToSystemTime
                                        \ function
   _win32-find-data r> cells+           \ struct FILETIME for
                                        \ ftWriteTime
   call FileTimeToSystemTime drop ;

\ ' zcount alias asciiz->asc-len       \ made a colon def - [cdo-2008May13]
: asciiz->asc-len ( adrz -- sadr slen )
        zcount ;

: dir->file-name ( -- adr count )
\ *G Returns the address and count of a file in a directory. \n
\ ** Need to call find-first-file or find-next-file word before using this word. \n
\ ** Can be used in combination with ForAllFileNames
        get-file-name zcount ;

: ForAllFileNames { cfa } ( adr slen cfa -- )
\ *G Executes the CFA for each found file in a directory. \n
\ ** A file specification adr slen may contain wildcards \n
\ ** NOTE: Directory names are also considered to be a file-name. \n
\ ** Directory names can be detected by dir-attribute?
        0 #files !                              \ reset # of files in dir
        find-first-file nip                     \ adrd ior - find first file
        0 <>    if      exit    then            \ if file is not found, exit
        dir->file-name   get-file-name 0>
                if      cfa execute 1 #files +!
                else    2drop
                then

                begin   find-next-file nip 0=   \ ior - find next file
                while   get-file-name 0>
                        if      1 #files +!  dir->file-name cfa execute
                        then
                repeat
        find-close drop ;

: ForAllFiles     (  cfa -- )
\ *G Executes the CFA on ALL found files in a directory. \n
\ ** NOTE: Directory names are also considered to be a file-name. \n
\ ** Directory names can be detected by dir-attribute? \n
        s" *.*" rot ForAllFileNames  ;


IN-SYSTEM


: .dir->file-name ( -- ;print file name in the dir )
        _win32-find-data 11 cells+              \ adrz
        zcount                                  \ adrz scan-len slen
        dup>r type                              \ adrz len  ;print file name
        12 r> - 0max spaces ;  deprecated


: .dir->file-size ( -- )
\ *G Print the size or directory indication of a file \n
\ ** Need to call find-first-file or find-next-file word before using this word. \n
\ ** Can be used in combination with ForAllFileNames
        dir-attribute?
                if   ."          dir "
                else    get-file-size dup 12 u,.r space \ print nFileSizeLow
                        total-file-bytes +!
                then ;

dpr-warning? dpr-warning-off checkstack

: _print-dir-files ( adr slen -- )
                0 total-file-bytes !
                0 #files !                           \ reset # of files in dir
                find-first-file nip                  \ adrd ior - find first file
                0 <> if exit then                    \ if file is not found, exit
                cr .dir->file-size                   \ print the size of file
                   .dir->file-name                   \ print the filename found
                1 #files +!                          \ update file number
                BEGIN find-next-file nip 0=          \ ior - find next file
                WHILE   1 #files +!                  \ update file number
                        25 ?cr
                        .dir->file-size               \ print the size of file
                        .dir->file-name               \ and the name of file
                        start/stop
                REPEAT ; deprecated

to dpr-warning?

: .file-size-name  ( adr len - )
\ *G Print the size or directory indication and the name of file.
\ ** It also formats the line. \n
\ ** Need to call find-first-file or find-next-file word before using this word. \n
\ ** Can be used in combination with ForAllFileNames
        25 ?cr      .dir->file-size
        dup>r type  12 r> - 0max spaces
        start/stop ;


: print-dir-files ( adr slen -- ) \ W32F      Files Extra
\ *G Print all the files and sub-directories in a directory that match a specific
\ ** pattern.
        cr ." Directory of: " 2dup type cr
        0 total-file-bytes !                         \ reset total-file-bytes
        0 #files !                                   \ reset # of files in dir
        ['] .file-size-name ['] ForAllFileNames catch
                IF      3drop                        \ discard abort results
                THEN
        cr #files @ . ." Files displayed, using "
        total-file-bytes @ 1 u,.r ."  bytes of disk." ;

: dir           ( "name" -- )   \ W32F      Files Extra
\ *G Print all the files and sub-directories in a directory that match a specific
\ ** pattern. \n
\ ** If "name" is missing or ends in \ or / search for all files that match *.* \n
\ ** If "name" contains a relative path then it's relative to the current directory. \n
\ ** If "name" ends in : assume a drive use "name"\*.* for the search pattern. \n
\ *P The pattern can contain the standard Windows wildcards.
                /parse-word dup c@ 0=                 \ if not spec given, use *.*
                IF   s" *.*" pocket place
                THEN dup count + 1- c@ [char] : =     \ if just a drive, add \
                IF   s" \"   pocket +place
                THEN dup count + 1- c@ dup [char] \ = \ if it ends in a \,
                     swap [char] / = or               \ or a /, add *.*
                IF   s" *.*" pocket +place
                THEN count print-dir-files ;

: do-rename-afile { RenamePart1$ RenamePart2$ \ RenameTemp$ -- } \ rename one file
                MAXSTRING LocalAlloc: RenameTemp$
                dir->file-name
                2dup 2dup RenamePart1$ count caps-search
                IF      2dup 2>r nip -              RenameTemp$  place \ leading part
                        RenamePart2$ count          RenameTemp$ +place
                        2r> RenamePart1$ c@ /string RenameTemp$ +place
                        RenameTemp$ count rename-file ( adr1 len adr2 len -- ior=0=OK )
                        0=
                        IF      1 #files +!                    \ update file number
                        THEN
                ELSE    4drop 2drop
                THEN    ;

: rename        ( -<name1 part1 part2>- )     \ rename file or files
                { \ RenameFrom$ RenamePart1$ RenamePart2$ -- }
                MAXSTRING LocalAlloc: RenameFrom$
                MAXSTRING LocalAlloc: RenamePart1$
                MAXSTRING LocalAlloc: RenamePart2$
                /parse-s$ count RenameFrom$  place
                /parse-s$ count RenamePart1$ place
                /parse-s$ count RenamePart2$ place
                RenameFrom$  c@ 0>
                RenamePart1$ c@ 0> and
                RenamePart2$ c@ 0> and 0=
                IF      beep
                        cr ." Usage:"
                        cr ."    RENAME <filespec> <oldsubstring> <newsubstring>"
                        EXIT                    \ leave if no names specified
                THEN
                cr ." Rename Files: "
                RenameFrom$  count type ."  from: "
                RenamePart1$ count type ."  To: "
                RenamePart2$ count type
                0 #files !                                     \ reset # of files in dir
                RenameFrom$ count find-first-file nip 0=        \ adrd ior - find first file
                IF      RenamePart1$
                        RenamePart2$
                        do-rename-afile
                        BEGIN   find-next-file nip 0=           \ ior - find next file
                        WHILE   RenamePart1$
                                RenamePart2$
                                do-rename-afile
                        REPEAT find-close drop
                        cr #files @ . ." Files renamed"
                ELSE    cr ." No matching files Found"          \ if file is not found, exit
                THEN    ;

IN-APPLICATION

module

\ *Z

\ $Id: paths.f,v 1.42 2016/01/02 22:41:48 jos_ven Exp $

\ *D doc\
\ *! Paths
\ *T Paths -- Multiple search path support
\ *S Glossary

cr .( Loading Path Functions...)

IN-SYSTEM

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: .program      ( -- )
\ *G Type the program path.
                &prognam count type ;

: .forthdir     ( -- )
\ *G Type the forth directory.
                &forthdir count type ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  change directory
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-APPLICATION

: "chdir        ( a1 n1 -- )  { \ current$ }
\ *G Set the current directory.
                MAX_PATH 1+ LocalAlloc: current$ dup
                IF  current$ place current$ dup +null 1+ $current-dir! drop  ELSE  2drop  THEN ;

IN-SYSTEM

: .dir          ( -- )
\ *G Print the current directory.
                cr ." Current directory: " current-dir$ count type ;

: chdir         ( -<optional_new_directory>- -- )
\ *G Set the current directory.
                /parse-word count "chdir cr .dir ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\       Multiple directory path search capability for file open
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IN-APPLICATION

: path:  ( -- )
\ *G Defines a directory search path. \n
\ ** The first cell holds a pointer to 2 cells in the user area which are used to handle a search path. \n
\ ** The next 260 bytes are reserved for a counted string of a path. \n
\ ** followed by null. \n
\ ** At runtime it returns address of the counted string of a path.
        create  next-user @ , 2 cells next-user +! MAX-PATH 1+ allot  does>   \ run-time: ( -- path )
        cell +
        ;

INTERNAL

: path-source   ( path  -- 2variable_path-source )
\ *G Path-source points to a substring in a path. \n
\ ** Path-source returns this address.
        cell- @ up@ + ;

EXTERNAL

: next-path"    ( path -- a1 n1  )      \ w32f path
\ *G Get the next path from dir list.
                dup>r path-source 2@ 2dup ';' scan  2dup 1 /string r> path-source 2!
                nip -

                2dup s" %FORTHDIR%"   ISTR= if 2drop &forthdir    dup ?+\ count "path-only" exit then
                2dup s" %CURRENTDIR%" ISTR= if 2drop current-dir$ dup ?+\ count "path-only" exit then
                2dup s" %APPDIR%"     ISTR= if 2drop &prognam             count "path-only" exit then
                ;

: reset-path-source     ( path --  )    \ w32f path
\ *G Points the path-source to the whole path.
                dup>r count r> path-source 2! ;

: first-path"   ( path -- a1 n1  )      \ w32f path
\ *G Get the first forth directory path.
                dup>r reset-path-source  r> next-path" ;

: "path+        ( a1 n1 path -- )       \ w32f path
\ *G Append a directory to a path.
                >r 2dup upper
                2dup + 1- c@ '\' =  \ end in '\'?
                if      1- 0max     \ if so, delete it
                then    r@ first-path"                            \ get first path
                begin   dup 0> >r 2over compare 0<> dup r> and \ check it
                while   drop r@ next-path"                        \ and remaining paths
                repeat  0=              \ -- f1=true if already in list
                if      2drop
                else    dup r@ c@ if char+ then MAX-PATH >= abort" Path overflow"
                        r@ c@ if r@ ?+; then
                        r@ +place
                then    r>drop ;

in-system

: .path         ( path -- )             \ w32f path system
\ *G Display a directory search path list.
\ ** Note: The path source will be reset for this path.
                dup >r first-path"
                begin  dup
                       if   2dup cr type
                       then nip
                while  r@ next-path"
                repeat r> reset-path-source ;


in-application

INTERNAL

: volume-indication? ( addr -- flag )
\ True when the counted string at addr starts with x: or \\name
                dup 2 + c@ [char] : <>
                if   count drop 2 s" \\" compare 0=
                else drop true
                then ;

: save-current  ( current$ -- )
\ save current dir
                dup current-dir$ count rot place +null ;

: restore-current  ( current$ -- )
\ Restore current dir
                char+ $current-dir! not abort" $current-dir!" ;

create path-file$ MAX-PATH 1+ allot

6 PROC SearchPath

EXTERNAL
: full-path     { a1 n1 path \ searchpath$ filename$ current$ -- a2 n2 f1 }
\ *G Find the file \i a1,n1 \d in the path \i path \d and return the full path.
\ ** \i a2,n2 \d . \i f1 \d = false if successful.
                a1 n1 MAX-PATH 1+ LocalAlloc ascii-z to filename$ \ save file name

                MAX_PATH 1+ LocalAlloc: current$
                current$ save-current \ save current dir

                MAX-PATH 1+ LocalAlloc: searchpath$

                path first-path"
                begin dup
                      if    searchpath$ place searchpath$ +null

                            searchpath$ volume-indication?   \ Test for another volume
                            if   searchpath$ char+ $current-dir!  \ 0 fails, then try next
                            else true
                            then

                            if   path-file$ off
                                 0                 \ file component
                                 path-file$        \ found file name buffer
                                 max-path          \ size of buffer
                                 defextz$          \ file extension
                                 filename$         \ file name
                                 searchpath$ char+ \ search path
                                 call SearchPath 0<>
                                 if   path-file$ zcount false   \ path found
                                      current$ restore-current  \ restore current dir
                                      exit                      \ and exit
                                 else true \ try next path...
                                 then
                            else true \ $current-dir! failed. try next path...
                            then
                       else nip
                       then
                while  path next-path"
                repeat

                current$ restore-current \ restore current dir
                a1 n1 true ;  \ return input file and error flag

: find-path     { a1 n1 basepath path \ filename$ current$ search-current$ -- a2 n2 f1 }
\ *G Find the file \i a1,n1 \d in the path \i basepath \d by scanning the sub folders
\ ** defined in \i path \d. Returns the full path of the file if possible.
\ ** \i a2,n2 \d . \i f1 \d = false if succeeded.

                \ Note: We have to save the file name in a temporay buffer,
                \ because a1 n2 can point to the internal buffer new$ and
                \ this buffer can be changed during the search (by current-dir$
                \ for example).
                MAX-PATH 1+ LocalAlloc: filename$
                a1 n1 filename$ place \ save file name

                MAX_PATH 1+ LocalAlloc: current$
                current$ save-current \ save current dir

                MAX_PATH 1+ LocalAlloc: search-current$

                basepath first-path"
                begin  dup
                       if   \ set the next base folder we shall look in
                            search-current$ place search-current$ +null
                            search-current$ char+ $current-dir!

                            \ and try to find the file in this folder
                            if   filename$ count path full-path 0=
                                 if   current$ restore-current
                                      0 exit \ we found the file !!!
                                 else 2drop true \ try the next folder...
                                 then
                            then
                       else nip
                       then
                while  basepath next-path"
                repeat

                current$ restore-current \ restore current dir
                a1 n1 true ;  \ return input file and error flag

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  "open with Multiple directory path search
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

path: search-base-path                  \ w32f path
\ *G The path buffer for the base search folders for Forth.\n
\ ** Applications that let Forth compile should not change it.

path: search-path                       \ w32f path
\ *G The path buffer for the sub folders to search in.
\ ** Applications that let Forth compile should not change it.

: "fbase-path+  ( a1 n1 -- )            \ w32f path
\ *G Append a directory to the Forth search base path.
                search-base-path "path+ ;

: "fpath+       ( a1 n1 -- )            \ w32f path
\ *G Append a directory to the Forth search path.
                search-path "path+ ;

in-system

: fbase-path+   ( -<directory>- -- )    \ w32f path system
\ *G Append a directory to the Forth search base path.
                /parse-s$ count "fbase-path+ ;

: fpath+        ( -<directory>- -- )    \ w32f path system
\ *G Append a directory to the Forth search path.
                /parse-s$ count "fpath+ ;

: .fpath        ( -- )                  \ w32f path system
\ *G Display the Forth directory search path list.
                cr ." Base path: "   search-base-path .path
                cr ." Search path: " search-path      .path ;

in-application

: program-path-init ( -- )
\ *G Initialize the Forth directory search path list. Automatically done at program
\ ** initialization and when Paths.f is loaded.
                search-base-path off    \ clear path list
                s" %CURRENTDIR%" "fbase-path+
                s" %FORTHDIR%"   "fbase-path+
                s" %APPDIR%"     "fbase-path+

                search-path off          \ clear path list
                s" ."            "fpath+ \ current dir is first
                s" src"          "fpath+
                s" src\lib"      "fpath+
                s" src\gdi"      "fpath+ \ GDI class library
                s" src\tools"    "fpath+
                s" src\res"      "fpath+
                s" src\console"  "fpath+
                s" demos"        "fpath+
                s" help"         "fpath+ \ last
                s" help\html"    "fpath+
                ;

program-path-init
INITIALIZATION-CHAIN CHAIN-ADD PROGRAM-PATH-INIT

: "path-file    ( a1 n1 -- a2 n2 f1 )
\ *G Find file a1,n1 in the Forth search path and return the full path. \n
\ ** a2,n2 and f1=false, succeeded.
                search-base-path  search-path  find-path ;

MAXSTRING newuser open-path$

: n"open        ( a1 n1 -- handle f1 )
\ *G Open file a1,n1 with a Forth path search.
                "path-file
                if   2drop 0 -1
                else 2dup open-path$ place \ save full path
                     _"open \ open file
                then ;

' n"open is "open  \ link multi-path open word into system


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\   MakeAbsolutePath  MakeRelativePath
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

INTERNAL

create <AbsRelPath$> max-path 1+ allot

EXTERNAL

: MakeAbsolutePath      ( a1 n1 a2 n2 -- a3 )
\ *G Make path a1 n1 absolute to path a2 n2.
        ?DUP \ only if a2 n2 point's to a path
        IF   2OVER IsAbsolutePath?
             IF   2DROP <AbsRelPath$> PLACE
             ELSE <AbsRelPath$> PLACE  \ store path
                  <AbsRelPath$> ?+\    \ append '\' if not already present
                  <AbsRelPath$> +PLACE \ append file name
             THEN
        else DROP <AbsRelPath$> PLACE
        then <AbsRelPath$> dup +null ;

: IsPathRelativeTo?     { a1 n1 a2 n2 -- f }
\ *G Return true if path a1 n1 is relative to path a2 n2
        a1 n1 n2 MIN a2 OVER ISTR= ;

: MakePathRelativeTo    ( a1 n1 a2 n2 -- a3 )
\ *G Make path a1 n1 relative to path a2 n2.
        4DUP IsPathRelativeTo?
        IF   NIP DUP>R - SWAP R> + SWAP ( a2 n3 )
        ELSE 2DROP                      ( a1 n1 )
        THEN <AbsRelPath$> PLACE
             <AbsRelPath$> ;

: FindRelativePath  ( a1 n1 path - a2 n2 )
\ *G Returns a relative path for file a1 n1 in path ( first part ). \n
\ ** n2=0 means not in search path.
        dup>r reset-path-source
                begin   r@ path-source 2@ nip 0>
                                if      r@ next-path" 4dup IsPathRelativeTo? not
                                else    over 0  false
                                then
                while   2drop
                repeat
        2nip  r>drop
 ;

: FindRelativeName  ( a1 n1 path - a2 n2 f )
\ *G Returns a relative name for file a1 n1 in path ( last-part ). \n
\ ** n2=0 means not in search path.
        >r 2dup r> FindRelativePath dup 0>
                if      nip dup 3 >
                                if      1+
                                then
                        /string true
                else    2drop  false
                then
   ;

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\  Prepend<home>\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: Prepend<home>\        ( a1 n1 -- a2 n2 )
        &forthdir count MakeAbsolutePath count ;

: GoHome         ( -- )
                0 0  Prepend<home>\ "chdir ;


\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ "LOADED?  \LOADED-  \LOADED  NEEDS
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

in-system

: "LOADED?      ( addr len -- flag )
\ *G True if a file addr len is loaded. The filename must contain a full path.
                CONTEXT @ >R               \ save context
                files                      \ set context
                CONTEXT @ SEARCH-WORDLIST  \ search for word
                IF DROP TRUE ELSE FALSE THEN \ correct the flag
                R> CONTEXT !
                ;

: LOADED?       ( -<name>- -- flag )  { \ current$ }
\ *G True if the following file is loaded. The filename may be relative.
                MAX_PATH 1+ LocalAlloc: current$
                current-dir$ count current$ place \ get current dir
                current$ ?+\                      \ append '\'
                new$ >r /parse-s$ count r@ place \ store file name
                r@ ?defext r> count              \ add default ext if needed
                "path-file  drop                 \ extend to full path
                "loaded? ;

: \LOADED-      ( -<name>- )
\ *G If the following file IS NOT LOADED interpret line.
                loaded? if postpone \ then ;

: \LOADED       ( -<name>- )
\ *G  If the following file IS LOADED interpret line.
                loaded? 0= if postpone \ then ;

: NEEDS         ( -<name>- )
\ *G Conditionally load file "name" if not loaded.
                >in @ loaded? 0= if >in ! fload else drop then ;

\ synonym Require needs             \ made a colon def - [cdo-2008May13]
: Require       \ synonym of NEEDS
\ *G Forth 200X name for needs.
                needs ;

: Required      ( addr len -- )
\ *G Non parsing version of Require.
                >in @ loaded? 0= if >in ! included else drop then ;

in-application

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

: "file-clip"   { addr len limit | temp$ pre -- addr len2 }
\ *G Clip filename to limit. If limit is less than 20 then the filename is clipped to
\ ** 20. len2=len if len < limit or len < 20. len2 = 20 if limit < 20. len2 = limt
\ ** otherwise. The string (if clipped) contains ... in the middle to indicate that#
\ ** it has been clipped.
                new$ to temp$                           \ so string isn't de-allocated on exit
                limit 20 max to limit                   \ must be at least 16
                limit 20 - 2 / 6 + to pre               \ balance start and end
                len limit >
                if      addr pre 3 -    temp$  place    \ lay in first 5 chars
                        s" ..."         temp$ +place    \ append some dots
                        addr len dup limit pre - - 0MAX /string \ clip to last part
                                        temp$ +place    \ of name and lay in
                                        temp$  count
                else    addr len                         \ no need to clip file
                then    ;

MODULE

\ *Z

anew -mkdir.f

: GetFileAttributes ( addr u -- FileAttributes )
\ *G Returns the file system attributes for a specified file or directory.
   MAX_PATH 1+ LocalAlloc dup>r place
   r@ +null r> 1+ Call GetFileAttributesA ;

: dir-exist? ( addr u -- flag )
\ *G Checks if a directory exists.
   GetFileAttributes dup -1 <>  and
   FILE_ATTRIBUTE_DIRECTORY and 0<> ;

: file-exist? (  ( adr len -- true-if-file-exist )
\ *G Checks if a file exists. Wild cards are possible.
   find-first-file not dup>r
      if    find-close 2drop
      else  drop
      then
   r> ;

: find-missing { adr cnt --  adr n-first-dir }
\ *G Finds the first missing directory.
  adr cnt 3 /string
    begin  dup 0>
             if  ascii \ scan nip cnt swap - adr over dir-exist?
             else 2drop false dup
             then
    while  1+ adr cnt rot /string
    repeat adr swap
 ;

: mkdir  ( adr n - )
\ *G Create the specified directory including the needed directory tree
\ ** when needed.
   MAX_PATH 1+ LocalAlloc >r
     begin  2dup find-missing dup
     while   0 -rot  r@ place r@ dup +null 1+ call CreateDirectory 0=
             abort" Failed to create the install directory"
     repeat
   4drop r> drop
;

\s

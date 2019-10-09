anew lz77files.f   \ April 12th, 2004

needs sub_dirs.f
needs lz77.f
needs w_search.f

variable end-of-file

: read-char-mem  ( infile -- char )
   drop Rpointer @ dup  end-of-file @ <
       IF      c@  Rpointer incr exit
       ELSE    drop -1
       THEN
    ;

: buffer-char ( AdrChar - )  c@ Out-File c! 1 +to Out-File ;

map-handle MhdnlOut

: extend-file ( size hndl - )
    dup>r file-size drop d>s +
    s>d r@ resize-file abort" Can't extend file."
    r> close-file  drop
 ;

: create-outfile ( name$ count size - 1stAdresInFile )
   >r 2dup W/O  FILE_WRITE_ATTRIBUTES or create-file abort" Can't create file."
   r> swap extend-file
   MhdnlOut open-map-file throw MhdnlOut >hfileAddress @
 ;

((  Map of the compressed-file lz-file:
#files-in-archieve
    \ Then for each file:
count relative filename
relative path + filename
dates file         \ Reserved for SetFileTime
Orginal fileLength
LClength compressed file
..
..  ))

6 constant length-files-dates
create file-dates length-files-dates cells allot

: Times ( - &lpLastWriteTime &lpLastAccessTime &lpCreationTime )
        [ file-dates 0 cells+ ] literal \ last written time
        [ file-dates 2 cells+ ] literal \ last access time
        [ file-dates 4 cells+ ] literal \ creation time
 ;

: get-file-dates ( fileid --  ) >r Times r> call GetFileTime drop ;
: set-file-dates ( fileid --  ) >r Times r> call SetFileTime drop ;

variable #files-in-archieve

also hidden

: Ending? { file$ cnt Ends$ count -- flag }
   file$ cnt dup count - /string Ends$ count caps-compare 0= ;

: exclude? ( file$ cnt - flag )
     2>r
     2r@ s" .bak"	 Ending?
     2r@ s" .dat"	 Ending? or
     2r@ s" .dbg"	 Ending? or
     2r@ s" .exe"	 Ending? or
     2r@ s" .hdb"	 Ending? or
     2r@ s" .hdx"	 Ending? or
     2r@ s" .ndx"	 Ending? or
     2r@ s" HelpWrd.tv"	 Ending? or
     2r@ s" logging.rtf" Ending? or
     2r@ s" .extra"	 Ending? or
     2r@ s" .old"	 Ending? or
     2r@ s" Root"	 Ending? or
     2r@ s" Entries"	 Ending? or
     2r@ s" Repository"	 Ending? or
     s" *\Help\html\class*.htm" 2r@ false w-search nip nip or
     s" *\Help\html\dexh*.htm"  2r@ false w-search nip nip or
     2r> 2drop
 ;

: +compress ( - )
    \in-system-ok list-file tab name-buf count
     2dup exclude?
       if 2drop ." skipped" exit then

    2dup swap 1- swap 1+ Out-File Write-String-in-File    \ rel-path to lz-file incl count
    r/o  OPEN-FILE  Checked TO In-File
    In-File get-file-dates
    file-dates length-files-dates cells  Out-File Write-String-in-File   \ write dates to lz-file
    In-File file-size drop d>s pad ! pad cell Out-File Write-String-in-File \ write file size to lz-file
    Out-File file-position drop 2>r
    Codesize cell Out-File Write-String-in-File           \ Reserve code-size in lz-file

    space Encode
    1 #files-in-archieve +!
    In-File Closed
    Out-File file-position drop
    2r> Out-File reposition-file drop
    Codesize cell Out-File Write-String-in-File           \ Write code-size in lz-file
    Out-File reposition-file drop
 ;

previous

' +compress is process-1file

0 value archive

: Wf32LzFile" ( - filename count ) s" Win32Forth.dat" ;

: move-lz-to-dictionary ( - )
   cr cr  s" Try to move: " type Wf32LzFile"  ['] get-file-size ForAllFileNames
   dup app-free 20 - <
       if   ."  fits"  app-free over - 10 u,.r ."  bytes left"
       else ."  **** ERROR **** need " app-free over -  abs 20 + 10 u,.r
                ."  bytes more. Adjust your dictionary space."
                \in-system-ok .free abort
       then
   Wf32LzFile"  R/O  OPEN-FILE Checked TO In-File
   here to archive dup allot \ create an archive for the lz file
   cr ." Moving... "
   archive swap In-File read-file Checked 3drop
   In-File Closed ." Done!
 ;

defer files-to-compress

: forth-files-to-compress ( - )
\  s" ." s" *.txt" true sdir exit \ for a quick test
   s" ." s" *?.?*" true sdir
    ;

' forth-files-to-compress is files-to-compress  \ Could be another list

also hidden

: compress-forth ( - )
    FILE_READ_ATTRIBUTES to sub_dir_access
    ['] Read-Char-ansi is Read-Char
    0  #files-in-archieve !
    Wf32LzFile"  DELETE-FILE DROP
    Wf32LzFile"  W/O  CREATE-FILE Checked TO Out-File
    s" 0000"  Out-File Write-String-in-File   \ reset #files-in-archieve to lz-file
    cr ." Compressing: "   timer-reset
    files-to-compress   cr cr .elapsed  Out-File Closed
    Wf32LzFile"  W/O  OPEN-FILE Checked TO Out-File
    #files-in-archieve 1 cells Out-File Write-String-in-File   \ #files-in-archieve to lz-file
    Out-File Closed
    move-lz-to-dictionary
 ;

previous

create out-file-name max_path allot
create target-dir    max_path allot
create window-line   max_path allot

string: &\\convert$

: &\\convert ( adr cnt -- adr' cnt )
   &\\convert$ off
   begin  2dup  ascii \ scan dup 0>
   while  2swap 2 pick - &\\convert$  +place s" \\" &\\convert$ +place 1 /string
   repeat 2drop &\\convert$ +place &\\convert$ count
 ;

: decompress-file ( - )
    target-dir c@
    Rpointer @ count  dup 1+ Rpointer +!      \ Get file name
    1 /string target-dir +place
    Rpointer @ file-dates length-files-dates cells cmove \ Get dates
    length-files-dates cells Rpointer +!
    Rpointer @ @ >r cell Rpointer +!          \ Get orginal filesize
    target-dir count  2dup "path-only"  mkdir \ create dir
    Rpointer @ dup @ cell+ + end-of-file !  cell Rpointer +!
    2dup r> create-outfile to Out-File
    Decode  MhdnlOut  close-map-file drop
    FILE_WRITE_ATTRIBUTES  open-file Checked TO Out-File \ To restore the date
    Out-File set-file-dates Out-File Closed
    target-dir c! ;

: decompress ( - )
    ['] read-char-mem is Read-Char
    ['] buffer-char   is Write-Char
    archive cell+ Rpointer !
    PromptTime ."  Decompressing..." cr
    archive @ dup 0  timer-reset
       ?do   decompress-file
       loop
     .elapsed  ." . " 1 u,.r ."  files decompressed." cr
 ;

\s

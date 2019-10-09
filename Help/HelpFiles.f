\ $Id: HelpFiles.f,v 1.2 2011/11/18 01:32:27 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008



needs HelpStruct.f



\ ------------------------------------------------------------------------------
\ QuickSort an array of record on any field
\ ------------------------------------------------------------------------------

VARIABLE hFILE      \ file or array of record handle
VARIABLE hFIELD     \ field handle to sort on
VARIABLE WORKRECORD \ an extra record storage address for swapping records

: hSWAPIJ       ( i j --- ) \ swap records i and j of file hFILE
                dup hFile @ vaddr   WORKRECORD @
                hFile @ SizeOfElt cmove                \ record j in record 0
                over hFile @ vaddr  swap hFile @ vaddr
                hFile @ SizeOfElt cmove                \ record i in record j
                WORKRECORD @        swap hFile @ vaddr
                hFile @ SizeOfElt cmove ;              \ record 0 in record i

: hCMPIJ        ( i j --- flag )
                \ compare contents of field hFIELD in the two records i and j
                \ of file hFILE: -1 = f(i)<f(j), 0 = f(i)=f(j), 1 = f(i)>f(j)
                swap hFile @ hField @ vaddr
                swap hFile @ hField @ vcmp ;


: hfQUICK       ( m n --- )
                \ quicksort partition m n
                2DUP OVER - 2/ +                     ( take middle as pivot )
                >R                 ( --- m n and pivot index on return stack)
                2DUP SWAP                                     ( --- m n j i )
                BEGIN                        ( m,n,j,i ) ( m <= i <= j <= n )
                  BEGIN DUP R@  hCMPIJ -1 = WHILE 1+ REPEAT SWAP
                  BEGIN R@ OVER hCMPIJ -1 = WHILE 1- REPEAT SWAP
                  ( --- m n j i )
                  2DUP U< NOT
                  IF   2DUP R@ =              ( follow pivot if it is swapped)
                       IF   R> DROP >R
                       ELSE R@ =
                            IF   R> DROP DUP >R
                       THEN THEN
                       2DUP hSWAPIJ
                       SWAP 1- SWAP 1+
                  THEN
                  2DUP U<
                UNTIL R> DROP                 ( m,n,j,i ) ( m <= j < i <= n )
                ROT ( m,j,i,n ) 2OVER 2OVER - + >
                IF 2SWAP ( i,n,m,j ) THEN
                ( push shorter part first to limit stack depth to 2*log2[m-n])
                2DUP U< IF RECURSE ELSE 2DROP THEN ( shorter part )
                2DUP U< IF RECURSE ELSE 2DROP THEN ( longer part ) ;

: FSORT+        ( recfrom recto ExtraRecordAddress pfafield pfaarray --- )
                \ quicksort whole file, supposed open, ascending, on field
                hFILE ! hFIELD ! WORKRECORD !
                                  ( partition to be sorted = recfrom to recto)
                hfQUICK ;         ( external call, as quicksort is recursive)



\ ------------------------------------------------------------------------------
\ Dychotomy search in ascending sorted array of records
\ ------------------------------------------------------------------------------

: FFIND         ( AddrOfVarToSearchFor fildescr hfld recfrom recto -- n0record flg )
                \ find n0rec of vartosearch by dichotomy in ascending sorted field.
                \ If found, flag=0
                \ If not found, flg=-1 and give next position, which is an insert
                \ position, maybe until #Recs+1.
                2dup > if 2drop 2drop 0 0 exit then    \ error or nothing to search
                swap
                begin                 \ -- adrstosearch fildescr hfld urecmax lrecmin
                  2dup >= while
                  2dup + 2/           \ -- adr fild hfld urecmax lrecmin imedium
                  5 pick over 6 pick 6 pick vcmp ?dup
                  if   -1 =                               \ value < fieldcontents ?
                       if   rot drop 1- swap              \ search lower part
                       else nip 1+                        \ search higher part
                       then
                  else >r 4drop drop r> 0 ( found) exit
                  then
                repeat
                drop >r 3drop r> 1+ -1 ( not found) ;

((
: FFINDM        ( AddrOfVarToSearchFor fildescr hfld recfrom recto -- n0record1 n0record2 flg )
                \ find n0rec of vartosearch by dichotomy in ascending sorted field.
                \ Same as FFIND but also find multiple keys. If key is single, n0rec1=n0rec2.
                \ If key is multiple, it occurs from n0rec1 to n0rec2 both included.
                \ If found, flag=0
                2>r 2 pick 2 pick 2 pick 2r> FFIND
                -1 = if >r 3drop r> dup 0 exit then
                ;
>r
n0recfirstfound 1-
begin
  5 pick over 6 pick 7 pick vcmp 0=
  notbof and
  while
  1-
repeat
r> swap >r
n0recfirstfound 1+
begin
  5 pick over 6 pick 7 pick vcmp 0=
  noteof and
  while
  1+
repeat
r>
))

\ ------------------------------------------------------------------------------
\ file descriptor
\ ------------------------------------------------------------------------------

 -1 CONSTANT closed           \ "closed" channel or handle
200 CONSTANT maxfilnam        \ max size of count+path+null

( Cells of file descriptor. All theese words, used to access descriptor's cells,
  have the same stack effect: ( fildescr -- celladdr )

: FilName    ;                                     \ ^asciiz filename
: FilChan    maxfilnam + ;                         \ file id, or "channel"
: FilSize    [ maxfilnam cell+ ] LITERAL + ;       \ current file size

\ file defining word

: FILENAME!     ( addr u fildescr --- ) \ store filename in file descriptor
                FilName >r
                -trailing
                maxfilnam 2 - min dup r@ c!     \ count
                0 over 1+ r@ + c!               \ null
                r> 1+ swap cmove ;              \ body

: .FILENAME     ( fildescr --- ) \ show filename
                FilName COUNT TYPE ;

: DFILE         ( compile: FILE name c:\dir\filename )
                ( execute: -- fildescr )
                \ file descriptor defining word.
         CREATE here >r                         \ save fildescr addr
                maxfilnam ALLOT                 \ allot filename space
                ( BL WORD COUNT) BL parse r> FILENAME!      \ transfer filename
                closed ,                        \ init channel to closed
                0 ,                             \ dummy filesize
          DOES> ;


\ ------------------------------------------------------------------------------
\ generic files functions
\ ------------------------------------------------------------------------------

: FForceCreate  ( fildescr --- ior )
                \ Create a file even if already exists (overwrite it). Do not open it.
                dup FilName count R/W Create-File
                if   nip
                else drop Close-File drop 0
                then ;

: FOpen         ( fildescr --- ior )
                \ open a file in R/W mode. File is supposed already exist
                >r
                r@ FilChan @ closed <> if r>drop 0 exit then \ already open: not an error
                r@ FilName count R/W Open-file ?dup if r>drop nip exit then
                r@ FilChan !                                 \ if ok, update FilChan
                \ * get / set file sizes
                r@ FilChan @ File-Size nip ?dup if r>drop nip exit then
                r@ FilSize !                                 \ if ok, update FilSize
                r>drop 0 ;

: FClose        ( fildescr --- ior )
                \ close file.
                >r
                r@ FilChan @ closed = if r>drop 0 exit then \ already closed, not an error
\                r@ FilSize @ 0 r@ FilChan @ Resize-File     \ resize file on disk
\                ?dup if r>drop exit then
                r@ FilChan @ Close-File                     \ close file
                ?dup if r>drop exit then
                closed r@ FilChan !
                0 r@ FilSize !
                r>drop 0 ;                                  \ close was successful

: FSeek         ( noffset fildescr --- ior )
                \ seek file pointer, noffset 0relative from bof.
                >r s>d r> FilChan @ Reposition-File ;


\ ------------------------------------------------------------------------------
\ sequential files on disk read / write
\ ------------------------------------------------------------------------------

\ remember to set file pointer, if needed, before read / write
\ after opening the file, file pointer is at bof

: READSEQ       ( bufferaddr n#bytestoread fildescr -- ior )
                \ use current file position
                \ error -2 if couldn't read requested #bytes
                over >r FilChan @ Read-File dup
                if   swap r> 2drop        \ true read error
                else drop r> <>           \ compare #bytes requested with actually read
                     if -2                \ "EOF" pseudo error
                     else 0
                then then ;

: WRITESEQ      ( bufferaddr n#bytestowrite fildescr -- ior )
                \ use current file position, update FilSize if write from eof
                >r
                r@ File-Position 2drop
                r@ FilSize @ = if dup r@ FilSize +! then
                r> FilChan @ Write-File ;
                \ Note: if write error, FilSize is inconsistent
                \ Note: Disk Full Error = ???


\ ------------------------------------------------------------------------------
\ sequential text files on disk read / write
\ ------------------------------------------------------------------------------

\ lines of variable lenght are delimited by CR + LF
\ remember to set file pointer, if needed, before read / write
\ after opening the file, file pointer is at bof

: READLN        ( adrbuffer maxnbbytes fildescr --- #bytes flag ior )
                \ load CR+LF but don't include them to count
                \ #bytes = 0 if empty line
                \ #bytes <= maxnbbytes (= if no EOL yet found) = line length
                \ flag = false if eof
                FilChan @ READ-LINE ;

: WRITELN       ( adrbuffer maxnbbytes fildescr --- ior )
                \ automatically append CR+LF
                >r
                r@ File-Position 2drop
                r@ FilSize @ = if dup 2 + r@ FilSize +! then
                r> FilChan @ Write-Line ;
                \ Note: if write error, FilSize is inconsistent
                \ Note: Disk Full Error = ???


\ ------------------------------------------------------------------------------
\ random access files read / write
\ ------------------------------------------------------------------------------

: READREC       ( recordbufferaddr recordsize n0rec fildescr --- ior )
                \ read record, n0rec is 0 based.
                \ beware: don't check for illegal n0rec
                >r
                over * s>d                        \ displ. to rec in file
                r@ FilChan @ Reposition-File      \ set pointer in file
                ?dup if 2drop r>drop exit then    \ exit there if error
                r@ FilChan @ Read-File NIP        \ read record, give ior
                r>drop ;

: WRITEREC      ( recordbufferaddr recordsize n0rec fildescr --- ior )
                \ write record, n0rec is 0 based.
                \ beware: don't check for illegal n0rec
                >r
                over * s>d                        \ displ. to rec in file
                r@ FilChan @ Reposition-File      \ set pointer in file
                ?dup if 2drop r>drop exit then    \ exit there if error
                r@ FilChan @ Write-File           \ write record, give ior
                r>drop ;

: APPENDREC     ( recordbufferaddr recordsize fildescr --- ior )
                \ append a record to eof, with its current contents
                >r
                r@ FilSize @ s>d r@ FilChan @ Reposition-File
                ?dup if 2drop r>drop exit then
                swap over r@ FilChan @ Write-File ?dup
                if   nip r>drop
                else r> FilSize +! 0              \ update FilSize
                then ;


\s

: FDELETE       ( filedescr --- ior )
                \ file must be closed before to release channel
                dup FilChan @ closed <>
                if FilChan @ Close-File drop then
                if   FilName count Delete-File
                ELSE DROP 32 WINERR ! 32    \ SHARING_VIOLATION = "file opened"
                THEN ;

: FRENAME       ( oldfildescr newfildescr --- ior )
                2DUP FilChan @ closed = SWAP FilChan @ closed = AND
                IF   >R FilName COUNT R> FilName COUNT RENAME-FILE
                ELSE 2DROP 32 WINERR ! 32   \ SHARING_VIOLATION = "file opened"
                THEN ;


: FSIZE?        ( fildescr --- dnbbytes ior )
                \ File must be opened.
                \ After this call, file pointer is set to bof.
                DUP>R FilChan @ FILE-SIZE
                0. R> FSEEK DROP ;




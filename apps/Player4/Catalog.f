\ $Id: Catalog.f,v 1.43 2011/09/06 18:03:18 georgeahubert Exp $

anew catalog.f  \ 15-10-2005

needs ExtStruct.f
needs Pl_Toolset.f
needs w_search.f
needs mshell_r.f
needs sub_dirs.f

internal
external

\ Define a database and index file
create DatabaseFile$ ," \catalog.dat"
create IndexFile$    ," \catalog.idx"

string: database$
string: index$
0 value #Excluded
0 value #playing

true value       _DriveType

\ Define the configuration of the database

:struct ConfigDef \ ConfigDef in PathMediaFiles.dat
                MAX-PATH    Field:      PathMediaFiles
                DWORD                   #free-list
                DWORD                   prev-free-record
                DWORD                   first-free-record
                DWORD                   MaximumRandomLevel
                BYTE                    s_Drivetype-
                BYTE                    s_Label-
                BYTE                    s_filesize-
                BYTE                    s_#Random-
                BYTE                    s_Random_popular-
                BYTE                    s_Random_impopular-
                BYTE                    s_#Played-
                BYTE                    s_Filename-
                BYTE                    s_Artist_Title-
                BYTE                    l_Index-
                BYTE                    l_Drivetype-
                BYTE                    l_Label-
                BYTE                    l_File_size-
                BYTE                    l_#Random-
                BYTE                    l_#Played-
                BYTE                    l_Filename-
                BYTE                    l_Record-
                BYTE                    ExitFailed-
                BYTE                    AutoStart-
                BYTE                    AutoMinimized-
                BYTE                    RequestLevel
                BYTE                    IgnoreRequests
                BYTE                    KeepRequests
                DWORD                   _SeparatorX
                BYTE                    Endless-
                DWORD                   VolLevel
                BYTE                    JoyStickDisabled-
                2 CELLS       Field:    SourcePathCatalog
                MAX-PATH 1+   Field:    SearchPathCatalog
                BYTE                    BlackBackGround-
;struct

sizeof ConfigDef  mkstruct: Config    s" \" Config ConfigDef PathMediaFiles place
create DatFileFile$ ," \PathMediaFiles.dat"
string: DatFile$

also  configdef

: InitFileNames ( - )
   current-dir$  count 2dup database$ place  2dup index$ place   DatFile$ place
   DatabaseFile$ count database$ +place
   IndexFile$    count index$    +place
   DatFileFile$  count DatFile$  +place
 ;

\ Record discription of the catalog. October 30th, 2005.
\ This model assumes that the filename is the title and
\ that it placed in a directory named after the album
\ The directory the album is is placed in a directory named after artist.

255 constant    /file_name
 32 constant    /MediaLabel
 90 constant    /artist
 80 constant    /album
 85 constant    /Title
  1 constant    /Drivetype
 90 constant    /Composer
 15 constant    /Genre

:struct RecordDef \ catalog
                BYTE                    Deleted-
                BYTE                    Excluded-
                BYTE                    Played-
                DWORD                   FileSize
Offset Deleted-thread
                DWORD                   RandomLevel
                DWORD                   #played
                /Drivetype      Field:  DriveType
                /MediaLabel     Field:  MediaLabel
                /Genre          Field:  Genre
                /artist         Field:  Artist   \ Extracted from the filename
                /Album          Field:  Album    \ Extracted from the filename
                /Title          Field:  Title    \ Extracted from the filename
                /file_name      Field:  File_name
                /Composer       Field:  Composer
                BYTE                    Cnt_File_name
                BYTE                    Cnt_MediaLabel
                BYTE                    Cnt_Artist
                BYTE                    Cnt_Album
                BYTE                    Cnt_Title
                BYTE                    UserRating
                BYTE                    PlayPeriod
                DWORD                   YearReleased
                DWORD                   Bitrate
                BYTE                    Request-
                BYTE                    RequestLevelRecord
                BYTE                    CollectedNotPlayed-
                BYTE                    NotUsed1
                DWORD                   hInTree
  ;struct

\ database part

\ Advantage of an inline record:
\ An easy way to create and debug a fixed record

sizeof  RecordDef dup   to record-size   mkstruct: InlineRecord

: file-exist?   ( adr len -- true-if-file-exist )  file-status nip 0= ;
: file-size>s   ( fileid -- len )       file-size drop d>s  ;
: map-hndl>vadr ( m_hndl - vadr )       >hfileAddress @ ;

map-handle idx-mhndl
map-handle database-mhndl
map-handle config-mhndl

: map-index         ( - )   index$    count idx-mhndl      open-map-file throw ;
: map-database-file ( - )   database$ count database-mhndl open-map-file throw ;
: map-config-file   ( - )   DatFile$  count config-mhndl   open-map-file throw ;

: create-index-file ( #records - f )
   cells
   index$ create-file-ptrs
   index$ open-file-ptrs
   extend-file
 ;

: set-data-pointers
   database-mhndl  map-hndl>vadr to records-pointer
   idx-mhndl       map-hndl>vadr to aptrs
 ;

: map-database  ( - )   map-database-file map-index set-data-pointers ;

: unmap-database  ( - )
    database-mhndl dup flush-view-file drop close-map-file
    idx-mhndl      dup flush-view-file drop close-map-file 2drop
 ;

: unmap-configuration  ( - )
    database-mhndl dup flush-view-file drop close-map-file drop
 ;

: create/open ( name - wHndl )
   count 2dup file-exist?
        if      r/w   open-file         abort" Can't open the file for writing"
        else    r/w create-file         abort" Can't create the file"
        then
 ;

: type-space    ( adr cnt -  )   type space  ;
: type-cr       ( adr cnt -  )   type cr  ;
: #records-in-database ( m_hndl - #records )  >hfileLength @ record-size /   ;

in-system

: do_part ( n - )
   s" database-mhndl #records-in-database  swap do i " EVALUATE ;


: for-all-records-from#        \ compiletime: ( -<word>- ) runtime: ( start - )
          do_part
           ' compile,         ( rec-adr -  )
         postpone loop
 ; immediate

: do_all_part     ( - ) s" database-mhndl #records-in-database  0 do i " EVALUATE ;

: for-all-records ( - )   \ compiletime: ( -<word>- ) runtime: ( - )
          do_all_part
           ' compile,         ( rec-adr -  )
         postpone loop
 ; immediate

in-application

\ Define a key before using sort-database
: sort-database ( key1..keyx #keys - )
    0 n>aptr  database-mhndl #records-in-database
      MciDebug?
        if      cr ." Sort-time:" timer-reset
        then
     mshell-rel
     MciDebug?
        if      .elapsed
        then
  ;

: add-file-ptrs ( #start #end - )
   dup to #records swap
      do  i records aptrs i cells + !
      loop
 ;

: build-file-ptrs ( #records -- ) 0 swap  add-file-ptrs ;

: rebuild-index-hdrs  ( - ) \ database must mapped
   database-mhndl #records-in-database build-file-ptrs
 ;

: _generate-index-file ( - )
   map-database-file
   database-mhndl #records-in-database create-index-file
   map-index set-data-pointers
   rebuild-index-hdrs
 ;

: generate-index-file ( - )   unmap-database  _generate-index-file  ;

\ ==== Part that depends on a record definition


: vadr-config  ( - vadr-config ) s" config-mhndl map-hndl>vadr " EVALUATE ; IMMEDIATE
: CatalogPath  ( - CatalogPath ) vadr-config SearchPathCatalog ;

: SeparatorX        ( - adr ) vadr-config _SeparatorX ;

: check-config   ( flag -- ) \ creates one with the right size
    not
        If      Config sizeof ConfigDef
                100 Config MaximumRandomLevel !
                DatFile$ count r/w create-file abort" Can't create configuration file"
                dup>r write-file abort" Can't save path to media folder"
                r>    close-file throw
                map-config-file
                true vadr-config s_Artist_Title- c!
                1000 vadr-config VolLevel !
        then
  ;

: in-freelist? ( adr - flag ) s" RecordDef Deleted- c@ " EVALUATE ; IMMEDIATE

: free-list-check  ( n - )
   n>record  dup in-freelist?
     if   vadr-config >r  record>r dup  r@ #free-list @ 0=
                if     dup r@ first-free-record ! dup r>record RecordDef Deleted-thread !
                else   r@ prev-free-record @ r>record RecordDef Deleted-thread !
                then
           r@ prev-free-record !  1 r> #free-list +!
     else  drop
     then
 ;

: next-in-freelist ( vadr-config - rel-ptr )
    first-free-record @ r>record RecordDef Deleted-thread @
  ;

: build-free-list   ( - )
    0 vadr-config  #free-list !
    for-all-records free-list-check
 ;

: get-a-record-from-the-free-list   ( - adr )
    vadr-config dup>r first-free-record  @
    r@ next-in-freelist r@ first-free-record ! r>record
    -1 r> #free-list +!
    dup record-size erase
  ;

: write-record ( wHndl - )    \ Recycle deleted records first.
   InlineRecord [ sizeof RecordDef ] literal
   vadr-config #free-list @ 0>
    if     get-a-record-from-the-free-list swap cmove drop
    else   rot write-file abort" Can't save record"
    then
 ;

: delete-record   ( n - )
   dup true swap n>record dup>r RecordDef Deleted- c!
   0 r> RecordDef Excluded- c!
   free-list-check
 ;

: mark-as-undeleted ( adr - )
    false 2dup swap RecordDef Deleted- c!
    swap 2dup RecordDef Excluded- c!
    2dup RecordDef RandomLevel !
    2dup RecordDef #played !
         RecordDef Played- c!
  ;

: undelete-record ( rel-adr - )  n>record mark-as-undeleted build-free-list  ;

: undelete-all ( - )
    vadr-config first-free-record @  vadr-config #free-list @ 0
      ?do    r>record dup RecordDef Deleted-thread @ swap mark-as-undeleted
      loop
     drop build-free-list
 ;

false value show-deleted

: delete-record-in-collection ( n - )
    dup n>record RecordDef Excluded- c@ 0=
         if      delete-record
         else    drop
         then
 ;

: WarningBox     ( adr len -- flag )
     asciiz z" Warning:"
     [ MB_OKCANCEL MB_ICONWARNING or MB_TASKMODAL or ] literal
     NULL MessageBox
     IDCANCEL <>
  ;

: delete-collection  ( - flag )
     s" Deleting the collection."  WarningBox  dup
        if   for-all-records delete-record-in-collection
        then
 ;

/artist /album + /Title +  constant  /Record

0 RecordDef File_name   previous /file_name key: FileNameKey
0 RecordDef MediaLabel  previous 255        key: FlexKey
0 RecordDef RandomLevel previous 1 cells    key: RandomKey       RandomKey       bin-sort
0 RecordDef #played     previous 1 cells    key: leastPlayedKey  leastPlayedKey  bin-sort
0 RecordDef Deleted-    previous 1          key: DeletedKey      DeletedKey      byte-sort
0 RecordDef FileSize    previous 1 cells    key: FileSizeKey     FileSizeKey     bin-sort
0 RecordDef Request-    previous 1 cells 2/ key: RequestKey      RequestKey Descending word-sort
0 RecordDef MediaLabel  previous /MediaLabel /Record + key: LabelKey

: &FlexKeyLen ( - &FlexKeyLen ) FlexKey &key-len ;
: MinFlexKey! ( n - )           min FlexKey !    ;

: by_record  ( - FlexKey )
    /Record &FlexKeyLen ! FlexKey @ 0 RecordDef Artist MinFlexKey! FlexKey
  ;

: RequestKeyFlagged
    vadr-config IgnoreRequests c@ not
      if  RequestKey
      then
 ;

: By_FileName           ( - by )  by[   FileNameKey RequestKeyFlagged    ]by ;
: By_Random             ( - by )  by[   RandomKey   RequestKeyFlagged    ]by ;
: by_leastPlayed        ( - by )  by[   leastPlayedKey Ascending RequestKeyFlagged ]by ;
: by_FileSize           ( - by )  by[   FileSizeKey    RequestKeyFlagged ]by ;
: by_cand_duplicates    ( - by )  by[   leastPlayedKey Ascending FileSizeKey
                                        FileNameKey LabelKey DeletedKey  ]by ;

: not-deleted? ( rec-adr - flag )   s" RecordDef deleted- c@ 0= " EVALUATE ; IMMEDIATE

:inline FileSizeRecord   ( adr - FileSizeRecord )  RecordDef FileSize @ ;

: _list-record ( rec-adr - )
    dup>r not-deleted?
        if      cr r@ .
                r@ RecordDef DriveType  c@ .
                r@ RecordDef MediaLabel r@ RecordDef Cnt_MediaLabel c@ type-space
                r@ RecordDef File_name  r@ Cnt_File_name c@   type-space
                cr 3 spaces
                r@ RecordDef Artist r@   Cnt_Artist c@   type-space
                r@ RecordDef Album  r@   Cnt_Album  c@   type-space
                r@ RecordDef Title  r@   Cnt_Title  c@   type-space

                r@ RecordDef #played ?
                r@ RecordDef RandomLevel ?
                r@ RecordDef Played-   c@ .
                r@ RecordDef Excluded- c@ .
                r@ FileSizeRecord 12  U,.R
                r@ RecordDef RequestLevelRecord c@  ."  Req " .
        then
    r>drop
   ;

: request? ( n - f ) n>record  RecordDef Request- c@ 0<> ;

: List-request   ( n - ) dup request?
                                if    n>record  _list-record
                                else  drop
                        then
 ;

: List-requests  ( - )   for-all-records List-request cr ;
: list-record    ( n - ) n>record  _list-record ;
: list-records   ( - )   for-all-records list-record cr ;
: list-database  ( - )   map-database  list-records unmap-database ;

: Level-request   ( n - ) dup request?
                                if    n>record  1 swap RecordDef RequestLevelRecord c!
                                else  drop
                        then
 ;

: Level-requests ( - )   for-all-records Level-request ;

 K_TAB variable separator  separator c!
0 value fid

: +inlineRecord      ( adr cnt -  )  InlineRecord +place ;
: type-separator     ( adr cnt -  )  +inlineRecord  separator 1 +inlineRecord ;
: .csv               ( n - adr cnt ) s>d  (d.)  ;
: fwrite             ( adr cnt - )   fid write-line abort" Can't write to file" ;

: _csv-record ( n - )
    dup >record
    dup>r not-deleted?
       if  .csv type-separator
           r@ RecordDef DriveType  c@ .csv  type-separator
           r@ RecordDef MediaLabel r@ RecordDef Cnt_MediaLabel c@ type-separator
           r@ RecordDef Artist     r@ Cnt_Artist c@ type-separator
           r@ RecordDef Album      r@ Cnt_Album  c@ type-separator
           r@ RecordDef Title      r@ Cnt_Title  c@ type-separator
           r@ RecordDef #played     @ .csv  type-separator
           r@ FileSizeRecord          .csv  type-separator
           r@ RecordDef RequestLevelRecord c@ .csv +inlineRecord
           InlineRecord count       fwrite
       else drop
       then
    r>drop
   ;

: csv-record   ( n - )   InlineRecord off  _csv-record  ;

: csv-catalog  ( - )
   wait-cursor
   s" Player4.csv"  r/w create-file abort" Can't create file"  to fid

   InlineRecord off
   s" Id"       type-separator          s" Drivetype"   type-separator
   s" Label"    type-separator          s" Artist"      type-separator
   s" Album "   type-separator          s" Title"       type-separator
   s" #played"  type-separator          s" Size"        type-separator
   s" ReqLevel" +inlineRecord
   InlineRecord count   fwrite

   for-all-records  csv-record
   fid close-file abort" close error"
   arrow-cursor
 ;

: record-not-played         ( n - )  n>record 0 swap RecordDef Played- c! ;
: set-all-not-played        ( -   ) for-all-records record-not-played ;

: Mark#playingAsPlayed      ( - )
        #playing  -1 >
                if      #playing RecordDef true #playing  RecordDef Played- c!
                then
 ;

: SetRecordInCollectionToNotPlayed    ( n - )
    n>record dup RecordDef Excluded- c@ not
        if      0 swap RecordDef Played- c!
        then
 ;

: SetCollectionToNotPlayed ( - )
    for-all-records  SetRecordInCollectionToNotPlayed
    Mark#playingAsPlayed  RefreshCatalog
 ;

: change-randomlevel  ( level n - )
   n>record over random swap RecordDef RandomLevel  !
 ;

: sort_by_filename              ( - )    by_FileName            sort-database ;
: sort_by_leastPlayed           ( - )    by_leastPlayed         sort-database ;
: sort_by_size                  ( - )    by_FileSize            sort-database ;
: sort_by_cand_duplicates       ( - )    by_cand_duplicates     sort-database ;

: SortByFlags ( - )
   vadr-config >r 1
    case
        r@ s_Filename- c@   of sort_by_filename             endof
        r@ s_#Random-  c@   of By_Random sort-database      endof

        r@ s_Random_impopular-  c@  of by[ by_record RandomKey
                                       leastPlayedKey Ascending RequestKeyFlagged ]by
                                       sort-database                endof
        r@ s_Random_popular-    c@  of by[ by_record RandomKey
                                       leastPlayedKey Descending RequestKeyFlagged ]by
                                       sort-database                endof

        r@ s_#Played-  c@   of sort_by_leastPlayed          endof
        r@ s_filesize- c@   of sort_by_size                 endof

        sizeof  RecordDef FlexKey !      0 &FlexKeyLen !
        r@ s_Drivetype- c@
                if      [ /Drivetype /MediaLabel +  /Record + ] literal &FlexKeyLen !
                         FlexKey @ 0 RecordDef DriveType MinFlexKey!
                then
        r@ s_Label- c@
                if      [ /MediaLabel /Record + ] literal &FlexKeyLen !
                        FlexKey @ 0 RecordDef MediaLabel MinFlexKey!
                then
        r@ s_Artist_Title- c@
                if      [ /Record ] literal &FlexKeyLen !
                        FlexKey @ 0 RecordDef Artist MinFlexKey!
                then
        FlexKey &key-len @ 0>
                if      by[ FlexKey RequestKeyFlagged ]by sort-database
                then

    endcase
   r>drop
 ;

: sort_by_RandomLevel ( - )
        By_Random sort-database
  ;

: shuffle-catalog ( - )
    vadr-config MaximumRandomLevel @ for-all-records change-randomlevel drop
;

: random-shuffle        ( -  )
    shuffle-catalog sort_by_RandomLevel RefreshCatalog
   ;

: incr-#played  ( adr - ) RecordDef #played dup @ 1+ swap ! ;
: mark-played   ( adr - ) -1 swap RecordDef Played- c!      ;

0 value #requests

: RequestDone   ( adr - )
    vadr-config KeepRequests c@
       if    drop
       else  0 swap RecordDef Request- w!  -1 +to #requests
       then
 ;

: EnableKeptRequest ( n - )
   n>record dup RecordDef Request- c@
     if     0 swap RecordDef Played- c!
     else   drop
     then
 ;

: EnableKeptRequests ( - )   for-all-records  EnableKeptRequest
 ;

internal

0 value /VolumeNameBuffer

: add.dir->file-size ( -- file-size )
    _win32-find-data @ FILE_ATTRIBUTE_DIRECTORY and
           if   0
           else _win32-find-data 8 cells+ @
           then ;

: ExtractRecord ( adr count - )
    >r dup r@ + 1- dup r@ ascii \ -scan   \ adr Title
    rot over ascii . -scan             \ count Title
    drop 2 pick 1+ 2dup -  dup   \ 0< if cr .s  ." file" abort then dup
    struct, InlineRecord RecordDef Cnt_Title    c!
    struct, InlineRecord RecordDef Title swap cmove \ move Title
    drop

    >r 1- dup r> ascii \ -scan  >r 2dup - r@ swap >r 0>
       if     1+ r@ struct, InlineRecord RecordDef Cnt_Album  c!
              struct, InlineRecord RecordDef Album  r@  cmove
       else   struct, InlineRecord RecordDef Cnt_Album  c!
       then                                                \ 4

    r> - 1- dup r>  ascii \ -scan 0>
       if    2dup - swap 1+ over
             struct, InlineRecord RecordDef Cnt_Artist  c!
             struct, InlineRecord RecordDef Artist rot  cmove
       else  0 struct, InlineRecord RecordDef Cnt_Artist  c! drop
       then
    drop   struct, InlineRecord RecordDef File_name  swap r>
    CatalogPath FindRelativeName drop >r swap r@ cmove
    r>   struct, InlineRecord RecordDef Cnt_File_name    c!
 ;

: (add-file)    ( wHndl addr len file-size - wHndl ) \ add a file to the catalog
   InlineRecord [ sizeof RecordDef ] literal erase
                       struct, InlineRecord RecordDef FileSize         !
                       ExtractRecord
   100 random          struct, InlineRecord RecordDef RandomLevel      !
   VolumeNameBuffer    struct, InlineRecord RecordDef MediaLabel
                              /VolumeNameBuffer /MediaLabel min        cmove
   /VolumeNameBuffer   struct, InlineRecord RecordDef Cnt_MediaLabel   c!
   _DriveType          struct, InlineRecord RecordDef DriveType        c!

   dup write-record
 ;

external

: add-file      ( wHndl addr len - wHndl ) \ add a file to the catalog ( for whole dir-trees )
     2dup IsValidFileType?
        if   add.dir->file-size (add-file)
        else 2drop
        then ;

: AddFile ( wHndl adr cnt - ) \ used for a few selected files
     2dup IsValidFileType?
        if   2dup r/o  open-file  throw dup file-size  throw  d>s
             swap  close-file  throw
             (add-file)
        then
     drop
 ;

0 value played_from_catalog
0 value last-selected-rec
0 value #InCollection

: RemoveFromCollection ( adr - )  true swap RecordDef Excluded- c! -1 +to #excluded ;
: Requests? ( adr - flag ) #requests 0> vadr-config IgnoreRequests c@ not and ;
: Requested?  ( adr - flag ) RecordDef Request- c@ ;

: Incollection? ( adr - flag )
    dup RecordDef Excluded- c@ not dup
        if    swap RemoveFromCollection
        else  nip
        then
         ;

: next-not-played ( - n ) \ -1 means all done.
        -1 database-mhndl #records-in-database last-selected-rec 0 max  \ Starting from the last-selected record
        do   i n>record >r Requests?    \ Handle requests first when they are there and not ignored
             if    r@ Requested? dup
                        if     r@ RequestDone
                        then
             else  #excluded            \ There is a collection when > 0
                        if     r@ Incollection?
                        else   r@ Requested? not

                        then
             then
             r@ RecordDef Played- c@  0= and
             r> RecordDef Deleted- c@ 0= and
             if   drop i leave
             then
        loop ;

: randomize-catalog     ( -- )
        set-all-not-played
        random-shuffle ;

: map-file-open?        ( map-handle -- f )
        >hfile @ -1 <> ;

: DataBaseFilled? ( - f )
    database$ count r/o open-file drop dup file-size drop d0= not
    swap close-file drop
  ;
: catalog-exist?        ( -- f )
        DatFile$ count file-exist?
        database$ count file-exist?     and
        DataBaseFilled? and dup
        if   index$ count file-exist? not
                if    _generate-index-file
                then
        then
[defined] MciDebug? [if]
        MciDebug?
        if   cr ." catalog-exist? " dup .
        then
[then]
      ;

\ --------------------------------------------------------------------------
\  add a directory tree to the catalog
\ --------------------------------------------------------------------------
internal

: select_tree ( - path count file-spec count flag-subdir )
        vadr-config PathMediaFiles dup 0=
        if    drop s" \"
        else  count
        then  s" *.*" true  \ Filtering is done by the catalog
        ;

: proc_fileinfo_sdir ( -  )
        name-buf count add-file
 ;

external

\ 2 records are considered to be duplicate when the
\ medialabel, relative filename and filesize are the same

: duplicates? { rec1 rec2 } ( rec rec+1 - f )
   rec1 FileSizeRecord rec2 FileSizeRecord =
        if      rec1 RecordDef MediaLabel  rec1 RecordDef Cnt_MediaLabel c@
                rec2 RecordDef MediaLabel  rec2 RecordDef Cnt_MediaLabel c@ compareia 0=
                        if      rec1 RecordDef File_name  rec1 RecordDef Cnt_File_name c@
                                rec2 RecordDef File_name  rec2 RecordDef Cnt_File_name c@ compareia 0=
                        else    false
                        then
        else    false
        then
 ;

: DuplicatedToNext? ( n - f ) dup n>record swap 1+ n>record duplicates? ;

: RemoveDuplicates   ( - )
   sort_by_cand_duplicates
   database-mhndl #records-in-database 1- 0
        ?do   i n>record in-freelist?
                if      leave
                then
              i DuplicatedToNext?
                        if      i delete-record
                        then
        loop
   SortByFlags
 ;

: CloseReMap  ( wHndl - )
        close-file abort" Close error database"
        generate-index-file
 ;

: OpenAppendDatabase ( - wHndl )
    database$  create/open dup file-append throw
 ;

: add_dir_tree  ( -- ) \ add a directory tree to the catalog
        wait-cursor  ['] proc_fileinfo_sdir is process-1file
        OpenAppendDatabase
        select_tree sdir
        CloseReMap
        RemoveDuplicates
        arrow-cursor
        ;

\ --------------------------------------------------------------------------
\ search in the catalog
\ --------------------------------------------------------------------------

0 value player-base

: search-record ( arg-adr$ count #rec - arg-adr$ count )
   n>record dup>r record-size 2over 2swap false *search
   nip nip dup not r@ RecordDef Excluded- c!
   r> RecordDef CollectedNotPlayed- c!
 ;

string: dialog$

: dialog$_ok?   ( - dialog$ count flag )
                        dialog$ +null dialog$ count dup 1 maxstring between ;

: init-dlg      ( base adr count - dialog$ base )
                        dialog$ place dialog$ swap ;


NewEditDialog searchDlg "Search for artist/album in the catalog." "The name contains:" "Ok" "Cancel" ""

: "search-records ( adr count - )
    for-all-records search-record 2drop Mark#playingAsPlayed
 ;

: search-records ( base - )
  s"  artist*album " init-dlg  Start: searchDlg >r dialog$_ok?
  over and r> 0> and
        if    "search-records RefreshCatalog
        else  2drop
        then
 ;

: EnableAllRecords ( - )   s" *"  "search-records  ;

string: tmp$

: n>tmp$   ( n - )    0 (d.) tmp$ place ;

NewEditDialog MaximumRandomLevelDlg "Maximum randomlevel" "Enter the maximum number to use:" "Ok" "Cancel" ""

: ask-max-random-level  ( - )
   vadr-config MaximumRandomLevel @ n>tmp$ tmp$ count init-dlg  Start: MaximumRandomLevelDlg drop
   dialog$ count number?
       if   d>s  vadr-config MaximumRandomLevel !
       else 2drop
       then
;

NewEditDialog RequestLevelDlg "Request level" "Enter the level to use:" "Ok" "Cancel" ""

: SetRequestLevel
   vadr-config RequestLevel c@ n>tmp$ tmp$ count init-dlg  Start: RequestLevelDlg drop
   dialog$ count number?
       if   d>s  vadr-config RequestLevel c!
       else 2drop
       then
 ;

previous previous previous

\s

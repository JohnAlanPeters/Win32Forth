\ $Id: HelpBuildHDB.f,v 1.6 2013/03/07 16:19:15 georgeahubert Exp $

\ By Camille Doiteau - Feb 2008


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ -------    Build the word-part of the help database (hdb in short)     -------
\ -------  Edit HelpScope.f before to select the words to be included    -------
\ -------     This must be run from a clean (just launched) Forth        -------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

timer-reset
anew -HelpBuildHDB.f

needs HelpScope.f        \ MUST be the first thing done

needs HelpFiles.f
needs FileParser.f

cr .(  )
cr .(  )
cr .(  )
\ ------------------------------------------------------------------------------
cr .( Building HelpSrc.hdb sources table from transient tSrcList...)
\ ------------------------------------------------------------------------------

\ declare and allocate an array of records HelpSrc[] for storing source names
\ it will be filled with tSrcList contents uppercased and sorted
\ then it will be saved to disc in HelpSrc.hdb and the file closed
\ record 0 is used for sorting work and then to store #recs and maxnamelenght
\ the transient tSrcList is then disposed
\ the array of record tHelpSrc[] remains allocated until end of help database building

MaxSrcName @ 2 cells max MaxSrcName !  \ so that record 0 is at least 2 cells wide

:DataType Src=
   MaxSrcName @ String= SrcName           \ source name
;DataType

Unallocated Array[ #Src @ ]Of Src= tHelpSrc[]
tHelpSrc[] valloc


: FillHelpSrc[] ( -- ) \ copy src list in array of record (uppercase file names)
                tHelpSrc[] vinit
                >FirstLink: tSrcList
                #links: tSrcList 0 do
                  Data@: tSrcList 0<>
                  if   getname: [ Data@: tSrcList ]
                       2dup upper
                       i tHelpSrc[] SrcName vaddr place
                  then
                  >NextLink: tSrcList
                loop ;
FillHelpSrc[]
tSrcList disposelist


: SortHelpSrc[] ( -- ) \ sort array of records
                1 #Src @ 0 tHelpSrc[] vaddr SrcName  tHelpSrc[]
                FSORT+                                        \ quicksort
                0 tHelpSrc[] vaddr tHelpSrc[] SizeOfElt erase \ erase record 0
                #Src @ 0 tHelpSrc[] vaddr !                   \ #records    in record 0 at 0
                MaxSrcName @ 0 tHelpSrc[] vaddr cell+ ! ;     \ name length in record 0 at cell+
SortHelpSrc[]


: ShowHelpSrc[] ( -- )
                #Src @ 1+ 0 do
                  cr i . i tHelpSrc[] SrcName v@ count type
                loop ;
\ ShowHelpSrc[]
cr .(    #recs         = ) 0 thelpsrc[] vaddr @ .
cr .(    MaxNameLength = ) 0 thelpsrc[] vaddr cell+ @ .


DFILE tHelpSrc.hdb DummyFilename                   \ file on disk

nostack New$ &ForthDir count 2 pick place          \ set file name
s" Help\hdb\HelpSrc.hdb" 2 pick +place
count tHelpSrc.hdb FileName!

thelpsrc.hdb fforcecreate 0<> [IF] -1 abort" Couldn't create HelpSrc.hdb" [THEN]
thelpsrc.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpSrc.hdb"   [THEN]
0 tHelpSrc[] vaddr tHelpSrc[] SizeOf
tHelpSrc.hdb WRITESEQ     0<> [IF] -1 abort" Write error in HelpSrc.hdb"  [THEN]
tHelpSrc.hdb fClose       drop



\ ------------------------------------------------------------------------------
cr .( Building HelpVoc.hdb vocabularies table from transient tVocList...)
\ ------------------------------------------------------------------------------

\ handling is similar to sources names

MaxVocName @ 2 cells max MaxVocName !  \ so that record 0 is at least 2 cells wide


:DataType Voc=
                 dword= Voc#Words         \ number of words in this voc
   MaxVocName @ String= VocName
;DataType
Unallocated Array[ #Voc @ ]Of Voc= tHelpVoc[]
tHelpVoc[] valloc


: FillHelpVoc[] ( -- ) \ copy voc list in array of record (uppercase voc names)
                tHelpVoc[] vinit
                >FirstLink: tVocList
                #links: tVocList 0 do
                  Data@: tVocList 0<>
                  if   getname: [ Data@: tVocList ]
                       2dup upper
                       i tHelpVoc[] VocName vaddr place
                       0 i tHelpVoc[] Voc#Words v!
                  then
                  >NextLink: tVocList
                loop ;
FillHelpVoc[]
tVocList disposelist


: SortHelpVoc[] ( -- ) \ sort array of records
                1 #Voc @ 0 tHelpVoc[] vaddr VocName  tHelpVoc[]
                FSORT+                                        \ quicksort
                0 tHelpVoc[] vaddr tHelpVoc[] SizeOfElt erase \ erase record 0
                #Voc @ 0 tHelpVoc[] vaddr !                   \ #records    in record 0 at 0
                MaxVocName @ 0 tHelpVoc[] vaddr cell+ ! ;     \ name length in record 0 at cell+
SortHelpVoc[]


: ShowHelpVoc[] ( -- )
                #Voc @ 1+ 0 do
                  cr i . i tHelpVoc[] VocName v@ count type space
                         i tHelpVoc[] Voc#words v@ .
                loop ;
\ ShowHelpVoc[]
cr .(    #recs         = ) 0 thelpvoc[] vaddr @ .
cr .(    MaxNameLength = ) 0 thelpvoc[] vaddr cell+ @ .


DFILE tHelpVoc.hdb DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpVoc.hdb" 2 pick +place
count tHelpVoc.hdb FileName!

\ tHelpVoc.hdb .filename
thelpVoc.hdb fforcecreate 0<> [IF] -1 abort" Couldn't create HelpVoc.hdb" [THEN]
thelpVoc.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpVoc.hdb"   [THEN]
0 tHelpVoc[] vaddr tHelpVoc[] SizeOf
tHelpVoc.hdb WriteSeq     0<> [IF] -1 abort" Write error in HelpVoc.hdb"  [THEN]
tHelpVoc.hdb fClose       drop


\ ------------------------------------------------------------------------------
cr .( Building HelpAns.hdb ANS standard table from HelpAns.txt text file...)
\ ------------------------------------------------------------------------------

\ handling is similar to sources names (but here we create the transient list before)

tList tAnsList

Variable #Ans             0 #Ans !
Variable MaxAnsName       0 MaxAnsName !
Variable MaxAnsInfo       0 MaxAnsInfo !

DFILE tHelpAns.txt DummyFilename                  \ txt file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpAns.txt" 2 pick +place
count tHelpAns.txt FileName!

tHelpAns.txt fopen 0<> [IF] -1 abort" Couldn't open HelpVoc.hdb"   [THEN]

Create AnsLineBuffer 200 allot
: FilltAnsList  ( -- )
                0 #Ans ! 0 MaxAnsName ! 0 MaxAnsInfo !
                begin AnsLineBuffer 200 tHelpAns.txt ReadLn
                      if 2drop -1 abort" Read error in HelpAns.txt" then
                      while
                      1 #Ans +!
                      AnsLineBuffer over bl scan nip dup>r 1-  \ info lenght
                      MaxAnsInfo @ max MaxAnsInfo !
                      dup r> - MaxAnsName @ max MaxAnsName !   \ name lenght
                      AnsLineBuffer swap
                      additem: tAnsList
                repeat drop ;
FilltAnsList
tHelpAns.txt fClose drop

\ showlist: tAnsList
\ cr .( Max Ans Name Length = ) MaxAnsName @ .
\ cr .( Max Ans Info Length = ) MaxAnsInfo @ .
\ cr .( # Ans              = ) #Ans @ .
\ cr .( # Ans in list      = ) #Links: tAnsList .


MaxAnsName @ 3 cells max MaxAnsName !  \ so that record 0 is at least 3 cells wide
                                       \ even if we throw away Ans Info
:DataType Ans=
     MaxAnsName @ String= AnsName
     MaxAnsInfo @ String= AnsInfo
;DataType
Unallocated Array[ #Ans @ ]Of Ans= tHelpAns[]
tHelpAns[] valloc


: FillHelpAns[] ( -- ) \ copy ans list in array of record (uppercase ans names)
                tHelpAns[] vinit
                >FirstLink: tAnsList
                #links: tAnsList 0 do
                  Data@: tAnsList 0<>
                  if   getname: [ Data@: tAnsList ]
                       2dup bl scan swap 1+ over 1-             \ store AnsInfo
                       i tHelpAns[] AnsInfo vaddr place
                       - 2dup upper                             \ store AnsName
                       i tHelpAns[] AnsName vaddr place
                  then
                  >NextLink: tAnsList
                loop ;
FillHelpAns[]
tAnsList disposelist


: SortHelpAns[] ( -- ) \ sort array of records
                1 #Ans @ 0 tHelpAns[] vaddr   AnsName tHelpAns[]
                FSORT+                                        \ quicksort
                0 tHelpAns[] vaddr tHelpAns[] SizeOfElt erase \ erase record 0
                #Ans @ 0 tHelpAns[] vaddr !                   \ #records    in record 0 at 0
                MaxAnsName @ 0 tHelpAns[] vaddr cell+ !       \ name length in record 0 at cell+
                MaxAnsInfo @ 0 tHelpAns[] vaddr 2 cells + ! ; \ name info at 2 cells +
SortHelpAns[]


: ShowHelpAns[] ( -- )
                #Ans @ 1+ 0 do
                  cr i . i tHelpAns[] AnsName v@ count type
                  space  i tHelpAns[] AnsInfo v@ count type
                loop ;
\ ShowHelpAns[]
cr .(    #recs         = ) 0 thelpans[] vaddr @ .
cr .(    MaxNameLength = ) 0 thelpans[] vaddr cell+ @ .
cr .(    MaxAnsInfo    = ) 0 thelpans[] vaddr 2 cells + @ .


DFILE tHelpAns.hdb DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpAns.hdb" 2 pick +place
count tHelpAns.hdb FileName!

\ tHelpAns.hdb .filename
thelpAns.hdb fforcecreate 0<> [IF] -1 abort" Couldn't create HelpAns.hdb" [THEN]
thelpAns.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpAns.hdb"   [THEN]
0 tHelpAns[] vaddr tHelpAns[] SizeOf
tHelpAns.hdb WRITESEQ     0<> [IF] -1 abort" Write error in HelpAns.hdb"  [THEN]
tHelpAns.hdb fClose       drop


\ ------------------------------------------------------------------------------
cr .( Building HelpFct.hdb functionality table from HelpFct.txt text file...)
\ ------------------------------------------------------------------------------

\ handling is similar to sources names (but here we create the transient list before)

tList tFctList

Variable #Fct             0 #Fct !
Variable MaxFctName       0 MaxFctName !
Variable MaxFctInfo       0 MaxFctInfo !

DFILE tHelpFct.txt DummyFilename                  \ txt file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpFct.txt" 2 pick +place
count tHelpFct.txt FileName!

tHelpFct.txt fopen        0<> [IF] -1 abort" Couldn't open HelpVoc.hdb"   [THEN]

Create FctLineBuffer 200 allot
: FilltFctList  ( -- )
                0 #Fct ! 0 MaxFctName ! 0 MaxFctInfo !
                begin FctLineBuffer 200 tHelpFct.txt ReadLn
                      if 2drop -1 abort" Read error in HelpFct.txt" then
                      while
                      1 #Fct +!
                      FctLineBuffer over bl scan nip dup>r 1-  \ info lenght
                      MaxFctInfo @ max MaxFctInfo !
                      dup r> - MaxFctName @ max MaxFctName !   \ name lenght
                      FctLineBuffer swap
                      additem: tFctList
                repeat drop ;
FilltFctList
tHelpFct.txt fClose drop

\ showlist: tFctList
\ cr .( Max Fct Name Length = ) MaxFctName @ .
\ cr .( Max Fct Info Length = ) MaxFctInfo @ .
\ cr .( # Fct              = ) #Fct @ .
\ cr .( # Fct in list      = ) #Links: tFctList .


MaxFctName @ 3 cells max MaxFctName !  \ so that record 0 is at least 3 cells wide
                                       \ even if we throw away Fct Info
:DataType Fct=
     MaxFctName @ String= FctName
     MaxFctInfo @ String= FctInfo
;DataType
Unallocated Array[ #Fct @ ]Of Fct= tHelpFct[]
tHelpFct[] valloc


: FillHelpFct[] ( -- ) \ copy Fct list in array of record (uppercase Fct names)
                tHelpFct[] vinit
                >FirstLink: tFctList
                #links: tFctList 0 do
                  Data@: tFctList 0<>
                  if   getname: [ Data@: tFctList ]
                       2dup bl scan swap 1+ over 1-             \ store FctInfo
                       i tHelpFct[] FctInfo vaddr place
                       - 2dup upper                             \ store FctName
                       i tHelpFct[] FctName vaddr place
                  then
                  >NextLink: tFctList
                loop ;
FillHelpFct[]
tFctList disposelist


: SortHelpFct[] ( -- ) \ sort array of records
                1 #Fct @ 0 tHelpFct[] vaddr   FctName tHelpFct[]
                FSORT+                                        \ quicksort
                0 tHelpFct[] vaddr tHelpFct[] SizeOfElt erase \ erase record 0
                #Fct @ 0 tHelpFct[] vaddr !                   \ #records    in record 0 at 0
                MaxFctName @ 0 tHelpFct[] vaddr cell+ !       \ name length in record 0 at cell+
                MaxFctInfo @ 0 tHelpFct[] vaddr 2 cells + ! ; \ name info at 2 cells +
SortHelpFct[]


: ShowHelpFct[] ( pfainstance -- )
                #Fct @ 1+ 0 do
                  cr i . i tHelpFct[] FctName v@ count type
                  space  i tHelpFct[] FctInfo v@ count type
                loop ;
\ ShowHelpFct[]
cr .(    #recs         = ) 0 thelpFct[] vaddr @ .
cr .(    MaxNameLength = ) 0 thelpFct[] vaddr cell+ @ .
cr .(    MaxFctInfo    = ) 0 thelpFct[] vaddr 2 cells + @ .


DFILE tHelpFct.hdb DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpFct.hdb" 2 pick +place
count tHelpFct.hdb FileName!

thelpFct.hdb fforcecreate 0<> [IF] -1 abort" Couldn't create HelpFct.hdb" [THEN]
thelpFct.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpFct.hdb"   [THEN]
0 tHelpFct[] vaddr tHelpFct[] SizeOf
tHelpFct.hdb WRITESEQ     0<> [IF] -1 abort" Write error in HelpFct.hdb"  [THEN]
tHelpFct.hdb fClose       drop



\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
cr .(  )
cr .( Building main help database HelpWrd.hdb and index HelpWrd.hdx)
cr .(  )
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------


\ ------------------------------------------------------------------------------
cr .( Defining HelpWrd.hdb structure...)
\ ------------------------------------------------------------------------------

\ HelpWrd.hdb record structure
:DataType HelpWord=
         byte= WordDepr?         \ true if word is deprecated
         byte= WordImm?          \ true if word is immediate
         byte= WordSys?          \ true if word is in System dictionary
         byte= WordCls?          \ true if class word (classes & methods)
        dword= WordVoc           \ pointer to HelpVoc.hdb record
        dword= WordSrc           \ pointer to HelpSrc.hdb record
        dword= WordLine          \ source line number
        dword= WordFct           \ pointer to HelpFct.hdb record
        dword= WordAns           \ pointer to HelpAns.hdb record
        dword= WordFrom          \ beginning fileposition in word help texts
        dword= WordTo            \ ending fileposition in word help texts
;DataType

HelpWord= HelpWord               \ room for one record


\ HelpWrd.hdb file
DFILE tHelpWrd.hdb DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpWrd.hdb" 2 pick +place
count tHelpWrd.hdb FileName!

thelpWrd.hdb fforcecreate 0<> [IF] -1 abort" Couldn't create HelpWrd.hdb" [THEN]
thelpWrd.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpWrd.hdb"   [THEN]

HelpWord vinit                                    \ write a dummy record 0
HelpWord vaddr HelpWord SizeOf 0 tHelpWrd.hdb WriteRec
                [IF] -1 abort" Write error in HelpWrd.hdb" [THEN]


\ ------------------------------------------------------------------------------
cr .( Defining transient index list tWrdList...)
\ ------------------------------------------------------------------------------

:Class wListItem   <super Object
      100 bytes WordName         \ word name
          int   WordRec          \ n0record for word in HelpWrd.hdb
          int   WordParent       \ parent class if and only if method
:M classinit:   ( -- )
                classinit: super
                WordName 100 erase
                0 to WordRec ;m
:M setname:     ( addr cnt -- )
                dup WordName c!
                98 min 0max WordName 1+ swap move ;m
:m getname:     ( -- addr count )
                WordName count ;m
:m setrecord:   ( n0rec -- )
                to WordRec ;m
:m getrecord:   ( -- n0rec )
                WordRec ;m
:m setparent:   ( parent -- )
                to WordParent ;m
:m getparent:   ( -- parent )
                WordParent ;m
;class


:class wList  <super linked-list
:m classinit:   ( n addr cnt --)
                classinit: super ;m
:m AddItem:     ( addr count n0rec parent -- )
                addlink: self
                new> wListItem Data!: self
                setparent: [ Data@: self ]
                setrecord: [ Data@: self ]
                setname: [ Data@: self ] ;m
:m ShowList:    ( -- )
                >FirstLink: self
                #links: self 0 do
                  Data@: self 0<>
                  if   cr Data@: self .
                          getname: [ Data@: self ] type space
                          getrecord: [ Data@: self ] . space
                          getparent: [ Data@: self ] .
                  then
                  >NextLink: self
                loop ;m
;class


wList tWrdList


\ ------------------------------------------------------------------------------
\ prepares for some statistics
\ ------------------------------------------------------------------------------

Variable MaxWrdName       0 MaxWrdName !    \ max word size
Variable #WrdNonClass     0 #WrdNonClass !
Variable #Wrd             0 #Wrd !          \ total # words



\ ------------------------------------------------------------------------------
\ search words : primitives : get all info about a word xt
\ ------------------------------------------------------------------------------


\ get index in HelpSrc.hdb ... tables for a given source, voc, ...
\ -----------------------------------------------------------------

create StringBuffer 255 allot

: VocIndex      ( addr count sysflg -- n0recindex ) \ =0 if not fount
                if s" SYS\" else s" APP\" then StringBuffer place
                2dup upper StringBuffer +place
                StringBuffer tHelpVoc[] VocName 1 #Voc @ ffind
                if drop 0 then ;

: SrcIndex      ( addr count -- n0recindex ) \ =0 if not fount
                2dup upper StringBuffer place
                &ForthDir count 2dup upper StringBuffer 1+ over compare 0=
                if   &ForthDir count >r drop
                     StringBuffer 1+ dup r@ + swap dup 1- count nip r> - dup>r
                     cmove
                     r> StringBuffer c!
                then
                StringBuffer tHelpSrc[] SrcName 1 #Src @ ffind
                if drop 0 then ;

: AnsIndex      ( addr count -- n0recindex ) \ =0 if not fount
                2dup upper StringBuffer place
                StringBuffer tHelpAns[] AnsName 1 #Ans @ ffind
                if drop 0 then ;

: FctIndex      ( addr count -- n0recindex ) \ =0 if not fount
                2drop 0 ; \ ??? todo


\ Get info for a word
\ -------------------

Variable CurrentVoc
Variable CurrentSysOrApp  \ 0=App -1=Sys

: SysWord?      ( xt -- flag ) \ true flag if word is in system dictionary
                sys-addr? ;


: Immediate?    ( xt -- flag ) \ true flag if word is immediate
                >name n>bfa c@ bfa_immediate and bfa_immediate = ;

: Deprecated?   ( xt -- flag ) \ true flag if word is deprecated
                >name n>bfa c@ bfa_deprecated and bfa_deprecated = ;

: GetName       ( xt -- addr count ) \ get xt's stringname
                dup >name dup name> ['] [UNKNOWN] =     \ if not found
                if   ( nfa) drop base @ >r hex
                     ( xt) 0 <# 8 0 DO # LOOP [CHAR] x HOLD [CHAR] 0 HOLD #>
                     r> base !
                else ( xt nfa -- ) nip ( nfa) count
                then ;

: GetViewInfo   ( xt -- line# filename )
                dup >view@ swap >ffa@         \ ( line# filename -- )
                over 1 <                      \ view < 1
                over -1 = or                  \ or file = -1
                if   drop CONSFILE            \ must be console
                else dup 0=                   \ if it's a zero, it's kernel
                     if   drop
                          &ForthDir count pad place s" SRC\KERNEL\FKERNEL.F" pad +place pad
                     then
                then ;
((
\ run this one to check what has not been included
: InSrcScope?   ( xt -- flg ) \ true flag if the word belongs to a source we selected
                GetViewInfo nip count 2dup SrcIndex
                0= if cr ." not included" type 0 else 2drop -1 then ;
))
\ run this one if no check wanted
: InSrcScope?   ( xt -- flg ) \ true flag if the word belongs to a source we selected
                GetViewInfo nip count SrcIndex 0<> ;


\ include a non-class word in the help database
\ ---------------------------------------------

s" FORTH"  0 ( app) VocIndex value ForthVocApp
s" FORTH" -1 ( sys) VocIndex value ForthVocSys

: IncludeWord   ( xt -- )
                \ xt of word to include in HelpWrd.hdb
                \ ..................................... update hdb record entry
                HelpWord vinit
                dup deprecated?                 HelpWord WordDepr? v!
                dup immediate?                  HelpWord WordImm?  v!
                dup sysword?                    HelpWord WordSys?  v!
                0                               HelpWord WordCls?  v!
                CurrentVoc @                    HelpWord WordVoc   v!
                dup GetViewInfo count SrcIndex  HelpWord WordSrc   v!
                                                HelpWord WordLine  v!
                0                               HelpWord WordFct   v!
                dup GetName AnsIndex
                currentvoc @ ForthVocApp =
                currentvoc @ ForthVocSys = or
                and                             HelpWord WordAns   v!
                0                               HelpWord WordFrom  v!
                0                               HelpWord WordTo    v!
                \ ..................................... update statistics
                dup GetName
                    nip MaxWrdName @ max MaxWrdName !
                    1 #Wrd +!
                \ ..................................... save record (#Wrd=n0rec is set)
                HelpWord vaddr HelpWord SizeOf #Wrd @ tHelpWrd.hdb WriteRec
                if -1 abort" Write error in HelpWrd.hdb" then
                \ ..................................... update tWrdList index
                dup GetName
                #Wrd @            \ -- xt addr count n0record
                0                 \ not in a class: n0rec of its class = 0
                additem: tWrdList
                drop ;


\ ------------------------------------------------------------------------------
cr .( Dictionary search of non-class words: fill HelpWrd.hdb and tWrdList...)
\ ------------------------------------------------------------------------------

: AddWords      { voc \ w#threads #words -- #words }
                \ count sys and app words in this voc
                0 to #words
                voc dup voc#threads to w#threads
                dup voc>vcfa
                ?IsClass not                     \ don't look through classes
                if   here 500 + w#threads cells move     \ copy vocabulary up
                     begin   here 500 + w#threads largest dup
                     while   dup l>name name> dup sys-addr? CurrentSysOrApp @ xor not
                             swap InSrcScope? and
                             if   1 +to #words
                                  dup l>name name> IncludeWord
                             then
                             @ swap !
                     repeat  2drop
                else drop
                then #Words ;

: AddVocabularies ( -- ) \ add the vocs we selected in HelpScope.f
                0 #wrd !
                voc-link @
                begin dup vlink>voc
                      dup voc>vcfa
                      ?IsClass not  \ don't look through classes
                      if   dup voc>vcfa getname
                           2dup 0 ( app) vocindex ?dup            \ add vocabulary ?
                           if   CurrentVoc ! 0 CurrentSysOrApp !  \ App part ?
                                2 pick ( voc) AddWords
                                CurrentVoc @ tHelpVoc[] Voc#Words v!
cr ."    Processing vocabulary " CurrentVoc @ tHelpVoc[] VocName v@ count type ." ..."
                           then
                           -1 ( sys) vocindex ?dup                \ Sys part ?
                           if   CurrentVoc ! -1 CurrentSysOrApp !
                                dup ( voc) AddWords
                                CurrentVoc @ tHelpVoc[] Voc#Words v!
cr ."    Processing vocabulary " CurrentVoc @ tHelpVoc[] VocName v@ count type ." ..."
                           then
                           drop
                      else drop
                      then
                      @ dup 0=
                until drop
                #Wrd @ #WrdNonClass ! ;

AddVocabularies                        \ ??? Can be transiently commented out


\ ------------------------------------------------------------------------------
cr .( Dictionary search of non-method class words: fill HelpWrd.hdb and tWrdList...)
\ ------------------------------------------------------------------------------

\ Theese are words defined inside classes that are not methods nor classes
\ This includes ivars, colon definitions, etc. Their voc is set to null.
\ They are included while including classes and methods (see next) but they
\ need a different handling.


\ include a non-method class word in the help database
\ --------------------------------(-------------------

: IncludeCWord  ( xt methodparentn0rec -- )
                \ xt of word to include in HelpWrd.hdb
                \ methodparent = n0rec of parent class
                >r
                \ ..................................... update hdb record entry
                HelpWord vinit
                dup deprecated?                 HelpWord WordDepr? v!
                dup immediate?                  HelpWord WordImm?  v!
                dup sysword?                    HelpWord WordSys?  v!
                -1                              HelpWord WordCls?  v!
                0                               HelpWord WordVoc   v!
                dup GetViewInfo count SrcIndex  HelpWord WordSrc   v!
                                                HelpWord WordLine  v!
                0                               HelpWord WordFct   v!
                0                               HelpWord WordAns   v!
                0                               HelpWord WordFrom  v!
                0                               HelpWord WordTo    v!
                \ ..................................... update statistics
                dup GetName
                    nip MaxWrdName @ max MaxWrdName !
                    1 #Wrd +!
                \ ..................................... save record (#Wrd=n0rec is set)
                HelpWord vaddr HelpWord SizeOf #Wrd @ tHelpWrd.hdb WriteRec
                if -1 abort" Write error in HelpWrd.hdb" then
                \ ..................................... update tWrdList index
                dup GetName
                #Wrd @            \ -- xt addr count n0record
                r>                \ n0rec of class where the word is defined
                additem: tWrdList
                drop ;


: Code-addr?    ( addr -- flg ) \ true if is a code address
                code-origin [ cdp 2 cells+ ] literal @ within ;

: App-addr?     ( addr -- flg ) \ true if is an app address
                app-origin [ adp 2 cells+ ] literal @ within ;

0 value MaxClsCode
0 value MaxClsApp
0 value MaxClsSys

: BoundClass    { voc \ w#threads -- }
                0 to MaxClsCode
                0 to MaxClsApp
                0 to MaxClsSys
                voc dup voc#threads to w#threads
                here 500 + w#threads cells move           \ copy vocabulary up
                begin  here 500 + w#threads largest dup
                while  dup l>name name>                   \ cfa of current word
                       dup app-addr?
                       if   MaxClsApp over max to MaxClsApp
                       else dup code-addr?
                            if   MaxClsCode over max to MaxClsCode
                            else MaxClsSys over max to MaxClsSys
                       then then
                       drop
                       @ swap !
                repeat
                2drop ;

0 value MethodParent

: ClassWords    { voc \ w#threads -- } \ add the words in a vocabulary to the treeview
                voc dup voc#threads to w#threads
                ( voc -- )
                here 500 + w#threads cells move
                begin  here 500 + w#threads largest dup
                while  dup l>name name>               \ current word cfa
                       dup app-addr?                  \ check if inside class
                       if   MaxClsApp over <          \ whatever it is a code
                       else dup code-addr?            \ sys or app definition
                            if   MaxClsCode over <
                            else MaxClsSys over <
                       then then
                       if ( xt) MethodParent IncludeCWord else drop then
                       @ swap !                       \ store lfa in thread until =0
                repeat 2drop ;

also classes
: AddClassWords ( class-cfa -- ) \ add non-method words from class
                dup ?IsClass not if drop exit then
                dup >body SFA @                       \ pfa of superclass
                body> vcfa>voc BoundClass             \ voc-address of superclass
                vcfa>voc ClassWords ;
previous




\ ------------------------------------------------------------------------------
cr .( Dictionary search of class words: fill HelpWrd.hdb and tWrdList...)
\ ------------------------------------------------------------------------------

\ searches classes : get classes and their methods in a top down way
\ Because the search for top-down classes is complicated, we will built the part
\ of the TV concerning the classes at the same time. This transient and partial
\ TV-structure-text-file will be inserted later in the All-Words-TV-structure


\ Utilities to write the tv-structure-text-file
\ ------------------------------------------------------------

DFILE tHelpCls.tv DummyFilename                  \ txt file on disk

NoStack New$ &ForthDir count 2 pick place        \ set file name
s" Help\hdb\HelpCls.tv" 2 pick +place
count tHelpCls.tv FileName!

tHelpCls.tv fforcecreate 0<> [IF] -1 abort" Couldn't create tHelpCls.tv" [THEN]

create ClsLineBuffer 200 allot

: AddLine2      ( n0rec addr count depth -- )
                s>d (d.)             ClsLineBuffer place
                s"  tvn| "           ClsLineBuffer +place
                                     ClsLineBuffer +place
                s" | tvd| "          ClsLineBuffer +place
                s>d (d.)             ClsLineBuffer +place
                s" |"                ClsLineBuffer +place
                ClsLineBuffer count tHelpCls.tv WriteLN
                if -1 abort" write error in tHelpCls.tv" then ;


\ Get info for a word: a little more for classes and methods
\ -----------------------------------------------------------

\ The following definitions enable us to find the name of an object defined with :OBJECT
\ from the xt of it's nameless class; gah

create NameBuf$ MAXSTRING 1+ allot

0 value SearchClass

: (objname)     ( nfa -- )
                dup name> dup @ doobj =
                if      >body @ SearchClass =
                        if      s" :OBJECT " NameBuf$ place
                                nfa-count NameBuf$ +place NameBuf$ +null
                                0 to SearchClass
                        else    drop
                        then
                else    2drop
                then    ;

: objname       ( xt -- )
                >body to SearchClass NameBuf$ off
\in-system-ok   ['] (objname) on-allwords ;

: ClassPFA>NAME ( class-pfa -- addr count ) \ get class name in namebuf$
                body> dup >NAME DUP NAME> ['] [UNKNOWN] =
                if   drop dup ?IsClass
                     if   dup objname Namebuf$ count 0=
                          if   drop s" [UNKNOWN]"
                          else drop Namebuf$ count
                          then
                     else s" [UNKNOWN]"
                     then
                else count
                then rot drop ;

: Hash>CFA      ( hash-val -- cfa flag ) \ get cfa from hash-value
                hash-wid dup voc#threads cells+ hash-wid  ( hash-wid end to hash-wid )
                do   i
                     begin @ ?dup
                     while ( hash-val link-field )
                           2dup link> >body @ =
                           if   nip ( discard hash value )
                                l>name name> ( cfa )
                                true unloop exit
                           then
                     repeat
                cell +loop
                drop -1 false ;


\ include a class-word in the help database
\ -----------------------------------------

0 value classsrc
0 value classline

: IncludeClass  ( addrname cntname methodparentn0rec -- )
                \ methodparent = n0rec of class of method
                >r
                \ ..................................... update hdb record entry
                HelpWord vinit
                0                                HelpWord WordDepr? v!
                0                                HelpWord WordImm?  v!
                0                                HelpWord WordSys?  v!
                -1                               HelpWord WordCls?  v!
                0                                HelpWord WordVoc   v!
                classsrc count SrcIndex          HelpWord WordSrc   v!
                classline                        HelpWord WordLine  v!
                0                                HelpWord WordAns   v!
                0                                HelpWord WordFct   v!
                0                                HelpWord WordFrom  v!
                0                                HelpWord WordTo    v!
                \ ..................................... update statistics
                ( cntname) dup MaxWrdName @ max MaxWrdName !
                    1 #Wrd +!
                \ ..................................... save record (#Wrd=n0rec is set)
                HelpWord vaddr HelpWord SizeOf #Wrd @ tHelpWrd.hdb WriteRec
                if -1 abort" Write error in HelpWrd.hdb" then
                \ ..................................... update tWrdList index
                ( addrname cntname)
                #Wrd @            \ -- addr count n0record
                r>                \ if method: n0rec of its class, if class: 0
\ cr ." methodparent= " dup .
                additem: tWrdList ;


\ Actually include classes and methods
\ -------------------------------------

create tparsefile 250 allot
0 Value InClass?

: AddMethods    ( depth class-pfa -- )  \ add all methods of a class (MethodParent is set too)
                classsrc count                          \ source where class is defined
                tparsefile place tparsefile +null
                tparsefile count r/w open-file
                abort" Source open error while searching methods"
                ( fileid) ParseInit                     \ parse this source
                classline ParseFrom                     \ from class definition
                true to SkipComment?
                true to InClass?
                begin GetWord ?dup
                      while
                      2dup upper

                      2dup s" ;CLASS"  compare 0= >r    \ check if end class def
                      2dup s" ;OBJECT" compare 0= r> or
                      InClass? and
                      if false to InClass? then

                      InClass?                          \ get methods
                      if   2dup s" :M"    compare 0=
                           if   GetWord
                                2dup upper \ -- depth classpfa addr:M cnt:M addrmeth cntmeth
                                2dup #Wrd @ 1+ -rot       \ -- addr cnt anticipatedn0rec
                                8 pick negate AddLine2    \ add method line as TVI_SORT
                                GetParseLine to classline
                                ( addrname cntname)
                                MethodParent IncludeClass \ include method word
                           then
                      then
                      2drop
                repeat drop
                nip ( class-pfa) body> AddClassWords      \ add non-method words of class
                ParseFileId close-file drop ;
                \ Note: we cannot use the class methods #mlists list because this
                \       doesn't give a method xt. We HAVE to parse the source
                \       to build viewinfo for methods

: AddClass      ( depth class-cfa -- ) \ add a class and its methods
                dup InSrcScope?
                if   #Wrd @ 1+                           \ anticipate n0rec
                     over >body classpfa>name
                     4 pick AddLine2                     \ add class line in TV struct
                     dup getviewinfo
                     to classsrc to classline
                     dup ( cfa) >body classpfa>name
                     0 IncludeClass                      \ include class word
                     0 s" -methods-" 4 pick 1+ AddLine2  \ add "-methods-" line in TV struct
                     #Wrd @ to methodparent              \ methodparent=n0recinhdb parent class
                     over 2 + over >body AddMethods      \ add all methods of this class
                     0 to MethodParent
                then
                2drop ;

0 value currentclass
0 value currentdepth
0 value #children

: (AddClasses)  ( [...depth class-cfa...] depth class-cfa -- )
                begin to currentclass              \ consume stack & handle current class
                      to currentdepth
                      currentdepth currentclass AddClass \ add this class and its methods
                      \
                      0 to #children
                      voc-link @                       \ search all children of class :
                      begin dup vlink>voc              \ voc-link voc --
                            dup voc>vcfa ?isclass      \ voc-link voc flg --
                            if   voc>vcfa              \ voc-link voc-cfa --
                                 dup >body [ classes ] sfa [ forth ] @
                                 body>                 \ parent pfa > cfa
                                 currentclass =        \ if has currentclass as parent
                                 if   1 +to #children  \ update children count
                                      currentdepth 1+ -rot
                                      swap             \ and push child on stack
                                 else drop
                                 then
                            else drop
                            then @ dup 0=
                      until drop
                      \
                      #children 0<> while              \ no child: done for this class
                      #children 0 do recurse loop exit \ recurse on all children
                repeat ;

: AddClasses    ( -- ) \ Add classes in a top down style
                \ don't reset #Wrd, keep current value
                tHelpCls.tv fopen
                0<> if -1 abort" Couldn't open tHelpCls.tv" then
                0 ['] ClassRoot (AddClasses)
                tHelpCls.tv fClose drop ;
AddClasses

\ ShowList: tWrdList


\ ------------------------------------------------------------------------------
cr .( A bit of housekeeping for HelpWrd.hdb and create HelpWrd.hdx from tWrdList...)
\ ------------------------------------------------------------------------------


\ save HelpWrd.hdb
\ -----------------

\ write #Wrd and #WrdNonClass in record 0
HelpWord vinit
#Wrd @ HelpWord vaddr !                 \ #records           in record 0 at 0
#WrdNonClass @ HelpWord vaddr cell+ !   \ #non class records in record 0 at cell+
NoStack HelpWord vaddr HelpWord SizeOf 0 tHelpWrd.hdb WriteRec
                              [IF] -1 abort" Write error in HelpWrd.hdb" [THEN]

\ close and reopen HelpWrd.hdb before going further (save)
tHelpWrd.hdb fClose       drop
thelpWrd.hdb fopen        0<> [IF] -1 abort" Couldn't open HelpWrd.hdb"   [THEN]



cr .( Creating HelpWrd.hdx from tWrdList...)
\ ------------------------------------------

MaxWrdName @ 2 cells max MaxWrdName !  \ so that record 0 is at least 2 cells wide

:DataType WordsIndex=
                 dword= Wordn0rec  \ n0rec in HelpWrd.hdb for this word
                 dword= WordExtra  \ n0rec of method's parent (firstly in hdb, later in ndx)
   MaxWrdName @ String= WordName   \ word name
;DataType
Unallocated Array[ #Wrd @ ]Of WordsIndex= tHelpWrd[]
tHelpWrd[] valloc

: FillHelpWrd[] ( -- ) \ copy wrd list in array of record (uppercase file names)
                tHelpWrd[] vinit
                >FirstLink: tWrdList
                #links: tWrdList 0 do
                  Data@: tWrdList 0<>
                  if   getname: [ Data@: tWrdList ]
                       2dup upper                             \ uppercase for searches
                       i tHelpWrd[] WordName vaddr place
                       getrecord: [ Data@: tWrdList ]
                       i tHelpWrd[] Wordn0rec v!
                       getparent: [ Data@: tWrdList ]
                       i tHelpWrd[] WordExtra v!
                  then
                  >NextLink: tWrdList
                loop ;
FillHelpWrd[]


: ShowHelpWrd[] ( pfainstance -- )
                #Wrd @ 1+ 0 do
                  cr i . i tHelpWrd[] WordName v@ count type space
                         i tHelpWrd[] Wordn0rec v@ . space
                         i tHelpWrd[] WordExtra v@ .
                loop ;
\ ShowHelpWrd[]
cr .(    # words ) #Wrd @ .
cr .(    # words non class ) #WrdNonClass @ .
cr .(    Max name length ) MaxWrdName @ .



\ now we can dispose tWrdlist
\ ---------------------------
tWrdList disposelist



cr .( Sorting HelpWrd.hdx by ascending words...)
cr .( [there may exist multiple keys, eg methods, same words in different vocs, etc])
\ -----------------------------------------------------------------------------

: SortHelpWrd[] ( m n -- ) \ sort a partition of array of records
                0 tHelpWrd[] vaddr WordName tHelpWrd[]
                FSORT+                                        \ quicksort
                0 tHelpWrd[] vaddr tHelpWrd[] SizeOfElt erase \ erase record 0
                #Wrd @ 0 tHelpWrd[] vaddr !                   \ #records    in record 0 at 0
                MaxWrdName @ 0 tHelpWrd[] vaddr cell+ ! ;     \ name length in record 0 at cell+


\ Now we sort all words (class & non-class) in index. This must be done before the next step
1 #Wrd @ SortHelpWrd[]

\ ShowHelpWrd[]



cr .( Modifying the links from methods to their parent classes...  *** please wait ***)
\ -----------------------------------------------------------------------------------
\
\ For now the WordExtra field contains (only for methods) the n0 of the record in
\ HelpWrd.hdb of the method's parent. Here we replace this by the n0 of the record
\ in HelpWrd.hdx itself. This must be done AFTER index sorting, so that n0records
\ in index will remain unchanged from now on.

create MethBuf 200 allot
: SetMethParents ( -- )
                s" " methbuf place
                #Wrd @ 1+ 1 do
                  i tHelpWrd[] WordExtra v@                \ if a method
                  if   i tHelpWrd[] Wordname v@ count
                       methbuf count compare 0<>           \ if new method name
                       if   i tHelpWrd[] Wordname v@ count \ update current method name
                            methbuf place
                       then
                       i tHelpWrd[] WordExtra v@        \ for each occurence of this method
                       #Wrd @ 1+ 1 do                   \ search index for parent
                         i tHelpWrd[] Wordn0rec v@      \ ie: HelpWrd.hdb n0rec =? extra
                         over =
                         if   i                         \ i is the n0rec of parent in index
                              j tHelpWrd[] WordExtra v! \ to be set in method extra
                              leave
                         then
                       loop
                       drop
                  then
                loop ;
SetMethParents

\ ShowHelpWrd[]



cr .( Saving word index to disk...)
\ ---------------------------------

\ (but keep tHelpWrd[] in memory for now)

\ save stats in record 0 of tHelpWrd[]
0 tHelpWrd[] vInitElt
#Wrd @ 0 tHelpWrd[] vaddr !               \ #records      in record 0 at 0
MaxWrdName @ 0 tHelpWrd[] vaddr cell+ !   \ maxnamelength in record 0 at cell+

\ save index to file
DFILE tHelpWrd.hdx DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpWrd.hdx" 2 pick +place
count tHelpWrd.hdx FileName!

\ tHelpWrd.hdx .filename
tHelpWrd.hdx fforcecreate 0<> [IF] -1 abort" Couldn't create tHelpWrd.hdx" [THEN]
tHelpWrd.hdx fopen        0<> [IF] -1 abort" Couldn't open tHelpWrd.hdx"   [THEN]
NoStack 0 tHelpWrd[] vaddr tHelpWrd[] SizeOf
tHelpWrd.hdx WRITESEQ     0<> [IF] -1 abort" Write error in tHelpWrd.hdx"  [THEN]
tHelpWrd.hdx fClose       drop



\ ------------------------------------------------------------------------------
cr .(  )
cr .( Optionally: check for duplicated non-class words...)
\ ------------------------------------------------------------------------------

\ This is used to check duplicated non-classes words. Duplicated in different vocs
\ or sources may be legal. Problems come with ALIAS and SYNONYM

\ Note: this code must be run here (after sorting the index and before getting quick
\       info from sources). However, when run here, it gets the many duplicated that
\       exist in classes words. To avoid this, one can transiently comment out the word
\       AddClasses above ( and uncomment the word ListDuplicated below) and re-run
\       HelpBuildhdb.f

create prevwrd 100 allot
0 Value firstmatch?
: showword      ( n0recindex -- )
                cr dup .
                   dup tHelpWrd[] WordName vaddr count type space
                   dup tHelpWrd[] WordN0rec v@ .
                   dup tHelpWrd[] WordExtra v@ .
                HelpWord vaddr HelpWord SizeOf
                rot tHelpWrd[] WordN0rec v@
                tHelpWrd.hdb ReadRec
                if -1 abort" read in HelpWrd.hdb" then
                HelpWord WordSrc v@ tHelpSrc[] SrcName v@ count type space
                HelpWord WordLine v@ .
                HelpWord WordVoc v@ tHelpVoc[] VocName v@ count type space ;

: ListDuplicated ( -- )
                s" " prevwrd place
                true to firstmatch?
                #Wrd @ 1+ 1 ?do
                   i tHelpWrd[] WordName vaddr count
                   2dup prevwrd count compare 0=
                   if   firstmatch?
                        if   false to firstmatch?
                             i 1- showword
                        then
                        i showword
                   else true to firstmatch?
                        prevwrd place
                   then
                loop ;
\ ListDuplicated


\ ??? todo ? : here we could, after listing the duplicated words, "manually" suppress
\              them and replace them by the rights SYNONYM and ALIAS ones


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
cr .(  )
cr .( Adding source quick info from each source file...)
cr .(  )
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ For Each word, we get, from its source, the first line where it was defined plus
\ all the subsequent comments until we find a word different from comments or an
\ empty line. (??? until empty line not yet implemented)
\ This piece of text is saved in HelpWrd.txt and the offsets in this file for the
\ beginning and the ending of the text are saved in HelpWrd.hdb


cr .( Defining HelpWrd.txt : text file that will contain quick info for each word)
\ --------------------------------------------------------------------------------

DFILE tHelpWrd.txt DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place         \ set file name
s" Help\hdb\HelpWrd.txt" 2 pick +place
count tHelpWrd.txt FileName!

tHelpWrd.txt fforcecreate 0<> [IF] -1 abort" Couldn't create tHelpWrd.txt" [THEN]
tHelpWrd.txt fopen        0<> [IF] -1 abort" Couldn't open tHelpWrd.txt"   [THEN]


\ Tools to get quick info from source with parser
\ -----------------------------------------------

0 value \addr
0 value \cnt

: Clean\        ( addr cnt -- addr' cnt' ) \ clean dexh escape sequences
                2dup to \cnt to \addr
                begin [CHAR] \ scan ?dup
                      while
                      over 1+ c@
                      CASE
                        [CHAR] \ OF 1 ENDOF
                        [CHAR] n OF 2 ENDOF
                        [CHAR] r OF 2 ENDOF
                        [CHAR] i OF 2 ENDOF
                        [CHAR] b OF 2 ENDOF
                        [CHAR] t OF 2 ENDOF
                        [CHAR] ^ OF 2 ENDOF
                        [CHAR] _ OF 2 ENDOF
                        [CHAR] d OF 2 ENDOF
                        0 swap
                      ENDCASE
                      ?dup
                      if   1 =
                           if   -1 +to \cnt
                                2dup >r dup 1+ swap r> 1- cmove
                                swap 1+ swap 2 -
                           else -2 +to \cnt
                                2dup >r dup 2 + swap r> 2 - cmove
                                2 -
                           then
                      else drop 0    \ will stop at next scan
                      then
                repeat
                drop \addr \cnt ;

: CleanDexh     ( addr cnt -- addr' cnt' ) \ clean dexh info from comment
                over c@ [CHAR] * =
                if   over 1+ c@
                     CASE
                       [CHAR] * OF 0 ENDOF
                       [CHAR] ! OF 0 ENDOF
                       [CHAR] > OF 0 ENDOF
                       [CHAR] T OF 0 ENDOF
                       [CHAR] S OF 0 ENDOF
                       [CHAR] N OF 0 ENDOF
                       [CHAR] A OF 0 ENDOF
                       [CHAR] Q OF 0 ENDOF
                       [CHAR] P OF 0 ENDOF
                       [CHAR] E OF 0 ENDOF
                       [CHAR] B OF 0 ENDOF
                       [CHAR] G OF 0 ENDOF
                       [CHAR] W OF 0 ENDOF
                       [CHAR] + OF 0 ENDOF
                       [CHAR] - OF 0 ENDOF
                       [CHAR] L OF 0 ENDOF
                       [CHAR] | OF 0 ENDOF
                       [CHAR] Z OF 0 ENDOF
                       [CHAR] D OF 0 ENDOF
                       -1 swap
                     ENDCASE
                else -1
                then
                if exit then                     \ no dexh info
                swap 3 + swap 3 -                \ delete dexh header
                0 max                            \ in case of empty dexh line : \ **
                Clean\ ;                         \ delete dexh escape sequences

create prev1 250 allot
create prev2 250 allot
create prev3 250 allot
create worddef 250 allot

: StepWord      ( addr count -- flag ) \ Search next word given by addr cnt.
                \ flag = 0 means EndOfParse has been reached
                \ get word definer and word
\ ??? This word could be moved to FileParser.f
                s" " prev1 place
                s" " prev2 place
                s" " prev3 place
                2dup upper -trailing BL skip
                begin  GetWord
                       nip 0= if 2drop 0 exit then    \ end of parse ==> failed
                       prev2 count prev3 place
                       prev1 count prev2 place
                       wordupper count prev1 place
                       2dup wordupper count
                       compare 0=                     \ use uppercased version
                       if
                            prev2 count               \ same ==> found
                            s" SYNONYM" compare 0=
                            if   prev2 count worddef place
                                 s"  " worddef +place
                                 prev1 count worddef +place
                                 s"  " worddef +place
                                 GetWord worddef +place
                                 s"  " worddef +place
                            else prev2 count worddef place
                                 s"  " worddef +place
                                 prev1 count worddef +place
                                 s"  " worddef +place
                            then
                            2drop
                            -1 exit
                       then
                again ;

Create InfoBuffer 8200 allot
0 value InfoCount

: Info+Place    ( addr cnt -- )
                InfoBuffer InfoCount + swap
                dup +to InfoCount
                cmove ;

0 value PrevPosition

: writeInfo     ( -- ) \ write from Info InfoBuffer
                InfoBuffer InfoCount tHelpWrd.txt Filchan @
                write-line
                abort" Write error in HelpWrd.txt"
                InfoCount 2 + +to PrevPosition
                0 to InfoCount ;

Create WordParsed 250 allot
0 Value WordParsedLine
: GetWordComments ( addr cnt -- ) \ suppose parsing set to line# of correct source file
                2dup WordParsed place
                #Parseline to WordParsedLine
                0 to InfoCount
                StepWord 0=
                if   cr ." At line: " WordParsedLine .  ." Word " WordParsed count type ."  not found"
                     -1 abort" check word and line number"
                then
                worddef count Info+Place
                begin GetWord ?dup
                      while
                      2dup s" \" compare 0=
                      if   GetStringEol CleanDexh
                           s" \ " Info+Place Info+Place
                           writeinfo
                      else 2dup s" (" compare 0=
                           if   s" )" GetString CleanDexh
                                s" ( " Info+Place Info+Place s" ) " Info+Place
                                writeinfo
                           else 2dup s" {" compare 0=
                                if   s" }" GetString CleanDexh
                                s" { " Info+Place Info+Place s" } " Info+Place
                                writeinfo
                                else 2drop InfoCount if writeinfo then exit
                      then then then
                      2drop
                repeat drop
                InfoCount if writeinfo then ;


cr .( Actually getting quick info for each source file one after another)
\ -----------------------------------------------------------------------

DFILE tQuick DummyFilename
0 value currSrcIndex
create quickbuf 250 allot

: AddQuickInfo  ( -- )
                0 to PrevPosition                        \ current position in HelpWrd.txt
                #Src @ 1+ 1 do                           \ for all source files
                &forthdir count quickbuf place
                i tHelpSrc[] SrcName v@ count 2dup quickbuf +place
                srcindex to CurrSrcIndex
                quickbuf count tQuick FileName!
                tQuick fopen                             \ open source file
                if -1 abort" Couldn't open source" then
                tQuick FilChan @ ParseInit               \ set source as parsed file
                false to SkipComment?
\ ???           true to EndOnEmptyLine?                  \ stop parsing if empty line
cr ."    Parsing : " tquick .filename  space currsrcindex .
                #Wrd @ 1+ 1 ?do                          \ loop on whole index
                    HelpWord vaddr HelpWord SizeOf       \ get HelpWrd.hdb record
                    i tHelpWrd[] WordN0rec v@
                    tHelpWrd.hdb ReadRec
                    if -1 abort" Read error in HelpWrd.hdb" then
                    HelpWord WordSrc v@ currSrcIndex =   \ if word comes from this source
                    if   PrevPosition                    \ this is the start of quick info
                         HelpWord WordFrom v!
                         HelpWord WordLine v@            \ get the line number
                         ParseFrom                       \ parse from line#
                         i tHelpWrd[] WordName vaddr count
                         2dup 4 min s" 0X00"    compare 0= >r
                         2dup 7 min s" :OBJECT" compare 0= r> or
                         if   2drop                      \ [UNKNOWN] and :OBJECT
                         else GetWordComments            \ get quick info from source
                         then
                         PrevPosition                    \ this is the end of quick info
                         HelpWord WordTo v!
                         HelpWord vaddr HelpWord SizeOf  \ save positions in HelpWrd.hdb
                         i tHelpWrd[] WordN0rec v@
                         tHelpWrd.hdb WriteRec
                         if -1 abort" Write error in HelpWrd.hdb" then
                    then
                  loop
                  tQuick fClose drop
                loop ;
AddQuickInfo

tHelpWrd.txt fclose drop


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
cr .(  )
cr .( Optionally create the base file for functionality tagging : Functionality .txt)
cr .(  )
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ For each word that is not in a hidden vocabulary nor in a class vocabulary, we
\ create a line entry with its name followed by "???". This will be the default
\ functionality for this word (that is "unknown"...) and will be manually
\ overwriten later...
\ (It would be a much better idea to have the word's functionality defined in its
\ own comments because we can't handle here words with same names in differents vocs)
\ Note: words will be in alphabetical order
((
DFILE tFunct.txt DummyFilename                  \ file on disk

NoStack New$ &ForthDir count 2 pick place       \ set file name
s" Help\hdb\Funct.txt" 2 pick +place
count tFunct.txt FileName!

Create FunctBuff 200 allot
Variable #Funct


\ Check in HelpScope.f the hidden vocabularies and files that you will retrieve
\ from the following search.
: PreBuildFct   ( -- )
                tFunct.txt fforcecreate
                abort" Couldn't create tFunct.txt"
                tFunct.txt fopen
                abort" Couldn't open tFunct.txt"
                0 #Funct !
                #Wrd @ 0 ?do
                  HelpWord vaddr HelpWord SizeOf
                  i tHelpWrd[] Wordn0rec v@ tHelpWrd.hdb ReadRec
                  if -1 abort" read in HelpWrd.hdb" then
                  HelpWord WordCls? v@ 0=                      \ don't take class words
                  if   HelpWord WordVoc v@                     \ don't take hiddens
                       tHelpVoc[] VocName v@ count
                       2dup s" APP\HIDDEN"     compare 0<> >r
                       2dup s" SYS\ASM-HIDDEN" compare 0<> r> and >r
                       2dup s" SYS\HIDDEN"     compare 0<> r> and >r
                       2drop
                       HelpWord WordSrc v@                     \ don't take some source files
                       tHelpSrc[] SrcName v@ count
                       2dup s" SRC\486ASM.F"     compare 0<> r> and >r
                       2dup s" SRC\ASMMAC.F"     compare 0<> r> and >r
                       2dup s" SRC\ASMWIN32.F"   compare 0<> r> and >r
                       2dup s" SRC\DIS486.F"     compare 0<> r> and >r
                       2dup s" SRC\FLOAT.F"      compare 0<> r> and >r
                       2dup s" SRC\IMAGEMAN.F"   compare 0<> r> and >r
                       2dup s" SRC\WINLIB.F"     compare 0<> r> and >r
                       2drop
                       r>
                       if   i tHelpWrd[] Wordname v@ count
                            FunctBuff place
                            s"  ???" FunctBuff +place
                            FunctBuff count
                            tFunct.txt FilChan @ write-Line
                            abort" write error in Funct.txt"
                            1 #Funct +!
                       then
                  then
                loop
cr ." # words candidates for functionality " #Funct @ .
                tFunct.txt fclose drop ;

PreBuildFct
))


\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
cr .(  )
cr .( Building the words-treeview-structure HelpWrd.tv from HelpWrd.hdb and its index)
cr .(  )
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------
\ ------------------------------------------------------------------------------

\ HelpWrd.hdb and HelpWrd.hdx are now finished.
\ We also have a little part of the tv-structure-text-file (for top down classes)
\ Now, we have to create the whole tv-structure-text-file

\ The TV data is the record number of the word information in HelpWrd.hdb.

\  Words treeview names (there are many many words, so we have to limit TV views)
\  ---------------------
\  + Words
\    + Non-class alphabetical   \ useless (too many words) use search editbox instead
\    + By functionality         \ not yet done - not sure it will work because of <> vocs
\    + ClassRoot
\    + Methods
\    + Classes                  \ old ClassBrowser style - needed ?
\    + By source file
\    + Ans standard
\    + Immediate
\    + Deprecated
\    + Vocs                     \ only vocs, no contents
\



\ create tv-structure-text-file
\ -----------------------------

DFILE tHelpWrd.tv DummyFilename                  \ txt file on disk
\ reuse transient tHelpCls
NoStack New$ &ForthDir count 2 pick place        \ set file name
s" Help\hdb\HelpWrd.tv" 2 pick +place
count tHelpWrd.tv FileName!

tHelpWrd.tv fforcecreate 0<> [IF] -1 abort" Couldn't create tHelpWrd.tv" [THEN]

0 value Extra
\ create WrdLineBuffer 200 allot
: AddLine       ( n0rec addr count depth -- )
                s>d (d.)             ClsLineBuffer place
                s"  tvn| "           ClsLineBuffer +place
                                     ClsLineBuffer +place
((
\ While debugging: append n0rec &
\ parent n0rec to name so that they
\ can be seen in the treeview with
\ the utility HelpTestTV.f
s" __"       ClsLineBuffer +place
dup s>d (d.) ClsLineBuffer +place
s" __"       ClsLineBuffer +place
Extra s>d (d.) ClsLineBuffer +place
))
                s" | tvd| "          ClsLineBuffer +place
                s>d (d.)             ClsLineBuffer +place
                s" |"                ClsLineBuffer +place
                ClsLineBuffer count tHelpWrd.tv WriteLN
                if -1 abort" write error in tHelpWrd.tv" then ;


\ evaluate (read) text-treeview-structure-file lines
\ ------------------------------------------------------------------------------

\ this is an old version of TV parsing, before I wrote FileParser.f . It doesn't accept
\ TABs but this is not a problem as the only file it reads was automatically generated
\ I keep this version here as doc. HelpMain will use FileParser.f

: -Heading      ( addr count -- addr' count' ) \ remove heading blanks if any
                over 1+ 0 begin over c@ BL = while 1 1 d+ repeat nip
                ?dup if 1+ /string then ;
                \ : -heading ( addr count -- addr' count' ) bl skip ;

create tvnbuff 200 allot
: tvn|          ( -- addr count )
                state @ if -1 abort" Interpretation only" then
                s" " tvnbuff place
                begin [char] | parse                \ we have at least one |
                      tvnbuff +place
                      \ after parse, >IN is one char after "|"
                      \ if a word contains an embedded "|", this one cannot be followed
                      \ by a blank, so we repeat if next char is not blank (and is
                      \ not end of source, which is 0)
\ ??? we should scan for tabs and replace them with blanks before tvn| is run
                      source nip >in @ - 0>
                      source drop >in @ + c@ BL <> and
                      while
                      s" |" tvnbuff +place
                repeat
                tvnbuff count
                -heading -trailing ;

create tvdbuff 200 allot
: tvd|          ( -- addr count ) \ same as tvn| but needs a different buffer
                state @ if -1 abort" Interpretation only" then
                s" " tvdbuff place
                begin [char] | parse
                      tvdbuff +place
                      source nip >in @ - 0>
                      source drop >in @ + c@ BL <> and
                      while
                      s" |" tvdbuff +place
                repeat
                tvdbuff count
                -heading -trailing ;

create tvevbuf 200 allot

: htmlTVeval    ( addr cnt -- zname addr2 cnt2 tvdepth  0 ) \ tvname tvlink tvdepth
                ( addr cnt --                          -1 ) \ empty or comment line
                depth 2 - >r evaluate depth r> - 0=
                if   -1
                else 2swap tvevbuf place tvevbuf +null tvevbuf 1+ -rot
                     3 roll 0
                then ;

: wordTVeval    ( addr cnt -- zname n0record tvdepth  0 ) \ tvname n0rec tvdepth
                ( addr cnt --                        -1 ) \ empty or comment line
                depth 2 - >r evaluate depth r> - 0=
                if   -1
                else evaluate >r
                     tvevbuf place tvevbuf +null tvevbuf 1+
                     r> rot 0
                then ;

create TVLineBuffer 200 allot

: GetLine       ( -- zname n0record tvdepth -1 | 0 )
                begin TVLineBuffer 188 tHelpCls.tv ReadLn
                      if 2drop -1 abort" Read error in tHelpCls.tv" then  \ error
                      0= if drop 0 exit then                           \ eof
                      TVLineBuffer swap wordTVeval
                      while                             \ empty or comment line
                repeat
                -1 ;


\ fill tv-structure-text-file
\ -----------------------------

(( Old stuff : non class words alphabetically :

: sqrt          ( n  -- nsqrt ) \ brute force square root
                dup 0= if exit then
                1
                begin 2dup dup * >
                while 1+
                repeat nip ;
create slice$ 50 allot
variable slice#
variable slice
: AddTVAlpha    ( -- ) \ we insert non-class words by alphabetical slices
                \ ! " # ' ( ) * + , - . / 0...9 : ; < = > ? @ A...Z [ \ ] ^ _ ` a...z ~
                #WrdNonClass @ dup 300 >
                if sqrt then 1+ slice# !                    \ avoid 0divide with 1+
                -1 slice !
                #Wrd @ 1+ 1 ?do                             \ for each word
                  HelpWord vaddr HelpWord SizeOf
                  i tHelpWrd[] Wordn0rec v@ tHelpWrd.hdb ReadRec
                  if -1 abort" read in HelpWrd.hdb" then
                  HelpWord WordCls? v@ 0=                   \ handle only non-class words
                  if   i slice# @ / slice @ >
                       if   1 slice +!                      \ at each new alpha slice
                            i tHelpWrd[] Wordname v@        \ create a header
                            0 swap count 5 min 2 AddLine
                       then
                       i tHelpWrd[] Wordn0rec v@            \ add non-class word
                       i tHelpWrd[] Wordname v@ count
                       3 AddLine
                  then
                loop ;
))
: AddTVFunct    ( -- ) \ ??? to be done ??? probably the most interesting classification
                       \ but pbs with same name in 2 vocs
                ;

: AddTVAns      ( -- )
                #Wrd @ 1+ 1 ?do
                  HelpWord vaddr HelpWord SizeOf
                  i tHelpWrd[] Wordn0rec v@ tHelpWrd.hdb ReadRec
                  if -1 abort" read in HelpWrd.hdb" then
                  HelpWord WordAns v@ 0<>
                  if   i tHelpWrd[] Wordn0rec v@
                       i tHelpWrd[] Wordname v@ count
                       2 AddLine
                  then
                loop ;

: AddTVImm      ( -- )
                #Wrd @ 1+ 1 ?do
                  HelpWord vaddr HelpWord SizeOf
                  i tHelpWrd[] Wordn0rec v@ tHelpWrd.hdb ReadRec
                  if -1 abort" read in HelpWrd.hdb" then
                  HelpWord WordImm? v@
                  if   i tHelpWrd[] Wordn0rec v@
                       i tHelpWrd[] Wordname v@ count
                       2 AddLine
                  then
                loop ;

: AddTVDep      ( -- )
                #Wrd @ 1+ 1 ?do
                  HelpWord vaddr HelpWord SizeOf
                  i tHelpWrd[] Wordn0rec v@ tHelpWrd.hdb ReadRec
                  if -1 abort" read in HelpWrd.hdb" then
                  HelpWord WordDepr? v@
                  if   i tHelpWrd[] Wordn0rec v@
                       i tHelpWrd[] Wordname v@ count
                       2 AddLine
                  then
                loop ;


: skip4         ( addr cnt -- addr' cnt' )
                4 - swap 4 + swap ;
: AddTVVocs     ( -- )
                0 s" Application space" 2 AddLine
                #Voc @ 1+ 0 ?do
                    i tHelpVoc[] VocName v@ count
                    drop 4 s" APP\" compare 0=
                    if 0 i tHelpVoc[] VocName v@ count skip4 3 Addline then
                loop
                0 s" System space" 2 AddLine
                #Voc @ 1+ 0 ?do
                    i tHelpVoc[] VocName v@ count
                    drop 4 s" SYS\" compare 0=
                    if 0 i tHelpVoc[] VocName v@ count skip4 3 Addline then
                loop ;


: right$        ( addr cnt char -- addr' cnt' )
                \ Example: s" c:\dir\file.ext" ascii \ right$ gives "file.ext"
                \ Example: s" aaaa.ext" ascii \ right$ gives "aaaa.ext"
                >r swap over + over r> -scan ?dup
                if   rot swap - 1- swap 1+ swap
                else swap
                then ;

DFILE tTVSrc DummyFilename
0 value currSrcNdx
create cursrcbuf 250 allot
: AddTVSrc      ( -- )
               #Src @ 1+ 1 ?do                              \ for all source files
                  &forthdir count cursrcbuf place
                  i tHelpSrc[] SrcName v@ count 2dup cursrcbuf +place
                  srcindex to currSrcNdx
                  cursrcbuf count tTVSrc FileName!
                  tTVSrc fopen                               \ open source file
                  if -1 abort" Couldn't open source" then
                  0 i tHelpSrc[] SrcName v@ count            \ add file tv entry
                  [char] \ right$                            \ keep filename only (no path)
                  -2 AddLine                                 \ sort them
                  #Wrd @ 1+ 1 ?do                            \ scan index
                    HelpWord vaddr HelpWord SizeOf
                    i tHelpWrd[] Wordn0rec v@
                    tHelpWrd.hdb ReadRec
                    if -1 abort" Read error in HelpWrd.hdb" then
                    HelpWord WordSrc v@ currSrcNdx =         \ if word comes from this source
                    if   i tHelpWrd[] Wordn0rec v@
                         i tHelpWrd[] WordName v@ count
                         3 AddLine                           \ add word tv entry
                    then
                  loop
                  tTVSrc fClose drop
                loop ;


: AddTVClass    ( -- )
                \ Note: we increase depth saved in transient so that this
                \       sub-tree fits its position in Words treeview
                tHelpCls.tv fopen
                abort" Couldn't open tHelpCls.tv"
                begin GetLine                \ -- zname n0record tvdepth -1 | 0
                      while
                      rot 1- count rot       \ -- n0rec addr count depth
                      dup 0< if negate 1+ negate else 1+ then
                      AddLine
                repeat
                tHelpCls.tv fClose drop ;


create MethBuff 200 allot
: AddTVMethods  ( -- )
                s" " methbuff place
                #Wrd @ 1+ 1 ?do
                  i tHelpWrd[] WordExtra v@                \ if a method
                  i tHelpWrd[] Wordname v@ count
                  + 1- c@ [CHAR] : =        and
                  if   i tHelpWrd[] Wordname v@ count
                       methbuff count compare 0<>          \ if new method name
                       if   i tHelpWrd[] Wordname v@ count \ update current method name
                            methbuff place
                            0
                            methbuff count               \ create entry for this method
\ i tHelpWrd[] WordExtra v@ to Extra
                            2 AddLine
\ 0 to extra
                       then
                       i tHelpWrd[] Wordn0rec v@      \ for each occurence of this method
                       i tHelpWrd[] WordExtra v@      \ create an entry for its parent
                       tHelpWrd[] Wordname v@ count   \ but pointing to the mehod info
\ i tHelpWrd[] WordExtra v@ tHelpWrd[] WordExtra v@ to Extra
                       -3 AddLine                     \ want parents sorted
\ 0 to extra
                  then
                loop ;


: AddTV         ( -- )
                tHelpWrd.tv fopen
                0<> if -1 abort" Couldn't open tHelpWrd.tv" then
                \
                0 s" Words" 0 AddLine
         \ cr ."    Non-class alphabetical TV part..."
              \ 0 s" Non-class alphabetical" 1 AddLine
              \ AddTVAlpha
         \ cr ."    By functionality TV part..."
              \ 0 s" By Functionality" 1 AddLine
              \ AddTVFunct
           cr ."    ClassRoot TV part..."
                AddTVClass
           cr ."    Methods TV part..."
                0 s" METHODS" 1 AddLine
                AddTVMethods
           cr ."    By source TV part... *** please wait ***"
                0 s" By source" 1 AddLine
                AddTVSrc
           cr ."    Ans Standard TV part..."
                0 s" Ans standard" 1 AddLine
                AddTVAns
           cr ."    Immediate TV part..."
                0 s" Immediate" 1 AddLine
                AddTVImm
           cr ."    Deprecated TV part..."
                0 s" Deprecated" 1 AddLine
                AddTVDep
           cr ."    Vocabularies TV part..."
                0 s" Vocabularies" 1 AddLine       \ only vocs, no words
                AddTVVocs
                \
                tHelpWrd.tv fClose drop ;
AddTV



\ ------------------------------------------------------------------------------
\ Free everything we no longer need
\ ------------------------------------------------------------------------------

tHelpSrc[] vfree
tHelpVoc[] vfree
tHelpAns[] vfree
tHelpFct[] vfree

tHelpWrd[] vfree
tHelpWrd.hdb fClose drop

tHelpCls.tv FilName count delete-file drop   \ delete transient Help\hdb\HelpCls.tv

cr .(  )
cr .(           **********************************************)
cr .(           *  Words Help Database successfully created  *)
cr .(           **********************************************)
cr
.elapsed
1 pause-seconds
\s


